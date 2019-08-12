add_library(preload_mappings SHARED preload_mappings.cpp)
target_link_libraries(preload_mappings
    ${CMAKE_DL_LIBS}
    ${LIBUNWIND_LIBRARY}
    ${CMAKE_THREAD_LIBS_INIT}
)

configure_file(preload_mappings.sh.in ${CMAKE_CURRENT_BINARY_DIR}/preload_mappings.sh @ONLY)
