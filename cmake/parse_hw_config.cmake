cmake_minimum_required(VERSION 3.19)

function(process_hw_configuration_file root_dir)
  message(STATUS "Processing configuration for board: ${BOARD}")
  file(READ ${root_dir}/boards/${BOARD}/board_configuration.json
       board_configuration_json)
  string(JSON cpu_name GET ${board_configuration_json} "cpu")
  set(cpu_name
      ${cpu_name}
      PARENT_SCOPE)

  file(READ ${root_dir}/cpu/${cpu_name}/cpu_config.json
       cpu_configuration_json)

  string(JSON cpu_architecture GET ${cpu_configuration_json} "arch")
  set(cpu_architecture
      ${cpu_architecture}
      PARENT_SCOPE)

  file(READ ${root_dir}/arch/${cpu_architecture}/arch_config.json
       arch_configuration_json)
  string(JSON cpu_type GET ${arch_configuration_json} "type")
  set(cpu_type
      ${cpu_type}
      PARENT_SCOPE)

  set(CMAKE_MODULE_PATH
      ${CMAKE_MODULE_PATH} ${root_dir}/arch/${cpu_type}/cmake
      ${root_dir}/cpu/${cpu_name}/cmake
      PARENT_SCOPE)

  include(${root_dir}/cpu/${cpu_name}/cmake/Platform/${cpu_name}.cmake)
endfunction()
