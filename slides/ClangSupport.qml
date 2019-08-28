import SlideViewer 1.0

SlideSet {
    title: "Clang Support"
    Slide {
        slideId: 65
        title: "Clang: Missing <tt>.debug_aranges</tt>"
        text: "* Clang does not emit <tt>.debug_aranges</tt> section by default
               ** This breaks CU DIE lookup via <tt>dwfl_module_addrdie</tt>
               ** Symbolization fails to find source file information, inline frames
               * Option 1:
               ** Recompile everything with <tt>clang++ -gdwarf-aranges ...</tt>
               * Option 2: workaround by building the mapping manually
               ** Based on https://github.com/bombela/backward-cpp
               ** <tt>dwfl_module_nextcu</tt> to find all CU DIEs in a module
               ** <tt>dwarf_child</tt> to find all DIEs in the CU DIE
               ** <tt>dwarf_ranges</tt> to find ranges for DIE
               ** See <tt>moduleAddrDie</tt> in <tt>symbolization_clang/symbolizer.cpp</tt>
               "
    }
}
