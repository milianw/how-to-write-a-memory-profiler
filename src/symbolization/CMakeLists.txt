add_executable(symbolization symbolization.cpp symbolizer.cpp)
target_link_libraries(symbolization
    ${LIBDW_LIBRARIES}
    ${LIBELF_LIBRARIES}
)
