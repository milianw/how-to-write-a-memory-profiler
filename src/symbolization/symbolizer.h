// SPDX-License-Identifier: LGPL-2.1-or-later

#pragma once

#include <string>

struct Dwfl;

//--> slide symbol_t
struct Symbol
{
    std::string name;
    uint64_t offset = 0;
    std::string dso;
    uint64_t dso_offset = 0;
    std::string file;
    int line = 0;
    int column = 0;
};
//<-- slide symbol_t

//--> slide symbolizer
class Symbolizer
{
public:
    Symbolizer();
    ~Symbolizer();

    void beginReportElf();
    void reportElf(const std::string &path, uint64_t addr);
    void endReportElf();

    Symbol symbol(uint64_t ip);

    std::string demangle(const std::string &symbol) const;

private:
    Dwfl *m_dwfl;
};
//<-- slide symbolizer
