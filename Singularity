Bootstrap: docker   # Generate singularity container based on Docker image
From: ubuntu:22.04  # ubuntu:22.04

# %post is implemented when container is created
%post -c /bin/bash

    cd /

    # Prepare directories for installing applications
    mkdir -p apps       # -p: no error even parent directoty does not exists or directory already exists
    mkdir -p installers

    # Set Permissions
    chmod 755 /apps

    # Update all libraries
    apt-get -y update

    # Install xvfb
    apt-get -y install xvfb

    # Install ghostscript for pdf management
    apt-get -y install ghostscript

    apt-get -y install python3 python3-venv python3-pip
    ln -sf /usr/bin/python3 /usr/bin/python

    # Install source code
    cd /
    apt-get -y install git git-lfs gcc libpq-dev python3-dev python3-pip python3 python3-dev python3-venv python3-wheel 
    git clone https://github.com/yoonjongyeon/CoRNN_DT1_tractography.git
    cd CoRNN_DT1_tractography
    git lfs pull
    # Add Tags and checkout in near future
    python3 -m venv /CoRNN_DT1_tractography/venv
    source /CoRNN_DT1_tractography/venv/bin/activate
    python3 --version
    pip3 install wheel
    pip install --upgrade pip
    pip install --upgrade setuptools
    bash install/pip.sh
    deactivate
    cd /

    # Install MRTrix3
    apt-get -y install git g++ python3-numpy libeigen3-dev zlib1g-dev libqt5opengl5-dev libgl1-mesa-dev libfftw3-dev libtiff5-dev python3-distutils libqt5svg5-dev
    cd /apps
    git clone https://github.com/MRtrix3/mrtrix3.git
    cd mrtrix3
    git checkout 3.0.4
    ./configure
    ./build
    cd /

    # Install FSL
    apt-get -y install python3 wget ca-certificates libglu1-mesa libgl1-mesa-glx libsm6 libice6 libxt6 libpng-dev libxrender1 libxcursor1 libxinerama1 libfreetype6 libxft2 libxrandr2 libgtk-3-dev libpulse0 libasound2 libcaca0 libopenblas-base bzip2 dc bc
    wget -O /installers/fslinstaller.py "https://fsl.fmrib.ox.ac.uk/fsldownloads/fslinstaller.py"
    cd /installers
    python fslinstaller.py -d /apps/fsl -V 6.0.6
    cd /

    # Install ANTs (and compatible CMake)
    apt-get -y install build-essential libssl-dev
    # CMake: The latest ANTs requires newer version of cmake than can be installed
    # through apt-get, so we need to build higher version of cmake from source
    cd /installers
    mkdir cmake_install
    cd cmake_install
    wget https://github.com/Kitware/CMake/releases/download/v3.23.0-rc2/cmake-3.23.0-rc2.tar.gz
    tar -xf cmake-3.23.0-rc2.tar.gz
    cd cmake-3.23.0-rc2/
    ./bootstrap
    make
    make install
    cd /
    # ANTS
    cd /installers
    mkdir ants_installer
    cd ants_installer
    git clone https://github.com/ANTsX/ANTs.git
    mkdir ants_build
    cd ants_build
    cmake /installers/ants_installer/ANTs -DCMAKE_INSTALL_PREFIX=/apps/ants
    make 2>&1 | tee build.log
    cd ANTS-build
    make install 2>&1 | tee install.log
    cd /
    
    # SCILPY
    apt-get -y install git gcc libpq-dev python3 python3-dev python3-pip python3-venv python3-wheel python3-distutils
    apt-get -y install libblas-dev liblapack-dev libfreetype6-dev pkg-config
    apt-get -y install libglu1-mesa libgl1-mesa-glx libxrender1 gfortran
    cd /apps
    git clone https://github.com/scilus/scilpy.git
    cd scilpy
    git checkout 2.0.0
    python3 --version
    source /CoRNN_DT1_tractography/venv/bin/activate
    pip install --upgrade pip setuptools wheel cython
    export SETUPTOOLS_USE_DISTUTILS=stdlib
    pip install -e .
    deactivate
    cd /

    # Make custom folders
    mkdir -p data

    # Set Permissions
    chmod 755 /data

    # Clean up
    rm -r /installers

%environment    # Set environment variables inside the container.

    source /CoRNN_DT1_tractography/venv/bin/activate

    # MRTrix3
    export PATH="/apps/mrtrix3/bin:$PATH"

    # FSL
    FSLDIR=/apps/fsl
    . ${FSLDIR}/etc/fslconf/fsl.sh
    PATH=${FSLDIR}/bin:${PATH}
    export FSLDIR PATH

    # ANTs
    export ANTSPATH=/apps/ants/bin/
    export PATH=${ANTSPATH}:$PATH

    # CUDA
    export CPATH="/usr/local/cuda/include:$CPATH"
    export PATH="/usr/local/cuda/bin:$PATH"
    export LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"
    export CUDA_HOME="/usr/local/cuda"

%runscript

    xvfb-run -a --server-num=$((65536+$$)) --server-args="-screen 0 1600x1280x24 -ac" bash /CoRNN_DT1_tractography/src/generate.sh "$@"