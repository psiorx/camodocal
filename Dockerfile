FROM nvidia/cuda:8.0-devel-ubuntu16.04

RUN apt-get update && apt-get install -y \
        git \
        cmake \
        build-essential \
        curl \
        libblas-dev \
        libopenblas-dev \
        libboost-all-dev \
        libeigen3-dev \
        libgoogle-glog-dev \
        openssl \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sSLO http://faculty.cse.tamu.edu/davis/SuiteSparse/SuiteSparse-4.2.1.tar.gz \
    && tar zxf SuiteSparse-4.2.1.tar.gz \
    && cd SuiteSparse \
    && make -j \
    && make install

RUN curl -sSLO https://github.com/opencv/opencv/archive/2.4.8.tar.gz \
    && tar zxf 2.4.8.tar.gz \
    && curl -sSL https://github.com/opencv/opencv/commit/60a5ada4541e777bd2ad3fe0322180706351e58b.patch | patch -d opencv-2.4.8 -p1 \
    && curl -sSL https://github.com/opencv/opencv/commit/10896129b39655e19e4e7c529153cb5c2191a1db.patch | patch -d opencv-2.4.8/modules/gpu -p3 \
    && cd opencv-2.4.8 \
    && cmake -D CMAKE_BUILD_TYPE=Release -DWITH_CUDA=OFF -DWITH_OPENCL=OFF . \
    && make \
    && make install \
    && cd .. \
    && rm -rf opencv-2.4.8
ENV CMAKE_PREFIX_PATH=/usr/local:$CMAKE_PREFIX_PATH

RUN mkdir -p /camodocal
WORKDIR /camodocal

COPY . /camodocal

RUN mkdir build \
    && cd build \
    && cmake .. \
    && make
