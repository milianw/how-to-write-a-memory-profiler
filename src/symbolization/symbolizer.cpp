// SPDX-License-Identifier: LGPL-2.1-or-later

#include "symbolizer.h"

//--> slide demangle
#include <cxxabi.h>
//<-- slide demangle

//--> slide setup
#include <libdwfl.h>

namespace {
const Dwfl_Callbacks s_callbacks = {
    /* find_elf = */        &dwfl_build_id_find_elf,
    /* find_debuginfo = */  &dwfl_standard_find_debuginfo,
    /* section_address = */ &dwfl_offline_section_address,
    /* debuginfo_path = */  nullptr
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
//<-- slide setup

//--> slide elf reporting
void Symbolizer::beginReportElf()
{
    dwfl_report_begin(m_dwfl);
}

// addr is the base address obtained from e.g. dl_phdr_info->dlpi_addr
void Symbolizer::reportElf(const std::string &path, uint64_t addr)
{
    if (!dwfl_report_elf(m_dwfl, path.c_str(), path.c_str(), -1, addr, false)) {
        fprintf(stderr, "failed to report elf %s at %zx: %s\n",
                path.c_str(), addr, dwfl_errmsg(dwfl_errno()));
    }
}

void Symbolizer::endReportElf()
{
    if (dwfl_report_end(m_dwfl, nullptr, nullptr) != 0) {
        fprintf(stderr, "failed to end elf reporting: %s\n",
                dwfl_errmsg(dwfl_errno()));
    }
}
//<-- slide elf reporting

namespace {
//--> slide setDsoInfo
// 0xDEADBEEF -> libfoo @ 0xBEEF
void setDsoInfo(Symbol &symbol, Dwfl_Module *mod, Dwarf_Addr ip)
{
    Dwarf_Addr moduleStart = 0;
    symbol.dso = dwfl_module_info(mod, nullptr, &moduleStart, nullptr,
                                  nullptr, nullptr, nullptr, nullptr);
    symbol.dso_offset = ip - moduleStart;
}
//<-- slide setDsoInfo

//--> slide setSymInfo
// 0xDEADBEEF -> foobar @ 0xEF
void setSymInfo(Symbol &symbol, Dwfl_Module *mod, Dwarf_Addr ip)
{
    GElf_Sym sym;
    auto symname = dwfl_module_addrinfo(mod, ip, &symbol.offset, &sym,
                                        nullptr, nullptr, nullptr);
    if (!symname)
        symname = "??";
    symbol.name = symname;
}
//<-- slide setSymInfo

//--> slide setFileLineInfo
// 0xDEADBEEF -> foo.cpp:42
void setFileLineInfo(Symbol &symbol, Dwfl_Module *mod, Dwarf_Addr ip)
{
    Dwarf_Addr bias = 0;
    auto die = dwfl_module_addrdie(mod, ip, &bias);
    if (!die)
        return;
    auto srcloc = dwarf_getsrc_die(die, ip - bias);
    if (!srcloc)
        return;
    auto srcfile = dwarf_linesrc(srcloc, nullptr, nullptr);
    if (!srcfile)
        return;

    symbol.file = srcfile;
    dwarf_lineno(srcloc, &symbol.line);
    dwarf_linecol(srcloc, &symbol.column);
}
//<-- slide setFileLineInfo
}

//--> slide symbol resolution
Symbol Symbolizer::symbol(uint64_t ip)
{
    auto *mod = dwfl_addrmodule(m_dwfl, ip);
    if (!mod) {
        fprintf(stderr, "failed to find module for ip %zx: %s\n",
                ip, dwfl_errmsg(dwfl_errno()));
        return {};
    }

    Symbol symbol;
    setDsoInfo(symbol, mod, ip);
    setSymInfo(symbol, mod, ip);
    setFileLineInfo(symbol, mod, ip);
    return symbol;
}
//<-- slide symbol resolution

//--> slide demangle
std::string Symbolizer::demangle(const std::string &symbol) const
{
    if (symbol.size() < 3 || symbol[0] != '_' || symbol[1] != 'Z')
        return symbol;
    auto demangled = abi::__cxa_demangle(symbol.c_str(), nullptr,
                                         nullptr, nullptr);
    if (!demangled)
        return symbol;
    std::string ret = demangled;
    free(demangled);
    return ret;
}
//<-- slide demangle
