add_executable(symbolization_clang symbolization.cpp symbolizer.cpp)
target_link_libraries(symbolization_clang
    ${LIBDW_LIBRARIES}
    ${LIBELF_LIBRARIES}
)
