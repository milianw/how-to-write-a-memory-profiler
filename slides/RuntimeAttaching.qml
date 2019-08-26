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
}
