// PABLO ANDRES COUTINHO BURGOS
// AUGUSTO ESTUARDO ALONSO ASCENCIO
#include <stdlib.h> 
#include <iostream>
#include <fstream>
#include <string>
#include <vector>
#include <sstream>
#include <utility>
#include <stdio.h>
#include <string>
#include <cmath>
#include <math.h>

using namespace std;
__global__
void getTotal(int n, float *array, float *total)
{
  int index = blockIdx.x*blockDim.x + threadIdx.x;

  if (index < n) total += array[index];
}
void getVariance(int n, float *array, float *mean, float *vairance)
{
  int index = blockIdx.x*blockDim.x + threadIdx.x;

  if (index < n) vairance += pow(array[index] - mean, 2);
}

vector<string> explode(string const & s, char delim)
{
    vector<string> result;
    istringstream iss(s);

    for (string token; getline(iss, token, delim); )
    {
        result.push_back(move(token));
    }

    return result;
}

int main(void)
{
	int N = 100000;
	float *hoursArray, *cudaHours;
	float #temperaturesArray, *cudaTemperatures;
	hoursArray = (float*)malloc(N*sizeof(float));
	temperaturesArray = (float*)malloc(N*sizeof(float));
	cudaMalloc(&cudaHours, N*sizeof(float));
	cudaMalloc(&cudaTemperatures, N*sizeof(float));

	for (int i = 1; i < 5; ++i)
	{
		int offset = (i - 1) * 25000;
		ifstream hoursFile;
		ifstream tempsFile;
		hoursFile.open("hours" + to_string(i) + ".txt");
		tempsFile.open("temps" + to_string(i) + ".txt");
		string hours = "";
		string temps = "";
		string line ="";
		string lineT ="";
		while(getline(hoursFile,line))
	    {
	      hours += line;
	    }
		while(getline(tempsFile,lineT))
	    {
	      temps += lineT;
	    }
	    vector<string> hoursArrayS =explode(hours, ' ');
	    vector<string> tempsArrayS =explode(temps, ' ');
	    for (int j= 0; j< hoursArrayS.size(); ++j)
	    {
	    	hoursArray[j + offset] = stof(hoursArrayS[j].c_str());
	    	temperaturesArray[j + offset] = stof(tempsArrayS[j].c_str());
	    	// printf("%i\n", (j + offset));
	    	// printf("%f\n", hoursArray[j + offset]);
	    }
		hoursFile.close();
		tempsFile.close();
			/* code */
	}
	cudaMemcpy(cudaHours, hoursArray, N*sizeof(float), cudaMemcpyHostToDevice);
	cudaMemcpy(cudaTemperatures, tempe, N*sizeof(float), cudaMemcpyHostToDevice);
	// Statistics calcs
	float *totalTemps, *totalHours, *vairanceHours, *vairanceTemperature, meanHours, meanTemperature, standardDeviationHours, standardDeviationTemperature;

	getTotal<<<N/4, 4>>>(N, cudaHours, totalHours);
	getTotal<<<N/4, 4>>>(N, cudaTemperatures, totalTemps);
	cudaDeviceSynchronize();
	meanTemperature = totalTemps/N;
	meanHours = totalHours/N;
	getVariance<<<N/4, 4>>>(N, cudaHours, meanHours, vairanceHours);
	getVariance<<<N/4, 4>>>(N, cudaTemperatures, meanTemperature, vairanceTemperature);
	cudaDeviceSynchronize();
	vairanceHours = vairanceHours/N;
	vairanceTemperature = vairanceTemperature/N;
	printf("La desviacion estandar de la temperatura entre las 13:00 - 16:00 fue de %f\n", vairanceTemperature);
	printf("La media de la temperatura entre las 13:00 - 16:00 fue de %f\n", totalTemps);
    for (int j= 0; j< N; ++j)
    {
    	printf("%f\n", hoursArray[j]);
    	printf("%f\n", temperaturesArray[j]);
    }
}