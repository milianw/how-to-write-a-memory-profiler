import SlideViewer 1.0

SlideSet {
    title: "Stack Unwinding"
    Slide {
        slideId: 30
        title: "Stack Unwinding"
        text: "* We need to unwind the stack to get a backtrace
               * Approaches:
               ** Frame pointer unwinding (requires <tt>-fno-omit-frame-pointer</tt>)
               ** Use exception unwind tables (<tt>.eh_frame</tt> or <tt>.ARM.exidx</tt> sections)
               ** DWARF debug information (<tt>.debug_frame</tt> section)
               ** Alternatives:
               *** Intel LBR (often too shallow)
               *** Shadow Stack (https://github.com/nokia/not-perf)"
    }

    Slide {
        slideId: 31
        title: "Backtrace Libraries"
        text: "* libc's <tt>backtrace</tt> depends on frame pointers
               * elfutils <tt>dwfl_thread_getframes</tt> is complex to use
               * libunwind is easy to use, fast and feature rich
               ** https://github.com/libunwind/libunwind"
    }

    Slide {
        slideId: 32
        title: "Using libunwind"
        id: trace
        text: "Using libunwind is trivial:"
        CppCode {
            code: "
                #define UNW_LOCAL_ONLY
                #include <libunwind.h>

                std::vector<void*> backtrace()
                {
                    const auto MAX_SIZE = 64;
                    std::vector<void *> trace(MAX_SIZE);
                    const auto size = unw_backtrace(trace.data(), MAX_SIZE);
                    trace.resize(size);
                    return trace;
                }"
        }
        Text {
            visible: trace.minStep(1)
            text: "But the output isn't really useable as-is:"
        }
        Code {
            visible: trace.minStep(1)
            dialect: "Bash"
            code: "$ ./backtrace/preload_backtrace.sh ./test_clients/vector "
        }
        Code {
            visible: trace.minStep(1)
            code: "
                    0x7f37c70ea63c
                    0x7f37c6f53ac9
                    0x562c61aa1ca1
                    0x562c61aa1ad0
                    0x7f37c6bb4ee2
                    0x562c61aa1b5d"
        }
    }
}
