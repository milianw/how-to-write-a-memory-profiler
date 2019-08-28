#include <cstdlib>
#include <cstring>
#include <cstdio>
#include <cassert>

#include <elftable.h>

//--> slide hook
void *intercept_malloc(size_t size)
{
    static auto original_malloc = reinterpret_cast<decltype(&::malloc)>(dlsym(RTLD_NEXT, "malloc"));
    assert(original_malloc);

    auto ret = original_malloc(size);

    fprintf(stderr, "malloc intercepted: %zu -> %p\n", size, ret);
    return ret;
}

void overwriteGotEntry(const char *symname, Elf::Addr gotAddr)
{
    if (strcmp(symname, "malloc") == 0) {
        auto ptr = reinterpret_cast<void **>(gotAddr);
        fprintf(stderr, "relocation: %s: %zx | %p\n", symname, gotAddr, *ptr);
        *ptr = reinterpret_cast<void *>(&intercept_malloc);
    }
}
//<-- slide hook

//--> slide relocations
void overwriteGotEntries(const Elf::JmprelTable &relocations,
                         const Elf::SymbolTable &symbols,
                           const Elf::StringTable &strings,
                         Elf::Addr baseAddr)
{
    for (const auto &relocation : relocations) {
        const auto index = ELF_R_SYM(relocation.r_info);
        const char* symname = strings.table + symbols.table[index].st_name;
        const auto gotAddr = relocation.r_offset + baseAddr;
        overwriteGotEntry(symname, gotAddr);
    }
}
//<-- slide relocations

//--> slide tables
void overwriteDynEntries(const Elf::Dyn *dynEntries, Elf::Addr baseAddr)
{
    Elf::SymbolTable symbols;
    Elf::JmprelTable jmprels;
    Elf::StringTable strings;

    // initialize the elf tables
    for (auto dyn = dynEntries; dyn->d_tag != DT_NULL; ++dyn) {
        symbols.consume(dyn) || strings.consume(dyn) || jmprels.consume(dyn);
    }

    overwriteGotEntries(jmprels, symbols, strings, baseAddr);
}
//<-- slide tables

//--> slide dl_iterate_phdr
void overwritePhdrs()
{
    dl_iterate_phdr([](dl_phdr_info* info, size_t /*size*/, void* /*data*/) {
        if (strstr(info->dlpi_name, "/ld-linux")) {
            // don't touch anything in the linker itself
            return 0;
        }

        for (int i = 0; i < info->dlpi_phnum; ++i) {
            const auto &phdr = info->dlpi_phdr[i];
            if (phdr.p_type == PT_DYNAMIC) {
                const auto dynEntriesAddr = phdr.p_vaddr + info->dlpi_addr;
                const auto dynEntries = reinterpret_cast<const Elf::Dyn *>(dynEntriesAddr);
                const auto base = info->dlpi_addr;
                overwriteDynEntries(dynEntries, base);
            }
        }
        return 0;
    }, nullptr);
}
//<-- slide dl_iterate_phdr

//--> slide main
void *foo()
{
    return malloc(100);
}

int main()
{
    auto f = foo();
    overwritePhdrs();
    auto f2 = foo();

    free(f);
    free(f2);
    return f != f2;
}
//<-- slide main
