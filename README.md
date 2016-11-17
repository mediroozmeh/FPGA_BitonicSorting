## High Level Synthesis of Bitonic Sorting Algorithm:

This OpenCL model of the bitonic sorting algorithm is specifically optimized to be synthesized by SDAccel targeting Xilinx FPGAs. 
The original source code had been written by NVidia for its GPUs. Our
optimizations improved the performance of the original source code, when run on
an FPGA, by several orders of magnitude.

### Legal Status 
The original OpenCL source is distributed with the NVIDIA OpenCL examples
repository. Extensive modifications and optimizations were performed by Mehdi Roozmeh, of
Politecnico di Torino, Italy, in order to generate high performance RTL.

### Brief Analysis of the Bitonic Sorting Algorithm:

Sorting vectors is a fundamental algorithm used in a variety of
high-performance data center applications. Among various possible version of
sorting solutions, the bitonic algorithm is one of the fastest sorting
networks. In general the term __sorting network__ identifies a sorting
algorithm where the sequence of comparisons is not data-dependent, thus making
it suitable for hardware implementation. The bitonic sorting network consists
of comparators, which are the basic block of any sorting network and sort a pair of values presents on inputs.         

![sorting_network](https://github.com/mediroozmeh/Bitonic-Sorting/blob/master/Figures/SORTINGCOMPARATOR.jpg )


The figure shows a simple sorting network with five comparator and four inputs.
Each comparator puts the higher value on the bottom output and the lower value
on the top output. Two comparators on the left hand side and two in the middle
can work in parallel, requiring three time steps. 


The depth and number of comparators is a key parameter to evaluate the
performance of a sorting network. The maximum number of comparators along any
path is the depth of the sorting network. Assuming that all the comparisons at each
level are done in parallel, the depth of the sorting network is equal to the
number of stages and thus proportional to the total execution time. The bitonic
merge sort network is one of the fastest comparison sorting networks, where the following formulas representing the depth and number of comparators:
 
 D(N)= (log<sub>2</sub> N.(log<sub>2</sub> N+1)) / 2              ---->  Depth of sorting network
 

 C(N)= (N.log  <sub>2 N</sub> (log<sub>2</sub>N+1)) / 4            ---->  Number of Comparator

The following figure illustrates a Bitonic Merge sort network with eight inputs (N=8). It operates in 3 stages, it has a depth of 6 steps and employs 24 comparators.

![sorting_network] (https://github.com/mediroozmeh/Bitonic-Sorting/blob/master/Figures/SORTINGNETWOR.jpg)



Divide and conquer is the principle of the merge sort algorithm. 
It is based on the notion of__bitonic sequence__, i.e. a sequence of N elements 
in which the
first K elements are sorted in ascending order, and the last N-K elements are
sorted in descending order (i.e. the K-th element acts as a divider between two
sub-lists, each sorted in a different direction), or some circular shift of
such an order.

Bitonic sort first
divides the input into pairs and then sorts each pair into a bitonic sequence.
It then merges (and sorts) two adjacent bitonic sequences, and repeats this process through all stages until the entire sequence is stored. 

### Some useful information to run and synthesize bitonic sorting:

__sdaccel.tcl__ : This tcl file is used to run software simulation, hardware
emulation and synthesize the source code. Furthermore, synthesis constraints
such as the maximum memory ports and the number of compute units for each kernel, are added to the design using this tcl file.

__BitonicSort.cl__ : This file includes the three kernels which model bitonic
sorting. The original code included a fourth kernel, to be used for small input
arrays. It has not been optimized since it is not significant.

hostcode.cpp__: This file provides inputs to the kernels, executes them in the
right sequence, and reads back the outputs.  It also checks the correctness of
the output.

__param.h__ :  This header file is shared between both host and FPGA code, and
defines some parameters such as the sizes of global and local arrays.



__Key Parameters of the Bitonic Sorting Algorithm__ :

|    Parameter      |  Default Value      | Description    |   
|----------|:-------------:|------:|
|  arrayLength        |  DATA_SIZE | Number of array elements |
|  Local Size         |  LOCAL_SIZE_LIMIT / 2 |  Local size of each workgroup for each kernel 


### Techniques to improve performance:

#### Burst Data Transfers:

Off-chip memory access can be a serious bottleneck in any OpenCl application.
SDAccel uses the async_work_group_copy OpenCL function to copy global to local
memory and vice-versa using AXI bursts, thus improving the overall performance
by taking advantage of the full bit width of the DDR3 interfaces.    


#### Multiple Compute Units: 


SDAccel enables designers to take advantage of the parallel programming model
of OpenCL by instantiating multiple work groups of same kernel separately and
executing them in parallel. The FPGA parallel architecture can be exploited by
this technique, due to improved overall memory bandwidth utilization and better
coarse-grained level parallelism.

![sorting_network](https://github.com/mediroozmeh/Bitonic-Sorting/blob/master/Figures/OCLREGION.jpg)

#### High-Level Synthesis Techniques: 
The use of specific high-level synthesis directives is necessary in order to
achieve optimized RTL. In this OpenCl example we used unrolling, pipelining and
memory partitioning in order to generate optimized RTL from essentially the
same source code which is executed on the GPU.

### Performance and Power Analysis for GPU and FPGA Devices: 
SDAccel enables users to generate multiple RTL solutions from the same source
code. We also executed the OpenCL code on two different GPU devices (GeForce
GTX 960 and Quadro K4200). We present performance and energy consumption
results.

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

#References
[1] http://www.xilinx.com/support/documentation/sw_manuals/ug1207-sdaccel-performance-optimization.pdf

[2] Vukasin Rankovic, Anton Kos,"Performance of the Bitonic MergeSort Network on Dataflow Computer", Serbia, Belgrade, 2013

[3] http://www.xilinx.com/support/documentation/data_sheets/ds180_7Series_Overview.pdf

[4] http://www.xilinx.com/support/documentation/ip_documentation/axis_interconnect/v1_1/pg035_axis_interconnect.pdf

[5] https://www.micron.com/products/datasheets/f3a0d8c5-ce92-4641-b59a-6c0fb1826645

[6] http://www.xilinx.com/support/documentation/white_papers/wp375_HPC_Using_FPGAs.pdf

[7] http://www.xilinx.com/support/documentation/ip_documentation/ug586_7Series_MIS.pdf

[8] Qi Mu. Liqing Cui. Yufei Son, "The implementation and optimization of Bitonic sort algorithm based on CUDA"
https://arxiv.org/pdf/1506.01446v1.pdf

[9] http://www.xilinx.com/support/documentation/white_papers/wp375_HPC_Using_FPGAs.pdf










