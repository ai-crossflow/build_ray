FROM crossflowai/ray_builder AS builder

ARG RAY_VERSION=1.6.0

RUN bazel version
RUN conda info

ENV RAY_INSTALL_JAVA=0
ENV RAY_INSTALL_CPP=0

RUN git clone -b ray-${RAY_VERSION} --depth 1 https://github.com/ray-project/ray.git \
    && cd ray && bazel build //:ray_pkg && cd .. \
    && cd ray/dashboard/client && npm install && npm run build && cd ../../.. \
    && cd ray/python && python setup.py bdist_wheel \
    && RAY_INSTALL_CPP=1 python setup.py bdist_wheel && pip cache purge

FROM condaforge/miniforge3
COPY --from builder 


CMD  ["/bin/sh"]

