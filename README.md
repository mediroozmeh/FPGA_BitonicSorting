## High Level Synthesis of Bitonic Sorting Algorithm:

In this experiment OpenCL description of bitonic sorting algorithm is used as a source code to be synthesized by SDAccel targeting xilinx FPGAs. However, same source code is run on GPU as a competitive platform of FPGA but the main goal of this experiment is to go through and complete FPGA design flow using SDAccel and explore its capabilities.

### Legal Status 
OpenCL source code of this work is chosen from NVIDIA OpenCL examples repository. Modification and optimization are done in order to generate high performance RTL.

### Brief Analysis of Bitonic Sorting Algorithm:

In the field of computer science and high performance data center application sorting a set of inputs is fundamental. Among various possible version of sorting solutions, bitonic algorithm is one of the fastest sorting networks. In general sorting network is type of algorithm where the sequence of comparisons are not data-dependent thus making it suitable for hardware implementation. This sorting network consists of D(N) comparators (where N is the number of elements). A comparator is the basic block of sorting network and it sorts a pair of values presents on inputs.         

![sorting_network](https://github.com/mediroozmeh/Bitonic-Sorting/blob/master/Figures/SORTINGCOMPARATOR.jpg )


In the simple sorting network with five comparator and four inputs each comparator presents higher values at lower wire and lower value at top wire. Two comparator in the left hand side and other two in the middle can work in parallel within three steps. 


 Depth and number of comparator is key parameter to evaluate performance of sorting network. Maximum number of comparator along any path is the depth of sorting network. Assuming that all comparison on each level is done in parallel the depth of the sorting network is equal to number of stages.Bitonic mergesort network is one of the fastest comparison sorting network with the following formulas representing the depth and number of comparators:
 
 D(N)= (log<sub>2</sub> N.(log<sub>2</sub> N+1)) / 2              ---->  Depth of sorting network
 

 C(N)= (N.log  <sub>2 N</sub> (log<sub>2</sub>N+1)) / 4            ---->  Number of Comparator

Following figure illustrates a Bitonic Merge sort network with eight inputs (N=8). It operates in 3 stages, it has a depth of 6(steps) and employs 24 comparators.

![sorting_network] (https://github.com/mediroozmeh/Bitonic-Sorting/blob/master/Figures/SORTINGNETWOR.jpg)



Conquer and divide is the principle of merge sort algorithm, first it divides the input into pairs and then sort each pair into the bitonic sequence. It then merges sorts the adjacent bitonic sequence and repeat the process through all stages until the entire sequence is stored. 

### Some useful information to run and synthesize sorting algorithm:

__sdaccel.tcl__ : This tcl file is used to run software simulation, hardware emulation and synthesize the source code. Furthermore, SDAccel based optimizaions such as maximum memory ports and multiple compute unit, are added to the design using this tcl file.

__BitonicSort.cl__ : This file includes all four kernels which describe and model bitonic-sorting algorithm. Different versions of the kernels are also available in the same directory (e.g. BitonicSort_default.cl ,BitonicSort_fully_optimized.cl) which are different in terms of optimization.

__main.cpp and hostcode.cpp__: These two files write inputs into the kernels, before execution on specified platform, and write back the output to the global memory when the execution is complete.

__param.h__ :  This header file is shared between different source files which provides easy modification of key parameters.



__Key Parameters in Bitonic Sorting Algorithm__ :

|    Parameter      |  Value      | Description    |   
|----------|:-------------:|------:|
|  arrayLength        |  LOCAL_SIZE_LIMIT * LOCAL_SIZE_LIMIT | Number of array elements  |
|  Global Size        |  arrayLength / 2 | Total size of the problem for each kernel  |
|  Local Size         |  LOCAL_SIZE_LIMIT / 2 |  Local size of each workgroup for each kernel |


### Techniques to improve performance:

#### Burst Data Transfer:

Off-chip memory access can be a serious bottleneck in datacenter applications, sorting algorithms all are proper examples to study this problems and experiment available techniques to improve overall performance. SDAccel implements built in function in OpenCL programming language which copy global to local memory in burst fashion and improve overall performance by taking advantage of full bit width of DDR.    


#### Multiple Compute Unit: 


SDAccel enables designers to take advantage of parallel model of OpenCL programming model by instantiating multiple work group of same kernel separately and executing them in parallel. In fact FPGA parallel architecture can be exploit by mapping multiple workgroup of OpenCL kernel on FPGA in parallel which result in better performance mainly due to improved overall band width utilization and coarse-grained level parallelism.

![sorting_network](https://github.com/mediroozmeh/Bitonic-Sorting/blob/master/Figures/OCLREGION.jpg)

#### Classic High Level Synthesis Techniques: 
Using classic directives of high level synthesis process is necessary in order to achieve optimized RTL, in this work also unrolling, pipelining and memory partitioning techniques are used in order to generate optimized RTL from same source code which is used to be executed on GPU.

### Performance and Power Analysis for GPU and FPGA Devices: 
SDAccel enables users to generate multiple RTL solutions from same source code whose functionality can be verified with the provided host code used for software emulation. However, OpenCL code is executed on two different GPU devices (GeForce GTX 960 and Quadro K4200) as a competitor platform to virtex7 but OpenCL code is optimized by using SDAccel features and attributes targeting FPGA. Following table presents performance and power analysis using different platforms.

| Parameters/Devices|Virtex7               |GTX960|K4200|    
|--------------------|:-------------: |:-------------: |:-------------: |
|  Total time (ms) |   17    | 16 | 25|
|  Power(W) |     11     |120| 108|
|  Energy(mj) |  187        |1920|2700|
|  LUT Utilization |  166740   (38 %)       |-|-|
|  FF Utilization |   137210    (15 %)   |-|-|
|  DSP Utilization |   160    (4.4 %)   |-|-|
|  BRAMs Utilization |    1300   (44 %)   |-|-|


### Power and performance specification of GPUs and FPGA:

| Parameters/Devices| Virtex 7       |GTX960| K4200|
|--------------------|:-------------: |:-------------: | :-------------: |
| Memory Bandwidth (GB/sec)|  34 |  112 |  173 |
|Graphics Card Power (W)| - |  120 |  108 |
|CUDA CORES |  - |  1024|  1344 |

### Conclusion:

This work presents the results of SDAccel synthesis and hardware emulation which digests OpenCL source code of bitonic sorting algorithm provided by NVIDIA targeting its GPUs and generate high performance RTL which can be used to program Xilinx FPGAs. In this work SDAccel is used to optimize and improve overall performance by using attributes provided by Xilinx which guides synthesis process toward desired RTL.  

#References
[1] http://www.xilinx.com/support/documentation/sw_manuals/ug1207-sdaccel-performance-optimization.pdf

[2] Vukasin Rankovic, Anton Kos,"Performacne of the Bitonic MergeSort Network on Dataflow Computer", Serbia, Belgrade, 2013

[3] http://www.xilinx.com/support/documentation/data_sheets/ds180_7Series_Overview.pdf

[4] http://www.xilinx.com/support/documentation/ip_documentation/axis_interconnect/v1_1/pg035_axis_interconnect.pdf

[5] https://www.micron.com/products/datasheets/f3a0d8c5-ce92-4641-b59a-6c0fb1826645

[6] http://www.xilinx.com/support/documentation/white_papers/wp375_HPC_Using_FPGAs.pdf

[7] http://www.xilinx.com/support/documentation/ip_documentation/ug586_7Series_MIS.pdf

[8] Qi Mu. Liqing Cui. Yufei Son, "The implementation and optimization of Bitonic sort algorithm based on CUDA"
https://arxiv.org/pdf/1506.01446v1.pdf

[9] http://www.xilinx.com/support/documentation/white_papers/wp375_HPC_Using_FPGAs.pdf










