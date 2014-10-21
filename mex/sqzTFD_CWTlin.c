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

void sqzTFD_CWTlin(double *w, double *freq, double *tfdr, double *tfdi, int n, int nscale, int nalpha, int scale, int nvoice, int nfreq, double freqlow, double alpha, double *stfdr, double *stfdi)
{
	mwIndex b, kscale, k, count = 0;
    double qscale, ha, hb;
    
    ha = *(freq+1)-*(freq);
    
	for (b=0; b<n; b++) {
                
		for (kscale=0; kscale<nscale; kscale++) {
            
            qscale = scale * pow(2,(kscale+1)/nvoice);
            hb = sqrt(qscale)*log(2)/(ha * nvoice);
            
            if ( (*(w+count) < 1e9) && (*(w+count) > 0)){
            
                k = floor((*(w+count) - freqlow)/alpha);
                
                if ((k>=0) && (k<nfreq)){
                    
                     *(stfdr+b*nalpha+k) += *(tfdr+count) * hb;
                     *(stfdi+b*nalpha+k) += *(tfdi+count) * hb;
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
	/*stfd=sqzTFD_core(w, freq, tfd, n, nscale, nalpha, squeezing.TFR.scale, squeezing.TFR.voice, squeezing.freqrange.low, alpha);*/
	double *w, *freq, *tfdr, *tfdi, *stfdr, *stfdi;
	int n, nscale, nfreq, nalpha, scale, nvoice;
    double freqlow, alpha;

	/*  Get the scalar inputs */
	n               = (int)mxGetScalar(prhs[3]);
	nscale			= (int)mxGetScalar(prhs[4]);
    nalpha			= (int)mxGetScalar(prhs[5]);
    scale			= (int)mxGetScalar(prhs[6]);
    nvoice			= (int)mxGetScalar(prhs[7]);
	freqlow			= (double)mxGetScalar(prhs[8]);
    alpha			= (double)mxGetScalar(prhs[9]);

	/*  Create a pointer to the input matrices . */
	w                = mxGetPr(prhs[0]);
    freq             = mxGetPr(prhs[1]);
	tfdr             = mxGetPr(prhs[2]);
    tfdi             = mxGetPi(prhs[2]);
    nfreq = mxGetN(prhs[1]);

	/*  Set the output pointer to the output matrix. */
	plhs[0] = mxCreateDoubleMatrix(nalpha, n, mxCOMPLEX);

	/*  Create a C pointer to a copy of the output matrix. */
	stfdr = mxGetPr(plhs[0]);
    stfdi = mxGetPi(plhs[0]);

	/*  Call the C subroutine. */
	sqzTFD_CWTlin(w, freq, tfdr, tfdi, n, nscale, nalpha, scale, nvoice, nfreq, freqlow, alpha, stfdr, stfdi);

}