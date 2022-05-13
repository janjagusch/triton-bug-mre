# triton-bug-mre

A minimal reproducible example for a bug encountered in Triton.

## Instructions

Build the image:

```sh
docker build .\
    --tag "triton-custom-python-backend-stub-builder" \
    --file "Dockerfile"
```

Create the Python backend stub:

```sh
docker run \
    -v $(pwd)/artefacts:/root/artefacts \
    triton-custom-python-backend-stub-builder
```

Copy the Python backend stub into the model repository:

```
cp ./artefacts/triton_python_backend_stub ./models/add_sub/
```

Start the Trition server:

```
docker run \
    --shm-size 1500000000 \
    --rm -p8000:8000 -p8001:8001 -p8002:8002 -v $(pwd)/models:/models \
    nvcr.io/nvidia/tritonserver:22.04-py3 tritonserver \
        --model-repository=/models
```

Which will cause the following error:

```
I0513 07:05:21.037698 1 model_repository_manager.cc:1077] loading: add_sub:1
I0513 07:05:21.157577 1 python.cc:2054] TRITONBACKEND_ModelInstanceInitialize: add_sub_0 (CPU device 0)
bash: /models/add_sub/triton_python_backend_stub: Operation not permitted
bash: /models/add_sub/triton_python_backend_stub: Success
```

You can see that the server is unresponsive by running the Python test script (you will need to have `tritonclient` installed, for examlpe by executing `mamba env create && conda activate triton-bug-mre`):

```
python test_server.py
```

Which raises `geventhttpclient.response.HTTPConnectionClosed: connection closed.`.

## Hardware

I built this example on:

MacBook Pro (13-inch, 2020, Four Thunderbolt 3 ports)
2,3 GHz Quad-Core Intel Core i7
16 GB 3733 MHz LPDDR4X
macOS Monterey 12.2 (21D49)
