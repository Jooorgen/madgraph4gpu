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

# Set user/SYCL-flags variables
prefix=/p/project/prpb109
export DPCPP_HOME=/p/project/prpb109/sycl_workspace
export CUDA_PATH=/p/software/juwelsbooster/stages/2022/software/CUDA/11.5
# export SYCLFLAGS="-fsycl -fsycl-targets=nvptx64-nvidia-cuda -target-backend '--cuda-gpu-arch=sm_80' -fgpu-rdc --cuda-path=$CUDA_PATH"
export SYCLFLAGS="-fsycl -fsycl-targets=nvptx64-nvidia-cuda -Xsycl-target-backend '--cuda-gpu-arch=sm_80' -fgpu-rdc --cuda-path=$CUDA_PATH"
export GPU_VERSION="sycl_v100_cuda_11.5_gcc_10.3"
export WORKSPACE=$prefix/workspace_mg4gpu

# Finds correct subprocess
case $MG_PROC in
    ee_mumu ) export MG_SUBPROC="P1_Sigma_sm_epem_mupmum" ;;
    gg_tt ) export MG_SUBPROC="P1_Sigma_sm_gg_ttx" ;;
    gg_ttg ) export MG_SUBPROC="P1_Sigma_sm_gg_ttxg" ;;
    gg_ttgg ) export MG_SUBPROC="P1_Sigma_sm_gg_ttxgg" ;;
    gg_ttggg ) export MG_SUBPROC="P1_Sigma_sm_gg_ttxggg" ;;
esac

export DEVICE_ID=0 #if unknown set at the run step after running LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$MG_LIBS $MG_EXE --param_card $MG5AMC_CARD_PATH/param_card.dat --device_info 1024 128 10

# Set up compiler and compile options
export USEBUILDDIR=1
export NTPBMAX=1024
export CXX=$DPCPP_HOME/llvm/build/bin/clang++

mkdir -p $WORKSPACE/mg4gpu/lib
mkdir -p $WORKSPACE/mg4gpu/bin

export MG4GPU_LIB=$WORKSPACE/mg4gpu/lib
export MG4GPU_BIN=$WORKSPACE/mg4gpu/bin

export MG_PROC_DIR=$prefix/madgraph4gpu/epochX/sycl/$MG_PROC
export MG_SP_DIR=$MG_PROC_DIR/SubProcesses/$MG_SUBPROC

export MG_LIBS_DIR="${MG4GPU_LIB}/build_${MG_PROC}_${MG_SUBPROC}_${GPU_VERSION}"
export MG_LIBS="$DPCPP_HOME/llvm/build/lib:$MG_LIBS_DIR"

export MG_EXE_DIR="${MG4GPU_BIN}/build_${MG_PROC}_${MG_SUBPROC}_${GPU_VERSION}"
export MG_EXE="$MG_EXE_DIR/check.exe"
export MG5AMC_CARD_PATH=$MG_PROC_DIR/Cards

# Build executable
cd $MG_SP_DIR
make
mv ../../lib/build.d_inl0/ $MG_LIBS_DIR #2>/dev/null; true
mv build.d_inl0/ $MG_EXE_DIR #2>/dev/null; true

# Run executable
cd $WORKSPACE

# Display the devices
#LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$MG_LIBS $MG_EXE --param_card $MG5AMC_CARD_PATH/param_card.dat --device_info 32 32 10

# Add MG Libs to linker library path and run the executable
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$MG_LIBS $MG_EXE -j --json_file $WORKSPACE/test_${GPU_VERSION}_${MG_PROC}_${MG_SUBPROC}_${blocksPerGrid}_${threadsPerBlock}_${iterations}.json --param_card $MG5AMC_CARD_PATH /param_card.dat --device_id $DEVICE_ID $blocksPerGrid $threadsPerBlock $iterations

# View output
#nano $WORKSPACE/test_${GPU_VERSION}_${MG_PROC}_${MG_SUBPROC}_${blocksPerGrid}_${threadsPerBlock}_${iterations}.json-+