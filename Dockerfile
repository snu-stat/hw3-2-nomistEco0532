# 1. 기반 이미지 설정
FROM rocker/tidyverse:4.4.0

# 2. 시스템 의존성 설치
USER root
RUN apt-get update && apt-get install -y \
    wget \
    git \
    imagemagick \
    libmagick++-dev \
    && rm -rf /var/lib/apt/lists/*

# 3. Miniconda 설치
ENV CONDA_DIR=/opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    /bin/bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh

# 4. Conda 경로 설정
ENV PATH=/opt/conda/bin:$PATH

# 5. Python 환경 생성 및 패키지 설치
# 기본 Anaconda 채널 대신 conda-forge만 사용
RUN conda create -p /opt/conda/envs/r-reticulate -c conda-forge --override-channels python=3.10 -y && \
    conda install -p /opt/conda/envs/r-reticulate -c conda-forge --override-channels -y \
      pip \
      "expat>=2.7.2" \
      numpy \
      pandas \
      matplotlib \
      scipy \
      statsmodels \
      seaborn \
      polars \
      requests \
      beautifulsoup4 \
      ipykernel \
      ipython \
      session-info \
      plotnine \
      patsy && \
    /opt/conda/envs/r-reticulate/bin/python -m pip install \
      pybabynames \
      pylahman \
      patchworklib && \
    /opt/conda/envs/r-reticulate/bin/python -c "import xml.parsers.expat; import pyexpat; print('pyexpat OK')" && \
    /opt/conda/envs/r-reticulate/bin/python -c "import session_info, requests, polars, pandas, numpy, pybabynames, plotnine, bs4, matplotlib, patchworklib, IPython, scipy, seaborn, patsy, pylahman, statsmodels; print('Python packages OK')" && \
    conda clean -afy

# 6. Jupyter 설치 + Python 커널 등록
# Binder는 Jupyter Notebook / JupyterLab이 필요함
RUN conda install -n base -c conda-forge --override-channels -y \
      jupyterlab \
      notebook \
      jupyterhub && \
    /opt/conda/envs/r-reticulate/bin/python -m ipykernel install \
      --prefix=/opt/conda \
      --name python3 \
      --display-name "Python (r-reticulate)" && \
    conda clean -afy

# 7. R 패키지 설치 + R 커널 등록
RUN R -e "install.packages(c('reticulate', 'remotes', 'IRkernel', 'knitr', 'rmarkdown', 'tidyverse', 'mdsr', 'lubridate', 'Lahman', 'googlesheets4', 'babynames', 'rvest', 'NHANES', 'patchwork', 'mosaicData', 'bench'), repos='https://cloud.r-project.org')" && \
    R -e "IRkernel::installspec(user = FALSE)"

# 8. reticulate가 사용할 Python 경로 고정
ENV RETICULATE_PYTHON=/opt/conda/envs/r-reticulate/bin/python
ENV LD_LIBRARY_PATH=/opt/conda/envs/r-reticulate/lib:/opt/conda/lib

# 9. Binder 사용자 설정
# rocker/tidyverse에는 UID 1000의 rstudio 사용자가 이미 있음
ARG NB_USER=rstudio
ARG NB_UID=1000

ENV USER=${NB_USER} \
    NB_UID=${NB_UID} \
    HOME=/home/${NB_USER}

# 10. 저장소 내용을 Binder 홈 디렉토리로 복사
COPY . ${HOME}

USER root
RUN chown -R ${NB_UID} ${HOME} /opt/conda

USER ${NB_USER}
WORKDIR ${HOME}

# 11. Binder가 넘기는 실행 명령을 받을 수 있게 설정
ENTRYPOINT []
CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]
