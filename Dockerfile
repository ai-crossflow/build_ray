FROM ubuntu:bionic

ENV BAZEL_VERSION 4.1.0

RUN apt-get -qq update && apt-get -qq -y install curl gnupg git build-essential unzip psmisc \
        make g++ pkg-config openjdk-8-jdk libboost-all-dev libmsgpack-dev libgflags-dev googletest \
    && apt-get -qq -y autoremove \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* /var/log/dpkg.log

RUN if [ "$(uname -m)" = "aarch64" ]; then \
        curl -fsSL https://github.com/bazelbuild/bazel/releases/download/4.1.0/bazel-4.1.0-linux-arm64 -o /tmp/bazel ; \
    else \
        curl -fsSL https://github.com/bazelbuild/bazel/releases/download/4.1.0/bazel-4.1.0-linux-x86_64 -o /tmp/bazel ; \
    fi \
    && chmod +x /tmp/bazel \
    && mv /tmp/bazel /usr/local/bin/
    
RUN curl -fsSL https://deb.nodesource.com/setup_12.x | bash - \
    && apt-get -qq update \
    && apt-get -qq -y install nodejs \
    && apt-get -qq -y autoremove \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* /var/log/dpkg.log
    
RUN curl -sSL  https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-$(uname -m).sh -o /tmp/miniforge.sh \
    && bash /tmp/miniforge.sh -bfp /usr/local \
    && rm -rf /tmp/miniforge.sh \
    && conda install -y python=3.8 \
    && conda clean --all --yes

RUN bazel version
RUN conda info

CMD  ["/bin/sh"]
