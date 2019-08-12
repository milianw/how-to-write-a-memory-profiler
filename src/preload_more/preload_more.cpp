// SPDX-License-Identifier: LGPL-2.1-or-later

#include <cstdlib>
#include <cstdio>

#include "alloc_preload_intercepts.h"

namespace track {
void init()
{
    hooks::init_allocs();
    // cleanup environment to prevent tracing of child apps
    unsetenv("LD_PRELOAD");
}

void malloc(void *ptr, size_t size)
{
    fprintf(stderr, "malloc(%zu) = %p\n", size, ptr);
}

void free(void *ptr)
{
    fprintf(stderr, "free(%p)\n", ptr);
}
}
