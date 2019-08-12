// SPDX-License-Identifier: LGPL-2.1-or-later

#pragma once

#include "track.h"
#include "hooks.h"

#if defined(_ISOC11_SOURCE)
#define HAVE_ALIGNED_ALLOC 1
#else
#define HAVE_ALIGNED_ALLOC 0
#endif

namespace hooks {
DECLARE_HOOK(malloc);
DECLARE_HOOK(free);
DECLARE_HOOK(calloc);
DECLARE_HOOK(realloc);
DECLARE_HOOK(posix_memalign);
DECLARE_HOOK(valloc);
#if HAVE_ALIGNED_ALLOC
DECLARE_HOOK(aligned_alloc);
#endif

// Trivial memory pool implementation, to be used by dummy_calloc
struct DummyPool
{
    static const constexpr size_t MAX_SIZE = 1024;
    char buf[MAX_SIZE] = {0};
    size_t offset = 0;

    bool isDummyAllocation(void* ptr) noexcept
    {
        return ptr >= buf && ptr < buf + MAX_SIZE;
    }

    void* alloc(size_t num, size_t size) noexcept
    {
        size_t oldOffset = offset;
        offset += num * size;
        if (offset >= MAX_SIZE) {
            fprintf(stderr,
                    "failed to initialize, dummy calloc buf size exhausted: "
                    "%zu requested, %zu available\n",
                    offset, MAX_SIZE);
            abort();
        }
        return buf + oldOffset;
    }

    static DummyPool& instance() noexcept
    {
        static DummyPool pool;
        return pool;
    }

    static void* calloc(size_t num, size_t size) noexcept
    {
        return instance().alloc(num, size);
    }
};

void init_allocs()
{
    calloc.original = &DummyPool::calloc;
    calloc.init();
    malloc.init();
    free.init();
    realloc.init();
    posix_memalign.init();
    valloc.init();
#if HAVE_ALIGNED_ALLOC
    aligned_alloc.init();
#endif
}
}

namespace intercept {
void* malloc(size_t size) noexcept
{
    if (!hooks::malloc)
        track::init();

    void* ptr = hooks::malloc(size);
    track::malloc(ptr, size);
    return ptr;
}

void free(void* ptr) noexcept
{
    if (!hooks::free)
        track::init();

    // don't try to free dummy allocations, that would lead to crashes
    if (hooks::DummyPool::instance().isDummyAllocation(ptr))
        return;

    // call handler before handing over the real free implementation
    // to ensure the ptr is not reused in-between and thus the output
    // stays consistent
    track::free(ptr);

    hooks::free(ptr);
}

void* realloc(void* ptr, size_t size) noexcept
{
    if (!hooks::realloc)
        track::init();

    void* ret = hooks::realloc(ptr, size);

    if (ret) {
        track::free(ptr);
        track::malloc(ret, size);
    }

    return ret;
}

void* calloc(size_t num, size_t size) noexcept
{
    if (!hooks::calloc)
        track::init();

    void* ret = hooks::calloc(num, size);

    if (ret)
        track::malloc(ret, num * size);

    return ret;
}

int posix_memalign(void** memptr, size_t alignment, size_t size) noexcept
{
    if (!hooks::posix_memalign)
        track::init();

    int ret = hooks::posix_memalign(memptr, alignment, size);

    if (!ret)
        track::malloc(*memptr, size);

    return ret;
}

#if HAVE_ALIGNED_ALLOC
void* aligned_alloc(size_t alignment, size_t size) noexcept
{
    if (!hooks::aligned_alloc)
        track::init();

    void* ret = hooks::aligned_alloc(alignment, size);

    if (ret)
        track::malloc(ret, size);

    return ret;
}
#endif

void* valloc(size_t size) noexcept
{
    if (!hooks::valloc)
        track::init();

    void* ret = hooks::valloc(size);

    if (ret)
        track::malloc(ret, size);

    return ret;
}
}
