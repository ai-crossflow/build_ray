FROM crossflowai/ray_builder

ARG RAY_VERSION=1.4.1

RUN bazel version
RUN conda info

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
