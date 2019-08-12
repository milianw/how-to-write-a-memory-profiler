// SPDX-License-Identifier: LGPL-2.1-or-later

#pragma once

#include "track.h"
#include "hooks.h"

namespace hooks {
DECLARE_HOOK(dlopen);
DECLARE_HOOK(dlclose);

void init_modules()
{
    hooks::dlopen.init();
    hooks::dlclose.init();
}
}

namespace intercept {
void* dlopen(const char* filename, int flag) noexcept
{
    if (!hooks::dlopen)
        track::init();

    void* ret = hooks::dlopen(filename, flag);

    if (ret)
        track::invalidate_module_cache();

    return ret;
}

int dlclose(void* handle) noexcept
{
    if (!hooks::dlclose)
        track::init();

    int ret = hooks::dlclose(handle);

    if (!ret)
        track::invalidate_module_cache();

    return ret;
}
}
