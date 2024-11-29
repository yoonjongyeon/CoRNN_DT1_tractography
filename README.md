# CoRNN Diffusion T1 tractography
Enhancing clinically-feasible diffusion MRI tractography utilizing T1w-MRI and anatomical data

## Overview

This repository contains the model weights, source code, and containerized implementation of convolutional-recurrent neural network (CoRNN) tractography on low resolution diffusion MRI and T1w MRI with associated [SLANT](https://github.com/MASILab/SLANTbrainSeg) and [WM learning (WML)](https://github.com/MASILab/WM_learning_release) TractSeg segmentations. 


## Authors and Reference

TBD


## Containerization of Source Code

    git clone https://github.com/yoonjongyeon/CoRNN_DT1_tractography.git
    cd /path/to/repo/CoRNN_DT1_tractography
    sudo singularity build /path/to/CoRNN_DT1.sif Singularity

Alternatively, a pre-built container can be downloaded [here](https://vanderbilt.box.com/s/j478y901vya5girtv1z13fa6ux2gqefz).


## Preparation
Before running a container, output from [SLANT](https://github.com/MASILab/SLANTbrainSeg) and [WM learning (WML)](https://github.com/MASILab/WM_learning_release) TractSeg segmentations are essential.


## Command

    singularity run 
    -e 
    --contain
    --home <in_dir>
    -B <out_dir>:/data
    -B <t1_file>:/data/T1.nii.gz
    -B <dmri_file>:/data/dmri.nii.gz
    -B <bvec_file>:/data/dmri.bvec
    -B <bval_file>:/data/dmri.bval
    -B <slant_file>:/data/slant/T1_slant.nii.gz
    -B <wml_dir>:/data/wml
    -B /tmp:/tmp
    --nv
    /path/to/CoRNN_DT1.sif
    /data/T1.nii.gz
    /data/dmri.nii.gz
    /data/dmri.bvec
    /data/dmri.bval
    /data/<out_name>
    --slant /data/slant/T1_slant.nii.gz
    --wml /data/wml
    [options]
    
* Binding `/tmp` is required with `--contain` when `--work_dir` is not specified.
* `--nv` is optional. See `--device`.

## Arguments and I/O

* **`<in_dir>`** Path on the host machine to the *directory* in which will be used as home directory.   

* **`<out_dir>`** Path on the host machine to the *directory* in which the output tractogram will be saved.

* **`<t1_file>`** Path on the host machine to the T1-weighted MRI with which tractography is to be performed in NIFTI format (either compressed or not).

* **`<dmri_file>`** Path on the host machine to the diffusion MRI with which tractography is to be performed in NIFTI format (either compressed or not).

* **`<bvec_file>`** Path on the host machine to the b-vector file.

* **`<bval_file>`** Path on the host machine to the b-value file.

* **`<slant_file>`** Path on the host machine to the SLANT output file.

* **`<wml_dir>`** Path on the host machine to the TractSeg WM Learning output directory.

* **`<out_name>`** *Name* (i.e., no directory) of the output tractogram with extension in trk, tck, vtk, fib, or dpy format.

## Options

* **`--help`** Print help statement.

* **`--device cuda/cpu`** A string indicating the device on which to perform inference. If "cuda" is selected, container option `--nv` must be included. Default = "cpu"

* **`--num_streamlines N`** A positive integer indicating the number of streamlines to identify. Default = 1000000

* **`--num_seeds N`** A positive integer indicating the number of streamlines to seed per batch. One GB of GPU memory can handle approximately 10000 seeds. Default = 100000

* **`--min_steps N`** A positive integer indicating the minimum number of 1mm steps per streamline. Default = 50

* **`--max_steps N`** A positive integer indicating the maximum number of 1mm steps per streamline. Default = 250

* **`--buffer_steps N`** A positive integer indicating the number of 1mm steps where the angle stopping criteria are ignored at the beginning of tracking. Default = 5

* **`--unidirectional`** A flag indicating that bidirectional tracking should not be performed. The buffer steps are NOT removed in this case. Default = Perform bidirectional tracking

* **`--work_dir /data/work_dir`** A string indicating the working directory to use. The location of the working directory on the host machine, `<work_dir>`, must also exist and be bound into the container with `-B <work_dir>:/data/work_dir` in the [command](#command). If the working directory contains previously generated intermediates, the corresponding steps will not be rerun. Default = create a new working directory in `/tmp`

* **`--keep_work`** A flag indicating that the intermediates in the working directory should NOT be cleared. Default = Clear working directory after completion

* **`--num_threads N`** A positive integer indicating the number of threads to use during multithreaded steps. Default = 1

* **`--force`** A flag indicating that the output file should be overwritten if it already exists. Default = Do NOT override existing output file
