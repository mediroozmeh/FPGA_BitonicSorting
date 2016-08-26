##Synthesis of Bitonic Sorting Algorithm Targeting FPGA by SDAccel Using OpenCL as a Source Code:

In this experiment OpenCL description of bitonic sorting algorithm is used as a source code to be digested by SDAccel targeting xilinx FPGAs. However, same source code is run on GPU as a competitive platform of FPGA but the main goal of this experiment is to go through and complete FPGA design flow using SDAccel and explore its capabilities.

### Brief Analysis of Bitonic Sorting algorithm:

Sorting a list of input numbers is one of the most fundamental problems in the field of computer science in general and high-throughput database applications in particular. Among various version of sorting algorithms, bitonic sorting is one of the fastest sorting networks. A sorting network is a special type of sorting algorithm, where the sequence of comparisons are not dada-dependent which makes it suitable for hardware implementation. This sorting network consists of D(N) comparators (which N is the number of inputs)  , a comparator is a building block of sorting network and it sorts a pair of values presents on inputs. 

![sorting_network](https://github.com/mediroozmeh/Bitonic-Sorting/blob/master/Figures/sorting_network.jpeg)
 
 Efficiency of sorting network depends on depth and the number of comparator, the depth is defined as the maximum number of comparators along any path from input to output. Assuming that all comparisons on each level of the network are done in parallel, the depth of the network defines the number of steps, and with that also the sorting time, needed to sort all of N numbers on the inputs and thus defines the complexity of the sorting network. Bitonic mergesort network is one of the fastest comparison sorting network which following formulas drive depth and number of comparators:
 
 D(N)= (log<sub>2</sub> N.(log<sub>2</sub> N+1)) / 2              ---->  Depth of sorting network
 

 C(N)= (N.log<sub>2</sub> N.(log<sub>2</sub>N+1)) / 4            ---->  Number of Comparator

Following figure illustrates a Bitonic Merge sort network with eight inputs (N=8). It operates in 3 stages, it has a depth of 6(steps) and employs 24 comparators.

![Bitonic](https://github.com/mediroozmeh/Bitonic-Sorting/blob/master/Figures/Bitonic.jpg)

Conquer and divide is the principle of merge sort algorithm, first it divides the input into the pairs and sort each pair into the bitonic sequence, then it mergesorts the adjacent bitonic sequence and repeat the process through all stages until the entire sequence is stored.   

### Performance and Power Analysis for GPU and FPGA devices: 

|     Bitonic-Sorting Design               | Execution Time               |    
|--------------------|:-------------: |
|    Unoptimized |          325 ms      | |
|  Partial Optimized |      261 ms   |






### Source Code:

OpenCl source code of this work is chosen from NVIDIA OpenCl examples repository, modification and optimization are done in order to execute it on GPU and FPGA. 





### Performance and Power Analysis for GPU and FPGA devices: 
*** <<  Draw a table and report GPU performance(only unique version) and FPGA performance for three different implementation, UNoptimizaed, partially optimized, fully optimized which also use multiple compute units >>****

***   Draw a Table and Compare the Power Usage of FPGA for GPU and best FPGA design*****

#Refrences
[1] Vukasin Rankovic, Anton Kos,"Performacne of the Bitonic MergeSort Network on Dataflow Computer", Serbia, Belgrade, 2013









