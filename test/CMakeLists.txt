file(GLOB sources "*.cpp")
file(GLOB headers "*.h")

file(GLOB contracts_sources "contracts/*.cpp")
file(GLOB contracts_headers "contracts/*.h")
file(GLOB libdevcore_sources "libdevcore/*.cpp")
file(GLOB libdevcore_headers "libdevcore/*.h")
file(GLOB libvvmasm_sources "libvvmasm/*.cpp")
file(GLOB libvvmasm_headers "libvvmasm/*.h")
file(GLOB libjulia_sources "libjulia/*.cpp")
file(GLOB libjulia_headers "libjulia/*.h")
file(GLOB liblll_sources "liblll/*.cpp")
file(GLOB liblll_headers "liblll/*.h")
file(GLOB libsolidity_sources "libsolidity/*.cpp")
file(GLOB libsolidity_headers "libsolidity/*.h")

add_executable(soltest ${sources} ${headers}
    ${contracts_sources} ${contracts_headers}
    ${libdevcore_sources} ${libdevcore_headers}
    ${libvvmasm_sources} ${libvvmasm_headers}
    ${libjulia_sources} ${libjulia_headers}
    ${liblll_sources} ${liblll_headers}
    ${libsolidity_sources} ${libsolidity_headers}
)
target_link_libraries(soltest PRIVATE libsolc solidity lll vvmasm devcore ${Boost_UNIT_TEST_FRAMEWORK_LIBRARIES})

add_subdirectory(tools)
