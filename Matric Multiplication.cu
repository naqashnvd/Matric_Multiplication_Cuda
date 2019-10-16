#include <stdio.h>

//for matrices of A(2x3) and  B(3x2)//
#define SIZE 2
#define SIZE1 3  

__global__ void matMult(int * matProd, int * matA, int * matB)
{
        int row = blockIdx.x;
        int col = threadIdx.x;

        int tmpSum = 0;;
        if (row < SIZE && col < SIZE)
        {
                for (int i=0; i<SIZE1; ++i)
                        tmpSum += matA[row*SIZE1 + i] * matB[i*SIZE + col];
                matProd[row*SIZE + col] = tmpSum;
        }
}

int main()
{
        // initialize, aalocate and define host memory
        int matA[SIZE*SIZE1] = { 0 };
        int matB[SIZE1*SIZE] = { 0 };
        int matProd[SIZE*SIZE] = { 0 };

        //set Matrix A
        for (int i=0; i<SIZE; i++)
        {
                for (int j=0; j<SIZE1; j++)
                {
                        matA[i*SIZE1 + j] = i+j;    
                }
        }

        //set Matrix B
        for (int i=0; i<SIZE1; i++)
        {
                for (int j=0; j<SIZE; j++)
                {  
                        matB[i*SIZE + j] = i-j;
                }
        }


        // initialize and allocate device memory
        int * dev_matProd, * dev_matA, * dev_matB;
        cudaMalloc((void **)&dev_matA, SIZE*SIZE1*sizeof(int));
        cudaMalloc((void **)&dev_matB, SIZE1*SIZE*sizeof(int));
        cudaMalloc((void **)&dev_matProd, SIZE*SIZE*sizeof(int));


        // copy data to device memory
        cudaMemcpy((void *)dev_matA, (void *)matA, SIZE*SIZE1*sizeof(int),
                        cudaMemcpyHostToDevice);
        cudaMemcpy((void *)dev_matB, (void *)matB, SIZE1*SIZE*sizeof(int),
                        cudaMemcpyHostToDevice);

        matMult<<<SIZE,SIZE>>>(dev_matProd, dev_matA, dev_matB);
        
        // check for successful thread execution
        if (cudaDeviceSynchronize() != cudaSuccess)
        {
                printf("Error\n");
                return -1;
        }

        // copy results from device to host memory
        cudaMemcpy(matProd, dev_matProd, SIZE*SIZE*sizeof(int),
                        cudaMemcpyDeviceToHost);

        
        printf("Matrix A \n");
        for(int i =0;i<SIZE;i++)
        {
            for(int j=0;j<SIZE1;j++)
            {
                printf("%d \t",matA[i*SIZE1+j]);
            }
            printf("\n");
        }

        printf("Matrix B \n");
        for(int i =0;i<SIZE1;i++)
        {
            for(int j=0;j<SIZE;j++)
            {
                printf("%d \t",matB[i*SIZE+j]);
            }
            printf("\n");
        }


        printf("Matrix Product \n");
        for(int i =0;i<SIZE;i++)
        {
            for(int j=0;j<SIZE;j++)
            {
                printf("%d \t",matProd[i*SIZE+j]);
            }
            printf("\n");
        }





        return 0;
}