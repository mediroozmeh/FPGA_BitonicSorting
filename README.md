## High Level Synthesis of Bitonic Sorting Algorithm:

In this experiment OpenCL description of bitonic sorting algorithm is used as a source code to be synthesized by SDAccel targeting xilinx FPGAs. However, same source code is run on GPU as a competitive platform of FPGA but the main goal of this experiment is to go through and complete FPGA design flow using SDAccel and explore its capabilities.

### Legal Status 
OpenCL source code of this work is chosen from NVIDIA OpenCL examples repository. Modification and optimization are done in order to generate high performance RTL.

### Brief Analysis of Bitonic Sorting Algorithm:

Sorting a list of input numbers is one of the most fundamental problems in the field of computer science in general and high-throughput database applications in particular. Among various versions of the sorting algorithms, bitonic sorting is one of the fastest sorting networks. A sorting network is a special type of sorting algorithm, where the sequence of comparisons are not data-dependent thus making it suitable for hardware implementation. This sorting network consists of D(N) comparators (where N is the number of inputs). A comparator is a building block of sorting network and it sorts a pair of values presents on inputs. 

![sorting_network](https://github.com/mediroozmeh/Bitonic-Sorting/blob/master/Figures/sorting_network.jpeg)
 
 Efficiency of sorting network depends on the depth and the number of comparators. The depth is defined as the maximum number of comparators along any path from input to output. Assuming that all comparisons on each level of the network are done in parallel, the depth of the network defines the number of steps, and with that also the sorting time needed to sort all of N numbers on the inputs and thus defines the complexity of the sorting network. Bitonic mergesort network is one of the fastest comparison sorting network with the following formulas representing the depth and number of comparators:
 
 D(N)= (log<sub>2</sub> N.(log<sub>2</sub> N+1)) / 2              ---->  Depth of sorting network
 

 C(N)= (N.log<sub>2</sub> N.(log<sub>2</sub>N+1)) / 4            ---->  Number of Comparator

Following figure illustrates a Bitonic Merge sort network with eight inputs (N=8). It operates in 3 stages, it has a depth of 6(steps) and employs 24 comparators.

![sorting_network] (https://github.com/mediroozmeh/Bitonic-Sorting/blob/master/Figures/Bitonic.jpg)



Conquer and divide is the principle of merge sort algorithm, first it divides the input into pairs and then sort each pair into the bitonic sequence. It then merges sorts the adjacent bitonic sequence and repeat the process through all stages until the entire sequence is stored. 

### Some useful information to run and synthesize sorting algorithm:

__sdaccel.tcl__ : This tcl file is used to run software simulation, hardware emulation and synthesize the source code. Furthermore, SDAccel based optimizaions such as maximum memory ports and multiple compute unit, are added to the design using this tcl file.

__BitonicSort.cl__ : This file includes all four kernels which describe and model bitonic-sorting algorithm. Different versions of the kernels are also available in the same directory(e.g. BitonicSort_default.cl ,BitonicSort_fully_optimized.cl) which are different in terms of optimization.

__main.cpp and hostcode.cpp__: These two files write inputs into the kernels, before execution on specified platform, and write back the output to the global memory when the execution is complete.

__param.h__ :  This header file is shared between different source files which provides easy modification of key parameters.



__Key Parameters in Bitonic Sorting Algorithm__ :

|    Parameter      |  Value      | Description    |   
|----------|:-------------:|------:|
|  arrayLength        |  LOCAL_SIZE_LIMIT * LOCAL_SIZE_LIMIT | Number of array elements  |
|  Global Size        |  arrayLength / 2 | Total size of the problem for each kernel  |
|  Local Size         |  LOCAL_SIZE_LIMIT / 2 |  Local size of each workgroup for each kernel |


Following graph illustrates total number of transfers in two different scenario. One is the default code without any optimization and the second one is using burst data transfer which isolates the read and write operations from the computation part of the algorithm.

![sorting_network](https://github.com/mediroozmeh/Bitonic-Sorting/blob/master/Figures/total_number.jpg)

### Memory access and bandwidth utilization for single compute unit:

For better performance and memory access analysis SDAccel provides users with hardware emulation which consider memory architecture and underlying hardware in more details. Following table presents performance and memory access analysis for single compute unit. 


|    Device     | Kernel Name        | Number of Transfer    |Transfer Rate (MB/s) |Average Bandwidth Utilization(%)|   
|----------|:-------------:|------:|------:|------:|
|  Virtex7        | ALL  | 516096  |190.86|1.988|


__An SDAccel device contains a customization area called the OpenCL region (OCL Region).
Although not defined in the OpenCL standard, the OCL Region is an important concept in
SDAccel. The compute units generated from user kernel functions are placed in this region.
These compute units are highly specialized to execute a single kernel function and
internally contain parallel execution resources to exploit work-group level parallelism. By
placing multiple compute units of the same type in the OCL Region, developers can easily
scale the performance of single kernels across larger NDRange sizes. By placing multiple
compute units of different types in the OCL Region, developers can leverage task
parallelism between disparate kernels. In this way, the massive amounts of parallelism
available in the FPGA device can be customized and harnessed by the SDAccel developer.
This is different from CPU and GPU implementations of OpenCL which contain a fixed set of
general purpose resources__ [1]. 

In this work possible transfer data rate for each compute unit is less than 200 Mb/s which utilizes around 2 percent of available bandwidth on virtex7 fabric. Multiple compute units which are running concurrently allows to improve bandwidth utilization and total performance by factor of 10. Next section of this report presents analysis of different key parameters of algorithm implementation on FPGA.     

![sorting_network](https://github.com/mediroozmeh/Bitonic-Sorting/blob/master/Figures/multiple.jpeg)

The performance of the AXI4-Stream Interconnect core is limited only by the FPGA logic
speed. The core utilizes only block RAMs, LUTs, and registers and contains no I/O elements [4]. 



### Performance and Power Analysis for GPU and FPGA Devices: 
SDAccel enables users to generate multiple RTL solutions from same source code whose functionality can be verified with the provided host code used for software emulation. However, OpenCL code is executed on two different GPU devices (GeForce GTX 960 and Quadro K4200) as a competitor platform to virtex7 but OpenCL code is optimized by using SDAccel features and attributes targeting FPGA. Following table presents performance and power analysis using different platforms.

| Parameters/Devices|Virtex7               |GTX960|K4200|    
|--------------------|:-------------: |:-------------: |:-------------: |
|  Total time (ms) |   8.6     | 13|16|
|  Power(W) |     24     |120| 108|
|  Energy(mj) |     206.4     |1560|1728|
|  LUT Utilization |  166740   (38 %)       |-|-|
|  FF Utilization |   137210    (15 %)   |-|-|
|  DSP Utilization |   160    (4.4 %)   |-|-|
|  BRAMs Utilization |    1300   (44 %)   |-|-|


### Power and performance specification of GPUs and FPGA:

| Parameters/Devices|GTX960|K4200| Virtex 7 |  
|--------------------|:-------------: |:-------------: |:-------------: |
| Memory Bandwidth (GB/sec)          |173|112| 34|
|   Graphics Card Power (W)          |120|108|-|
|   CUDA CORES        |1024|1344| -|



#Refrences
[1] http://www.xilinx.com/support/documentation/sw_manuals/ug1207-sdaccel-performance-optimization.pdf

[2] Vukasin Rankovic, Anton Kos,"Performacne of the Bitonic MergeSort Network on Dataflow Computer", Serbia, Belgrade, 2013

[3] http://www.xilinx.com/support/documentation/data_sheets/ds180_7Series_Overview.pdf

[4] http://www.xilinx.com/support/documentation/ip_documentation/axis_interconnect/v1_1/pg035_axis_interconnect.pdf

[5] https://www.micron.com/products/datasheets/f3a0d8c5-ce92-4641-b59a-6c0fb1826645

[6] http://www.xilinx.com/support/documentation/white_papers/wp375_HPC_Using_FPGAs.pdf

[7] http://www.xilinx.com/support/documentation/ip_documentation/ug586_7Series_MIS.pdf










