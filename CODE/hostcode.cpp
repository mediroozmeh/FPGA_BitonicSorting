#include <stdio.h>
#include <stdlib.h>
#include <CL/opencl.h> 
#include "param.h"

// Used to check the result of OpenCl API calls
#define check_err(a, b) if (CL_SUCCESS != a) {printf("%s %d\n", b, a); return -1;}

// 
static cl_uint 
factorRadix2(cl_uint& log2L, cl_uint L) 
{
    if (!L) {
        log2L = 0;
        return 0;
    } else {
        for (log2L = 0; (L & 1) == 0; L >>= 1, log2L++);
        return L;
    }
}

// Used to load a binary kernel file to memory.
int 
load_file_to_memory(const char *filename, char **result)
{
	size_t size = 0;
	FILE *f = fopen(filename, "rb");
	if (f == NULL) {
		*result = NULL;
		return -1; // -1 means file opening fail 
	}
	fseek(f, 0, SEEK_END);
	size = ftell(f);
	fseek(f, 0, SEEK_SET);
	*result = (char *)malloc(size + 1);
	if (size != fread(*result, sizeof(char), size, f)) {
		free(*result);
		return -2; // -2 means file reading fail 
	}
	fclose(f);
	(*result)[size] = 0;
	return size;
}

unsigned int srckey[DATA_SIZE];
unsigned int srcval[DATA_SIZE];
unsigned int dstkey[DATA_SIZE];
unsigned int dstval[DATA_SIZE];

