export DEBIAN_FRONTEND=noninteractive \
  && apt-get update \
  && apt-get install -y \
    vim git wget build-essential libssl-dev\
    g++ python3.6-dev gphoto2 libgphoto2-dev doxygen \
    libbz2-dev unzip libjpeg-dev libpng-dev \
    libtbb2 libtbb-dev libtiff5-dev libv4l-dev \
    libicu-dev autotools-dev axel\
  && apt-get autoclean && apt-get clean \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# cmake 3.16.6 installation
cd ~/Downloads \
  && wget https://cmake.org/files/v3.16/cmake-3.16.6.tar.gz \
  && tar xfz cmake-3.16.6.tar.gz \
  && rm cmake-3.16.6.tar.gz \
  && cd cmake-3.16.6/ \
  && ./bootstrap \
  && make -j8 install \
  && rm -rf ~/Downloads/cmake-3.16.6

# Boost 1.67 installation
cd ~/Downloads && wget https://sourceforge.net/projects/boost/files/boost/1.67.0/boost_1_67_0.tar.gz \
  && tar xfz boost_1_67_0.tar.gz \
  && rm boost_1_67_0.tar.gz \
  && cd boost_1_67_0 \
  && ./bootstrap.sh --with-python=/usr/bin/python3 --with-python-version=3.6 \
  && export CPLUS_INCLUDE_PATH="$CPLUS_INCLUDE_PATH:/usr/include/python3.6m/" \
  && ./b2 -j8 install \
  && cd /usr/local/lib \
  && ln -s libboost_python36.so libboost_python3.so \
  && ln -s libboost_python36.o libboost_python3.o \
  && ldconfig \
  && rm -rf /home/boost_1_67_0

# Cuda installation
cd ~/Downloads 
    && wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/cuda-ubuntu1804.pin \
    && mv cuda-ubuntu1804.pin /etc/apt/preferences.d/cuda-repository-pin-600 \
    && axel -a -n 16 http://developer.download.nvidia.com/compute/cuda/10.2/Prod/local_installers/cuda-repo-ubuntu1804-10-2-local-10.2.89-440.33.01_1.0-1_amd64.deb \
    && dpkg -i cuda-repo-ubuntu1804-10-2-local-10.2.89-440.33.01_1.0-1_amd64.deb \
    && apt-key add /var/cuda-repo-10-2-local-10.2.89-440.33.01/7fa2af80.pub \
    && apt-get update && apt-get -y install cuda  
    # && axel -a -n 8 https://developer.nvidia.com/compute/machine-learning/cudnn/secure/7.6.5.32/Production/10.2_20191118/Ubuntu18_04-x64/libcudnn7_7.6.5.32-1%2Bcuda10.2_amd64.deb \
    # && axel -a -n 8 https://developer.nvidia.com/compute/machine-learning/cudnn/secure/7.6.5.32/Production/10.2_20191118/Ubuntu18_04-x64/libcudnn7-dev_7.6.5.32-1%2Bcuda10.2_amd64.deb
    # && dpkg -i libcudnn7_7.6.5.32-1+cuda10.2_amd64.deb \
    # && dpkg -i libcudnn7-dev_7.6.5.32-1+cuda10.2_amd64.deb \
    # && apt-get update && apt-get install -y libcudnn7 libcudnn7-dev

# Docker installation
cd ~/Downloads \
    && apt-get update && apt-get install -y \
        apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs)  stable"
apt-get update && apt-get install -y docker-ce

# NVIDIA Docker installation
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | tee /etc/apt/sources.list.d/nvidia-docker.list
curl -s -L https://nvidia.github.io/nvidia-container-runtime/gpgkey | apt-key add -
curl -s -L https://nvidia.github.io/nvidia-container-runtime/$distribution/nvidia-container-runtime.list | tee /etc/apt/sources.list.d/nvidia-container-runtime.list
apt-get update && apt-get install -y nvidia-container-toolkit
  && apt-get install -y nvidia-container-runtime
tee /etc/docker/daemon.json <<EOF
{
    "runtimes": {
        "nvidia": {
            "path": "/usr/bin/nvidia-container-runtime",
            "runtimeArgs": []
        }
    },
    "default-runtime": "nvidia"
}
EOF
gpasswd -a $USER docker
systemctl restart docker
