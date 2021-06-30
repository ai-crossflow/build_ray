FROM ubuntu:bionic

ENV BAZEL_VERSION 4.1.0

RUN apt-get -qq update && apt-get -qq -y install curl wget gnupg \
    && curl -fsSL https://bazel.build/bazel-release.pub.gpg | gpg --dearmor > bazel.gpg \
    && mv bazel.gpg /etc/apt/trusted.gpg.d/
RUN if [ "$(uname -m)" = "aarch64" ]; then \
        echo "deb [arch=arm64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list ; \
    else \
        echo "deb [arch=amd64] https://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list ; \
    fi \
    && apt-get -y update \
    && apt-get install bazel
RUN curl -sSL  https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-$(uname -m).sh -o /tmp/miniforge.sh \
    && bash /tmp/miniforge.sh -bfp /usr/local \
    && rm -rf /tmp/miniforge.sh \
    && conda install -y python=3.9 \
    && conda update conda \
    && apt-get -qq -y remove curl bzip2 \
    && apt-get -qq -y autoremove \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* /var/log/dpkg.log \
    && conda clean --all --yes
    
#RUN if [ "$(uname -m)" = "aarch64" ]; then \
#        wget https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-linux-arm64 -o /tmp/bazel ; \
#    else \
#        wget https://github.com/bazelbuild/bazel/releases/download/${BAZEL_VERSION}/bazel-${BAZEL_VERSION}-linux-x86_64 -o /tmp/bazel ; \
#    fi \
#    && chmod +x /tmp/bazel \
#    && mv /tmp/bazel /usr/local/bin/
RUN bazel version
RUN conda install jupyterlab scipy
CMD  ["/bin/sh"]
