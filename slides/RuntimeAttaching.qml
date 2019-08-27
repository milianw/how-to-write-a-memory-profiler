import SlideViewer 1.0

SlideSet {
    title: "Runtime Attaching"
    Slide {
        text: "* gdb attach and then call custom code
               * auto-solib-add performance
               * dlopen vs. libc's internal dlopen (-ldl)
               * pipe output forwarding
               * GOT / PLT, cf. https://www.akkadia.org/drepper/dsohowto.pdf and https://stackoverflow.com/questions/27137527/overload-symbols-of-running-process-ld-preload-attachment"
    }
    SlideSet {
        title: "GOT / PLT"
        Slide {
            title: "Short Introduction to GOT / PLT"
            text: "* Calls to dynamically shared objects require relocations
                   ** See: https://www.akkadia.org/drepper/dsohowto.pdf
                   * GOT: Global Offset Table
                   ** Writable section for the linker
                   * PLT: Procedure Linkage Table "
        }
        Slide {
            title: "Short Introduction to GOT / PLT"
            CppCode {
                fileName: "../src/test_clients/one_malloc.cpp"
            }
            Code {
                dialect: "Bash"
                code: "$ objdump -S one_malloc
                ...
                Disassembly of section .plt:
                ...
                0000000000000720 <malloc@plt>:
                720:   ff 25 da 18 00 00       jmpq   *0x18da(%rip)        # 2000 <malloc@GLIBC_2.2.5>
                726:   68 00 00 00 00          pushq  $0x0
                72b:   e9 e0 ff ff ff          jmpq   710 <_init+0x28>
                ...
                0000000000000839 <main>:
                ...
                int main()
                {
                839:   55                      push   %rbp
                83a:   48 89 e5                mov    %rsp,%rbp
                83d:   48 83 ec 10             sub    $0x10,%rsp
                //--> slide
                    auto *buffer = malloc(100);
                841:   bf 64 00 00 00          mov    $0x64,%edi
                846:   e8 d5 fe ff ff          callq  720 <malloc@plt>
                84b:   48 89 45 f8             mov    %rax,-0x8(%rbp)
                //<-- slide
                "
            }
        }
    }
}
