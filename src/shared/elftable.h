// SPDX-License-Identifier: LGPL-2.1-or-later
#pragma once

#include <link.h>

#if __WORDSIZE == 64
#define ELF_R_SYM(i) ELF64_R_SYM(i)
#elif __WORDSIZE == 32
#define ELF_R_SYM(i) ELF32_R_SYM(i)
#else
#error unsupported word size
#endif

namespace Elf {

//--> slide tables
using Addr = ElfW(Addr);
using Dyn = ElfW(Dyn);
using Rel = ElfW(Rel);
using Rela = ElfW(Rela);
using Sym = ElfW(Sym);
using Sxword = ElfW(Sxword);
using Xword = ElfW(Xword);
//<-- slide tables

//--> slide table_def
template <typename T, Elf::Sxword AddrTag, Elf::Sxword SizeTag>
struct Table
{
    using type = T;
    T* table = nullptr;
    Elf::Xword size = {};

    bool consume(const Elf::Dyn* dyn) noexcept
    {
        if (dyn->d_tag == AddrTag) {
            table = reinterpret_cast<T*>(dyn->d_un.d_ptr);
            return true;
        } else if (dyn->d_tag == SizeTag) {
            size = dyn->d_un.d_val;
            return true;
        }
        return false;
    }

    const T* begin() const noexcept { return table; }
    const T* end() const noexcept { return table + size / sizeof(T); }
};
//<-- slide table_def

//--> slide tables
using StringTable = Table<const char, DT_STRTAB, DT_STRSZ>;
using SymbolTable = Table<Elf::Sym, DT_SYMTAB, DT_SYMENT>;
using RelTable = Table<Elf::Rel, DT_REL, DT_RELSZ>;
using RelaTable = Table<Elf::Rela, DT_RELA, DT_RELASZ>;
using JmprelTable = Table<Elf::Rela, DT_JMPREL, DT_PLTRELSZ>;
//<-- slide tables
}
