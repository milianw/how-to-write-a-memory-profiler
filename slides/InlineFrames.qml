import SlideViewer 1.0

SlideSet {
    title: "Inline Frames"
    Slide {
        slideId: 60
        title: "libdwfl: CU DIE"
        text: "Find compilation unit (CU) debug information entry (DIE):"

        CppCode {
            title: "symbolization.cpp"
            fileName: "../src/symbolization_inlines/symbolizer.cpp"
            fileMarker: "slide cu die"
        }
    }
    Slide {
        slideId: 61
        title: "libdwfl: Scope DIE"
        text: "Find innermost scope DIE:"
        CppCode {
            title: "symbolization.cpp"
            fileName: "../src/symbolization_inlines/symbolizer.cpp"
            fileMarker: "slide scope die"
        }
    }
    Slide {
        slideId: 62
        title: "libdwfl: Inlined DIEs"
        text: "Find inlined frames, i.e. other DIEs that contain scope DIE:"
        CppCode {
            title: "symbolization.cpp"
            fileName: "../src/symbolization_inlines/symbolizer.cpp"
            fileMarker: "slide die scopes"
        }
    }
    Slide {
        slideId: 67
        title: "libdwfl:Symbol Resolution for Inlined Frames"
        text: "Resolve symbol name for inlined frame scope:"
        CppCode {
            title: "symbolization.cpp"
            fileName: "../src/symbolization_inlines/symbolizer.cpp"
            fileMarker: "slide dieName"
        }
    }
    Slide {
        slideId: 64
        title: "libdwfl: Information for inlined DIE"
        text: "Resolve source file and line number for inlined frame scope:"
        CppCode {
            title: "symbolization.cpp"
            fileName: "../src/symbolization_inlines/symbolizer.cpp"
            fileMarker: "slide inlinedSubroutineSymbol"
        }
    }
    Slide {
        slideId: 63
        title: "Symbolizing Allocation Backtraces"
        text: "Putting it all together:"

        Code {
            dialect: "Bash"
            code: "
                    $ ./mappings/preload_mappings.sh ./test_clients/vector |& \\
                        ./symbolization_inlines/symbolization_inlines"
        }
        Code {
            code: "
                malloc(4) = 0x55de17384400
                ip: 0x7fb788cd026c (.../mappings/libpreload_mappings.so@226c)
                    intercept::malloc(unsigned long)@2c
                ip: 0x7fb788b38ac9 (/usr/lib/libstdc++.so.6@a2ac9)
                    operator new(unsigned long)@19
                ip: 0x55de15b09ca1 (.../test_clients/vector@ca1)
                    inline: __gnu_cxx::new_allocator&lt;int>::allocate(unsigned long, void const*)
                    inline: std::allocator_traits&lt;std::allocator&lt;int> >::allocate...
                    inline: std::_Vector_base&lt;int, std::allocator&lt;int> >::_M_allocate(unsigned long)
                    void std::vector&lt;int, std::allocator&lt;int> >::_M_realloc_insert&lt;int>(...
                ip: 0x55de15b09ad0 (.../test_clients/vector@ad0)
                    inline: int& std::vector&lt;int, std::allocator&lt;int> >::emplace_back&lt;int>(int&&)
                    inline: std::vector&lt;int, std::allocator&lt;int> >::push_back(int&&)
                    inline: std::back_insert_iterator&lt;std::vector&lt;int, std::allocator&lt;int> > >::operator=...
                    inline: generate_n&lt;std::back_insert_iterator&lt;std::vector&lt;int> >, int, ...
                    main@70
                ip: 0x7fb788799ee2 (/usr/lib/libc.so.6@26ee2)
                    __libc_start_main@f2
                ip: 0x55de15b09b5d (.../test_clients/vector@b5d)
                    _start@2d
            "
        }
    }
}
