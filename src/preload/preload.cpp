// SPDX-License-Identifier: LGPL-2.1-or-later

#include <cstdlib> // malloc
#include <cstdio>  // fprintf
#include <cassert> // assert
//--> slide
#include <dlfcn.h> // dlsym

extern "C"
{
void* malloc(size_t size)
{
    static void* original_malloc = dlsym(RTLD_NEXT, "malloc");
    assert(original_malloc);
    auto *original_malloc_fn = reinterpret_cast<decltype(&::malloc)>(original_malloc);

    void *ret = original_malloc_fn(size);
    fprintf(stderr, "malloc intercepted: %zu -> %p\n", size, ret);
    return ret;
}
}
//<-- slide
