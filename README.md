# License status:

# Overview:

####Implementation of Bitonic Sorting algorithm on FPGA through SDAccel using Opencl as source code

In this experiment Opencl description of bitonic sorting algorithm is used as a source code to be digested by SDAccel in order to target xilinx FPGAs. However, same OpenCL code is run on GPU for compariosn purpose but the main goal of this experiment is to go through and complete FPGA design flow using SDAccel and its capabilities.

### Brief Analysis of Bitonic Sorting algorithm:

Sorting a list of input numbers is one of the most fundamental problems in the field of computer science in general and high-throughput database applications in particular. Among various version of sorting algorithms, bitonic sorting is one of the fastest sorting networks.A sorting network is a special type of sorting algorithm, where the sequence of comparisons are not dada-dependent which makes it suitable for hardware implementation.
This sorting network consists of (nlog(n)<sup>2</sup>) comparators. *** Put a figure and diagrams in order to describe data flow of biotonic sorting algorithm, describe also how the opencl code emulate this behaviot and code ****

### Performance and Power Analysis for GPU and FPGA devices: 
*** <<  Draw a table and report GPU performance(only unique version) and FPGA performance for three different implementation, UNoptimizaed, partially optimized, fully optimized which also use multiple compute units >>****

***   Draw a Table and Compare the Power Usage of FPGA for GPU and best FPGA design*****

#Refrences










