#!/usr/bin/env bash

set -eux

eval "$(/opt/conda/bin/conda shell.posix activate base)"

export PYTHONNOUSERSITE=True

mamba install --yes python=3.10

# Taken from: https://github.com/triton-inference-server/python_backend#1-building-custom-python-backend-stub
git clone https://github.com/triton-inference-server/python_backend -b "r${NVIDIA_TRITON_SERVER_VERSION}"

pushd python_backend
mkdir build && cd build
# Taken from: https://github.com/triton-inference-server/server/issues/4340#issuecomment-1119054014
cmake -DTRITON_ENABLE_GPU=ON -DCMAKE_INSTALL_PREFIX:PATH=`pwd`/install \
  -D TRITON_BACKEND_REPO_TAG="r${NVIDIA_TRITON_SERVER_VERSION}" \
  -D TRITON_COMMON_REPO_TAG="r${NVIDIA_TRITON_SERVER_VERSION}" \
  -D TRITON_CORE_REPO_TAG="r${NVIDIA_TRITON_SERVER_VERSION}"  \
  ..
make triton-python-backend-stub
ldd triton_python_backend_stub
cp triton_python_backend_stub "/root/artefacts/triton_python_backend_stub"
popd
