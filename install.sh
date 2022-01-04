#!/data/data/com.termux/files/usr/bin/bash

# Abort on any errors
set -e

# XMRig and HWLOC version
XMRIG_VERSION=6.16.2
HWLOC_VERSION=2.7.0

# Preferred threads for compile
CORES=4

CURRENT_DIR=$(basename "$0")
cd ${CURRENT_DIR}

[[ ! -d src/ ]] && mkdir src
mkdir src/built

# Install dependencies
pkg install git build-essential binutils wget

# Get HWLOC tarball
wget https://download.open-mpi.org/release/hwloc/v${HWLOC_VERSION:0:-2}/hwloc-${HWLOC_VERSION}.tar.gz
tar -xzvf hwloc-${HWLOC_VERSION}.tar.gz -C src/
rm -rf hwloc-${HWLOC_VERSION}.tar.gz

# Install HWLOC
mkdir ${CURRENT_DIR}/src/built/hwloc-${HWLOC_VERSION}
cd src/hwloc-${HWLOC_VERSION}
./configure --prefix=${CURRENT_DIR}/src/built/hwloc-${HWLOC_VERSION}
make -j${CORES}
make install

cd ${CURRENT_DIR}/src

# Clone XMRig and checkout to latest version
git clone -q https://github.com/xmrig/xmrig.git xmrig-v${XMRIG_VERSION} && cd xmrig-v${XMRIG_VERSION}
git checkout v${XMRIG_VERSION}

# Install XMRig
mkdir ${CURRENT_DIR}/src/built/xmrig-v${XMRIG_VERSION}
cd src/xmrig-v${XMRIG_VERSION}
mkdir build && cd build
cmake .. \
  -DHWLOC_INCLUDE_DIR=/data/data/com.termux/files/home/xmrig-on-termux/src/built/hwloc-${HWLOC_VERSION}/include \
  -DHWLOC_LIBRARY=/data/data/com.termux/files/home/xmrig-on-termux/src/built/hwloc-${HWLOC_VERSION}/lib/libhwloc.so
make -j${CORES}

# Copy XMRig binary to src/built
cp ./xmrig ${CURRENT_DIR}/src/built/xmrig-v${XMRIG_VERSION}

