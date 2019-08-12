// SPDX-License-Identifier: LGPL-2.1-or-later

#pragma once

#include <cstdio>

#include <atomic>
#include <mutex>
#include <filesystem>

#include <link.h> // dl_iterate_phdr

struct mappings
{
    static void update(FILE *out)
    {
        if (!dirty())
            return;
        static std::mutex mutex;
        std::lock_guard<std::mutex> lock(mutex);
        if (!dirty())
            return;

        fprintf(out, "begin modules\n");
        dl_iterate_phdr([](dl_phdr_info *info, size_t /*size*/, void *data) -> int {
            auto out = reinterpret_cast<FILE *>(data);
            auto *name = info->dlpi_name;
            if (!name || !name[0])
                name = "exe";

            fprintf(out, "\tmodule: 0x%zx %s\n", info->dlpi_addr, name);
            return 0;
        }, out);
        fprintf(out, "end modules\n");

        dirty() = false;
    }

    static auto write_exe(FILE *out)
    {
        fprintf(out, "exe: %s\n", std::filesystem::canonical("/proc/self/exe").c_str());
    }

    static std::atomic<bool>& dirty()
    {
        // the mappings is initially dirty - we want to output it on first use
        static std::atomic<bool> dirty(true);
        return dirty;
    }
};
