
### Some useful information to run and synthesize Bitonic Sorting algorithm on FPGAs:

__sdaccel.tcl__ : This tcl file is used to run software simulation, hardware emulation and synthesize the source code. Furthermore, maximizing memory ports and generating multiple compute unit are implemented using this tcl file.

__BitonicSort.cl__ : This file includes all four kernels which describe and model bitonic-sorting algorithm, different version of kernels are also available in the same directory(e.g. BitonicSort_default.cl ,BitonicSort_fully_optimized.cl) which are different in terms of how they are optimized.

__main.cpp and hostcode.cpp__: This two files are writing input into the kernels, before execution on specified platform, and write back output to global memory when execution is complete.

__param.h__ :  This header file is shared between different source files which provides easy modification of key parameters.







__Key Parameters in Bitonic Sorting Algorithm__ :




|    Parameter      |  Value      | Description    |   
|----------|:-------------:|------:|
|  arrayLength        |  LOCAL_SIZE_LIMIT * LOCAL_SIZE_LIMIT | Number of array elements  |
|  Global Size        |  arrayLength / 2 | Total size of the problem for each kernel  |
|  Local Size         |  LOCAL_SIZE_LIMIT / 2 |  Local size of each workgroup for each kernel |



![sorting_network](https://github.com/mediroozmeh/Bitonic-Sorting/blob/master/Figures/total_number.jpeg)
















 

