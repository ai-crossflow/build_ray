FROM crossflowai/ray_builder

ARG RAY_VERSION=1.4.1

RUN bazel version
RUN conda info

# build ray
RUN conda install -y jupyterlab cython=0.29 grpcio protobuf scipy aiohttp gpustat jsonschema msgpack-python pydantic pyyaml psutil \
                     blessings multidict yarl uvicorn requests pandas lz4-c
                   
RUN pip install redis py-spy aioredis click opencensus filelock aiohttp-cors starlette fastapi tensorboardx tabulate colorama prometheus-client \
        flask 

RUN git clone -b ray-${RAY_VERSION} --depth 1 https://github.com/ray-project/ray.git
RUN cd ray && bazel build //:ray_pkg
RUN cd ray && bazel build //cpp:ray_cpp_pkg
RUN cd ray && bazel build //java:ray_java_pkg
RUN cd ray/dashboard/client \
    && npm install \
    && npm run build \
    && cd ../../.. \
    && cd ray/python \
    && pip install -e . \
    && pip cache purge
    
CMD  ["/bin/sh"]
