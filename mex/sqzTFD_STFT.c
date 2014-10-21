/*
* sqzTFD_STFT.c -
* You can compile it and should work on any platform.
*
* Copyright: Thibault Vatter
* Based on Hau-tieng Wu's matlab code
*/

#include <math.h>
#include "mex.h"
#include "matrix.h"

void sqzTFD_STFT(double *w, double *tfdr, double *tfdi, int n, int nscale, int nalpha, int measure, double freqlow, double alpha, double *stfdr, double *stfdi)
{
	mwIndex b, jj, k, count = 0;

	for (b=0; b<n; b++) {
                
		for (jj=0; jj<nscale; jj++) {
            
            if (*(w+count) < 1e9){
            
                k = floor((*(w+count) - freqlow)/alpha)-1;
                
                if ((k>=0) && (k<nalpha)){
                    if (measure){
                                *(stfdr+b*nalpha+k) += 1;
                                *(stfdi+b*nalpha+k) += 1;            
                    }else{  
                                *(stfdr+b*nalpha+k) += *(tfdr+count);
                                *(stfdi+b*nalpha+k) += *(tfdi+count);
                    }
                }
            }
            
            count++;
		}
 	}
}


/* The gateway routine */
void mexFunction( int nlhs, mxArray *plhs[],
				 int nrhs, const mxArray *prhs[])
{
	/*stfd=sqzTFD_core(w, tfd, n, nscale, nalpha, squeezing.TFR.measure, squeezing.freqrange.low, alpha);*/
	double *w, *tfdr, *tfdi, *stfdr, *stfdi;
	int n, nscale, nalpha, measure;
    double freqlow, alpha;

	/*  Get the scalar inputs */
	n               = (int)mxGetScalar(prhs[2]);
	nscale			= (int)mxGetScalar(prhs[3]);
    nalpha			= (int)mxGetScalar(prhs[4]);
    measure			= (int)mxGetScalar(prhs[5]);
	freqlow			= (double)mxGetScalar(prhs[6]);
    alpha			= (double)mxGetScalar(prhs[7]);

	/*  Create a pointer to the input matrices . */
	w             = mxGetPr(prhs[0]);
	tfdr           = mxGetPr(prhs[1]);
    tfdi           = mxGetPi(prhs[1]);

	/*  Set the output pointer to the output matrix. */
	plhs[0] = mxCreateDoubleMatrix(nalpha, n, mxCOMPLEX);

	/*  Create a C pointer to a copy of the output matrix. */
	stfdr = mxGetPr(plhs[0]);
    stfdi = mxGetPi(plhs[0]);

	/*  Call the C subroutine. */
	sqzTFD_STFT(w, tfdr, tfdi, n, nscale, nalpha, measure, freqlow, alpha, stfdr, stfdi);

}