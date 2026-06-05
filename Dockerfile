# 1. 기반 이미지 설정 (latest가 아닌 명시적 태그)
FROM rocker/tidyverse:4.4.0

# 2. 시스템 의존성 설치 (ImageMagick 포함)
USER root
RUN apt-get update && apt-get install -y \
    wget \
    git \
    imagemagick \
    libmagick++-dev \
    && rm -rf /var/lib/apt/lists/*

# 3. Miniconda 설치
ENV CONDA_DIR=/opt/conda
RUN wget --quiet https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    /bin/bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh

# 4. Conda 경로 설정
ENV PATH=/opt/conda/bin:$PATH

# Anaconda 기본 채널 ToS 자동 수락 (2025-07 이후 비대화형 빌드에서 필수)
ENV CONDA_PLUGINS_AUTO_ACCEPT_TOS=yes

# 환경 생성 및 패키지 설치
RUN conda create -p /opt/conda/envs/r-reticulate python=3.10 -y && \
    conda install -p /opt/conda/envs/r-reticulate -c conda-forge \
    numpy pandas matplotlib scipy statsmodels seaborn polars requests beautifulsoup4 ipykernel session-info -y
    
# 5. Jupyter 본체 설치 (base conda, PATH에 노출됨) + Python 커널 등록
#    IRkernel::installspec 보다 먼저 와야 'ir' 커널이 올바른 prefix에 등록됨
RUN /opt/conda/bin/conda install -n base -c conda-forge jupyterlab notebook -y && \
    /opt/conda/envs/r-reticulate/bin/python -m ipykernel install \
        --prefix=/opt/conda --name python3 --display-name "Python (r-reticulate)"

# 6. R 패키지 설치 (reticulate 및 필수 패키지) + R 커널 등록
RUN R -e "install.packages(c( \
    'reticulate', \
    'tidyverse', \
    'mdsr', \
    'lubridate', \
    'Lahman', \
    'googlesheets4', \
    'babynames', \
    'rvest', \
    'bench', \
    'NHANES', \
    'patchwork', \
    'mosaicData', \
    'IRkernel', \
    'remotes' \
), repos='https://cloud.r-project.org')" && \
    R -e "IRkernel::installspec(user = FALSE)"

# 7. reticulate가 사용할 Python 경로 고정
ENV RETICULATE_PYTHON=/opt/conda/envs/r-reticulate/bin/python

# 8. Binder 사용자 설정
#    rocker 이미지엔 이미 UID 1000인 'rstudio' 사용자가 존재하므로 새로 만들지 않음
#    (표준 binder의 'adduser --uid 1000 jovyan'은 UID 1000 충돌을 일으키므로 사용 금지)
ARG NB_USER=rstudio
ARG NB_UID=1000
ENV USER=${NB_USER} \
    NB_UID=${NB_UID} \
    HOME=/home/${NB_USER}

# 9. 저장소 내용을 홈으로 복사하고 소유권 변경
COPY . ${HOME}
USER root
RUN chown -R ${NB_UID} ${HOME} /opt/conda
USER ${NB_USER}
WORKDIR ${HOME}

# 10. 기본 실행 명령
CMD ["jupyter", "notebook", "--ip", "0.0.0.0"]
