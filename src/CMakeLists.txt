cmake_minimum_required(VERSION 3.1.0)
project(HowToWriteAHeapMemoryProfiler)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED On)

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wpedantic")

add_subdirectory(test_clients)

add_subdirectory(preload)
