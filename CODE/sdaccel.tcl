#******************************************************************************
# Define the solution for SDAccel
create_solution -name SORTING_multiple_128 -dir . -force
add_device -vbnv xilinx:adm-pcie-7v3:1ddr:2.1

# Host Compiler Flags
set_property -name host_cflags -value "-g -Wall"  -objects [current_solution]

# Host Source Files
add_files "hostcode.cpp"

#Memory port optimization
#set_property max_memory_ports true [get_kernels bitonicSortLocal]


# Kernel Definition
#create_kernel  bitonicSortLocal -type clc
#set_property max_memory_ports true [get_kernels bitonicSortLocal]

create_kernel  bitonicSortLocal1 -type clc
#set_property max_memory_ports true [get_kernels bitonicSortLocal1]

create_kernel  bitonicMergeGlobal -type clc

#set_property max_memory_ports true [get_kernels bitonicMergeGlobal]

create_kernel  bitonicMergeLocal -type clc

# set_property max_memory_ports true [get_kernels bitonicMergeLocal]

# Workaround for the bug in kernel_flags, which does not pass the value to 
# the -D compiler option, only defines the macro as empty.
exec cpp BitonicSort.cl > BitonicSort.tmp.cl
# add_files -kernel [get_kernels bitonicSortLocal] "BitonicSort.tmp.cl"
add_files -kernel [get_kernels bitonicSortLocal1] "BitonicSort.tmp.cl"
add_files -kernel [get_kernels bitonicMergeGlobal] "BitonicSort.tmp.cl"
add_files -kernel [get_kernels bitonicMergeLocal] "BitonicSort.tmp.cl"
# set_property -name kernel_flags -value "-g" -objects [get_kernels bitonicSortLocal]
set_property -name kernel_flags -value "-g" -objects [get_kernels bitonicSortLocal1]
set_property -name kernel_flags -value "-g" -objects [get_kernels bitonicMergeGlobal]
set_property -name kernel_flags -value "-g" -objects [get_kernels bitonicMergeLocal]

# Define Binary Containers
create_opencl_binary bitonicsort
set_property region "OCL_REGION_0" [get_opencl_binary bitonicsort]
# Creating compute units for first kernl
create_compute_unit -opencl_binary [get_opencl_binary bitonicsort] -kernel [get_kernels bitonicSortLocal1] -name bitonicSortLocal1_0

create_compute_unit -opencl_binary [get_opencl_binary bitonicsort] -kernel [get_kernels bitonicSortLocal1] -name bitonicSortLocal1_1
#Creating compute units for second kernel
create_compute_unit -opencl_binary [get_opencl_binary bitonicsort] -kernel [get_kernels bitonicMergeGlobal] -name bitonicMergeGlobal_0

create_compute_unit -opencl_binary [get_opencl_binary bitonicsort] -kernel [get_kernels bitonicMergeGlobal] -name bitonicMergeGlobal_1

create_compute_unit -opencl_binary [get_opencl_binary bitonicsort] -kernel [get_kernels bitonicMergeGlobal] -name bitonicMergeGlobal_2

create_compute_unit -opencl_binary [get_opencl_binary bitonicsort] -kernel [get_kernels bitonicMergeGlobal] -name bitonicMergeGlobal_3
## Creating compute units for Third kernel
create_compute_unit -opencl_binary [get_opencl_binary bitonicsort] -kernel [get_kernels bitonicMergeLocal] -name bitonicMergeLocal_0

create_compute_unit -opencl_binary [get_opencl_binary bitonicsort] -kernel [get_kernels bitonicMergeLocal] -name bitonicMergeLocal_1

create_compute_unit -opencl_binary [get_opencl_binary bitonicsort] -kernel [get_kernels bitonicMergeLocal] -name bitonicMergeLocal_2

create_compute_unit -opencl_binary [get_opencl_binary bitonicsort] -kernel [get_kernels bitonicMergeLocal] -name bitonicMergeLocal_3

# Compile the design for CPU based emulation<F5>
compile_emulation -flow cpu -opencl_binary [get_opencl_binary bitonicsort]

# Run the compiled application in CPU based emulation mode
#run_emulation -debug -flow cpu -args "bitonicsort.xclbin"
run_emulation -flow cpu -args "bitonicsort.xclbin"

# Compile the design for hardware based emulation
compile_emulation -flow hardware -opencl_binary [get_opencl_binary bitonicsort]

# Run the compiled application in hardware based emulation mode
run_emulation -flow hardware -args "bitonicsort.xclbin"

#report_estimate
report_estimate

# Compile the application to run on the accelerator card
#build_system

# Package the application binaries
#package_system

