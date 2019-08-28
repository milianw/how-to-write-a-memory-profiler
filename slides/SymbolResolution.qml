import SlideViewer 1.0

SlideSet {
    title: "Symbol Resolution"
    Slide {
        id: symbolResolution
        title: "Symbol Resolution"
        text: "* Instruction pointer: <tt>0x55b20bc95d9f</tt>
               * Corresponding ELF map:"
        Code {
            code: "$ ./backtrace/preload_backtrace.sh ./test_clients/delay &
                   $ cat /proc/$(pidof delay)/maps
                    55b20bc95000-55b20bc97000 r-xp 00000000 08:04 18622503 \\
                        .../test_clients/delay
                    55b20bc97000-55b20bc98000 r--p 00001000 08:04 18622503 \\
                        .../test_clients/delay
                    55b20bc98000-55b20bc99000 rw-p 00002000 08:04 18622503 \\
                        .../test_clients/delay
                    ..."
        }
        Text {
            text: "* Mapped address: <tt>0x55b20bc95d9f - 0x55b20bc95000 = 0xd9f</tt>
                   * Symbol resolution:"
        }
        Code {
            title: "addr2line"
            visible: symbolResolution.onlyStep(0)
            code: "
                $ addr2line -p -e .../test_clients/delay -a 0xD9F
                0x0000000000000d9f:
                    /usr/include/c++/9.1.0/ostream:570"
        }
        Code {
            title: "addr2line with functions"
            visible: symbolResolution.onlyStep(1)
            code: "
                $ addr2line -p -f -e .../test_clients/delay -a 0xD9F
                0x0000000000000d9f:
                    _ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc
                        at /usr/include/c++/9.1.0/ostream:570"
        }
        Code {
            title: "addr2line with demangling"
            visible: symbolResolution.onlyStep(2)
            code: "
                $ addr2line -p -f -C -e .../test_clients/delay -a 0xD9F
                0x0000000000000d9f:
                    std::basic_ostream&lt;...>& std::operator&lt;&lt; &lt;...>(...)
                        at /usr/include/c++/9.1.0/ostream:570"
        }
        Code {
            title: "addr2line with inline frames"
            visible: symbolResolution.onlyStep(3)
            code: "
                $ addr2line -p -f -C -i -e .../test_clients/delay -a 0xD9F
                0x0000000000000d9f:
                    std::basic_ostream&lt;...>& std::operator&lt;&lt; &lt;...>(...)
                        at /usr/include/c++/9.1.0/ostream:570
                    (inlined by) main
                        at .../test_clients/delay.cpp:9"
        }
    }
    SlideSet {
        title: "ELF mappings"
        Slide {
            title: "<tt>dl_iterate_phdr</tt>"
            text: "Iterate over DSO mappings with <tt>dl_iterate_phdr</tt> from <tt>libdl.so</tt> / <tt>link.h</tt>:"

            CppCode {
                code: "
                    #include &lt;link.h>

                    void dumpMappings(FILE *out)
                    {
                        dl_iterate_phdr([](dl_phdr_info *info, size_t /*size*/, void *data) -> int {
                            auto *name = info->dlpi_name;
                            if (!name || !name[0])
                                name = \"exe\";

                            auto out = reinterpret_cast&lt;FILE *>(data);
                            fprintf(out, \"%s is mapped at: 0x%zx\\n\", name, info->dlpi_addr);
                            return 0;
                        }, out);
                    }"
            }
        }
        Slide {
            title: "Preload Mappings"

            text: "Integrated into <tt>LD_PRELOAD</tt> library:
                    * Also intercept <tt>dlopen</tt> and <tt>dlclose</tt>
                    ** Mark mappings as dirty whenever one of these is called
                    * Before writing a backtrace, check if mapping cache is dirty
                    ** If so, iterate the current mappings and output it
                    * On startup, also output the executable path once
                    ** <tt>std::filesystem::canonical(\"/proc/self/exe\")</tt>"
            Code {
                dialect: "Bash"
                code: "./mappings/preload_mappings.sh ./test_clients/one_malloc"
            }
        }
        Slide {
            title: "Preload Mappings Output"
            Code {
                code: "
                    exe: .../test_clients/vector
                    begin modules
                        module: 0x5569a6bce000 exe
                        module: 0x7fffc0fff000 linux-vdso.so.1
                        module: 0x7f81ed72d000 .../mappings/libpreload_mappings.so
                        module: 0x7f81ed4f5000 /usr/lib/libstdc++.so.6
                        module: 0x7f81ed3af000 /usr/lib/libm.so.6
                        module: 0x7f81ed395000 /usr/lib/libgcc_s.so.1
                        module: 0x7f81ed1d2000 /usr/lib/libc.so.6
                        module: 0x7f81ed1cd000 /usr/lib/libdl.so.2
                        module: 0x7f81ed1a9000 /usr/lib/libunwind.so.8
                        module: 0x7f81ed735000 /lib64/ld-linux-x86-64.so.2
                        module: 0x7f81ecf83000 /usr/lib/liblzma.so.5
                        module: 0x7f81ecf62000 /usr/lib/libpthread.so.0
                    end modules
                    malloc(72704) = 0x5569a8081620
                        ip: 0x7f81ed72f26c
                        ip: 0x7f81ed593aea
                        ip: 0x7f81ed745799
                        ip: 0x7f81ed7458a0
                        ip: 0x7f81ed737139
                    malloc(4) = 0x5569a8080400
                    ..."
            }
        }
    }
    SlideSet {
        title: "elfutils"
        Slide {
            title: "Symbol Resolution with elfutils"
            text: "* Doing symbol resolution is complex
                   ** Symbol table
                   ** Debug information interpretation
                   ** Compressed debug information
                   ** Split debug info
                   * Let's use <tt>libdwfl</tt> from elfutils for this task"
        }
        Slide {
            title: "libdwfl: Setup"
            text: "Basic libdwfl setup:"
            CppCode {
                title: "symbolizer.cpp"
                fileName: "../src/symbolization/symbolizer.cpp"
                fileMarker: "slide setup"
            }
        }
        Slide {
            title: "libdwfl: ELF Reporting"
            text: "Reporting mapped ELF objects:"
            CppCode {
                title: "symbolizer.cpp"
                fileName: "../src/symbolization/symbolizer.cpp"
                fileMarker: "slide elf reporting"
            }
        }
        Slide {
            title: "libdwfl: Symbol Resolution"
            text: "Resolve symbol of address:"
            CppCode {
                title: "symbolizer.cpp"
                fileName: "../src/symbolization/symbolizer.cpp"
                fileMarker: "slide symbol resolution"
            }
            CppCode {
                title: "symbolizer.cpp"
                fileName: "../src/symbolization/symbolizer.cpp"
                fileMarker: "slide setDsoInfo"
            }
        }
        Slide {
            title: "libdwfl: Resolving Symbol Names"
            text: "Resolving symbol names from symbol table or DWARF:"
            CppCode {
                title: "symbolizer.cpp"
                fileName: "../src/symbolization/symbolizer.cpp"
                fileMarker: "slide setSymInfo"
            }
        }
        Slide {
            title: "libdwfl: Resolving Source Code Locations"
            text: "Resolving source code file name and line number from DWARF:"
            CppCode {
                title: "symbolizer.cpp"
                fileName: "../src/symbolization/symbolizer.cpp"
                fileMarker: "slide setFileLineInfo"
            }
        }
    }
    SlideSet {
        title: "Demangling"
        Slide {
            title: "Demangling: <tt>c++filt</tt>"

            text: "Demangling C++ function with <tt>c++filt</tt>:"
            Code {
                dialect: "Bash"
                code: "$ c++filt _ZStlsISt11char_traitsIcEERSt13basic_ostreamIcT_ES5_PKc"
            }
            Code {
                code: "
                std::basic_ostream&lt;char, std::char_traits&lt;char>>&
                    std::operator&lt;&lt; &lt;std::char_traits&lt;char>>
                    (std::basic_ostream&lt;char, std::char_traits&lt;char>>&, char const*)
                "
            }
        }
        Slide {
            title: "Demangling: <tt>cxxabi.h</tt>"

            text: "Manual demangling via <tt>cxxabi.h</tt>:"
            CppCode {
                title: "symbolizer.cpp"
                fileName: "../src/symbolization/symbolizer.cpp"
                fileMarker: "slide demangle"
            }
        }
    }
    Slide {
        title: "Symbolizing Allocation Backtraces"
        text: "Putting it all together:"
        Code {
            dialect: "Bash"
            code: "$ ./mappings/preload_mappings.sh ./test_clients/vector |& ./symbolization/symbolization"
        }
        Code {
            code: "
                ...
                malloc(4) = 0x55f390225400
                ip: 0x7fbaebf6d26c
                    intercept::malloc(unsigned long)@2c
                    .../mappings/libpreload_mappings.so@226c
                    .../src/shared/alloc_hooks.h:85:18
                ip: 0x7fbaebdd5ac9
                    operator new(unsigned long)@19
                    /usr/lib/libstdc++.so.6@a2ac9
                    /build/gcc/src/gcc/libstdc++-v3/libsupc++/new_op.cc:50:22
                ip: 0x55f38ef73ca1
                    void std::vector&lt;int, std::allocator&lt;int> >::_M_realloc_insert...
                    .../test_clients/vector@ca1
                    /usr/include/c++/9.1.0/ext/new_allocator.h:114:41
                ip:0x55f38ef73ad0
                    main@70
                    .../test_clients/vector@ad0
                    /usr/include/c++/9.1.0/bits/vector.tcc:121:4
                ip: 0x7fbaeba36ee2
                    __libc_start_main@f2
                    /usr/lib/libc.so.6@26ee2
                ip: 0x55f38ef73b5d
                    _start@2d
                    .../test_clients/vector@b5d
            "
        }
    }

    InlineFrames {}
    ClangSupport {}
}
