FROM rocker/tidyverse:4.4.0

LABEL org.opencontainers.image.source="https://github.com/snu-stat/hw3-2-nomistEco0532"
LABEL org.opencontainers.image.description="R and Python environment for Homework 3"

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    git \
    imagemagick \
    libmagick++-dev \
    && rm -rf /var/lib/apt/lists/*

ENV CONDA_DIR=/opt/conda
ENV PATH=${CONDA_DIR}/bin:${PATH}

RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    /bin/bash /tmp/miniconda.sh -b -p ${CONDA_DIR} && \
    rm /tmp/miniconda.sh && \
    conda clean -afy

RUN conda create -n r-reticulate python=3.10 -y && \
    conda install -n r-reticulate -c conda-forge -y \
      pip \
      openssl \
      expat \
      libexpat \
      notebook \
      jupyterlab \
      jupyterhub \
      ipykernel \
      session-info \
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
      statsmodels && \
    conda run -n r-reticulate python -m pip install --no-cache-dir \
      pybabynames \
      pylahman \
      patchworklib && \
    conda clean -afy

ENV RETICULATE_PYTHON=/opt/conda/envs/r-reticulate/bin/python
ENV PATH=/opt/conda/envs/r-reticulate/bin:/opt/conda/bin:${PATH}

RUN R -e "install.packages(c('reticulate', 'remotes', 'IRkernel', 'knitr', 'rmarkdown', 'mdsr', 'lubridate', 'Lahman', 'googlesheets4', 'babynames', 'rvest', 'NHANES', 'patchwork', 'mosaicData', 'bench', 'MASS'), repos = 'https://cloud.r-project.org')" && \
    R -e "IRkernel::installspec(user = FALSE)"

COPY --chown=rstudio:rstudio _site/hw03.ipynb /home/rstudio/hw03.ipynb
COPY --chown=rstudio:rstudio _site/hw03.html /home/rstudio/hw03.html

USER rstudio
WORKDIR /home/rstudio

ENTRYPOINT []
