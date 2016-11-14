/*
 * Copyright 1993-2010 NVIDIA Corporation.  All rights reserved.
 *
 * Please refer to the NVIDIA end user license agreement (EULA) associated
 * with this source code for terms and conditions that govern your use of
 * this software. Any use, reproduction, disclosure, or distribution of
 * this software and related documentation outside the terms of the EULA
 * is strictly prohibited.
 *
 */


#include "param.h"

inline void ComparatorPrivate(
    uint *keyA,
    uint *valA,
    uint *keyB,
    uint *valB,
    uint arrowDir
){
    if( (*keyA > *keyB) == arrowDir ){


       #pragma HLS PIPELINE
        uint t;
        t = *keyA; *keyA = *keyB; *keyB = t;
        t = *valA; *valA = *valB; *valB = t;
    }
}

inline void ComparatorLocal(
    __local uint *keyA,
    __local uint *valA,
    __local uint *keyB,
    __local uint *valB,
    uint arrowDir
){
    if( (*keyA > *keyB) == arrowDir ){
    #pragma HLS 
        uint t;
        t = *keyA; *keyA = *keyB; *keyB = t;
        t = *valA; *valA = *valB; *valB = t;
    }
}

//
// Monolithic bitonic sort kernel for short arrays fitting into local memory
//
// Bitonic sort kernel for large arrays (not fitting into local memory)
//
//Bottom-level bitonic sort
//Almost the same as bitonicSortLocal with the only exception
//of even / odd subarrays (of LOCAL_SIZE_LIMIT points) being
//sorted in opposite directions
__kernel __attribute__((reqd_work_group_size(LOCAL_SIZE_LIMIT / 2, 1, 1)))
void bitonicSortLocal1(
    __global uint *d_DstKey,
    __global uint *d_DstVal,
    __global uint *d_SrcKey,
    __global uint *d_SrcVal
){

    __local uint l_keyA[LOCAL_SIZE_LIMIT ] __attribute__((xcl_array_partition(block , 8 , 1)));
    __local uint l_valA[LOCAL_SIZE_LIMIT ] __attribute__((xcl_array_partition(block , 8 , 1)));


    //Offset to the beginning of subarray and load data

//////// off-chip to on-chip memory copy
async_work_group_copy(l_keyA , d_SrcKey + get_group_id(0)*LOCAL_SIZE_LIMIT  , LOCAL_SIZE_LIMIT   ,  0) ;
async_work_group_copy(l_valA , d_SrcVal + get_group_id(0)*LOCAL_SIZE_LIMIT  , LOCAL_SIZE_LIMIT   ,  0) ;
//

 
    uint comparatorI = get_global_id(0) & ((LOCAL_SIZE_LIMIT / 2) - 1);



      __attribute__((xcl_pipeline_loop))

     for(uint size = 2; size < LOCAL_SIZE_LIMIT  ; size <<= 1){
        // Bitonic merge
         uint dir = (comparatorI & (size / 2)) != 0;
         for(uint stride = size / 2; stride > 0; stride >>= 1){
            barrier(CLK_LOCAL_MEM_FENCE);
             uint pos = 2 * get_local_id(0) - (get_local_id(0) & (stride - 1));
             ComparatorLocal(
                 &l_keyA[pos +      0], &l_valA[pos +      0],
                 &l_keyA[pos + stride], &l_valA[pos + stride],
                 dir
             );
        }
     }

    //Odd / even arrays of LOCAL_SIZE_LIMIT elements
    //sorted in opposite directions
    {
        uint dir = (get_group_id(0) & 1);


    __attribute__((xcl_pipeline_loop))

   for(uint stride = LOCAL_SIZE_LIMIT / 2 ; stride > 0; stride >>= 1)
  
{

    
 
 
            barrier(CLK_LOCAL_MEM_FENCE);

            uint pos = 2 * get_local_id(0) - (get_local_id(0) & (stride - 1));

            ComparatorLocal(
                &l_keyA[pos +      0], &l_valA[pos +      0],
                &l_keyA[pos + stride], &l_valA[pos + stride],
               dir
            );

        }
    }

// on-chip to off-chip memory copy
  async_work_group_copy(d_DstKey + get_group_id(0)* LOCAL_SIZE_LIMIT , l_keyA , LOCAL_SIZE_LIMIT  , 0);
  async_work_group_copy(d_DstVal + get_group_id(0)* LOCAL_SIZE_LIMIT , l_valA , LOCAL_SIZE_LIMIT  , 0);
//
     
}

