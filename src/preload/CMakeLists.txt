add_library(preload SHARED preload.cpp)
target_link_libraries(preload ${CMAKE_DL_LIBS})

configure_file(preload.sh.in ${CMAKE_CURRENT_BINARY_DIR}/preload.sh @ONLY)
