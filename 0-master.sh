#!/bin/bash

# Execute this file to perform all data transformation and analyses in Ball et al. (2020).
# Raw data are the data Strumia shared directly with Erin Hengel in November 2019.
python 1-import.py
stata-mp -s 2-transform.do
stata-mp -s 3-analyse.do
	
# Trim white space around figures 1 and 2.
convert -density 400 figures/distributions.pdf -trim figures/distributions.png
convert -density 400 figures/coeffs.pdf -trim figures/coeffs.png

# Remove unnecessary files.
rm 2-transform.smcl
rm 3-analyse.smcl
rm figures/coeffs.pdf
rm figures/distributions.pdf
