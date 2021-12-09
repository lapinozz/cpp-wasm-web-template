#When calling the cmake command, or in your IDE cmake options:
#Set -DCLIENT_BUILD_CMAKE_TOOLCHAIN="<EmscriptenRoot>/cmake/Modules/Platform/Emscripten.cmake" where "EmscriptenRoot" is your Emscripten SDK
#location.
include("cmake/GetEmscripten.cmake")

if(WIN32)
    set(CLIENT_BUILD_MAKEFILES "MinGW Makefiles")
    include("cmake/GetMingw.cmake")
else()
    set(CLIENT_BUILD_MAKEFILES "Unix Makefiles")
endif()
#Client directory setup.
string(TOLOWER "${CMAKE_BUILD_TYPE}" CLIENT_BUILD_DIR)
set(CLIENT_BUILD_DIR "${CMAKE_CURRENT_BINARY_DIR}/client-build-${CLIENT_BUILD_DIR}")
file(MAKE_DIRECTORY "${CLIENT_BUILD_DIR}")
#Generate client make files.
message("Configuring client project " ${CLIENT_BUILD_DIR})
execute_process(COMMAND ${CMAKE_COMMAND} "-DCMAKE_TOOLCHAIN_FILE=${EMSCRIPTEN_TOOLCHAIN}"
                                         "-DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}"
                                         "-G" "${CLIENT_BUILD_MAKEFILES}"
                                         "-DCMAKE_SH=SH-NOTFOUND"
                                         "${CLIENT_SOURCE_DIR}"
                WORKING_DIRECTORY "${CLIENT_BUILD_DIR}")
#Build the client.
add_custom_target(build-client ALL COMMAND ${CMAKE_COMMAND} "--build" "${CLIENT_BUILD_DIR}" "--target" "all")
#Copy the built client to a folder in the server build directory.

list(APPEND CLIENT_WASM_FILES "${CLIENT_BUILD_DIR}/client.wasm.js")
list(APPEND CLIENT_WASM_FILES "${CLIENT_BUILD_DIR}/client.wasm.wasm")

set(CLIENT_CONTENT_DIR  "${CLIENT_SOURCE_DIR}/content/")

set(CLIENT_WASM_OUT_DIR "${CLIENT_CONTENT_DIR}/wasm")

add_custom_target(copy-client ALL 
    COMMAND ${CMAKE_COMMAND} "-E" "make_directory" "${CLIENT_WASM_OUT_DIR}"
    COMMAND ${CMAKE_COMMAND} "-E" "copy_if_different" ${CLIENT_WASM_FILES} "${CLIENT_WASM_OUT_DIR}")
add_dependencies(copy-client build-client)

add_custom_target(client-all DEPENDS build-client copy-client)

if(${CMAKE_BUILD_TYPE} MATCHES "Debug")

    set(DEBUG_OUT_DIR "${CLIENT_CONTENT_DIR}/debug")

    add_custom_target(copy-debug-map ALL 
        COMMAND ${CMAKE_COMMAND} "-E" "make_directory" "${DEBUG_OUT_DIR}"
        COMMAND ${CMAKE_COMMAND} "-E" "copy" "${CLIENT_BUILD_DIR}/client.wasm.wasm.map" "${DEBUG_OUT_DIR}")
    add_dependencies(copy-debug-map copy-client)
    add_custom_target(copy-debug-src ALL 
        COMMAND ${CMAKE_COMMAND} "-E" "make_directory" "${DEBUG_OUT_DIR}"
        COMMAND ${CMAKE_COMMAND} "-E" "copy_directory" "${CLIENT_SOURCE_DIR}/src/cpp" "${DEBUG_OUT_DIR}/src/cpp")
    add_dependencies(copy-debug-src copy-client)

    add_dependencies(client-all copy-debug-src)
    add_dependencies(client-all copy-debug-map)
endif()


#[[
#set(CLIENT_OUT_DIR "$<TARGET_FILE_DIR:server>/Client")
set(CLIENT_WASM_OUT_DIR "${CLIENT_OUT_DIR}/wasm")
set(CLIENT_CONTENT_OUT_DIR "${CLIENT_OUT_DIR}")

add_custom_target(copy-client ALL 
    COMMAND ${CMAKE_COMMAND} "-E" "copy_directory" "${CLIENT_CONTENT_DIR}" "${CLIENT_CONTENT_OUT_DIR}"
    COMMAND ${CMAKE_COMMAND} "-E" "make_directory" "${CLIENT_WASM_OUT_DIR}"
    COMMAND ${CMAKE_COMMAND} "-E" "copy_if_different" ${CLIENT_WASM_FILES} "${CLIENT_WASM_OUT_DIR}")
add_dependencies(copy-client build-client)

add_custom_target(client-all DEPENDS build-client copy-client)

if(${CMAKE_BUILD_TYPE} MATCHES "Debug")

    set(DEBUG_OUT_DIR "${CLIENT_OUT_DIR}/debug")

    add_custom_target(copy-debug-map ALL 
		COMMAND ${CMAKE_COMMAND} "-E" "make_directory" "${DEBUG_OUT_DIR}"
		COMMAND ${CMAKE_COMMAND} "-E" "copy" "${CLIENT_BUILD_DIR}/client.wasm.wasm.map" "${DEBUG_OUT_DIR}")
    add_dependencies(copy-debug-map copy-client)
    add_custom_target(copy-debug-src ALL 
		COMMAND ${CMAKE_COMMAND} "-E" "make_directory" "${DEBUG_OUT_DIR}"
    	COMMAND ${CMAKE_COMMAND} "-E" "copy_directory" "${CLIENT_SOURCE_DIR}/src/cpp" "${DEBUG_OUT_DIR}/src/cpp")
    add_dependencies(copy-debug-src copy-client)

    add_dependencies(client-all copy-debug-src)
    add_dependencies(client-all copy-debug-map)
endif()
]]