# Per https://www.adacore.com/uploads/technical-papers/Stack_Analysis.pdf
cmake_minimum_required( VERSION "3.21" )

if ( CMAKE_CXX_COMPILER_ID STREQUAL "GNU" )
  # using GCC
  add_compile_options( -fcallgraph-info -fstack-usage )
elseif ( CMAKE_CXX_COMPILER_ID MATCHES "Clang" )
  # TODO: Check for variants
  message( "Stack usage is not supported yet under ${CMAKE_CXX_COMPILER_ID}" )
else()
  message( "Stack usage is not supported yet under ${CMAKE_CXX_COMPILER_ID}" )
endif()

# ADSP = Analog VisualDSP++ (analog.com)
# ARMCC = ARM Compiler (arm.com)
# ARMClang = ARM Compiler based on Clang (arm.com)
# Absoft = Absoft Fortran (absoft.com)
# AppleClang = Apple Clang (apple.com)
# Bruce = Bruce C Compiler
# CCur = Concurrent Fortran (ccur.com)
# Clang = LLVM Clang (clang.llvm.org)
# Cray = Cray Compiler (cray.com)
# Embarcadero, Borland = Embarcadero (embarcadero.com)
# Flang = Flang LLVM Fortran Compiler
# Fujitsu = Fujitsu HPC compiler (Trad mode)
# FujitsuClang = Fujitsu HPC compiler (Clang mode)
# G95 = G95 Fortran (g95.org)
# GHS = Green Hills Software (www.ghs.com)
# GNU = GNU Compiler Collection (gcc.gnu.org)
# HP = Hewlett-Packard Compiler (hp.com)
# IAR = IAR Systems (iar.com)
# IBMClang = IBM LLVM-based Compiler (ibm.com)
# Intel = Intel Compiler (intel.com)
# IntelLLVM = Intel LLVM-Based Compiler (intel.com)
# LCC = MCST Elbrus C/C++/Fortran Compiler (mcst.ru)
# MSVC = Microsoft Visual Studio (microsoft.com)
# NVHPC = NVIDIA HPC SDK Compiler (nvidia.com)
# NVIDIA = NVIDIA CUDA Compiler (nvidia.com)
# OpenWatcom = Open Watcom (openwatcom.org)
# PGI = The Portland Group (pgroup.com)
# PathScale = PathScale (pathscale.com)
# SDCC = Small Device C Compiler (sdcc.sourceforge.net)
# SunPro = Oracle Solaris Studio (oracle.com)
# TI = Texas Instruments (ti.com)
# TinyCC = Tiny C Compiler (tinycc.org)
# XL, VisualAge, zOS = IBM XL (ibm.com)
# XLClang = IBM Clang-based XL (ibm.com)

# vim:nospell
