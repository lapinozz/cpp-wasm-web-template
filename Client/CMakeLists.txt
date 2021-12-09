cmake_minimum_required(VERSION 3.15)

project(fueros_client)
set(CMAKE_CXX_STANDARD 20)
add_compile_options(-std=c++20)
set(CMAKE_CXX_FLAGS_RELEASE -O3)
#Generates the debug symbols for in browser source debugging.
set(CMAKE_CXX_FLAGS_DEBUG "-gsource-map --source-map-base /debug/")
#Build the client as a wasm file.

set(SRC_PATH ${PROJECT_SOURCE_DIR}/src/cpp)
file(GLOB SRC_FILES ${SRC_PATH}/*.cpp)
file(GLOB HEADER_FILES ${SRC_PATH}/*.hpp)

set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS ${SRC_FILES} ${HEADER_FILES})

set(files_content "")
foreach(file_path IN LISTS SRC_FILES HEADER_FILES)
	file(READ ${file_path} file_content)
	set(files_content "${files_content}\n${file_content}")
endforeach()

#EM_EXPORT STUFF
set(EXPORT_REGEX "EM_EXPORT ([A-Za-z0-9_]+)")

set(EXPORT_MATCHES "")
string(REGEX MATCHALL ${EXPORT_REGEX} EXPORT_MATCHES ${files_content})

foreach(MATCH IN LISTS EXPORT_MATCHES)
	string(REGEX REPLACE ${EXPORT_REGEX} "'_\\1'" MATCH ${MATCH})
	list(APPEND EXPORT_LIST ${MATCH})
endforeach()

list(JOIN EXPORT_LIST ", " EXPORT_LIST)

add_executable(client ${SRC_FILES})
set(CMAKE_EXECUTABLE_SUFFIX ".wasm.js")
set_target_properties(client PROPERTIES LINK_FLAGS "--bind -s WASM=1 -s ENVIRONMENT=web -s MODULARIZE=1 -s \"EXPORTED_FUNCTIONS=[${EXPORT_LIST}]\"")
