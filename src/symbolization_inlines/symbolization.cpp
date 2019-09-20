// SPDX-License-Identifier: LGPL-2.1-or-later

#include <iostream>
#include <string>
#include <string_view>
#include <cstdio>
#include <iomanip>

#include "symbolizer.h"

bool startsWith(const std::string &haystack, const std::string_view &needle)
{
    return haystack.compare(0, needle.size(), needle) == 0;
}

int main()
{
    Symbolizer symbolizer;
    std::string exe;

    std::string line;
    while (std::getline(std::cin, line)) {
        std::cout << line;
        if (startsWith(line, "exe: ")) {
            exe = line.substr(5);
        } else if (line == "begin modules") {
            symbolizer.beginReportElf();
        } else if (line == "end modules") {
            symbolizer.endReportElf();
        } else if (startsWith(line, "\tmodule: ")) {
            uint64_t addr = 0;
            ssize_t pathStart = 0;
            if (sscanf(line.c_str(), "\tmodule: %zx %zn", &addr, &pathStart) == 1) {
                std::string path = line.substr(pathStart);
                if (path == "exe")
                    path = exe;
                if (!startsWith(path, "linux-vdso.so"))
                    symbolizer.reportElf(path, addr);
            }
        } else if (startsWith(line, "\tip: ")) {
            uint64_t ip = 0;
            if (sscanf(line.c_str(), "\tip: %zx", &ip) == 1) {
                const auto info = symbolizer.ipInfo(ip);
                std::cout << " (" << info.dso << '@' << std::hex << info.dso_offset << std::dec << ')';
                for (const auto &symbol : info.symbols) {
                    std::cout << "\n\t\t" << symbolizer.demangle(symbol.name);
                    if (!symbol.isInlined)
                        std::cout << '@' << std::hex << info.symbol_offset << std::dec;
                    if (!symbol.file.empty())
                        std::cout << ' ' << symbol.file << ':' << symbol.line << ':' << symbol.column;
                    if (symbol.isInlined)
                        std::cout << " (inline)";
                }
            }
        }
        std::cout << '\n';
    }
}
