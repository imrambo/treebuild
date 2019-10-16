#!/bin/bash
envName=$1
conda create -n $envName python=3.7 && \
conda install -n $envName -c conda-forge scons && \
conda install -n $envName -c anaconda numpy pandas && \
conda install -n $envName -c bioconda iqtree