//Bitonic merge iteration for 'stride' >= LOCAL_SIZE_LIMIT
__kernel void bitonicMergeGlobal(
    __global uint *d_DstKey,
    __global uint *d_DstVal,
    __global uint *d_SrcKey,
    __global uint *d_SrcVal,
    uint arrayLength,
    uint size,
    uint stride,
    uint sortDir
){

  
   
 __attribute__((xcl_pipeline_workitems))

{
    uint global_comparatorI = get_global_id(0);
    uint        comparatorI = global_comparatorI & (arrayLength / 2 - 1);

    //Bitonic merge
    uint dir = sortDir ^ ( (comparatorI & (size / 2)) != 0 );
    uint pos = 2 * global_comparatorI - (global_comparatorI & (stride - 1));
//
    uint keyA = d_SrcKey[pos +      0];
    uint valA = d_SrcVal[pos +      0];
    uint keyB = d_SrcKey[pos + stride];
    uint valB = d_SrcVal[pos + stride];   
// 
      ComparatorPrivate(
        &keyA, &valA,
        &keyB, &valB,
        dir
    );



    d_DstKey[pos +      0] = keyA;
    d_DstVal[pos +      0] = valA;
    d_DstKey[pos + stride] = keyB;
    d_DstVal[pos + stride] = valB;

}

}
//'size' > LOCAL_SIZE_LIMIT and 'stride' = [1 .. LOCAL_SIZE_LIMIT / 2]
__kernel __attribute__((reqd_work_group_size(LOCAL_SIZE_LIMIT / 2, 1, 1)))
void bitonicMergeLocal(
    __global uint *d_DstKey,
    __global uint *d_DstVal,
    __global uint *d_SrcKey,
    __global uint *d_SrcVal,
    uint arrayLength,
    uint stride,
    uint size,
    uint sortDir
){

    
      
    __local uint l_key[LOCAL_SIZE_LIMIT] __attribute__((xcl_array_partition (complete , 1)));

    __local uint l_val[LOCAL_SIZE_LIMIT] __attribute__((xcl_array_partition (complete, 1)));


// on-chip to off-chip memory copy
    async_work_group_copy(l_key , d_SrcKey + get_group_id(0)*LOCAL_SIZE_LIMIT , LOCAL_SIZE_LIMIT  , 0);
    async_work_group_copy(l_val , d_SrcVal + get_group_id(0)*LOCAL_SIZE_LIMIT  , LOCAL_SIZE_LIMIT  ,  0 );
//
    //Bitonic merge
    uint comparatorI = get_global_id(0) & ((arrayLength / 2) - 1);
    uint         dir = sortDir ^ ( (comparatorI & (size / 2)) != 0 );

   
    __attribute__((xcl_pipeline_loop))

    for_mergelocal_last: for(; stride > 0; stride >>= 1){

        barrier(CLK_LOCAL_MEM_FENCE);

        uint pos = 2 * get_local_id(0) - (get_local_id(0) & (stride - 1));
        ComparatorLocal(
            &l_key[pos +      0], &l_val[pos +      0],
            &l_key[pos + stride], &l_val[pos + stride],
            dir
        );
    }

    barrier(CLK_LOCAL_MEM_FENCE);
// write back to off-chip memory 
async_work_group_copy(d_DstKey + get_group_id(0) * LOCAL_SIZE_LIMIT , l_key , LOCAL_SIZE_LIMIT , 0);
async_work_group_copy(d_DstVal + get_group_id(0) * LOCAL_SIZE_LIMIT , l_val , LOCAL_SIZE_LIMIT , 0); 

}
