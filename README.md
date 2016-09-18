## High Level Synthesis of Bitonic Sorting Algorithm  :

In this experiment OpenCL description of bitonic sorting algorithm is used as a source code to be synthesized by SDAccel targeting xilinx FPGAs. However, same source code is run on GPU as a competitive platform of FPGA but the main goal of this experiment is to go through and complete FPGA design flow using SDAccel and explore its capabilities.

### Legal Status 
OpenCL source code of this work is chosen from NVIDIA OpenCL examples repository, modification and optimization are done in order to generate high performance RTL.

### Brief Analysis of Bitonic Sorting Algorithm:

Sorting a list of input numbers is one of the most fundamental problems in the field of computer science in general and high-throughput database applications in particular. Among various version of sorting algorithms, bitonic sorting is one of the fastest sorting networks. A sorting network is a special type of sorting algorithm, where the sequence of comparisons are not dada-dependent which makes it suitable for hardware implementation. This sorting network consists of D(N) comparators (which N is the number of inputs)  , a comparator is a building block of sorting network and it sorts a pair of values presents on inputs. 

![sorting_network](https://github.com/mediroozmeh/Bitonic-Sorting/blob/master/Figures/sorting_network.jpeg)
 
 Efficiency of sorting network depends on depth and the number of comparator, the depth is defined as the maximum number of comparators along any path from input to output. Assuming that all comparisons on each level of the network are done in parallel, the depth of the network defines the number of steps, and with that also the sorting time, needed to sort all of N numbers on the inputs and thus defines the complexity of the sorting network. Bitonic mergesort network is one of the fastest comparison sorting network which following formulas drive depth and number of comparators:
 
 D(N)= (log<sub>2</sub> N.(log<sub>2</sub> N+1)) / 2              ---->  Depth of sorting network
 

 C(N)= (N.log<sub>2</sub> N.(log<sub>2</sub>N+1)) / 4            ---->  Number of Comparator

Following figure illustrates a Bitonic Merge sort network with eight inputs (N=8). It operates in 3 stages, it has a depth of 6(steps) and employs 24 comparators.



Conquer and divide is the principle of merge sort algorithm, first it divides the input into the pairs and sort each pair into the bitonic sequence, then it mergesorts the adjacent bitonic sequence and repeat the process through all stages until the entire sequence is stored.   

### Performance and Power Analysis for GPU and FPGA Devices: 
SDAccel enable users to generate multiple RTL solutions from same source code which their functionality can be verified with provided host code used for software emulation. However, same OpenCL code is executed on two different GPU devices (GeForce GTX 960 and Quadro K4200) as a competitor platform to Xilinx virtex7 FPGA but OpenCL code is optimized by using SDAccel features and attributes. Follwoing table presents performacne and power analysis using different platforms. 

| Parametersd/Devices|FPGA               |GTX960|K4200|    
|--------------------|:-------------: |:-------------: |:-------------: |
|  Total time (ms) |   8.6     | 13|16|
|  Power(Device) |     24     |120| 108|
|  Energy(Device) |          |||
|  LUT Utilization |          |||
|  FF Utilization |          |||
|  DSP Utilization |          |||
|  BRAMs Utilization |          |||


### Power and performance dpecifiaction of used devices:

| Parametersd/Devices|GTX960|K4200|    
|--------------------|:-------------: |:-------------: |
|  Memory Bandwidth (GB/sec)          |173|112|
|   Graphics Card Power (W)          |120|108|
|   CUDA CORES        |1024|1344|



#Refrences
[1] Vukasin Rankovic, Anton Kos,"Performacne of the Bitonic MergeSort Network on Dataflow Computer", Serbia, Belgrade, 2013

[2] http://www.xilinx.com/support/documentation/data_sheets/ds180_7Series_Overview.pdf











