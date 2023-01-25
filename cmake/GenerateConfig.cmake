function (generate_config source_directory output_directory)
  find_file (GENERATE_CONFIG generate_config.py ${source_directory}/kconfig)
  message (STATUS "KConfig generator: ${GENERATE_CONFIG}")
    execute_process(
        COMMAND ${CMAKE_COMMAND} -E env
          srctree=${source_directory}
          BOARD_DIR=${source_directory}/boards/**
           ${GENERATE_CONFIG} --input ${output_directory}/.config --output ${output_directory} --kconfig ${source_directory}/Kconfig
        RESULT_VARIABLE rc
    )

    if (${rc})
        message (FATAL_ERROR "Generation of config from KConfig failed")
    endif ()

    set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS ${GENERATE_CONFIG})
    set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS ${output_directory}/.config)
    set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS ${output_directory}/config.cmake)
    set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS ${output_directory}/config.json)
    include (${output_directory}/config.cmake)

    set_source_files_properties(${output_directory}/config.cmake PROPERTIES
        GENERATED TRUE
    )

  file(GLOB config ${output_directory}/.config)
  if(NOT config)
    message(STATUS "Command: ${command}")
    execute_process(
      COMMAND
        ${CMAKE_COMMAND} -E env srctree=${source_directory} BOARD_DIR=boards/**
        ${Python3_EXECUTABLE} ${source_directory}/kconfig/kconfig/guiconfig.py
        ${source_directory}/Kconfig COMMAND_ERROR_IS_FATAL ANY)
  endif()

  add_custom_target(
    menuconfig
    COMMAND
      ${CMAKE_COMMAND} -E env srctree=${source_directory} BOARD_DIR=boards/**
      ${Python3_EXECUTABLE} ${source_directory}/kconfig/kconfig/menuconfig.py
      ${source_directory}/Kconfig
    VERBATIM)

  
endfunction()


