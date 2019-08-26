add_library(preload_interning SHARED preload_interning.cpp)
target_link_libraries(preload_interning
    ${CMAKE_DL_LIBS}
    ${LIBUNWIND_LIBRARY}
    ${CMAKE_THREAD_LIBS_INIT}
)

configure_file(preload_interning.sh.in ${CMAKE_CURRENT_BINARY_DIR}/preload_interning.sh @ONLY)
