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
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/r-reticulate

ENV RETICULATE_PYTHON=/opt/r-reticulate/bin/python
ENV PATH=/opt/r-reticulate/bin:${PATH}

RUN python -m pip install --no-cache-dir --upgrade pip setuptools wheel && \
    python -m pip install --no-cache-dir \
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
      statsmodels \
      pybabynames \
      pylahman \
      patchworklib

RUN python -m ipykernel install \
    --name r-reticulate \
    --display-name "Python (r-reticulate)"

RUN R -e "install.packages(c('reticulate', 'remotes', 'IRkernel', 'knitr', 'rmarkdown', 'mdsr', 'lubridate', 'Lahman', 'googlesheets4', 'babynames', 'rvest', 'NHANES', 'patchwork', 'mosaicData', 'bench', 'MASS'), repos = 'https://cloud.r-project.org')" && \
    R -e "IRkernel::installspec(user = FALSE)"

ARG NB_USER=rstudio
ARG NB_UID=1000

ENV USER=${NB_USER}
ENV NB_USER=${NB_USER}
ENV NB_UID=${NB_UID}
ENV HOME=/home/${NB_USER}

RUN if ! id -u ${NB_USER} >/dev/null 2>&1; then \
      useradd -m -s /bin/bash -u ${NB_UID} ${NB_USER}; \
    fi && \
    mkdir -p ${HOME} && \
    chown -R ${NB_USER}:${NB_USER} ${HOME} /opt/r-reticulate

COPY . ${HOME}

RUN if [ -f ${HOME}/_site/hw03.ipynb ]; then cp ${HOME}/_site/hw03.ipynb ${HOME}/hw03.ipynb; fi && \
    if [ -f ${HOME}/_site/hw03.html ]; then cp ${HOME}/_site/hw03.html ${HOME}/hw03.html; fi && \
    chown -R ${NB_USER}:${NB_USER} ${HOME}

USER ${NB_USER}
WORKDIR ${HOME}

ENTRYPOINT []
