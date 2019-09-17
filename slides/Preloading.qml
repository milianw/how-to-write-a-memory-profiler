import SlideViewer 1.0

SlideSet {
    title: "Preloading"
//     SlideSet {
//         title: "Code Injection"
        Slide {
            slideId: 11
            title: "<tt>LD_PRELOAD</tt>"
            text: "Use the dynamic linker to inject custom library code:"
            Code {
                dialect: "Bash"
                code: "LD_PRELOAD=$(readlink -f path/to/libfoo.so) some_app"
            }
            Text {
                text: "* Dynamic linker resolves library calls
                    * First library with a suitable exported symbol wins
                    ** Make sure the mangled name matches
                    * <tt>LD_PRELOAD</tt> wins over dynamically linked <tt>libc</tt>
                    * ODR?
                    ** C++ standard does not define how linking works
                    "
            }
        }
        Slide {
            slideId: 12
            title: "Intercepting Library Calls"
            text: "Build a library with the symbols you want to intercept
                * Use <tt>dlsym</tt> from <tt>libdl.so</tt> to find the original function
                * Casting of <tt>void *</tt> to a function pointer is valid on POSIX"
            CppCode {
                title: "preload.cpp:"
                fileName: "../src/preload/preload.cpp"
            }
            Code {
                dialect: "Bash"
                code: "$ nm test_clients/one_malloc | grep \" malloc\"
                    U malloc
                    $ nm /usr/lib/libc.so.6 | grep \" malloc\"
                    00000000000875d0 T malloc
                    $ nm preload/libpreload.so | grep \" malloc\"
                    00000000000875d0 T malloc"
            }
        }
        Slide {
            slideId: 13
            title: "Intercepting Library Calls"
            text: "Now we can leverage <tt>LD_PRELOAD</tt> to inject our custom code:"
            Code {
                dialect: "Bash"
                title: "preload.sh:"
                fileName: "../src/preload/preload.sh.in"
            }
            Text {
                text: "* Use the above script to inject the code into arbitrary applications:"
            }
            CppCode {
                title: "one_malloc.cpp:"
                fileName: "../src/test_clients/one_malloc.cpp"
            }
            Code {
                code: "$ ./preload/preload.sh ./test_clients/one_malloc
                        malloc intercepted: 72704 -> 0x564d8f706260
                        malloc intercepted: 100 -> 0x564d8f717e70"
            }
        }

        Slide {
            slideId: 14
            title: "Inspecting Dynamic Linking: Without <tt>LD_PRELOAD</tt>"
            Code {
                dialect: "Bash"
                code: "$ LD_DEBUG=bindings ./test_clients/one_malloc |& grep -P '\\bmalloc\\b'"
            }
            Code {
                code: "
                    binding file /usr/lib/libc.so.6 [0] to /usr/lib/libc.so.6 [0]: \\
                            normal symbol `malloc` [GLIBC_2.2.5]
                    binding file /usr/lib/libgcc_s.so.1 [0] to /usr/lib/libc.so.6 [0]: \\
                            normal symbol `malloc` [GLIBC_2.2.5]
                    binding file /usr/lib/libstdc++.so.6 [0] to /usr/lib/libc.so.6 [0]: \\
                            normal symbol `malloc` [GLIBC_2.2.5]
                    binding file /lib64/ld-linux-x86-64.so.2 [0] to /usr/lib/libc.so.6 [0]: \\
                            normal symbol `malloc` [GLIBC_2.2.5]
                    binding file ./test_clients/one_malloc [0] to /usr/lib/libc.so.6 [0]: \\
                            normal symbol `malloc` [GLIBC_2.2.5]"
            }
        }
        Slide {
            slideId: 15
            title: "Inspecting Dynamic Linking: With <tt>LD_PRELOAD</tt>"
            Code {
                dialect: "Bash"
                code: "$ LD_DEBUG=bindings ./preload/preload.sh ./test_clients/one_malloc |& grep -P \"\\bmalloc\\b\""
            }
            Code {
                code: "
                        binding file /usr/lib/libc.so.6 [0] to .../preload/libpreload.so [0]: \\
                            normal symbol `malloc` [GLIBC_2.2.5]
                        binding file /usr/lib/libgcc_s.so.1 [0] to .../preload/libpreload.so [0]: \\
                            normal symbol `malloc` [GLIBC_2.2.5]
                        binding file /usr/lib/libstdc++.so.6 [0] to .../preload/libpreload.so [0]: \\
                            normal symbol `malloc` [GLIBC_2.2.5]
                        binding file /lib64/ld-linux-x86-64.so.2 [0] to .../preload/libpreload.so [0]: \\
                            normal symbol `malloc` [GLIBC_2.2.5]
                        binding file .../preload/libpreload.so [0] to /usr/lib/libc.so.6 [0]: \\
                            normal symbol `malloc`

                        malloc intercepted: 72704 -> 0x5607802f8260

                        binding file ./test_clients/one_malloc [0] to .../preload/libpreload.so [0]: \\
                            normal symbol `malloc` [GLIBC_2.2.5]

                        malloc intercepted: 100 -> 0x560780309e70"
            }
        }
//     }
    SlideSet {
        title: "Initialization"
        include: false
        Slide {
            slideId: 16
            title: "Global Static Initialization"
            text: "Constructors of global static objects:"
            CppCode {
                code: "
                struct Initializer
                {
                    Initializer()
                    {
                        // initialization code goes here
                    }
                };

                // at global scope
                static Initializer initializer;
                "
            }
            Text {
                text: "* In practice, this is unusable to initialize a memory profiler
                       ** The <tt>Initializer</tt> constructor gets called too late
                       ** Intercepted functions like <tt>calloc</tt> get called by the dynamic linker
                       "
            }
        }
        Slide {
            slideId: 17
            title: "Lazy Initialization"
            text: "Solution: Use lazy initialization"
            CppCode {
                code: "
                extern \"C\" {
                void* malloc(size_t size) noexcept
                {
                    if (!hooks::malloc) // check if dlsym was called already
                        track::init(); // otherwise call dlsym for all intercepted functions

                    void* ptr = hooks::malloc(size); // call original function
                    track::malloc(ptr, size); // report intercepted function call
                    return ptr; // return original return value
                }
                }"
            }
        }
    }
}
