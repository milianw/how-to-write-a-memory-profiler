// SPDX-License-Identifier: LGPL-2.1-or-later

#include <alloc_preload_intercepts.h>

#include <recursionguard.h>
#include <trace.h>

namespace track {
void init()
{
    hooks::init_allocs();
    // cleanup environment to prevent tracing of child apps
    unsetenv("LD_PRELOAD");
}

void malloc(void *ptr, size_t size)
{
    if (RecursionGuard::isActive)
        return;
    RecursionGuard guard;

    fprintf(stderr, "malloc(%zu) = %p\n", size, ptr);
    Trace::dump(stderr);
}

void free(void *ptr)
{
    if (RecursionGuard::isActive)
        return;
    RecursionGuard guard;

    fprintf(stderr, "free(%p)\n", ptr);
    Trace::dump(stderr);
}
}
