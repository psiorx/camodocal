FROM ubuntu:16.04

ENV HOME /root
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get install -y --force-yes build-essential cmake git libgtk2.0-dev pkg-config libavcodec-dev libavformat-dev libswscale-dev \
                    libtbb2 libtbb-dev libjpeg-dev libpng-dev libtiff-dev libjasper-dev libdc1394-22-dev liblapacke-dev checkinstall \
                    python3-dev python3-tk python3-numpy curl libblas-dev libopenblas-dev libboost-all-dev libeigen3-dev libgoogle-glog-dev openssl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* \
           /tmp/* \
           /var/tmp/*

RUN mkdir ~/opencv

RUN cd ~/opencv && git clone https://github.com/Itseez/opencv_contrib.git && cd opencv_contrib && git checkout 3.2.0
RUN cd ~/opencv && git clone https://github.com/Itseez/opencv.git && cd opencv && git checkout 3.2.0

RUN cd ~/opencv/opencv && mkdir release && cd release && \
          cmake -D CMAKE_BUILD_TYPE=RELEASE \
          -D CMAKE_INSTALL_PREFIX=/usr/local \
          -D OPENCV_EXTRA_MODULES_PATH=../../opencv_contrib/modules \
          -D INSTALL_C_EXAMPLES=ON \
          -D INSTALL_PYTHON_EXAMPLES=ON \
          -D BUILD_EXAMPLES=ON \
          -D WITH_OPENGL=ON \
          -D WITH_V4L=ON \
          -D WITH_XINE=ON \
          -D WITH_TBB=ON ..

RUN cd ~/opencv/opencv/release && make -j $(nproc) && make install

RUN curl -sSLO http://faculty.cse.tamu.edu/davis/SuiteSparse/SuiteSparse-4.2.1.tar.gz \
    && tar zxf SuiteSparse-4.2.1.tar.gz \
    && cd SuiteSparse \
    && make -j \
    && make install

ENV CMAKE_PREFIX_PATH=/usr/local:$CMAKE_PREFIX_PATH

RUN mkdir -p /camodocal
WORKDIR /camodocal

COPY . /camodocal

RUN mkdir build \
    && cd build \
    && cmake .. \
    && make -j



