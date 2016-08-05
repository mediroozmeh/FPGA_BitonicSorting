
# Bitonic Sorting
####Implementation of Bitonic Sorting algorithm on FPGA through SDAccel using Opencl as source code

In this experiment Opencl description of bitonic sorting algorithm is used as a source code to be digested by SDAccel which targets xilinx FPGAs. However, same Opencl code is run on GPU for compariosn purpose but the main goal of this experiment is to explore and complete FPGA design flow using SDAccel and its capabilities.

### Overview on Bitonic Sorting algorithm:

Sorting a list of input numbers is one of the most fundamental problems in the field of computer science in general and high-throughput database applications in particular. Among various version of sorting algorithms, bitonic sorting is one of the fastest sorting networks.A sorting network is a special type of sorting algorithm, where the sequence of comparisons are not dada-dependent which makes it suitable for hardware implementation. This sorting network consists of <img src ="https://github.com/mediroozmeh/Bitonic-Sorting/blob/master/Figures/latex_df563c4ffd98b71415248b56a1fff45e.png">comparators, in the following bitonic sorting algorithm is described in more detail.









