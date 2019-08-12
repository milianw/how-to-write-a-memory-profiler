// SPDX-License-Identifier: LGPL-2.1-or-later

#include "alloc_hooks.h"

extern "C" {
void* malloc(size_t size) noexcept
{
    return intercept::malloc(size);
}

void free(void* ptr) noexcept
{
    return intercept::free(ptr);
}

void* realloc(void* ptr, size_t size) noexcept
{
    return intercept::realloc(ptr, size);
}

void* calloc(size_t num, size_t size) noexcept
{
    return intercept::calloc(num, size);
}

int posix_memalign(void** memptr, size_t alignment, size_t size) noexcept
{
    return intercept::posix_memalign(memptr, alignment, size);
}

#if HAVE_ALIGNED_ALLOC
void* aligned_alloc(size_t alignment, size_t size) noexcept
{
    return intercept::aligned_alloc(alignment, size);
}
#endif

void* valloc(size_t size) noexcept
{
    return intercept::valloc(size);
}
}

