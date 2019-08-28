// SPDX-License-Identifier: LGPL-2.1-or-later

#include <cstdio>
#include <cstring>

#include <alloc_hooks.h>
#include <module_hooks.h>
#include <recursionguard.h>
#include <mappings.h>
#include <trace.h>
#include <elftable.h>

#include <cstdlib>
#include <cstring>

#include <errno.h>
#include <link.h>
#include <malloc.h>
#include <unistd.h>

#include <sys/mman.h>

#include <type_traits>

namespace {

template<typename Hook>
bool try_install_hook(const Hook &hook, typename Hook::signature_t intercept, const char* symname, Elf::Addr addr)
{
    if (strcmp(hook.identifier, symname) != 0)
        return false;

    // try to make the page read/write accessible, which is hackish
    // but apparently required for some shared libraries
    auto page = reinterpret_cast<void*>(addr & ~(0x1000 - 1));
    mprotect(page, 0x1000, PROT_READ | PROT_WRITE);

    // now write to the address, i.e. actually put our interceptor in place
    auto typedAddr = reinterpret_cast<typename Hook::signature_t *>(addr);
    *typedAddr = intercept;

    return true;
}

void try_install_hooks(const char* symname, Elf::Addr addr)
{
    // TODO: use std::apply once we can rely on C++17
#define TRY_INSTALL_HOOK(name) try_install_hook(hooks::name, &intercept::name, symname, addr)
    TRY_INSTALL_HOOK(malloc) || TRY_INSTALL_HOOK(free) || TRY_INSTALL_HOOK(realloc)
        || TRY_INSTALL_HOOK(calloc) || TRY_INSTALL_HOOK(valloc) || TRY_INSTALL_HOOK(posix_memalign)
        || TRY_INSTALL_HOOK(dlopen) || TRY_INSTALL_HOOK(dlclose);
#undef TRY_INSTALL_HOOK
}

template <typename Table>
void try_overwrite_elftable(const Table& jumps, const Elf::StringTable& strings, const Elf::SymbolTable& symbols,
                            const Elf::Addr base) noexcept
{
    const auto rela_end = reinterpret_cast<typename Table::type*>(reinterpret_cast<char*>(jumps.table) + jumps.size);
    for (auto rela = jumps.table; rela < rela_end; rela++) {
        const auto index = ELF_R_SYM(rela->r_info);
        const char* symname = strings.table + symbols.table[index].st_name;
        auto addr = rela->r_offset + base;
        try_install_hooks(symname, addr);
    }
}

void try_overwrite_symbols(const Elf::Dyn* dyn, const Elf::Addr base) noexcept
{
    Elf::SymbolTable symbols;
    Elf::RelTable rels;
    Elf::RelaTable relas;
    Elf::JmprelTable jmprels;
    Elf::StringTable strings;

    // initialize the elf tables
    for (; dyn->d_tag != DT_NULL; ++dyn) {
        symbols.consume(dyn) || strings.consume(dyn) || rels.consume(dyn) || relas.consume(dyn) || jmprels.consume(dyn);
    }

    // find symbols to overwrite
    try_overwrite_elftable(rels, strings, symbols, base);
    try_overwrite_elftable(relas, strings, symbols, base);
    try_overwrite_elftable(jmprels, strings, symbols, base);
}

int iterate_phdrs(dl_phdr_info* info, size_t /*size*/, void* /*data*/) noexcept
{
    if (strstr(info->dlpi_name, "/libattach_intercept.so")) {
        // prevent infinite recursion: do not overwrite our own symbols
        return 0;
    } else if (strstr(info->dlpi_name, "/ld-linux")) {
        // prevent strange crashes due to overwriting the free symbol in ld-linux
        return 0;
    }

    for (auto phdr = info->dlpi_phdr, end = phdr + info->dlpi_phnum; phdr != end; ++phdr) {
        if (phdr->p_type == PT_DYNAMIC) {
            try_overwrite_symbols(reinterpret_cast<const Elf::Dyn*>(phdr->p_vaddr + info->dlpi_addr), info->dlpi_addr);
        }
    }
    return 0;
}

void overwrite_symbols() noexcept
{
    dl_iterate_phdr(&iterate_phdrs, nullptr);
}
}

namespace track {
static FILE* out = nullptr;

void init()
{
    if (!out)
        return;

    RecursionGuard guard;
    mappings::write_exe(track::out);

    hooks::init_allocs();
    hooks::init_modules();
    overwrite_symbols();
}

void malloc(void *ptr, size_t size)
{
    if (RecursionGuard::isActive || !out)
        return;
    RecursionGuard guard;

    mappings::update(out);

    fprintf(out, "malloc(%zu) = %p\n", size, ptr);
    Trace::dump(out);
}

void free(void *ptr)
{
    if (RecursionGuard::isActive || !out)
        return;
    RecursionGuard guard;

    mappings::update(out);

    fprintf(out, "free(%p)\n", ptr);
    Trace::dump(out);
}

void invalidate_module_cache()
{
    // overwrite any symbols we may encounter after a dlopen
    overwrite_symbols();

    mappings::dirty() = true;
}
}

extern "C" {
const char *attach_init(const char *pipe)
{
    track::out = fopen(pipe, "w");
    if (!track::out) {
        return strerror(errno);
    }

    track::init();
    return "attached!";
}
}
