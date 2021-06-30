FROM ubuntu:bionic

RUN apt-get -qq update && apt-get -qq -y install curl bzip2 \
    && curl -sSL  https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-$(uname -m).sh -o /tmp/miniforge.sh \
    && bash /tmp/miniforge.sh -bfp /usr/local \
    && rm -rf /tmp/miniforge.sh \
    && conda install -y python=2.7 \
    && conda update conda \
    && apt-get -qq -y remove curl bzip2 \
    && apt-get -qq -y autoremove \
    && apt-get autoclean \
    && rm -rf /var/lib/apt/lists/* /var/log/dpkg.log \
    && conda clean --all --yes
RUN which python conda

CMD  ["/bin/sh"]
