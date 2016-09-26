### UG 1023 page 52 :

The default behavior of SDAccel creates a single physical memory port for the kernel. The single 
physical port creates a bottleneck that forces sequential accesses to buffers A and B. 
SDAccel detects this system-level issue and alerts you with a warning message displayed on 
the console.

One way of increasing the memory bandwidth available to a kernel is to increase the 
number of physical connections to memory that are attached to a kernel. Proper 
implementation of this optimization requires your knowledge of both the application and 
the target compute device. Therefore, SDAccel requires direct user intervention to increase 
the number of physical memory ports in a kernel. The SDAccel command to increase the 
number of physical memory ports available to the kernel is:
Set_property max_memory_ports true [get_kernels <kernel name>]
The max_memory_ports property tells SDAccel to generate one physical memory 
interface for every global memory buffer declared in the kernel function signature. This 
command is only valid for kernels that have been placed into binaries that will be executed 
in the FPGA logic. There is no effect on kernels executing in a processor.

|        |      Single Memory Ports   | Maximum Memory Port    |    
|----------|:-------------:|------:|------:|
|  Transfer Rate  (MB/s)      | 9.12  | 139.8  |9.5 |
| ~ Average Bandwidth Utilization (%)        | .1  | 1.45  | 
|  Total Available Bandwidth  (GB/s)      | 9.5  | 9.5  | 

### Memory Bandwidth of Virtex7 FPGAs:

 High-performance SelectIO™ technology with support for DDR3 interfaces up to 1,866 Mb/s ( 233.25 MB/s) .  
 

|        |      Single Memory Ports   | Maximum Memory Port    |    
|----------|:-------------:|------:|
|  Transfer Rate  (MB/s)      | 176  | 191 |   
| ~ Average Bandwidth Utilization (%)        | 75 %  | 81 %  | 
|  Total Available Bandwidth  (MB/s)      | 233   | 233   | 
