// SPDX-License-Identifier: LGPL-2.1-or-later

#include "module_hooks.h"

extern "C" {
void* dlopen(const char* filename, int flag) noexcept
{
    return intercept::dlopen(filename, flag);
}

int dlclose(void* handle) noexcept
{
    return intercept::dlclose(handle);
}
}

