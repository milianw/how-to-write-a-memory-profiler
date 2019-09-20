// SPDX-License-Identifier: LGPL-2.1-or-later

#pragma once

#include <string>
#include <vector>

struct Dwfl;

struct Symbol
{
    std::string name;
    std::string file;
    int line = -1;
    int column = -1;
    bool isInlined = false;
};

struct IpInfo
{
    std::vector<Symbol> symbols;
    std::string dso;
    uint64_t dso_offset = 0;
    uint64_t symbol_offset = 0;
};

class Symbolizer
{
public:
    Symbolizer();
    ~Symbolizer();

    void beginReportElf();
    void reportElf(const std::string &path, uint64_t addr);
    void endReportElf();

    IpInfo ipInfo(uint64_t ip);

    std::string demangle(const std::string &symbol) const;

private:
    Dwfl *m_dwfl;
};
