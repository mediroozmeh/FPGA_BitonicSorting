

### Some useful information to run and synthesize Bitonic Sorting algorithm on FPGAs:

__sdaccel.tcl__ : This tcl file is used to run software simulation, hardware emulation and synthesize the source code. Furthermore, maximizing memory ports and generating multiple compute unit are implemented using this tcl file.

__BitonicSort.cl__ : This file includes all four kernels which describe and model bitonic-sorting algorithm, different version of kernels are also available in the directory(e.g., BitonicSort_default.cl ,BitonicSort_fully_optimized.cl) which are different in terms of how they are optimized.

__main.cpp and hostcode.cpp__: This two files are writing into the kernels, before execution on specified platform, and write back data to global memory when execution is complete.


__Key Parameters in Bitonic Sorting Algorithm__ :














 

