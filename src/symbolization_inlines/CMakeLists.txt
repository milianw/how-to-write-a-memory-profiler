add_executable(symbolization_inlines symbolization.cpp symbolizer.cpp)
target_link_libraries(symbolization_inlines
    ${LIBDW_LIBRARIES}
    ${LIBELF_LIBRARIES}
)
