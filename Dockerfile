FROM ubuntu:bionic

ENV BAZEL_VERSION 4.1.0
ENV RAY_VERSION 1.4.0

RUN apt-get -qq update && apt-get -qq -y install curl wget gnupg git build-essential unzip psmisc make g++ pkg-config openjdk-8-jdk \
    && curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > bazel.gpg \
    && mv bazel.gpg /etc/apt/trusted.gpg.d/
    
RUN curl -fsSL https://deb.nodesource.com/setup_12.x | bash - \
    && apt-get -qq update \
    && apt-get -qq -y install nodejs
    
RUN if [ "$(uname -m)" = "aarch64" ]; then \
        curl -fsSL https://github.com/bazelbuild/bazel/releases/download/4.1.0/bazel-4.1.0-linux-arm64 -o /tmp/bazel ; \
    else \
        curl -fsSL https://github.com/bazelbuild/bazel/releases/download/4.1.0/bazel-4.1.0-linux-x86_64 -o /tmp/bazel ; \
    fi \
    && chmod +x /tmp/bazel \
    && mv /tmp/bazel /usr/local/bin/
RUN curl -sSL  https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-$(uname -m).sh -o /tmp/miniforge.sh \
    && bash /tmp/miniforge.sh -bfp /usr/local \
    && rm -rf /tmp/miniforge.sh \
    && conda install -y python=3.8 \
    && conda update conda \
    && apt-get -qq -y remove curl bzip2 \
    && apt-get -qq -y autoremove \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* /var/log/dpkg.log \
    && conda clean --all --yes

RUN bazel version

# build ray
RUN conda install -y jupyterlab cython=0.29 grpcio protobuf scipy aiohttp gpustat jsonschema msgpack-python pydantic pyyaml psutil \
                     blessings multidict yarl uvicorn requests pandas lz4-c
                   
RUN pip install redis py-spy aioredis click opencensus filelock aiohttp-cors starlette fastapi tensorboardx tabulate colorama prometheus-client \
        flask 

#RUN git clone -b ray-${RAY_VERSION} --depth 1 https://github.com/ray-project/ray.git
RUN git clone --depth 1 https://github.com/ray-project/ray.git
RUN cd ray && bazel build //:ray_pkg
RUN cd ray && bazel build //cpp:ray_cpp_pkg
RUN cd ray && bazel build //java:ray_java_pkg
RUN cd ray/dashboard/client \
    && npm install \
    && npm run build \
    && cd ../../.. \
    && cd ray/python \
    && pip install -e .
    
CMD  ["/bin/sh"]
