import SlideViewer 1.0

SlideSet {
    title: "Introduction"
    Slide {
        title: "This Talk"
        text: "This talk
                * is highly platform specific
                ** ELF, DWARF, ld-linux, ...
                * shows lots of dirty tricks
                ** Language lawyers beware!
                * contains information I had to learn the hard way"
    }
    Slide {
        title: "Tracing"
        text: "* Tracing is a useful debugging and profiling technique
               ** perf trace, strace, ltrace, heaptrack, printf-debugging, ..."
        text2: "Need a domain specific custom tracer?
                * Prefer to use existing tracing frameworks:
                ** lttng-ust
                ** perf with sdt / uprobe
                ** LLVM XRay"
    }
    SlideSet {
        title: "heaptrack"
        Slide {
            slideId: 1
            title: "heaptrack"

            topRight: Image {
                source: "images/heaptrack.png"
            }
            text: "Heap memory profiler for Linux
                * https://github.com/KDE/heaptrack"
            text2: "Main goal: better than Massif
                * Cope with millions of allocations per second
                * Low impact on parallel scaling
                * Wealth of data
                ** Track every individual allocation event
                ** Backtrace information
                * Runtime attaching"
        }
        Slide {
            slideId: 2
            title: "heaptrack: obstacles"

            text: "Biggest obstacles
                * Fast stack unwinding
                * Symbol resolution
                * Inline frames
                * Runtime attaching"
        }
        Slide {
            slideId: 3
            title: "heaptrack: main building blocks"

            text: "Main building blocks
                * Stack unwinding: <a href=\"https://github.com/libunwind/libunwind\">libunwind</a>
                * Debug symbols: <a href=\"https://github.com/ianlancetaylor/libbacktrace\">libbacktrace</a>
                * Runtime attaching: <a href=\"https://stackoverflow.com/questions/27137527/overload-symbols-of-running-process-ld-preload-attachment\">GOT manipulation</a>"
        }
    }
    SlideSet {
        title: "hotspot"
        Slide {
            slideId: 4
            title: "hotspot"

            topRight: Image {
                source: "images/hotspot.png"
            }
            text: "GUI for Linux perf
                * https://github.com/KDAB/hotspot"
            text2: "Main goal: easier to use than <tt>perf report</tt>
                * Interactive filtering, sorting
                * Integrated flame graph
                * Advanced analyses (e.g. for off-CPU time)"
        }
        Slide {
            slideId: 5
            title: "hotspot: obstacles"

            text: "Biggest obstacles
                    * Parsing <tt>perf.data</tt> files
                    * Stack unwinding
                    * Symbol resolution
                    * Inline frames"
        }
        Slide {
            slideId: 6
            title: "hotspot: main building blocks"

            text: "Main building blocks
                    * Parsing <tt>perf.data</tt>: <a href=\"https://code.qt.io/cgit/qt-creator/perfparser.git/tree/\">perfparser</a>
                    * Stack unwinding & debug symbols: <a href=\"https://sourceware.org/git/?p=elfutils.git\">elfutils</a>"
        }
    }
}
