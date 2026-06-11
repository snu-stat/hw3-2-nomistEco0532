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

RUN conda create -n r-reticulate python=3.10 -y && \
    conda install -n r-reticulate -c conda-forge numpy pandas matplotlib -y

RUN R -e "install.packages(c('reticulate', 'remotes', 'IRkernel'))" && \
    R -e "IRkernel::installspec(user = FALSE)"

ENV RETICULATE_PYTHON=/opt/conda/envs/r-reticulate/bin/python

RUN useradd -m -s /bin/bash jovyan && \
    chown -R jovyan:jovyan /opt/conda /home/jovyan

USER jovyan
WORKDIR /home/jovyan
