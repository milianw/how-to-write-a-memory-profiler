// SPDX-License-Identifier: LGPL-2.1-or-later

#include <cstdlib>
#include <cstdio>

#include <alloc_preload_intercepts.h>
#include <module_preload_intercepts.h>
#include <recursionguard.h>
#include <trace.h>
#include <mappings.h>


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

    mappings::update(stderr);

    fprintf(stderr, "malloc(%zu) = %p\n", size, ptr);
    Trace::dump(stderr);
}

void free(void *ptr)
{
    if (RecursionGuard::isActive)
        return;
    RecursionGuard guard;

    mappings::update(stderr);

    fprintf(stderr, "free(%p)\n", ptr);
    Trace::dump(stderr);
}

void invalidate_module_cache()
{
    mappings::dirty() = true;
}
}
