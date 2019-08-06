// SPDX-License-Identifier: LGPL-2.1-or-later

#include <cstdlib>
#include <cstdio>

#include <dlfcn.h> // dlsym

extern "C"
{
void* malloc(size_t size) noexcept
{
    static auto original_malloc = reinterpret_cast<decltype(&::malloc)>(dlsym(RTLD_NEXT, "malloc"));

    auto *ret = original_malloc(size);
    fprintf(stderr, "malloc intercepted: %zu -> %p\n", size, ret);
    return ret;
}
}
