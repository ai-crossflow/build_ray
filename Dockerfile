FROM ubuntu:bionic

ENV BAZEL_VERSION 4.1.0
RUN apt-get -qq update && apt-get -qq -y install  bzip2 apt-transport-https curl gnupg \
    && curl -sSL  https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-$(uname -m).sh -o /tmp/miniforge.sh \
    && bash /tmp/miniforge.sh -bfp /usr/local \
    && rm -rf /tmp/miniforge.sh \
    && conda install -y python=3.9 \
    && conda update conda \
    && apt-get -qq -y remove curl bzip2 \
    && apt-get -qq -y autoremove \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* /var/log/dpkg.log \
    && conda clean --all --yes
    
RUN if [ "$(uname -m)" = "aarch64" ]; then \
        curl -sSL https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-linux-arm64 -o /tmp/bazel \
    else \
        curl -sSL https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-linux-amd64 -o /tmp/bazel \
    fi \
    && chmod +x /tmp/bazel \
    && mv /tmp/bazel /usr/local/bin/
    
RUN bazel version
RUN conda install jupyterlab

CMD  ["/bin/sh"]
