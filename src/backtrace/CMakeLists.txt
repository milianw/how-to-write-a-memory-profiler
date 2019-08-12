include_directories(
    ${LIBUNWIND_INCLUDE_DIR}
)

add_library(preload_backtrace SHARED preload_backtrace.cpp)
target_link_libraries(preload_backtrace
    ${CMAKE_DL_LIBS}
    ${LIBUNWIND_LIBRARY}
    ${CMAKE_THREAD_LIBS_INIT}
)

configure_file(preload_backtrace.sh.in ${CMAKE_CURRENT_BINARY_DIR}/preload_backtrace.sh @ONLY)
