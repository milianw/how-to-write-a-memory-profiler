add_library(attach_intercept SHARED attach_intercept.cpp)
target_link_libraries(attach_intercept
    ${CMAKE_DL_LIBS}
    ${LIBUNWIND_LIBRARY}
    ${CMAKE_THREAD_LIBS_INIT}
)

configure_file(attach_intercept.sh.in ${CMAKE_CURRENT_BINARY_DIR}/attach_intercept.sh @ONLY)
