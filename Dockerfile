FROM rocker/tidyverse:4.4.0

LABEL org.opencontainers.image.source="https://github.com/snu-stat/hw3-2-nomistEco0532"
LABEL org.opencontainers.image.description="R and Python environment for Homework 3"

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    git \
    ca-certificates \
    imagemagick \
    libmagick++-dev \
    && rm -rf /var/lib/apt/lists/*

ENV CONDA_DIR=/opt/conda
ENV PATH=${CONDA_DIR}/bin:${PATH}

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    /bin/bash /tmp/miniconda.sh -b -p ${CONDA_DIR} && \
    rm /tmp/miniconda.sh && \
    conda clean -afy

RUN conda config --system --add channels conda-forge && \
    conda config --system --set channel_priority strict

RUN conda create -n r-reticulate -y \
    python=3.10 \
    pip \
    openssl \
    expat

ENV RETICULATE_PYTHON=/opt/conda/envs/r-reticulate/bin/python
ENV PATH=/opt/conda/envs/r-reticulate/bin:/opt/conda/bin:${PATH}

RUN conda install -n r-reticulate -y \
    requests \
    polars \
    pandas \
    numpy \
    plotnine \
    beautifulsoup4 \
    matplotlib \
    ipython \
    scipy \
    seaborn \
    patsy \
    statsmodels \
    ipykernel \
    && conda clean -afy

RUN python -m pip install --no-cache-dir \
    notebook \
    jupyterlab \
    jupyterhub \
    session-info \
    pybabynames \
    pylahman \
    patchworklib

RUN python -m ipykernel install \
    --sys-prefix \
    --name r-reticulate \
    --display-name "Python (r-reticulate)"

RUN python -c "import ssl; print(ssl.OPENSSL_VERSION)" && \
    python -c "import xml.parsers.expat; import pyexpat; print('pyexpat OK')" && \
    python -c "import session_info, requests, polars, pandas, numpy, pybabynames, plotnine, bs4, matplotlib, patchworklib, IPython, scipy, seaborn, patsy, pylahman, statsmodels; print('Python packages OK')"

RUN R -e "install.packages(c('reticulate', 'remotes', 'IRkernel', 'knitr', 'rmarkdown', 'mdsr', 'lubridate', 'Lahman', 'googlesheets4', 'babynames', 'rvest', 'NHANES', 'patchwork', 'mosaicData', 'bench'), repos = 'https://cloud.r-project.org')" && \
    R -e "IRkernel::installspec(user = FALSE)"

ARG NB_USER=rstudio
ARG NB_UID=1000

ENV USER=${NB_USER}
ENV NB_USER=${NB_USER}
ENV NB_UID=${NB_UID}
ENV HOME=/home/${NB_USER}

RUN mkdir -p ${HOME} && \
    chown -R ${NB_USER}:${NB_USER} ${HOME} ${CONDA_DIR}

COPY . ${HOME}

RUN test -f ${HOME}/_site/hw03.ipynb && \
    test -f ${HOME}/_site/hw03.html && \
    cp ${HOME}/_site/hw03.ipynb ${HOME}/hw03.ipynb && \
    cp ${HOME}/_site/hw03.html ${HOME}/hw03.html && \
    chown -R ${NB_USER}:${NB_USER} ${HOME}

USER ${NB_USER}
WORKDIR ${HOME}

ENTRYPOINT []
