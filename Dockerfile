FROM crossflowai/ray_builder

ARG RAY_VERSION=1.5.0

RUN bazel version
RUN conda info

ENV RAY_INSTALL_JAVA=0
ENV RAY_INSTALL_CPP=0

RUN git clone -b ray-${RAY_VERSION} --depth 1 https://github.com/ray-project/ray.git \
    && cd ray && bazel build //:ray_pkg && cd .. \
    && cd ray/dashboard/client && npm install && npm run build && cd ../../.. \
    && conda install numpy aiohttp gpustat && conda clean --all --yes \
    && pip install py_spy aioredis \
    && cd ray/python && python setup.py install && pip cache purge && cd ../.. \
    && rm -rf ray

CMD  ["/bin/sh"]

