import SlideViewer 1.0

SlideSet {
    title: "Introduction"
    Slide {
        slideId: 7
        title: "This Talk"
        text: "This talk
                * Is highly platform specific
                ** ELF, DWARF, ld-linux, ...
                * Shows lots of dirty tricks
                ** Language lawyers beware!
                * Contains information I had to learn the hard way"
    }
    Slide {
        slideId: 9
        title: "How I Learned All This"
        Row {
            Text {
                noAnchor: true
                text: "* heaptrack: heap memory profiler for linux
                       ** https://github.com/KDE/heaptrack
                       ** In-process backtrace generation with libunwind
                       ** Runtime attaching"
            }
            Image {
                source: "images/heaptrack.png"
            }
        }
        Space { height: 50 }
        Row {
            Text {
                noAnchor: true
                text: "* perfparser & hotspot: Linux perf GUI
                       ** https://github.com/KDAB/hotspot
                       ** Out-of-process symbol resolution with elfutils / libdwfl"
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
               ** Close to zero overhead when not used
               ** Runtime attaching or similar"
        text2: "Need to build a domain specific custom tracer?
                * Prefer to use existing tracing frameworks:
                ** lttng-ust
                ** perf with sdt / uprobe
                ** LLVM XRay"
    }
}
