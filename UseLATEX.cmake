#
# File: UseLATEX.cmake
# CMAKE commands to actually use the LaTeX compiler
# Version: 1.2.0
# Author: Kenneth Moreland (kmorel at sandia dot gov)
#
# Copyright 2004 Sandia Corporation.
# Under the terms of Contract DE-AC04-94AL85000, there is a non-exclusive
# license for use of this work by or on behalf of the
# U.S. Government. Redistribution and use in source and binary forms, with
# or without modification, are permitted provided that this Notice and any
# statement of authorship are reproduced on all copies.
#
# The following MACROS are defined:
#
# ADD_LATEX_IMAGES(<dir>)
#       Searches <dir> for images files and creates targets that convert
#       them to types that various LaTeX compilers understand.  Makes the
#       targets latex_images_ps and latex_images_pdf.
#
# ADD_LATEX_DOCUMENT(<tex_file> [<image_dir>]
#                       [BIBFILES <bib_files>] [INPUTS <input_tex_files>]
#                       [CONFIGURE] <tex_files>
#                       [USE_INDEX] [DEFAULT_PDF])
#       Adds targets that compile <tex_file>.  It is assumed that
#       ADD_LATEX_IMAGES has been called in <image_dir>.  (Note that the
#       dir parameter is different for the two commands.)  The latex
#       program is picky about where files are located, so all input files
#       are copied from the source directory to the binary directory.  This
#       includes the target tex file, any tex file listed with the INPUTS
#       option, the bibliography files listed with the BIBFILES option, and
#       any .cls, .bst, and .clo files found in the current source
#       directory.  Any tex files also listed with the INPUTS option are
#       also processed with the CMake CONFIGURE_FILE command (with the
#       @ONLY flag.  Any file listed in INPUTS but not the target tex file
#       or listed with INPUTS has no effect.
#
#       The following targets are made:
#               dvi: Makes <name>.dvi
#               pdf: Makes <name>.pdf using pdflatex.
#               safepdf: Makes <name>.pdf using ps2pdf.  If using the default
#                       program arguments, this will ensure all fonts are
#                       embedded and no lossy compression has been performed
#                       on images.
#               ps: Makes <name>.ps
#               html: Makes <name>.html
#               auxclean: Deletes <name>.aux.  This is sometimes necessary
#                       if a LaTeX error occurs and writes a bad aux file.
#
#       If the argument USE_INDEX is given, then commands to build an index
#       are made.
#
# ADD_LATEX_TARGETS(<tex_file> [<image_dir>]
#                       [BIBFILES <bib_files>] [INPUTS <input_tex_files>]
#                       [USE_INDEX])
#       Like ADD_LATEX_DOCUMENT, except no files are configured or copied.
#       The files are assumed to already be added to the binary directory.
#       This varient is helpful if one set of latex files makes different
#       varients of documents.  For example, with building chapters
#       separately from the entire document.
#
# History:
#
# 1.2.0 Changed the configuration options yet again.  Removed the NO_CONFIGURE
#       Replaced it with a CONFIGURE option that lists input files for which
#       configure should be run.
#
#       The pdf target no longer depends on the dvi target.  This allows you
#       to build latex documents that require pdflatex.  Also added an option
#       to make the pdf target the default one.
#
# 1.1.1 Added the NO_CONFIGURE option.  The @ character can be used when
#       specifying table column separators.  If two or more are used, then
#       will incorrectly substitute them.
#
# 1.1.0 Added ability include multiple bib files.  Added ability to do copy
#       sub-tex files for multipart tex files.
#
# 1.0.0 If both ps and pdf type images exist, just copy the one that
#       matches the current render mode.  Replaced a bunch of STRING
#       commands with GET_FILENAME_COMPONENT commands that were made to do
#       the desired function.
#
# 0.4.0 First version posted to CMake Wiki.
#

IF ("${CMAKE_CURRENT_BINARY_DIR}" STREQUAL "${CMAKE_CURRENT_SOURCE_DIR}")
  MESSAGE(SEND_ERROR "LaTeX files must be built out of source.")
ENDIF ("${CMAKE_CURRENT_BINARY_DIR}" STREQUAL "${CMAKE_CURRENT_SOURCE_DIR}")

