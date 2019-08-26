// SPDX-License-Identifier: LGPL-2.1-or-later

#include <cstdlib>
#include <cstdio>

#include <alloc_preload_intercepts.h>
#include <module_preload_intercepts.h>
#include <recursionguard.h>
#include <trace.h>
#include <mappings.h>
#include <tracetree.h>

#include <mutex>

namespace {
class TraceInterner
{
public:
    ~TraceInterner()
    {
        // don't handle deallocations while we are shutting down
        RecursionGuard::isActive = true;
    }
    auto intern(const Trace &trace)
    {
        std::lock_guard<std::mutex> lock(mutex);
        return tree.index(trace, [](uintptr_t ip, uint32_t index){
            fprintf(stderr, "\tip: %zx | %u\n", ip, index);
            return true;
        });
    };
private:
    std::mutex mutex;
    TraceTree tree;
};

auto intern(const Trace &trace)
{
    static TraceInterner interner;
    return interner.intern(trace);
}

inline auto traceIndex()
{
    mappings::update(stderr);

    Trace trace;
    uint32_t index = 0;
    if (trace.fill(2))
        index = intern(trace);
    return index;
}
}

namespace track {
void init()
{
    RecursionGuard guard;

    hooks::init_allocs();
    hooks::init_modules();
    // cleanup environment to prevent tracing of child apps
    unsetenv("LD_PRELOAD");

    mappings::write_exe(stderr);
}

void malloc(void *ptr, size_t size)
{
    if (RecursionGuard::isActive)
        return;
    RecursionGuard guard;

    fprintf(stderr, "malloc(%zu) = %p | %u\n", size, ptr, traceIndex());
}

void free(void *ptr)
{
    if (RecursionGuard::isActive)
        return;
    RecursionGuard guard;

    mappings::update(stderr);

    fprintf(stderr, "free(%p) | %u\n", ptr, traceIndex());
}

void invalidate_module_cache()
{
    mappings::dirty() = true;
}
}
