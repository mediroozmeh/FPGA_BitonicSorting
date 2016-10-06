## High Level Synthesis of Bitonic Sorting Algorithm:

In this experiment OpenCL description of bitonic sorting algorithm is used as a source code to be synthesized by SDAccel targeting xilinx FPGAs. However, same source code is run on GPU as a competitive platform of FPGA but the main goal of this experiment is to go through and complete FPGA design flow using SDAccel and explore its capabilities.

### Legal Status 
OpenCL source code of this work is chosen from NVIDIA OpenCL examples repository. Modification and optimization are done in order to generate high performance RTL.

### Brief Analysis of Bitonic Sorting Algorithm:

In the field of computer science and high performance data center application sorting a set of inputs is fundamental. Among various possible version of sorting solutions, bitonic algorithm is one of the fastest sorting networks. In general sorting network is type of algorithm where the sequence of comparisons are not data-dependent thus making it suitable for hardware implementation. This sorting network consists of D(N) comparators (where N is the number of elements). A comparator is the basic block of sorting network and it sorts a pair of values presents on inputs.         

![sorting_network](https://github.com/mediroozmeh/Bitonic-Sorting/blob/master/Figures/SORTINGCOMPARATOR.jpg )


In the simple sorting network with five comparator and four inputs each comparator presents higher values at lower wire and lower value at top wire. Two comprator in the left hand side and other two in the middle can work in parallel within three steps. 


 Depth and number of comparator is key parameter to evaluate performance of sorting network. Maximum number of comparator along any path is the depth of sorting network. Assuming that all comparison on each level is done in parallel the depth of the sorting network is equal to number of stages.Bitonic mergesort network is one of the fastest comparison sorting network with the following formulas representing the depth and number of comparators:
 
 D(N)= (log<sub>2</sub> N.(log<sub>2</sub> N+1)) / 2              ---->  Depth of sorting network
 

 C(N)= (N.log  <sub>2 N</sub> (log<sub>2</sub>N+1)) / 4            ---->  Number of Comparator

Following figure illustrates a Bitonic Merge sort network with eight inputs (N=8). It operates in 3 stages, it has a depth of 6(steps) and employs 24 comparators.

![sorting_network] (https://github.com/mediroozmeh/Bitonic-Sorting/blob/master/Figures/SORTINGNETWOR.jpg)



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

In this experiment maximum transfer data rate from off-chip memory to on-chip is 200 MB/s using unique physical memory ports for each buffer which is a way to increase available bandwidth to kernel. In fact by creating unique memory port for each IO we provide separate data-path for accessing off-chip memory with minimum conflicts. Following table reports improvements in bandwidth utilization by factor of 14 in cost of extra on-chip memory utilization. 




|        |      Single Memory Ports   | Maximum Memory Port    |    
|----------|:-------------:|------:|
|  Transfer Rate  (MB/s)      | 9.12  | 139.8  |
| ~ Average Bandwidth Utilization (%)        | .1  | 1.45  | 
|  Total Available Bandwidth  (GB/s)      | 9.5  | 9.5  |
|  Blocak of RAM      | 4 | 120  |





For better performance and memory access analysis SDAccel provides users with hardware emulation which consider memory architecture and underlying hardware in more details. Following table presents performance and memory access analysis for a single compute unit using asynchronous memory copies between global and local memory which decreases number of transfer by prefetching data from global memory.  


|    Device     | Kernel Name        | Number of Transfer    |Transfer Rate (MB/s) |Average Bandwidth Utilization(%)|   
|----------|:-------------:|------:|------:|------:|
|  Virtex7        | ALL  | 516096  |190.86|1.988|

Following graph demonstrates performance improvement ratio by using asyncronous_work_group_copy function which is supported by SDAccel.

! [Transfer_rate ](https://github.com/mediroozmeh/Bitonic-Sorting/blob/master/Figures/transfer_rate.jpg)





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

  

![sorting_network](https://github.com/mediroozmeh/Bitonic-Sorting/blob/master/Figures/OCLREGION.jpg)

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










