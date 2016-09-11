### Latency Computation of fully optimized design:

![Bitonic](https://github.com/mediroozmeh/Bitonic-Sorting/blob/master/Figures/latency.jpg)

### LATENCY = [512 + (512 + 513) + 66600 + (514 +513)] * 4 ns =  290 usecond


first plot: always size is changing from 4 to 32:

 1) Plot for Different Data Size Total Time exectution for sortlocal1 and see the effect of async work group copy versus default implementation.
 
 
 
 2) Plot Data Transfer rate using async work group copy and multiple Compute Unit versus DEFAULT.
 
 
 
 3) Draw a Table which Presents the best Latency of the algorithm and report it and compare it with GPU.
 
 
 
 
 # WARnings and messages from console:
 
 INFO [Time: 12:5] There is no traffic between DDR Memory and Kernel for last 200000 clock cycles
INFO [Time: 12:7] Hardware Emulation is in progress...
INFO [Time: 12:8] There is no traffic between DDR Memory and Kernel for last 400000 clock cycles
INFO [Time: 12:12] Hardware Emulation is in progress...

# report of local_size_limit 32
output: 1024
TEST PASSED 
INFO: [SDAccel 60-349] Executing hardware emulation using software accelerators...COMPLETE
run_emulation: Time (s): cpu = 03:54:42 ; elapsed = 03:54:48 . Memory (MB): peak = 404.734 ; gain = 0.000 ; free physical = 2324 ; free virtual = 43876
INFO: [SDAccel 60-244] Generating system estimate report...
INFO: [SDAccel 60-245] Generating system estimate report...COMPLETE

INFO [Time: 12:17] Hardware Emulation is in progress...

--  This message is generated when hardware emulation is done with the local size of 64
--  async work group copy is used in two kernel of sorting algorithm and mergeing algorithm.
--

### REPORT GENERATED AFTER RUNING HARDWARE EMULATION WITH LOCAL_SIZE_LIMIT OF 64, THE TOTAL EMULATION RUN TIME IS INTERsting which is more than a day.

 output: 4096
TEST PASSED 
INFO: [SDAccel 60-349] Executing hardware emulation using software accelerators...COMPLETE
run_emulation: Time (s): cpu = 24:59:09 ; elapsed = 25:00:21 . Memory (MB): peak = 404.742 ; gain = 0.000 ; free physical = 6660 ; free virtual = 43961
INFO: [SDAccel 60-244] Generating system estimate report...
INFO: [SDAccel 60-245] Generating system estimate report...COMPLETE
============================================
 
 
 
 




