ARG TRITON_VERSION="22.04"

FROM quay.io/condaforge/mambaforge:4.11.0-0 AS mambaforge

RUN echo $(which mamba)

RUN mamba install --yes conda-lock>=1.0 conda-pack

FROM nvcr.io/nvidia/tritonserver:${TRITON_VERSION}-py3

COPY --from=mambaforge /opt/conda /opt/conda
COPY --from=mambaforge /root/.bashrc /root/.bashrc

WORKDIR /root

# Update the CUDA Linux GPG Repository Key, see: https://developer.nvidia.com/blog/updating-the-cuda-linux-gpg-repository-key/
RUN apt-key del 7fa2af80 && \
    wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.0-1_all.deb && \
    dpkg -i cuda-keyring_1.0-1_all.deb

# Install system dependencies.
# Make sure latest version of cmake gets installed, see: https://askubuntu.com/a/865294
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /etc/apt/trusted.gpg.d/kitware.gpg >/dev/null && \
    apt-add-repository "deb https://apt.kitware.com/ubuntu/ $(lsb_release -cs) main" && \
    apt-get update && apt-get -y install cmake rapidjson-dev libarchive-dev zlib1g-dev

COPY entrypoint.sh .

CMD [ "./entrypoint.sh"]
