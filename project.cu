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
void getTotal(int n, float *array, float * totalL)
{
  int index = blockIdx.x*blockDim.x + threadIdx.x;

  if (index < n) totalL[0] += (array[index]);

}
__global__

void getVariance(int n, float *array, float * mean, float * vairance)
{
  int index = blockIdx.x*blockDim.x + threadIdx.x;

  if (index < n) vairance[0] += (pow(array[index] - mean[0], 2));
}

// vector<string> explode(string const & s, char delim)
// {
//     vector<string> result;
//     istringstream iss(s);

//     for (string token; getline(iss, token, delim); )
//     {
//         result.push_back(move(token));
//     }

//     return result;
// }

int main(void)
{
	int N = 100000;
	float *hoursArray, *cudaHours;
	float *temperaturesArray, *cudaTemperatures;
	hoursArray = (float*)malloc(N*sizeof(float));
	temperaturesArray = (float*)malloc(N*sizeof(float));
	cudaMalloc(&cudaHours, N*sizeof(float));
	cudaMalloc(&cudaTemperatures, N*sizeof(float));

	const char *ts[4] = {"temps1.txt", "temps2.txt", "temps3.txt", "temps4.txt"};
	const char *hs[4] = {"hours1.txt", "hours2.txt", "hours3.txt", "hours4.txt"};
	    vector<string> hoursArrayS;
	    vector<string> tempsArrayS;
	for (int i = 1; i < 5; ++i)
	{

		int offset = (i - 1) * 25000;
		ifstream hoursFile;
		ifstream tempsFile;
		hoursFile.open(hs[i-1]);
		tempsFile.open(ts[i-1]);
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


	    for (int i = 0; i < 3000; i+=3)
	    {
	    	string s = hours.substr(i, 2);

	    	hoursArrayS.push_back(hours.substr(i, 2));
	    }

	    for (int i = 0; i < 3000; i+=3)
	    {
	    	tempsArrayS.push_back(temps.substr(i, 2));
	    }
	    for (int j= 0; j< hoursArrayS.size(); ++j)
	    {
	    	char* pEnd;
	    	hoursArray[j + offset] = strtof(hoursArrayS[j].c_str(),&pEnd);
	    	temperaturesArray[j + offset] = strtof(tempsArrayS[j].c_str(),&pEnd);
	    	// printf("%i\n", (j + offset));
	    	// printf("%f\n", hoursArray[j + offset]);
	    }
		hoursFile.close();
		tempsFile.close();
			/* code */
	}
	cudaMemcpy(cudaHours, hoursArray, N*sizeof(float), cudaMemcpyHostToDevice);
	cudaMemcpy(cudaTemperatures, temperaturesArray, N*sizeof(float), cudaMemcpyHostToDevice);
	// Statistics calcs
	float *totalTemps, *totalHours, *vairanceHours, *vairanceTemperature, *meanHours, *meanTemperature, standardDeviationTemperature;
	float *totalTempsCuda, *totalHoursCuda, *vairanceHoursCuda, *vairanceTemperatureCuda, *meanHoursCuda, *meanTemperatureCuda;
	totalTemps = (float*)malloc(1*sizeof(float));
	totalHours = (float*)malloc(1*sizeof(float));
	vairanceHours = (float*)malloc(1*sizeof(float));
	vairanceTemperature = (float*)malloc(1*sizeof(float));
	meanHours = (float*)malloc(1*sizeof(float));
	meanTemperature = (float*)malloc(1*sizeof(float));
	cudaMalloc(&totalTempsCuda, 1*sizeof(float));
	cudaMalloc(&totalHoursCuda, 1*sizeof(float));
	cudaMalloc(&vairanceHoursCuda, 1*sizeof(float));
	cudaMalloc(&vairanceTemperatureCuda, 1*sizeof(float));
	cudaMalloc(&meanHoursCuda, 1*sizeof(float));
	cudaMalloc(&meanTemperatureCuda, 1*sizeof(float));
	// totalHours = 0.0f;
	// totalTemps = 0.0f;
	// vairanceHours = 0.0f;
	// vairanceTemperature = 0.0f;
	getTotal<<<hoursArrayS.size()/4, 4>>>(hoursArrayS.size(), cudaHours, totalHoursCuda);
	getTotal<<<hoursArrayS.size()/4, 4>>>(hoursArrayS.size(), cudaTemperatures, totalTempsCuda);

	cudaDeviceSynchronize();
	cudaMemcpy(totalHours, totalHoursCuda, 1*sizeof(float), cudaMemcpyHostToDevice);
	cudaMemcpy(totalTemps, totalTempsCuda, 1*sizeof(float), cudaMemcpyHostToDevice);
	printf("%f\n", totalHours[0]);
	meanTemperature[0] = totalTemps[0]/N;
	meanHours[0] = totalHours[0]/N;
	cudaMemcpy(meanTemperatureCuda, meanTemperature, 1*sizeof(float), cudaMemcpyHostToDevice);
	cudaMemcpy(meanHoursCuda, meanHours, 1*sizeof(float), cudaMemcpyHostToDevice);
	getVariance<<<hoursArrayS.size()/4, 4>>>(hoursArrayS.size(), cudaHours, meanHoursCuda, vairanceHoursCuda);
	getVariance<<<hoursArrayS.size()/4, 4>>>(hoursArrayS.size(), cudaTemperatures, meanTemperatureCuda, vairanceTemperatureCuda);

	cudaDeviceSynchronize();
	cudaMemcpy(vairanceHoursCuda, vairanceHours, 1*sizeof(float), cudaMemcpyHostToDevice);
	cudaMemcpy(vairanceTemperatureCuda, vairanceTemperature, 1*sizeof(float), cudaMemcpyHostToDevice);
	vairanceHours[0] = vairanceHours[0]/hoursArrayS.size();
	vairanceTemperature[0] = vairanceTemperature[0]/hoursArrayS.size();
	standardDeviationTemperature = sqrt(vairanceTemperature[0]);
	printf("La desviacion estandar de la temperatura entre las 13:00 - 16:00 fue de %f\n", standardDeviationTemperature);
	printf("La varianza de la temperatura entre las 13:00 - 16:00 fue de %f\n", vairanceTemperature[0]);
	printf("La media de la temperatura entre las 13:00 - 16:00 fue de %f\n", meanTemperature[0]);
    // for (int j= 0; j< N; ++j)
    // {
    // 	printf("%f\n", hoursArray[j]);
    // 	printf("%f\n", temperaturesArray[j]);
    // }
}