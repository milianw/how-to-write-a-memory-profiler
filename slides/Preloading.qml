import SlideViewer 1.0

SlideSet {
    title: "Preloading"
    Slide {
        text: "* <tt>LD_PRELOAD</tt>
            * <tt>dlsym</tt> + <tt>-ldl</tt>
            ** <tt>reinterpret_cast</tt>
            ** ODR violations
            ** make sure to use the absolute path
            * hard to debug
            ** cannot use valgrind / sanitizers
            * various malloc-related functions"
    }
}
