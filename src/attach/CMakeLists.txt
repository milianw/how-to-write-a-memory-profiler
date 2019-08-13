add_library(attach SHARED attach.cpp)
target_link_libraries(attach
    ${CMAKE_DL_LIBS}
    ${LIBUNWIND_LIBRARY}
    ${CMAKE_THREAD_LIBS_INIT}
)

configure_file(attach.sh.in ${CMAKE_CURRENT_BINARY_DIR}/attach.sh @ONLY)