int 
main(int argc, char** argv)
{
	cl_context context;
	cl_context_properties properties[3];
	cl_kernel sortLocal1Kernel, mergeGlobalKernel, mergeLocalKernel;
	cl_command_queue command_queue;
	cl_program program;
	cl_int err;
	cl_uint num_of_platforms = 0;
	cl_platform_id platform_id;
	cl_device_id device_id;
	cl_uint num_of_devices = 0;
	int test_flag=0;

	size_t global;
        size_t local;

        unsigned int elements = DATA_SIZE;

	for (unsigned int i = 0; i < elements; i++) {
		srckey[i] = (i%2) ? i : elements-i; // rand();
		srcval[i] = i;
#ifdef DEBUG
		printf("srckey %d %d\n", srckey[i], srcval[i]);
#endif
	}
	// retrieve a list of available platforms 
	if (clGetPlatformIDs(1, &platform_id, &num_of_platforms) != CL_SUCCESS) {
		printf("Unable to get platform_id\n");
		return 1;
	}

	int fpga = 1;
	if (clGetDeviceIDs(platform_id, fpga ? CL_DEVICE_TYPE_ACCELERATOR : CL_DEVICE_TYPE_CPU, 1, &device_id, &num_of_devices) != CL_SUCCESS) {
		printf("Unable to get device_id\n");
		return 1;
	}

	// context properties list - must be terminated with 0
	properties[0] = CL_CONTEXT_PLATFORM;
	properties[1] = (cl_context_properties)platform_id;
	properties[2] = 0;

	// create a context with the device
	context = clCreateContext(properties, 1, &device_id, NULL, NULL, &err);
	check_err(err, "context");

	// create command queue using the context and device
	command_queue = clCreateCommandQueue(context, device_id, 0, &err);
	check_err(err, "queue");

	// Load binary from disk
	int status;
	unsigned char *kernelbinary;
	char *xclbin = argv[1];
	printf("loading %s\n", xclbin);
	int n_i = load_file_to_memory(xclbin, (char **)&kernelbinary);
	if (n_i < 0) {
		printf("failed to load kernel from xclbin: %s\n", xclbin);
		printf("Test failed\n");
		return EXIT_FAILURE;
	}
	size_t n = n_i;

	// Create the program off line
	program = clCreateProgramWithBinary(context, 1, &device_id, &n,
		(const unsigned char **)&kernelbinary, &status, &err);
	check_err(err, "program");

	// compile the program
	if (clBuildProgram(program, 0, NULL, NULL, NULL, NULL) != CL_SUCCESS) {
		printf("Error building program\n");
		return 1;
	}

	// create buffers for the input and ouput
	cl_mem src_key, src_val, dst_key, dst_val;

	src_key = clCreateBuffer(context,  CL_MEM_READ_WRITE , sizeof(unsigned int) * elements, NULL, &err);
	src_val = clCreateBuffer(context,  CL_MEM_READ_WRITE , sizeof(unsigned int) * elements, NULL, &err);
	dst_key = clCreateBuffer(context,  CL_MEM_READ_WRITE , sizeof(unsigned int) * elements, NULL, &err);
	dst_val = clCreateBuffer(context,  CL_MEM_READ_WRITE , sizeof(unsigned int) * elements, NULL, &err);
	check_err(err, "buf");

	// load data into the input buffer
	err |= clEnqueueWriteBuffer(command_queue, src_key, CL_TRUE, 0, sizeof(unsigned int) * elements, srckey, 0, NULL, NULL);
	err |= clEnqueueWriteBuffer(command_queue, src_val, CL_TRUE, 0, sizeof(unsigned int) * elements, srcval, 0, NULL, NULL);
	check_err(err, "write");

	sortLocal1Kernel = clCreateKernel(program, "bitonicSortLocal1", &err); 
	check_err(err, "bitonicSortLocal1 kernel"); 
	mergeGlobalKernel = clCreateKernel(program, "bitonicMergeGlobal", &err);
	check_err(err, "bitonicMergeGlobal kernel"); 
	mergeLocalKernel = clCreateKernel(program, "bitonicMergeLocal", &err); 
	check_err(err, "bitonicMergeLocal kernel"); 

	unsigned int arrayLength = DATA_SIZE;
	unsigned int batch = DATA_SIZE / arrayLength;

	// 0 is descending, 1 is ascending.
	cl_uint dir = 1;
	cl_uint log2L;
	if (factorRadix2(log2L, arrayLength) != 1 || factorRadix2(log2L, LOCAL_SIZE_LIMIT) != 1) {
	    printf("only global and local data sizes that are a power of 2 are supported");
	    exit(-1);
	}

	// Arrays are sortedby executing bitonicSortLocal1
	// and then iterating bitonicMergeGlobal bitonicMergeLocal
        err |= clSetKernelArg(sortLocal1Kernel, 0, sizeof(cl_mem), &dst_key); 
        err |= clSetKernelArg(sortLocal1Kernel, 1, sizeof(cl_mem), &dst_val); 
        err |= clSetKernelArg(sortLocal1Kernel, 2, sizeof(cl_mem), &src_key); 
        err |= clSetKernelArg(sortLocal1Kernel, 3, sizeof(cl_mem), &src_val); 
        check_err(err, "arg"); 
  
        global = batch * arrayLength / 2;
        local = LOCAL_SIZE_LIMIT / 2;
        printf("STARTING KERNEL SortLocal1\n"); 
        err |= clEnqueueNDRangeKernel(command_queue, sortLocal1Kernel, 1, NULL, (size_t *)&global,(size_t *) &local, 0, NULL, NULL); 
     
        check_err(err, "exec"); 
        printf("FINISHED KERNEL\n");
        for (unsigned int size = 2 * LOCAL_SIZE_LIMIT; size <= arrayLength; size <<= 1) {
	  for (unsigned stride = size / 2; stride > 0; stride >>= 1) {
	      if (stride >= LOCAL_SIZE_LIMIT) {
		err |= clSetKernelArg(mergeGlobalKernel, 0, sizeof(cl_mem), &dst_key); 
		err |= clSetKernelArg(mergeGlobalKernel, 1, sizeof(cl_mem), &dst_val); 
		err |= clSetKernelArg(mergeGlobalKernel, 2, sizeof(cl_mem), &dst_key); 
		err |= clSetKernelArg(mergeGlobalKernel, 3, sizeof(cl_mem), &dst_val); 
		err |= clSetKernelArg(mergeGlobalKernel, 4, sizeof(cl_uint), &arrayLength); 
		err |= clSetKernelArg(mergeGlobalKernel, 5, sizeof(cl_uint), &size); 
		err |= clSetKernelArg(mergeGlobalKernel, 6, sizeof(cl_uint), &stride); 
		err |= clSetKernelArg(mergeGlobalKernel, 7, sizeof(cl_uint), &dir); 
		check_err(err, "arg"); 

		printf("STARTING KERNEL MergeGlobal %u %u\n", size, stride); 
		err |= clEnqueueNDRangeKernel(command_queue, mergeGlobalKernel, 1, NULL, (size_t *)&global,(size_t *) &local, 0, NULL, NULL); 
		check_err(err, "exec"); 
		printf("FINISHED KERNEL\n");
	      } else {
		err |= clSetKernelArg(mergeLocalKernel, 0, sizeof(cl_mem), &dst_key); 
		err |= clSetKernelArg(mergeLocalKernel, 1, sizeof(cl_mem), &dst_val); 
		err |= clSetKernelArg(mergeLocalKernel, 2, sizeof(cl_mem), &dst_key); 
		err |= clSetKernelArg(mergeLocalKernel, 3, sizeof(cl_mem), &dst_val); 
		err |= clSetKernelArg(mergeLocalKernel, 4, sizeof(cl_uint), &arrayLength); 
		err |= clSetKernelArg(mergeLocalKernel, 5, sizeof(cl_uint), &stride); 
		err |= clSetKernelArg(mergeLocalKernel, 6, sizeof(cl_uint), &size); 
		err |= clSetKernelArg(mergeLocalKernel, 7, sizeof(cl_uint), &dir); 
		check_err(err, "arg"); 

		printf("STARTING KERNEL MergeLocal %u %u\n", size, stride); 
		err |= clEnqueueNDRangeKernel(command_queue, mergeLocalKernel, 1, NULL, (size_t *)&global,(size_t *) &local, 0, NULL, NULL); 
		check_err(err, "exec"); 
		printf("FINISHED KERNEL\n");
	    }
	  }
        }

	err |= clFinish(command_queue);
	check_err(err, "finish");

	// copy the results from the output buffer
	err |= clEnqueueReadBuffer(command_queue, dst_key, CL_TRUE, 0, sizeof(unsigned int) *elements, dstkey, 0, NULL, NULL);
	err |= clEnqueueReadBuffer(command_queue, dst_val, CL_TRUE, 0, sizeof(unsigned int) *elements, dstval, 0, NULL, NULL);
	check_err(err, "read");

	for (int unsigned i = 0 ; i < elements - 1; i++) {
            if ((dir && dstkey[i]>dstkey[i+1]) || (!dir &&
	    dstkey[i]<dstkey[i+1])) {
		printf("ERROR: %d > %d\n", dstkey[i], dstkey[i+1]);
		test_flag = 1;
	    }
#ifdef DEBUG
	    printf("output: %d\n", dstkey[i]);
#endif
        }
#ifdef DEBUG
	printf("output: %d\n", dstkey[elements-1]);
#endif

	if (test_flag==1)
	   printf("TEST FAILED \n");
	else
	   printf("TEST PASSED \n");

	// cleanup - release OpenCL resources
	clReleaseMemObject(src_key);
	clReleaseMemObject(src_val);
	clReleaseMemObject(dst_key);
	clReleaseMemObject(dst_val);
	clReleaseProgram(program);
	clReleaseKernel(sortLocal1Kernel);
	clReleaseKernel(mergeGlobalKernel);
	clReleaseKernel(mergeLocalKernel);
	clReleaseCommandQueue(command_queue);
	clReleaseContext(context);
	return 0;
}
