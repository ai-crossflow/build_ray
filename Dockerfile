FROM crossflowai/ray_builder AS builder

ARG RAY_VERSION=1.6.0

RUN bazel version
RUN conda info

ENV RAY_INSTALL_JAVA=0
ENV RAY_INSTALL_CPP=0

RUN git clone -b ray-${RAY_VERSION} --depth 1 https://github.com/ray-project/ray.git
RUN cd ray \
    && sed -i s/6.0.10.tar.gz/6.0.15.tar.gz/g bazel/ray_deps_setup.bzl \
    && sed -i s/900cb82227bac58242c9b7668e7113cd952253b256fe04bbdab1b78979cf255a/00e65fae3307bf73a1197dda7f533f06d8688eb8e097f49cd3bd0958f3ffa5c5/g bazel/ray_deps_setup.bzl
RUN cd ray && bazel build //:ray_pkg
RUN cd ray/dashboard/client && npm install && npm run build
RUN cd ray/python && python setup.py bdist_wheel \
    && RAY_INSTALL_CPP=1 python setup.py bdist_wheel && pip cache purge

FROM condaforge/miniforge3:4.9.2-7
ENV RAY_VERSION=1.6.0
COPY --from=builder /ray/python/dist/ /dist
RUN conda install -y psutil && conda clean --all --yes
RUN pip install /dist/ray-${RAY_VERSION}-cp38-cp38-linux_$(uname -m).whl[default] && pip cache purge

CMD  ["/bin/sh"]