INCLUDE(${CMAKE_ROOT}/Modules/FindLATEX.cmake)
MARK_AS_ADVANCED(CLEAR
  LATEX_COMPILER
  PDFLATEX_COMPILER
  BIBTEX_COMPILER
  MAKEINDEX_COMPILER
  DVIPS_CONVERTER
  PS2PDF_CONVERTER
  LATEX2HTML_CONVERTER
  )

MACRO(LATEX_NEEDIT VAR NAME)
  IF (NOT ${VAR})
    MESSAGE(SEND_ERROR "I need the ${NAME} command.")
  ENDIF(NOT ${VAR})
ENDMACRO(LATEX_NEEDIT)
MACRO(LATEX_WANTIT VAR NAME)
  IF (NOT ${VAR})
    MESSAGE(STATUS "I could not find the ${NAME} command.")
  ENDIF(NOT ${VAR})
ENDMACRO(LATEX_WANTIT)

LATEX_NEEDIT(LATEX_COMPILER latex)
LATEX_WANTIT(PDFLATEX_COMPILER pdflatex)
LATEX_NEEDIT(BIBTEX_COMPILER bibtex)
LATEX_NEEDIT(MAKEINDEX_COMPILER makeindex)
LATEX_WANTIT(DVIPS_CONVERTER dvips)
LATEX_WANTIT(PS2PDF_CONVERTER ps2pdf)
LATEX_WANTIT(LATEX2HTML_CONVERTER latex2html)

SET(LATEX_COMPILER_FLAGS "-interaction=nonstopmode"
  CACHE STRING "Flags passed to latex.")
SET(PDFLATEX_COMPILER_FLAGS ${LATEX_COMPILER_FLAGS}
  CACHE STRING "Flags passed to pdflatex.")
SET(BIBTEX_COMPILER_FLAGS ""
  CACHE STRING "Flags passed to bibtex.")
SET(MAKEINDEX_COMPILER_FLAGS ""
  CACHE STRING "Flags passed to makeindex.")
SET(DVIPS_CONVERTER_FLAGS "-Ppdf -G0 -t letter"
  CACHE STRING "Flags passed to dvips.")
SET(PS2PDF_CONVERTER_FLAGS "-dMaxSubsetPct=100 -dCompatibilityLevel=1.3 -dSubsetFonts=true -dEmbedAllFonts=true -dAutoFilterColorImages=false -dAutoFilterGrayImages=false -dColorImageFilter=/FlateEncode -dGrayImageFilter=/FlateEncode -dMonoImageFilter=/FlateEncode"
  CACHE STRING "Flags passed to ps2pdf.")
SET(LATEX2HTML_CONVERTER_FLAGS ""
  CACHE STRING "Flags passed to latex2html.")
MARK_AS_ADVANCED(
  LATEX_COMPILER_FLAGS
  PDFLATEX_COMPILER_FLAGS
  BIBTEX_COMPILER_FLAGS
  MAKEINDEX_COMPILER_FLAGS
  DVIPS_CONVERTER_FLAGS
  PS2PDF_CONVERTER_FLAGS
  LATEX2HTML_CONVERTER_FLAGS
  )
SEPARATE_ARGUMENTS(LATEX_COMPILER_FLAGS)
SEPARATE_ARGUMENTS(PDFLATEX_COMPILER_FLAGS)
SEPARATE_ARGUMENTS(BIBTEX_COMPILER_FLAGS)
SEPARATE_ARGUMENTS(MAKEINDEX_COMPILER_FLAGS)
SEPARATE_ARGUMENTS(DVIPS_CONVERTER_FLAGS)
SEPARATE_ARGUMENTS(PS2PDF_CONVERTER_FLAGS)
SEPARATE_ARGUMENTS(LATEX2HTML_CONVERTER_FLAGS)

FIND_PROGRAM(IMAGEMAGICK_CONVERT convert
  DOC "The convert program that comes with ImageMagick (available at http://www.imagemagick.org)."
  )
IF (NOT IMAGEMAGICK_CONVERT)
  MESSAGE(SEND_ERROR "Could not find convert program.  Please download ImageMagick from http://www.imagemagick.org and install.")
