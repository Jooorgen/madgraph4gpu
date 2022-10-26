#!/bin/bash

helpFunction()
{
   echo ""
   echo "Usage: $0 -n gg_ttgg -b 1024 -t 128 -i 10"
   echo -e "\t-n Name of the physics process being built and run"
   echo -e "\t-b Blocks per grid"
   echo -e "\t-t Threads per block"
   echo -e "\t-i Iterations"
   exit 1 # Exit script after printing help
}

while getopts "n:b:t:i:" opt
do
   case "$opt" in
      n ) MG_PROC="$OPTARG" ;; #process to target
      b ) blocksPerGrid="$OPTARG" ;;
      t ) threadsPerBlock="$OPTARG" ;;
      i ) iterations="$OPTARG" ;;
      ? ) helpFunction ;; # Print helpFunction in case parameter is non-existent
   esac
done

# Print helpFunction in case parameters are empty

if [ -z "${MG_PROC}" ] || [ -z "${blocksPerGrid}" ] || [ -z "${threadsPerBlock}" ] || [ -z "${iterations}" ]
then
   echo "Some or all of the parameters are empty";
   helpFunction
fi

# Begin script in case all parameters are correct

##################################################################

# Set user specific variables

prefix=/afs/cern.ch/work/j/jteig
export CUDA_HOME=/usr/local/cuda-11.5/
export FC=`which gfortran`

# Set up compiler and compile options

export USEBUILDDIR=1
export NTPBMAX=1024
export MG_EXE="./gcheck.exe"
export WORKSPACE=$prefix/workspace_mg4gpu
export NAME_PREFIX="cudacpp_v100s_cuda_11.5"

##################################################################

# Sets CUDA in PATH

export PATH=$CUDA_HOME:$PATH

# Finds correct subprocess

case $MG_PROC in
    ee_mumu ) export MG_SUBPROC="P1_Sigma_sm_epem_mupmum" ;;
    gg_tt ) export MG_SUBPROC="P1_Sigma_sm_gg_ttx" ;;
    gg_ttg ) export MG_SUBPROC="P1_Sigma_sm_gg_ttxg" ;;
    gg_ttgg ) export MG_SUBPROC="P1_Sigma_sm_gg_ttxgg" ;;
    gg_ttggg ) export MG_SUBPROC="P1_Sigma_sm_gg_ttxggg" ;;
esac

# Makes workspace in correct folder

export MG_PROC_DIR=$prefix/madgraph4gpu/epochX/cudacpp/$MG_PROC
export MG_SP_DIR=$MG_PROC_DIR/SubProcesses/$MG_SUBPROC
export MG5AMC_CARD_PATH=$MG_PROC_DIR/Cards

mkdir -p $MG_SP_DIR/perf/data

# Build executable

cd $MG_SP_DIR
make

# Run executable

$MG_EXE -j $blocksPerGrid $threadsPerBlock $iterations

# Move JSON report to workspace

cd $MG_SP_DIR/pref/data/
mv 0-perf-test-run0.json ${WORKSPACE}/test_${NAME_PREFIX}_${MG_PROC}_${blocksPerGrid}_${threadsPerBlock}_${iterations}.json