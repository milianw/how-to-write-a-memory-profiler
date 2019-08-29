// SPDX-License-Identifier: LGPL-2.1-or-later

#include "symbolizer.h"

#include <libdwfl.h>
#include <cxxabi.h>
#include <dwarf.h>

namespace {
const Dwfl_Callbacks s_callbacks = {
    &dwfl_build_id_find_elf,
    &dwfl_standard_find_debuginfo,
    &dwfl_offline_section_address,
    nullptr
};
}

Symbolizer::Symbolizer()
    : m_dwfl(dwfl_begin(&s_callbacks))
{
}

Symbolizer::~Symbolizer()
{
    dwfl_end(m_dwfl);
}

void Symbolizer::beginReportElf()
{
    dwfl_report_begin(m_dwfl);
}

void Symbolizer::reportElf(const std::string &path, uint64_t addr)
{
    if (!dwfl_report_elf(m_dwfl, path.c_str(), path.c_str(), -1, addr, false))
        fprintf(stderr, "failed to report elf %s at %zx: %s\n", path.c_str(), addr, dwfl_errmsg(dwfl_errno()));
}

void Symbolizer::endReportElf()
{
    if (dwfl_report_end(m_dwfl, nullptr, nullptr) != 0)
        fprintf(stderr, "failed to end elf reporting: %s\n", dwfl_errmsg(dwfl_errno()));
}

DsoSymbol Symbolizer::symbol(uint64_t ip)
{
    auto *mod = dwfl_addrmodule(m_dwfl, ip);
    if (!mod) {
        fprintf(stderr, "failed to find module for ip %zx: %s\n", ip, dwfl_errmsg(dwfl_errno()));
        return {};
    }

    DsoSymbol symbol;

    // dso info
    {
        Dwarf_Addr moduleStart = 0;
        symbol.dso = dwfl_module_info(mod, nullptr, &moduleStart, nullptr, nullptr, nullptr, nullptr, nullptr);
        symbol.dso_offset = ip - moduleStart;
    }

    // sym info
    {
        GElf_Sym sym;
        auto symname = dwfl_module_addrinfo(mod, ip, &symbol.offset, &sym, nullptr, nullptr, nullptr);
        if (!symname)
            symname = "??";
        symbol.name = symname;
    }

    // srcfile info
    {
        Dwarf_Addr bias = 0;
        auto die = dwfl_module_addrdie(mod, ip, &bias);
        if (die) {
            auto srcloc = dwarf_getsrc_die(die, ip - bias);
            if (srcloc) {
                auto srcfile = dwarf_linesrc(srcloc, nullptr, nullptr);
                if (srcfile) {
                    symbol.file = srcfile;
                    dwarf_lineno(srcloc, &symbol.line);
                    dwarf_linecol(srcloc, &symbol.column);
                }
            }
        }
    }

    return symbol;
}

namespace {
//--> slide dieName
const char *dieName(Dwarf_Die *die)
{
    Dwarf_Attribute attr;
    Dwarf_Attribute *result = dwarf_attr_integrate(die, DW_AT_MIPS_linkage_name, &attr);
    if (!result)
        result = dwarf_attr_integrate(die, DW_AT_linkage_name, &attr);

    auto *name = dwarf_formstring(result);
    if (name)
        return name;

    return dwarf_diename(die);
}
//<-- slide dieName

//--> slide inlinedSubroutineSymbol
Symbol inlinedSubroutineSymbol(Dwarf_Die *scope, Dwarf_Files *files)
{
    Dwarf_Attribute attr;
    Dwarf_Word val = 0;

    Symbol symbol;

    symbol.name = dieName(scope);

    const char *file = nullptr;
    if (dwarf_formudata(dwarf_attr(scope, DW_AT_call_file, &attr), &val) == 0)
        file = dwarf_filesrc(files, val, nullptr, nullptr);
    symbol.file = file ? file : "??";

    if (dwarf_formudata(dwarf_attr(scope, DW_AT_call_line, &attr), &val) == 0)
        symbol.line = static_cast<int>(val);

    if (dwarf_formudata(dwarf_attr(scope, DW_AT_call_column, &attr), &val) == 0)
        symbol.column = static_cast<int>(val);

    return symbol;
}
//<-- slide inlinedSubroutineSymbol
}

std::vector<Symbol> Symbolizer::inlineSymbols(uint64_t ip)
{
//--> slide cu die
    auto *mod = dwfl_addrmodule(m_dwfl, ip);
    if (!mod)
        return {};

    Dwarf_Addr bias = 0;
    // CU DIE: Compilation Unit Debug Information Entry
    auto cuDie = dwfl_module_addrdie(mod, ip, &bias);
    if (!cuDie)
        return {};
//<-- slide cu die

//--> slide scope die
    // innermost scope DIE
    Dwarf_Die scopeDie;
    {
        Dwarf_Die *scopes = nullptr;
        const auto nscopes = dwarf_getscopes(cuDie, ip - bias, &scopes);
        if (nscopes == 0)
            return {};
        scopeDie = scopes[0];
        free(scopes);
    }
//<-- slide scope die

//--> slide die scopes
    Dwarf_Die *scopes = nullptr;
    const auto nscopes = dwarf_getscopes_die(&scopeDie, &scopes);

    Dwarf_Files *files = nullptr;
    dwarf_getsrcfiles(cuDie, &files, nullptr);

    std::vector<Symbol> symbols;
    for (int i = 0; i < nscopes; ++i) {
        const auto scope = &scopes[i];
        if (dwarf_tag(scope) == DW_TAG_inlined_subroutine)
            symbols.push_back(inlinedSubroutineSymbol(scope, files));
    }
    free(scopes);
//<-- slide die scopes

    return symbols;
}

std::string Symbolizer::demangle(const std::string &symbol) const
{
    if (symbol.size() < 3 || symbol[0] != '_' || symbol[1] != 'Z')
        return symbol;
    auto demangled = abi::__cxa_demangle(symbol.c_str(), nullptr, nullptr, nullptr);
    if (!demangled)
        return symbol;
    std::string ret = demangled;
    free(demangled);
    return ret;
}
