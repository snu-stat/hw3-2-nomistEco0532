FROM rocker/tidyverse:4.4.0

USER root

RUN apt-get update && apt-get install -y \
    wget \
    git \
    imagemagick \
    libmagick++-dev \
    && rm -rf /var/lib/apt/lists/*

ENV CONDA_DIR=/opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    /bin/bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh

ENV PATH=$CONDA_DIR/bin:$PATH

RUN conda config --add channels conda-forge && \
    conda config --set channel_priority strict && \
    conda install -y python=3.10 numpy pandas matplotlib && \
    conda clean -afy

RUN R -e "install.packages(c('reticulate', 'remotes', 'IRkernel'))" && \
    R -e "IRkernel::installspec(user = FALSE)"

ENV RETICULATE_PYTHON=/opt/conda/bin/python

RUN useradd -m -s /bin/bash jovyan && \
    chown -R jovyan:jovyan /opt/conda /home/jovyan

USER jovyan
WORKDIR /home/jovyan
