import SlideViewer 1.0

SlideSet {
    title: "Introduction"
    Slide {
        slideId: 7
        title: "This Talk"
        text: "This talk
                * Isn't really about C++
                * Demystifies some central tooling aspects
                * Contains information I had to learn the hard way
                * Is highly platform specific
                ** ELF, DWARF, ld-linux, ...
                * Shows lots of dirty details
                ** Language lawyers beware!
                "
        Space { height: 50 }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            noAnchor: true
            width: 700
            text: "https://github.com/milianw/how-to-write-a-memory-profiler"
        }
    }
    Slide {
        slideId: 9
        title: "How I Learned All This"
        Row {
            Text {
                noAnchor: true
                text: "* heaptrack: heap memory profiler for linux
                       ** May 2013
                       ** https://github.com/KDE/heaptrack
                       "
            }
            Image {
                source: "images/heaptrack.png"
            }
        }
        Space { height: 50 }
        Row {
            Text {
                noAnchor: true
                text: "* hotspot & perfparser: Linux perf GUI
                       ** December 2016
                       ** https://github.com/KDAB/hotspot
                       ** https://code.qt.io/qt-creator/perfparser.git
                       "
            }
            Image {
                source: "images/hotspot.png"
            }
        }
    }
    Slide {
        slideId: 8
        title: "Tracing"
        text: "* Tracing is a useful debugging and profiling technique
               ** perf trace, strace, ltrace, heaptrack, printf-debugging, ...
               * Requirements for a useful tracer:
               ** Cope with thousands or even millions of trace events per second
               ** Ideally zero overhead when not used
               ** Support for runtime attaching or similar"
        Space { height: 50 }
        Text {
            text: "Need to build a domain specific custom tracer?
                    * Prefer to use existing tracing frameworks:
                    ** perf with sdt / uprobe
                    ** lttng-ust
                    ** LLVM XRay"
        }
    }
    Slide {
        slideId: 6
        title: "So What Do We Want To Achieve?"
        text: "
            * Inject custom code into a (running) application
            * Intercept all calls to heap (de)allocation functions
            * Annotate every (de)allocation event with a backtrace
            * Post-process the data to symbolize the backtrace
            "
    }
    Slide {
        slideId: 10
        title: "Memory Allocations"
        text: "What is allocating dynamic storage (i.e. heap memory)?
               * In <tt>libc</tt>:
               ** <tt>malloc</tt>, <tt>free</tt>
               ** <tt>realloc</tt>, <tt>calloc</tt>
               ** <tt>posix_memalign</tt>, <tt>aligned_alloc</tt>, <tt>valloc</tt>
               * In <tt>libstdc++</tt> / <tt>libc++</tt>:
               ** <tt>operator new</tt>, <tt>operator new[]</tt>
               ** <tt>operator delete</tt>, <tt>operator delete[]</tt>
               ** Each with a couple of overloads, e.g. <tt>std::align_val_t</tt>
               * In custom allocator implementations:
               ** <tt>sbrk</tt>, <tt>mmap</tt> with <tt>MAP_ANONYMOUS</tt>"
    }
}
