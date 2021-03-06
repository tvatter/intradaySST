Non-Parametric Estimation of Intraday Spot Volatility: Disentangling Instantaneous Trend and Seasonality
================================================================

Overview
--------

This is the code which accompanies the paper ["Non-Parametric Estimation of Intraday Spot Volatility: Disentangling Instantaneous Trend and Seasonality"](http://papers.ssrn.com/sol3/papers.cfm?abstract_id=2330159)
by Thibault Vatter, Hau-Tieng Wu, Valerie Chavez-Demoulin and Bin Yu.

The code is written in [MATLAB](http://www.mathworks.it/products/matlab/); it
provides functions to clean intraday FX prices and apply the Synchrosqueezing transform to extract the trend and seasonality from the returns volatilities.

The code uses some MATLAB MEX files written in C, which need to be compiled; in
case a compiler is not available, it will still work, but it will use (much)
slower fallbacks written in MATLAB code.

Usage
--------

Open and run the file setup.m for examples.
