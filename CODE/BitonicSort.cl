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
//Passed down by clBuildProgram
//#ifndef LOCAL_SIZE_LIMIT
//#define LOCAL_SIZE_LIMIT 512
//#endif



inline void ComparatorPrivate(
    uint *keyA,
    uint *valA,
    uint *keyB,
    uint *valB,
    uint arrowDir
){

     #pragma HLS PIPELINE

    if( (*keyA > *keyB) == arrowDir ){
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
   
   #pragma HLS PIPELINE
   
    if( (*keyA > *keyB) == arrowDir ){
        uint t;
        t = *keyA; *keyA = *keyB; *keyB = t;
        t = *valA; *valA = *valB; *valB = t;
    }
}

////////////////////////////////////////////////////////////////////////////////
// Monolithic bitonic sort kernel for short arrays fitting into local memory
////////////////////////////////////////////////////////////////////////////////
__kernel __attribute__((reqd_work_group_size(LOCAL_SIZE_LIMIT / 2, 1, 1)))
void bitonicSortLocal(
    __global uint *d_DstKey,
    __global uint *d_DstVal,
    __global uint *d_SrcKey,
    __global uint *d_SrcVal,
    uint arrayLength,
    uint sortDir
)
{




    __local  uint l_key[LOCAL_SIZE_LIMIT];
    __local  uint l_val[LOCAL_SIZE_LIMIT];

    //Offset to the beginning of subbatch and load data
    d_SrcKey += get_group_id(0) * LOCAL_SIZE_LIMIT + get_local_id(0);
    d_SrcVal += get_group_id(0) * LOCAL_SIZE_LIMIT + get_local_id(0);
    d_DstKey += get_group_id(0) * LOCAL_SIZE_LIMIT + get_local_id(0);
    d_DstVal += get_group_id(0) * LOCAL_SIZE_LIMIT + get_local_id(0);
    l_key[get_local_id(0) +                      0] = d_SrcKey[                     0];
    l_val[get_local_id(0) +                      0] = d_SrcVal[                     0];
    l_key[get_local_id(0) + (LOCAL_SIZE_LIMIT / 2)] = d_SrcKey[(LOCAL_SIZE_LIMIT / 2)];
    l_val[get_local_id(0) + (LOCAL_SIZE_LIMIT / 2)] = d_SrcVal[(LOCAL_SIZE_LIMIT / 2)];


      

    for(uint size = 2; size < arrayLength; size <<= 1)
{
        //Bitonic merge

     
    
        uint dir = ( (get_local_id(0) & (size / 2)) != 0 );
     for(uint stride = size / 2; stride > 0; stride >>= 1)
{



            barrier(CLK_LOCAL_MEM_FENCE);
            uint pos = 2 * get_local_id(0) - (get_local_id(0) & (stride - 1));
            ComparatorLocal(
                &l_key[pos +      0], &l_val[pos +      0],
                &l_key[pos + stride], &l_val[pos + stride],
                dir
            );
        }
    }

    //dir == sortDir for the last bitonic merge step
    {

    // __attribute__((opencl_unroll_hint(2)))
     //  __attribute__((xcl_pipeline_loop))
 for_local_last: for(uint stride = arrayLength / 2; stride > 0; stride >>= 1)
{
     // #paragma HLS PIPELINE
     
   
            barrier(CLK_LOCAL_MEM_FENCE);
            uint pos = 2 * get_local_id(0) - (get_local_id(0) & (stride - 1));
            ComparatorLocal(
                &l_key[pos +      0], &l_val[pos +      0],
                &l_key[pos + stride], &l_val[pos + stride],
                sortDir
            );
        }
    }

    barrier(CLK_LOCAL_MEM_FENCE);
    d_DstKey[                     0] = l_key[get_local_id(0) +                      0];
    d_DstVal[                     0] = l_val[get_local_id(0) +                      0];
    d_DstKey[(LOCAL_SIZE_LIMIT / 2)] = l_key[get_local_id(0) + (LOCAL_SIZE_LIMIT / 2)];
    d_DstVal[(LOCAL_SIZE_LIMIT / 2)] = l_val[get_local_id(0) + (LOCAL_SIZE_LIMIT / 2)];



}

////////////////////////////////////////////////////////////////////////////////
// Bitonic sort kernel for large arrays (not fitting into local memory)
////////////////////////////////////////////////////////////////////////////////
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




    __local uint l_key[LOCAL_SIZE_LIMIT];

   #pragma HLS ARRAY_PARTITION variable=l_key complete dim=1

    __local uint l_val[LOCAL_SIZE_LIMIT];

  #pragma HLS ARRAY_PARTITION variable=l_val complete dim=1
  


    //Offset to the beginning of subarray and load data
   // d_SrcKey += get_group_id(0) * LOCAL_SIZE_LIMIT + get_local_id(0);
   // d_SrcVal += get_group_id(0) * LOCAL_SIZE_LIMIT + get_local_id(0);
//    d_DstKey += get_group_id(0) * LOCAL_SIZE_LIMIT + get_local_id(0);
 //  d_DstVal += get_group_id(0) * LOCAL_SIZE_LIMIT + get_local_id(0);
   //  l_key[get_local_id(0) +                      0] = d_SrcKey[                     0];
   //  l_val[get_local_id(0) +                      0] = d_SrcVal[                     0];
   //  l_key[get_local_id(0) + (LOCAL_SIZE_LIMIT / 2)] = d_SrcKey[(LOCAL_SIZE_LIMIT / 2)];
    // l_val[get_local_id(0) + (LOCAL_SIZE_LIMIT / 2)] = d_SrcVal[(LOCAL_SIZE_LIMIT / 2)];



barrier(CLK_LOCAL_MEM_FENCE);


      if (get_local_id(0) == 0) {

      async_work_group_copy(l_key , d_SrcKey + (get_group_id(0) * LOCAL_SIZE_LIMIT) , LOCAL_SIZE_LIMIT  ,0);
      async_work_group_copy(l_val , d_SrcVal + (get_group_id (0) * LOCAL_SIZE_LIMIT) , LOCAL_SIZE_LIMIT ,0);
   
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////
barrier(CLK_LOCAL_MEM_FENCE);


    uint comparatorI = get_global_id(0) & ((LOCAL_SIZE_LIMIT / 2) - 1);

    for(uint size = 2; size < LOCAL_SIZE_LIMIT; size <<= 1){
       #pragma HLS UNROLL

        //Bitonic merge
        uint dir = (comparatorI & (size / 2)) != 0;
        for(uint stride = size / 2; stride > 0; stride >>= 1){

                     

            barrier(CLK_LOCAL_MEM_FENCE);
            uint pos = 2 * get_local_id(0) - (get_local_id(0) & (stride - 1));
            ComparatorLocal(
                &l_key[pos +      0], &l_val[pos +      0],
                &l_key[pos + stride], &l_val[pos + stride],
                dir
            );
        }
    }

    //Odd / even arrays of LOCAL_SIZE_LIMIT elements
    //sorted in opposite directions
    {
        uint dir = (get_group_id(0) & 1);
    for_local1_last: for(uint stride = LOCAL_SIZE_LIMIT / 2; stride > 0; stride >>= 1)
{

            #pragma HLS UNROLL
            #pragma HLS PIPELINE          
 
            barrier(CLK_LOCAL_MEM_FENCE);
            uint pos = 2 * get_local_id(0) - (get_local_id(0) & (stride - 1));
            ComparatorLocal(
                &l_key[pos +      0], &l_val[pos +      0],
                &l_key[pos + stride], &l_val[pos + stride],
               dir
            );
        }
    }

    barrier(CLK_LOCAL_MEM_FENCE);

/*     
      d_DstKey[                     0] = l_key[get_local_id(0) +                      0];
      d_DstVal[                     0] = l_val[get_local_id(0) +                      0];
      d_DstKey[(LOCAL_SIZE_LIMIT / 2)] = l_key[get_local_id(0) + (LOCAL_SIZE_LIMIT / 2)];
      d_DstVal[(LOCAL_SIZE_LIMIT / 2)] = l_val[get_local_id(0) + (LOCAL_SIZE_LIMIT / 2)];

*/
///////////////

if (get_local_id(0) == 0) 

{
     async_work_group_copy (d_DstKey+(get_group_id(0) * LOCAL_SIZE_LIMIT),  l_key, LOCAL_SIZE_LIMIT,  0 );


     async_work_group_copy (d_DstVal+(get_group_id(0) * LOCAL_SIZE_LIMIT),  l_val , LOCAL_SIZE_LIMIT, 0 );     
}


///////////////////////////////////////////////////////////////////////////////////////

      
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

  

    
  //  uint global_comparatorI = get_global_id(0);
    // uint        comparatorI = global_comparatorI & (arrayLength / 2 - 1);

  //  Bitonic merge
   // uint dir = sortDir ^ ( (comparatorI & (size / 2)) != 0 );
   // uint pos = 2 * global_comparatorI - (global_comparatorI & (stride - 1));


  __local  uint global_comparatorI[LOCAL_SIZE_LIMIT / 2] ;
 #pragma HLS ARRAY_PARTITION variable=global_comparatorI complete dim=1

  __local   uint        comparatorI[LOCAL_SIZE_LIMIT / 2] ;

 #pragma HLS ARRAY_PARTITION variable=comparatorI complete dim=1


  //  Bitonic merge
   __local uint dir[LOCAL_SIZE_LIMIT / 2] ;
 #pragma HLS ARRAY_PARTITION variable=dir complete dim=1

   __local uint pos[LOCAL_SIZE_LIMIT / 2] ;

 #pragma HLS ARRAY_PARTITION variable=pos complete dim=1



/////////////////////////////////////////////////////////
   global_comparatorI[get_local_id(0)] = get_global_id(0);

 barrier(CLK_LOCAL_MEM_FENCE);

if(get_local_id(0)==0){

__attribute__((opencl_unroll_hint(32)))


  for(int m=0; m < LOCAL_SIZE_LIMIT / 2 ; m++){

   // global_comparatorI[get_local_id(0) ] = get_global_id(0);
   comparatorI[m ] = global_comparatorI[m ] & (arrayLength / 2 - 1);
   dir[m] = sortDir ^ ( (comparatorI[m]  & (size / 2)) != 0 );
   pos[m] = 2 * global_comparatorI[m ] - (global_comparatorI[m] & (stride - 1));
}
}
////////////////////////////////////////////////////// 
  



 // printf("pri is : %d, %d, %d ,%d \n ", global_comparatorI_p, comparatorI_p, dir_p, pos_p);

///////////////////////////////////////////////////////////
   __local uint keyA[LOCAL_SIZE_LIMIT / 2];

#pragma HLS ARRAY_PARTITION variable=keyA complete dim=1

    
   __local uint valA[LOCAL_SIZE_LIMIT / 2 ];

#pragma HLS ARRAY_PARTITION variable=valA complete dim=1

   
   __local uint keyB[LOCAL_SIZE_LIMIT / 2];

#pragma HLS ARRAY_PARTITION variable=keyB complete dim=1


   __local uint valB[LOCAL_SIZE_LIMIT/ 2];

#pragma HLS ARRAY_PARTITION variable=valB complete dim=1

///////////////////////////////////////////////////////////////////////////////////////////
 barrier(CLK_LOCAL_MEM_FENCE);

if(get_local_id(0) == 0){ 
 
__attribute__((opencl_unroll_hint(32)))

   for(int i =0 ; i < LOCAL_SIZE_LIMIT / 2 ; i++)
{

     uint pos_i= pos[i];

     keyA[i] = d_SrcKey[pos_i +      0];
     valA[i] = d_SrcVal[pos_i +      0];
     keyB[i] = d_SrcKey[pos_i + stride];
     valB[i] = d_SrcVal[pos_i + stride];
}
}

barrier(CLK_LOCAL_MEM_FENCE);
//////////////////////////////////////////////////////////////
  uint dir_ = dir[get_local_id(0)];


ComparatorLocal(
                &keyA[get_local_id(0)], &valA[get_local_id(0)],
                &keyB[get_local_id(0)], &valB[get_local_id(0)],
              dir_
            );
 
barrier(CLK_LOCAL_MEM_FENCE);


/////////////////////////////////////////////////////

      
if(get_local_id(0)== 0){

__attribute__((opencl_unroll_hint(32)))

for(int j=0; j< LOCAL_SIZE_LIMIT / 2 ; j++ ){
  uint pos_o= pos[j];

    d_DstKey[pos_o +      0] = keyA[j];
    d_DstVal[pos_o +      0] = valA[j];
    d_DstKey[pos_o  + stride] = keyB[j];
    d_DstVal[pos_o  + stride] = valB[j];
}
}
 barrier(CLK_LOCAL_MEM_FENCE);

}



//Combined bitonic merge steps for
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

    
      
    __local uint l_key[LOCAL_SIZE_LIMIT];

   #pragma HLS ARRAY_PARTITION variable=l_key complete dim=1

    __local uint l_val[LOCAL_SIZE_LIMIT];

   #pragma HLS ARRAY_PARTITION variable=l_val complete dim=1


/*
    d_SrcKey += get_group_id(0) * LOCAL_SIZE_LIMIT + get_local_id(0);
    d_SrcVal += get_group_id(0) * LOCAL_SIZE_LIMIT + get_local_id(0);
    d_DstKey += get_group_id(0) * LOCAL_SIZE_LIMIT + get_local_id(0);
    d_DstVal += get_group_id(0) * LOCAL_SIZE_LIMIT + get_local_id(0);
    l_key[get_local_id(0) +                      0] = d_SrcKey[                     0];
   l_val[get_local_id(0) +                      0] = d_SrcVal[                     0];
    l_key[get_local_id(0) + (LOCAL_SIZE_LIMIT / 2)] = d_SrcKey[(LOCAL_SIZE_LIMIT / 2)];
    l_val[get_local_id(0) + (LOCAL_SIZE_LIMIT / 2)] = d_SrcVal[(LOCAL_SIZE_LIMIT / 2)];

*/


    if (get_local_id(0) == 0) {
     async_work_group_copy(l_key, &d_SrcKey[(get_group_id(0) * LOCAL_SIZE_LIMIT)], LOCAL_SIZE_LIMIT,0);
     async_work_group_copy(l_val, &d_SrcVal[(get_group_id (0) * LOCAL_SIZE_LIMIT)], LOCAL_SIZE_LIMIT,0);
   }



    //Bitonic merge
    uint comparatorI = get_global_id(0) & ((arrayLength / 2) - 1);
    uint         dir = sortDir ^ ( (comparatorI & (size / 2)) != 0 );
    for_mergelocal_last: for(; stride > 0; stride >>= 1){

       #pragma HLS UNROLL

       #pragma HLS PIPELINE
                                    
        barrier(CLK_LOCAL_MEM_FENCE);
        uint pos = 2 * get_local_id(0) - (get_local_id(0) & (stride - 1));
        ComparatorLocal(
            &l_key[pos +      0], &l_val[pos +      0],
            &l_key[pos + stride], &l_val[pos + stride],
            dir
        );
    }

    barrier(CLK_LOCAL_MEM_FENCE);

  //   d_DstKey[                     0] = l_key[get_local_id(0) +                      0];
   //   d_DstVal[                     0] = l_val[get_local_id(0) +                      0];
   //   d_DstKey[(LOCAL_SIZE_LIMIT / 2)] = l_key[get_local_id(0) + (LOCAL_SIZE_LIMIT / 2)];
   //   d_DstVal[(LOCAL_SIZE_LIMIT / 2)] = l_val[get_local_id(0) + (LOCAL_SIZE_LIMIT / 2)]; 

 
if (get_local_id(0) == 0) 

{
     async_work_group_copy (&d_DstKey [ (get_group_id(0) * LOCAL_SIZE_LIMIT)],  l_key, LOCAL_SIZE_LIMIT, 0 );

     async_work_group_copy (&d_DstVal [ (get_group_id(0) * LOCAL_SIZE_LIMIT)], l_val,LOCAL_SIZE_LIMIT,0);     
}

}
