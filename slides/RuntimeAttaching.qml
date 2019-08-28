import SlideViewer 1.0

SlideSet {
    title: "Runtime Attaching"
    SlideSet {
        title: "Code Injection"
        Slide {
            slideId: 20
            id: injection
            title: "Code Injection"
            text: "Q: How can we inject and execute our code into a running application?"

            Space { height: 20 }

            Text {
                visible: injection.minStep(1)
                text: "A: With a debugger and dlopen!<br/><br/>
                       <small>Caveat: only works for dynamically linked applications</small>
                       "
            }
        }
        Slide {
            slideId: 21
            title: "GDB injection"
            id: gdb
            text: "
                * Attach to any application via <tt>gdb -p PID</tt>
                ** Auto loading of symbols is often quite slow
                ** Thus disable that and resolve necessary symbols manually
                * Call <tt>dlopen</tt> to load your own code
                ** <tt>dlopen</tt> is only available when application links against <tt>libdl.so</tt>
                ** Use <tt>libc.so</tt> internal <tt>__libc_dlopen_mode</tt> instead
                * Optionally call custom init function with tracing arguments"
            Code {
                dialect: "Bash"
                visible: gdb.minStep(1)
                code: "
                    __RTLD_DLOPEN=\"0x80000000\"
                    RTLD_NOW=\"0x00002\"
                    gdb --batch-silent -n \\
                        -iex=\"set auto-solib-add off\" \\
                        -p $pid \\
                        --eval-command=\"sharedlibrary libc.so\" \\
                        --eval-command=\"call (void) __libc_dlopen_mode(\\\"/path/to/mylib.so\\\", \\
                                                                        $__RTLD_DLOPEN | $RTLD_NOW)\" \\
                        --eval-command=\"sharedlibrary mylib\" \\
                        --eval-command=\"call (void) attach_init(\\\"/path/to/trace.log\\\")\" \\
                        --eval-command=\"detach\"
                "
            }
            textNote: "- auto-solib-add performance: much improved performance
                       - dlopen only available when linked against libdl
                       - __libc_dlopen_mode quite similar, always available when libc is linked in"
        }
    }
    SlideSet {
        title: "Intercepting Library Calls"
        Slide {
            slideId: 22
            title: "Short Introduction to GOT / PLT"
            text: "* Calls to dynamically shared objects require relocations
                   ** See: https://www.akkadia.org/drepper/dsohowto.pdf
                   * GOT: Global Offset Table
                   ** Writable section for the linker
                   * PLT: Procedure Linkage Table "
        }
        Slide {
            slideId: 23
            title: "Short Introduction to GOT / PLT"
            CppCode {
                code: "
                        int main() {
                            auto *buffer = malloc(100);
                        }"
            }
            Text {
                text: "Relocations can be seen with <tt>readelf</tt>:"
            }
            Code {
                dialect: "Bash"
                code: "$ readelf -r test_clients/one_malloc"
            }
            Code {
                code: "
                        Relocation section '.rela.plt' at offset 0x6b8 contains 2 entries:
                        Offset          Info           Type           Sym. Value    Sym. Name + Addend
                        000000002000  000100000007 R_X86_64_JUMP_SLO 0000000000000000 malloc@GLIBC_2.2.5 + 0"
            }
            Text {
                text: "Indirect calls to <tt>malloc</tt> are visible in the disassembly:"
            }
            Code {
                dialect: "Bash"
                code: "$ objdump -S test_clients/one_malloc"
            }
            Code {
                code: "
                        Disassembly of section .plt:
                        ...
                        0000000000000720 <malloc@plt>:
                        720:   ff 25 da 18 00 00       jmpq   *0x18da(%rip)        # 2000 <malloc@GLIBC_2.2.5>
                        726:   68 00 00 00 00          pushq  $0x0
                        72b:   e9 e0 ff ff ff          jmpq   710 <_init+0x28>
                        ...
                        0000000000000839 <main>:
                        ...
                            auto *buffer = malloc(100);
                        841:   bf 64 00 00 00          mov    $0x64,%edi
                        846:   e8 d5 fe ff ff          callq  720 <malloc@plt>
                        84b:   48 89 45 f8             mov    %rax,-0x8(%rbp) "
            }
        }
        Slide {
            slideId: 24
            id: rebinding
            title: "Dynamic Rebinding For Tracing"
            text: "
                * Iterate over all relocations in all DSOs
                * Check if the symbol name matches one of our trace points
                * If so, overwrite the address in the GOT with the address to our trace point
                "
            CppCode {
                fileName: "../src/got_overwriting/got_overwriting.cpp"
                fileMarker: "slide main"
                visible: rebinding.onlyStep(1)
            }
            CppCode {
                fileName: "../src/got_overwriting/got_overwriting.cpp"
                fileMarker: "slide dl_iterate_phdr"
                visible: rebinding.onlyStep(2)
            }
            CppCode {
                fileName: "../src/got_overwriting/got_overwriting.cpp"
                fileMarker: "slide tables"
                visible: rebinding.onlyStep(3)
            }
            CppCode {
                fileName: "../src/shared/elftable.h"
                fileMarker: "slide table_def"
                visible: rebinding.onlyStep(4)
            }
            CppCode {
                fileName: "../src/shared/elftable.h"
                fileMarker: "slide tables"
                visible: rebinding.onlyStep(5)
            }
            CppCode {
                fileName: "../src/got_overwriting/got_overwriting.cpp"
                fileMarker: "slide relocations"
                visible: rebinding.onlyStep(6)
            }
            CppCode {
                fileName: "../src/got_overwriting/got_overwriting.cpp"
                fileMarker: "slide hook"
                visible: rebinding.onlyStep(7)
            }
            Code {
                title: "got_overwriting"
                code: "
                        $ ./got_overwriting/got_overwriting
                        relocation: malloc: 5604cc5c0038 | 0x7fec64a0e5d0
                        malloc intercepted: 100 -> 0x5604cd0a8ee0"
                visible: rebinding.onlyStep(8)
            }
        }
    }
}
