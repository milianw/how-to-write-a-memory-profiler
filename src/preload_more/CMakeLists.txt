add_library(preload_more SHARED preload_more.cpp)
target_link_libraries(preload_more ${CMAKE_DL_LIBS})

configure_file(preload_more.sh.in ${CMAKE_CURRENT_BINARY_DIR}/preload_more.sh @ONLY)
