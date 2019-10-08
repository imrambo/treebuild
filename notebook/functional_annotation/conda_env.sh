#!/bin/bash
#Conda environment
envName=$1
conda create -n $envName python=3.7
conda install -n $envName nb_conda_kernels
conda install -c r -n $envName rpy2 r-ggplot2 r-dplyr
conda install -c conda-forge -n $envName r-vegan
conda install -c anaconda -n $envName numpy pandas
