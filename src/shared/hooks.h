// SPDX-License-Identifier: LGPL-2.1-or-later

#pragma once

#include <cstdio>
#include <cstdlib>

#include <dlfcn.h> // dlsym

namespace hooks {
template <typename Signature, typename Base>
struct hook
{
    using signature_t = Signature;
    signature_t original = nullptr;

    void init() noexcept
    {
        auto ret = dlsym(RTLD_NEXT, Base::identifier);
        if (!ret) {
            fprintf(stderr, "Could not find original function %s\n", Base::identifier);
            abort();
        }
        original = reinterpret_cast<signature_t>(ret);
    }

    template <typename... Args>
    auto operator()(Args... args) const noexcept -> decltype(original(args...))
    {
        return original(args...);
    }

    explicit operator bool() const noexcept
    {
        return original;
    }
};
}

#define DECLARE_HOOK(name)                                                                                             \
    /* silence warning: ignoring attributes on template argument ‘...’ [-Wignored-attributes] */                       \
    _Pragma("GCC diagnostic ignored \"-Wignored-attributes\"")                                                         \
    struct name##_t : public hooks::hook<decltype(&::name), name##_t>                                                  \
    {                                                                                                                  \
        static constexpr const char* identifier = #name;                                                               \
    } name
