### UG 1023 page 52 :

One way of increasing the memory bandwidth available to a kernel is to increase the 
number of physical connections to memory that are attached to a kernel. Proper 
implementation of this optimization requires your knowledge of both the application and 
the target compute device. Therefore, SDAccel requires direct user intervention to increase 
the number of physical memory ports in a kernel. The SDAccel command to increase the 
number of physical memory ports available to the kernel is:
__ Set_property max_memory_ports true [get_kernels <kernel name>]
The max_memory_ports property tells SDAccel to generate one physical memory 
interface for every global memory buffer declared in the kernel function signature. This 
command is only valid for kernels that have been placed into binaries that will be executed 
in the FPGA logic. There is no effect on kernels executing in a processor __.