ENDIF (NOT IMAGEMAGICK_CONVERT)

OPTION(LATEX_SMALL_IMAGES
  "If on, the raster images will be converted to 1/6 the original size.  This is because papers usually require 600 dpi images whereas most monitors only require at most 96 dpi.  Thus, smaller images make smaller files for web distributation and can make it faster to read dvi files."
  OFF)
IF (LATEX_SMALL_IMAGES)
  SET(LATEX_RASTER_SCALE 16)
  SET(LATEX_OPPOSITE_RASTER_SCALE 100)
ELSE (LATEX_SMALL_IMAGES)
  SET(LATEX_RASTER_SCALE 100)
  SET(LATEX_OPPOSITE_RASTER_SCALE 16)
ENDIF (LATEX_SMALL_IMAGES)

MACRO(LATEX_CAR var)
  SET(${var} ${ARGV1})
ENDMACRO(LATEX_CAR)
MACRO(LATEX_CDR var junk)
  SET(${var} ${ARGN})
ENDMACRO(LATEX_CDR)

MACRO(ADD_LATEX_IMAGES dir)
  FILE(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/${dir})

  # This command just makes sure we rebuild images of LATEX_SMALL_IMAGES
  # changed.
  ADD_CUSTOM_COMMAND(OUTPUT raster_image_rescale_${LATEX_RASTER_SCALE}
    COMMAND ${CMAKE_COMMAND}
    ARGS -E remove raster_image_rescale_${LATEX_OPPOSITE_RASTER_SCALE} \; ${CMAKE_COMMAND} -E echo Built > raster_image_rescale_${LATEX_RASTER_SCALE}
    )

  FILE(GLOB png_file_list ${CMAKE_CURRENT_SOURCE_DIR}/${dir}/*.png)
  FOREACH (png_file ${png_file_list})
    GET_FILENAME_COMPONENT(image_name ${png_file} NAME_WE)
    SET(png_out_file ${CMAKE_CURRENT_BINARY_DIR}/${dir}/${image_name}.png)
    ADD_CUSTOM_COMMAND(OUTPUT ${png_out_file}
      COMMAND ${IMAGEMAGICK_CONVERT}
      ARGS ${png_file} -resize ${LATEX_RASTER_SCALE}% ${png_out_file}
      DEPENDS ${png_file} raster_image_rescale_${LATEX_RASTER_SCALE}
      COMMENT "png image"
      )
    SET(OUT_PNG_FILES ${OUT_PNG_FILES} ${png_out_file})
    IF (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${dir}/${image_name}.eps)
      # An eps file already exists.  No need to convert.
    ELSE (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${dir}/${image_name}.eps)
      SET(eps_file ${CMAKE_CURRENT_BINARY_DIR}/${dir}/${image_name}.eps)
      ADD_CUSTOM_COMMAND(OUTPUT ${eps_file}
        COMMAND ${IMAGEMAGICK_CONVERT}
        ARGS ${png_file} -resize ${LATEX_RASTER_SCALE}% ${eps_file}
        DEPENDS ${png_file} raster_image_rescale_${LATEX_RASTER_SCALE}
        COMMENT "postscript image"
        )
      SET(OUT_EPS_FILES ${OUT_EPS_FILES} ${eps_file})
    ENDIF (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${dir}/${image_name}.eps)
  ENDFOREACH (png_file)

  FILE(GLOB eps_file_list ${CMAKE_CURRENT_SOURCE_DIR}/${dir}/*.eps)
  FOREACH (eps_file ${eps_file_list})
    GET_FILENAME_COMPONENT(image_name ${eps_file} NAME_WE)
    IF (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${dir}/${image_name}.pdf)
      # A pdf file already exists.  No need to convert.
    ELSE (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${dir}/${image_name}.pdf)
      IF (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${dir}/${image_name}.png)
        # A png file already exists.  No need to convert.
      ELSE (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${dir}/${image_name}.png)
        SET(pdf_file ${CMAKE_CURRENT_BINARY_DIR}/${dir}/${image_name}.pdf)
        ADD_CUSTOM_COMMAND(OUTPUT ${pdf_file}
          COMMAND ${IMAGEMAGICK_CONVERT}
          ARGS ${eps_file} ${pdf_file}
          DEPENDS ${eps_file}
          COMMENT "pdf image"
          )
        SET(OUT_PDF_FILES ${OUT_PDF_FILES} ${pdf_file})
      ENDIF (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${dir}/${image_name}.png)
    ENDIF (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${dir}/${image_name}.pdf)
    SET(eps_out_file ${CMAKE_CURRENT_BINARY_DIR}/${dir}/${image_name}.eps)
    ADD_CUSTOM_COMMAND(OUTPUT ${eps_out_file}
      COMMAND ${CMAKE_COMMAND}
      ARGS -E copy ${eps_file} ${eps_out_file}
      DEPENDS ${eps_file}
      COMMENT "postscript image"
      )
    SET(OUT_EPS_FILES ${OUT_EPS_FILES} ${eps_out_file})
  ENDFOREACH (eps_file)

  FILE(GLOB pdf_file_list ${CMAKE_CURRENT_SOURCE_DIR}/${dir}/*.pdf)
  FOREACH (pdf_file ${pdf_file_list})
    GET_FILENAME_COMPONENT(image_name ${pdf_file} NAME_WE)
    SET(pdf_out_file ${CMAKE_CURRENT_BINARY_DIR}/${dir}/${image_name}.pdf)
    ADD_CUSTOM_COMMAND(OUTPUT ${pdf_out_file}
      COMMAND ${CMAKE_COMMAND}
      ARGS -E copy ${pdf_file} ${pdf_out_file}
      DEPENDS ${pdf_file}
      COMMENT "pdf image"
      )
    SET(OUT_PDF_FILES ${OUT_PDF_FILES} ${pdf_out_file})
    IF (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${dir}/${image_name}.eps)
      # An eps file already exists.  No need to convert
    ELSE (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${dir}/${image_name}.eps)
      SET(eps_file ${CMAKE_CURRENT_BINARY_DIR}/${dir}/${image_name}.eps)
      ADD_CUSTOM_COMMAND(OUTPUT ${eps_file}
        COMMAND ${IMAGEMAGICK_CONVERT}
        ARGS ${pdf_file} ${eps_file}
        DEPENDS ${pdf_file}
        COMMENT "postscript image"
        )
      SET(OUT_EPS_FILES ${OUT_EPS_FILES} ${eps_file})
    ENDIF (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${dir}/${image_name}.eps)
  ENDFOREACH (pdf_file)

  ADD_CUSTOM_TARGET(latex_images_ps
    ${CMAKE_COMMAND} -E echo "Building image files for ps documents."
    DEPENDS ${OUT_EPS_FILES}
    )
  ADD_CUSTOM_TARGET(latex_images_pdf
    DEPENDS ${OUT_PNG_FILES} ${OUT_PDF_FILES})
ENDMACRO(ADD_LATEX_IMAGES)


MACRO(LATEX_COPY_GLOBBED_FILES pattern dest)
  FILE(GLOB file_list ${pattern})
  FOREACH(in_file ${file_list})
    GET_FILENAME_COMPONENT(out_file ${in_file} NAME)
    CONFIGURE_FILE(${in_file} ${dest}/${out_file} COPYONLY)
  ENDFOREACH(in_file)
ENDMACRO(LATEX_COPY_GLOBBED_FILES)

MACRO(LATEX_LIST_CONTAINS var value)
  SET(${var})
  FOREACH (value2 ${ARGN})
    IF (${value} STREQUAL ${value2})
      SET(${var} TRUE)
    ENDIF (${value} STREQUAL ${value2})
  ENDFOREACH (value2)
ENDMACRO(LATEX_LIST_CONTAINS)

MACRO(LATEX_PARSE_ARGUMENTS prefix arg_names option_names)
  SET(DEFAULT_ARGS)
  FOREACH(arg_name ${arg_names})
    SET(${prefix}_${arg_name})
  ENDFOREACH(arg_name)
  FOREACH(option ${option_names})
    SET(${prefix}_${option})
  ENDFOREACH(option)

  SET(current_arg_name DEFAULT_ARGS)
  SET(current_arg_list)
  FOREACH(arg ${ARGN})
    LATEX_LIST_CONTAINS(is_arg_name ${arg} ${arg_names})
    IF (is_arg_name)
      SET(${prefix}_${current_arg_name} ${current_arg_list})
      SET(current_arg_name ${arg})
      SET(current_arg_list)
    ELSE (is_arg_name)
      LATEX_LIST_CONTAINS(is_option ${arg} ${option_names})
      IF (is_option)
        SET(${prefix}_${arg} TRUE)
      ELSE (is_option)
        SET(current_arg_list ${current_arg_list} ${arg})
      ENDIF (is_option)
    ENDIF (is_arg_name)
  ENDFOREACH(arg)
  SET(${prefix}_${current_arg_name} ${current_arg_list})
ENDMACRO(LATEX_PARSE_ARGUMENTS)

MACRO(LATEX_USAGE command message)
  MESSAGE(SEND_ERROR
    "${message}\nUsage: ${command}(<tex_file> [<image_dir>]\n           [BIBFILES <bib_file> <bib_file> ...]\n           [INPUTS <tex_file> <tex_file> ...]\n           [CONFIGURE <tex_file> <tex_file> ...]\n           [USE_INDEX] [DEFAULT_PDF])"
    )
ENDMACRO(LATEX_USAGE command message)

# Parses arguments to ADD_LATEX_DOCUMENT and ADD_LATEX_TARGETS and sets the
# variables LATEX_TARGET, LATEX_IMAGE_DIR, LATEX_BIBFILES, and
# LATEX_INPUTS.
MACRO(PARSE_ADD_LATEX_ARGUMENTS command)
  LATEX_PARSE_ARGUMENTS(
    LATEX
    "BIBFILES;INPUTS;CONFIGURE"
    "USE_INDEX;DEFAULT_PDF"
    ${ARGN}
    )

  # The first argument is the target latex file.
  IF (LATEX_DEFAULT_ARGS)
    LATEX_CAR(target ${LATEX_DEFAULT_ARGS})
    LATEX_CDR(LATEX_DEFAULT_ARGS ${LATEX_DEFAULT_ARGS})
    GET_FILENAME_COMPONENT(LATEX_TARGET ${target} NAME_WE)
  ELSE (LATEX_DEFAULT_ARGS)
    LATEX_USAGE(${command} "No tex file target given to ${command}.")
  ENDIF (LATEX_DEFAULT_ARGS)

  # The second argument is the (optional) image dir.
  IF (LATEX_DEFAULT_ARGS)
    LATEX_CAR(LATEX_IMAGE_DIR ${LATEX_DEFAULT_ARGS})
    LATEX_CDR(LATEX_DEFAULT_ARGS ${LATEX_DEFAULT_ARGS})
    IF ("${LATEX_IMAGE_DIR}" STREQUAL NONE)
      # Backward compatibility
      SET(LATEX_IMAGE_DIR)
    ENDIF ("${LATEX_IMAGE_DIR}" STREQUAL NONE)
  ENDIF (LATEX_DEFAULT_ARGS)

  # Old versions of UseLATEX.cmake had a bibtex file as the third argument.
  IF (LATEX_DEFAULT_ARGS)
    IF ("${LATEX_DEFAULT_ARGS}" STREQUAL NONE)
      # Backward compatibility
    ELSE ("${LATEX_DEFAULT_ARGS}" STREQUAL NONE)
      SET(LATEX_BIBFILES ${LATEX_DEFAULT_ARGS})
    ENDIF ("${LATEX_DEFAULT_ARGS}" STREQUAL NONE)
  ENDIF (LATEX_DEFAULT_ARGS)
ENDMACRO(PARSE_ADD_LATEX_ARGUMENTS)

MACRO(ADD_LATEX_TARGETS)
  PARSE_ADD_LATEX_ARGUMENTS(ADD_LATEX_TARGETS ${ARGV})

  IF (LATEX_IMAGE_DIR)
    IF (${LATEX_IMAGE_DIR} MATCHES ^[.]?$)
      # Do not need to do anything, targets should already be made.
    ELSE (${LATEX_IMAGE_DIR} MATCHES ^[.]?$)
      ADD_CUSTOM_TARGET(latex_images_ps
        ${CMAKE_COMMAND} -E chdir ${LATEX_IMAGE_DIR} ${CMAKE_MAKE_PROGRAM} latex_images_ps)
      ADD_CUSTOM_TARGET(latex_images_pdf
        ${CMAKE_COMMAND} -E chdir ${LATEX_IMAGE_DIR} ${CMAKE_MAKE_PROGRAM} latex_images_pdf)
    ENDIF (${LATEX_IMAGE_DIR} MATCHES ^[.]?$)
  ELSE (LATEX_IMAGE_DIR)
    # No image directory.  Fake image targets.
    ADD_CUSTOM_TARGET(latex_images_ps)
    ADD_CUSTOM_TARGET(latex_images_pdf)
  ENDIF (LATEX_IMAGE_DIR)

  SET(make_dvi_command
    ${LATEX_COMPILER} ${LATEX_COMPILER_FLAGS} ${LATEX_TARGET}.tex)
  SET(make_dvi_depends ${LATEX_TARGET}.tex ${LATEX_INPUTS})
  SET(make_pdf_command
    ${PDFLATEX_COMPILER} ${PDFLATEX_COMPILER_FLAGS} ${LATEX_TARGET}.tex)
  SET(make_pdf_depends ${LATEX_TARGET}.tex ${LATEX_INPUTS})

  IF (LATEX_BIBFILES)
    SET(make_dvi_command ${make_dvi_command}
      COMMAND ${BIBTEX_COMPILER} ${BIBTEX_COMPILER_FLAGS} ${LATEX_TARGET})
    SET(make_pdf_command ${make_pdf_command}
      COMMAND ${BIBTEX_COMPILER} ${BIBTEX_COMPILER_FLAGS} ${LATEX_TARGET})
    SET(make_dvi_depends ${make_dvi_depends} ${LATEX_BIBFILES})
    SET(make_pdf_depends ${make_pdf_depends} ${LATEX_BIBFILES})
  ENDIF (LATEX_BIBFILES)

  IF (LATEX_USE_INDEX)
    SET(make_dvi_command ${make_dvi_command}
      COMMAND ${LATEX_COMPILER} ${LATEX_COMPILER_FLAGS} ${LATEX_TARGET}.tex
      COMMAND ${MAKEINDEX_COMPILER} ${MAKEINDEX_COMPILER_FLAGS} ${LATEX_TARGET}.idx)
    SET(make_pdf_command ${make_pdf_command}
      COMMAND ${PDFLATEX_COMPILER} ${PDFLATEX_COMPILER_FLAGS} ${LATEX_TARGET}.tex
      COMMAND ${MAKEINDEX_COMPILER} ${MAKEINDEX_COMPILER_FLAGS} ${LATEX_TARGET}.idx)
  ENDIF (LATEX_USE_INDEX)

  SET(make_dvi_command ${make_dvi_command}
    COMMAND ${LATEX_COMPILER} ${LATEX_COMPILER_FLAGS} ${LATEX_TARGET}.tex
    COMMAND ${LATEX_COMPILER} ${LATEX_COMPILER_FLAGS} ${LATEX_TARGET}.tex)
  SET(make_pdf_command ${make_pdf_command}
    COMMAND ${PDFLATEX_COMPILER} ${PDFLATEX_COMPILER_FLAGS} ${LATEX_TARGET}.tex
    COMMAND ${PDFLATEX_COMPILER} ${PDFLATEX_COMPILER_FLAGS} ${LATEX_TARGET}.tex)

  IF (LATEX_DEFAULT_PDF)
    ADD_CUSTOM_TARGET(dvi ${make_dvi_command})
  ELSE (LATEX_DEFAULT_PDF)
    ADD_CUSTOM_TARGET(dvi ALL ${make_dvi_command})
  ENDIF (LATEX_DEFAULT_PDF)
  ADD_DEPENDENCIES(dvi ${make_dvi_depends} latex_images_ps)

  IF (PDFLATEX_COMPILER)
    IF (LATEX_DEFAULT_PDF)
      ADD_CUSTOM_TARGET(pdf ALL ${make_pdf_command})
    ELSE (LATEX_DEFAULT_PDF)
      ADD_CUSTOM_TARGET(pdf ${make_pdf_command})
    ENDIF (LATEX_DEFAULT_PDF)
    ADD_DEPENDENCIES(pdf ${make_pdf_depends} latex_images_pdf)
  ENDIF (PDFLATEX_COMPILER)

  IF (DVIPS_CONVERTER)
    ADD_CUSTOM_TARGET(ps
      ${DVIPS_CONVERTER} ${DVIPS_CONVERTER_FLAGS} -o ${LATEX_TARGET}.ps ${LATEX_TARGET}.dvi
      )
    ADD_DEPENDENCIES(ps dvi)
    IF (PS2PDF_CONVERTER)
      ADD_CUSTOM_TARGET(safepdf
        ${PS2PDF_CONVERTER} ${PS2PDF_CONVERTER_FLAGS} ${LATEX_TARGET}.ps ${LATEX_TARGET}.pdf
        )
      ADD_DEPENDENCIES(safepdf ps)
    ENDIF (PS2PDF_CONVERTER)
  ENDIF (DVIPS_CONVERTER)

  IF (LATEX2HTML_CONVERTER)
    ADD_CUSTOM_TARGET(html
      ${LATEX2HTML_CONVERTER} ${LATEX2HTML_CONVERTER_FLAGS} ${LATEX_TARGET}.tex
      )
    ADD_DEPENDENCIES(html ${LATEX_TARGET}.tex ${LATEX_INPUTS})
  ENDIF (LATEX2HTML_CONVERTER)

  ADD_CUSTOM_TARGET(auxclean
    ${CMAKE_COMMAND} -E remove ${LATEX_TARGET}.aux ${LATEX_TARGET}.idx ${LATEX_TARGET}.ind
    )
ENDMACRO(ADD_LATEX_TARGETS)

MACRO(LATEX_COPY_TEX_FILE file)
  GET_FILENAME_COMPONENT(file_we ${file} NAME_WE)
  LATEX_LIST_CONTAINS(use_config1 ${file_we} ${LATEX_CONFIGURE})
  LATEX_LIST_CONTAINS(use_config2 ${file_we}.tex ${LATEX_CONFIGURE})
  IF (use_config1 OR use_config2)
    SET(latex_config_flags @ONLY)
  ELSE (use_config1 OR use_config2)
    SET(latex_config_flags COPYONLY)
  ENDIF (use_config1 OR use_config2)
  CONFIGURE_FILE(${CMAKE_CURRENT_SOURCE_DIR}/${file_we}.tex
    ${file_we}.tex
    ${latex_config_flags}
    )
  ADD_CUSTOM_TARGET(${file_we}.tex
    ${CMAKE_COMMAND} .
    DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/${file_we}.tex
    )
ENDMACRO(LATEX_COPY_TEX_FILE)

MACRO(ADD_LATEX_DOCUMENT)
  PARSE_ADD_LATEX_ARGUMENTS(ADD_LATEX_DOCUMENT ${ARGV})

  LATEX_COPY_TEX_FILE(${LATEX_TARGET})

  FOREACH (bib_file ${LATEX_BIBFILES})
    CONFIGURE_FILE(${CMAKE_CURRENT_SOURCE_DIR}/${bib_file}
      ${bib_file}
      COPYONLY)
    ADD_CUSTOM_TARGET(${bib_file}
      ${CMAKE_COMMAND} .
      DEPENDS ${CMAKE_CURRENT_SOURCE_DIR}/${bib_file}
      )
  ENDFOREACH (bib_file)

  FOREACH (input ${LATEX_INPUTS})
    LATEX_COPY_TEX_FILE(${input})
  ENDFOREACH(input)

  LATEX_COPY_GLOBBED_FILES(${CMAKE_CURRENT_SOURCE_DIR}/*.cls .)
  LATEX_COPY_GLOBBED_FILES(${CMAKE_CURRENT_SOURCE_DIR}/*.bst .)
  LATEX_COPY_GLOBBED_FILES(${CMAKE_CURRENT_SOURCE_DIR}/*.clo .)

  ADD_LATEX_TARGETS(${ARGV})
ENDMACRO(ADD_LATEX_DOCUMENT)
