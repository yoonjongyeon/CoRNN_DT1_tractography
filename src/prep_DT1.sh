#!/bin/bash

# Inputs:
# - T1.nii.gz

in_dir=$1
slant_file=$2
wml_dir=$3
num_threads=$4

# Set number of threads for OpenMP operations (ANTs)

export OMP_NUM_THREADS=$num_threads

# Get directories

supp_dir=$CORNN_DIR/supplemental
src_dir=$CORNN_DIR/src

# Generate mask:
# - T1_mask.nii.gz
export MRTRIX_NOMMAP=1
echo "prep_DT1.sh: T1w - Computing T1 mask..."
cmd="fslmaths $slant_file -div $slant_file -fillh $in_dir/T1_mask.nii.gz -odt int"
[ ! -f $in_dir/T1_mask.nii.gz ] && (echo $cmd && eval $cmd) || echo "prep_DT1.sh: T1w - Output exists, skipping!"

# Bias correction
# - T1_N4.nii.gz

echo "prep_DT1.sh: T1w - Bias correcting T1..."
cmd="N4BiasFieldCorrection -d 3 -i $in_dir/T1.nii.gz -x $in_dir/T1_mask.nii.gz -o $in_dir/T1_N4.nii.gz"
[ ! -f $in_dir/T1_N4.nii.gz ] && (echo $cmd && eval $cmd) || echo "prep_DT1.sh: T1w - Output exists, skipping!"

# Generate tissue classes
# - T1_5tt.nii.gz

echo "prep_DT1.sh: T1w - Computing 5tt classes..."
cmd="5ttgen fsl $in_dir/T1_N4.nii.gz $in_dir/T1_5tt.nii.gz -mask $in_dir/T1_mask.nii.gz -nocrop -scratch $in_dir -nthreads $num_threads"
[ ! -f $in_dir/T1_5tt.nii.gz ] && (echo $cmd && eval $cmd) || echo "prep_DT1.sh: T1w - Output exists, skipping!"

# Generate seed map:
# - T1_seed.nii.gz

echo "prep_DT1.sh: T1w - Computing seed mask..."
cmd="fslmaths $in_dir/T1_5tt.nii.gz -roi 0 -1 0 -1 0 -1 2 1 -bin -Tmax $in_dir/T1_seed.nii.gz -odt int"
[ ! -f $in_dir/T1_seed.nii.gz ] && (echo $cmd && eval $cmd) || echo "prep_DT1.sh: T1w - Output exists, skipping!"

# Register to MNI template:
# - T12mni_0GenericAffine.mat

echo "prep_DT1.sh: T1w - Registering to MNI space at 1mm isotropic..."
cmd="antsRegistrationSyN.sh -d 3 -m $in_dir/T1_N4.nii.gz -f $supp_dir/mni_icbm152_t1_tal_nlin_asym_09c_1mm.nii.gz -t r -o $in_dir/T12mni_"
[ ! -f $in_dir/T12mni_0GenericAffine.mat ] && (echo $cmd && eval $cmd) || echo "prep_DT1.sh: T1w - Transform exists, skipping!"
cmd="mv $in_dir/T12mni_Warped.nii.gz $in_dir/T1_N4_mni_1mm.nii.gz"
[ ! -f $in_dir/T1_N4_mni_1mm.nii.gz ] && (echo $cmd && eval $cmd) || echo "prep_DT1.sh: T1w - Outputs renamed, skipping!"
cmd="rm $in_dir/T12mni_InverseWarped.nii.gz"
[ -f $in_dir/T12mni_InverseWarped.nii.gz ] && (echo $cmd && eval $cmd) || echo "prep_DT1.sh: T1w - Outputs cleaned, skipping!"

# Move data to MNI
# - T1_N4_mni_2mm.nii.gz
# - T1_mask_mni_2mm.nii.gz
# - T1_seed_mni_2mm.nii.gz
# - T1_5tt_mni_2mm.nii.gz

echo "prep_DT1.sh: T1w - Moving images to MNI space at 2mm isotropic..."
cmd="antsApplyTransforms -d 3 -e 0 -r $supp_dir/mni_icbm152_t1_tal_nlin_asym_09c_2mm.nii.gz -i $in_dir/T1_N4.nii.gz   -t $in_dir/T12mni_0GenericAffine.mat -o $in_dir/T1_N4_mni_2mm.nii.gz   -n Linear"
[ ! -f $in_dir/T1_N4_mni_2mm.nii.gz ] && (echo $cmd && eval $cmd) || echo "prep_DT1.sh: T1w - T1_N4 transformed, skipping!"
cmd="antsApplyTransforms -d 3 -e 0 -r $supp_dir/mni_icbm152_t1_tal_nlin_asym_09c_2mm.nii.gz -i $in_dir/T1_mask.nii.gz -t $in_dir/T12mni_0GenericAffine.mat -o $in_dir/T1_mask_mni_2mm.nii.gz -n NearestNeighbor"
[ ! -f $in_dir/T1_mask_mni_2mm.nii.gz ] && (echo $cmd && eval $cmd) || echo "prep_DT1.sh: T1w - Mask transformed, skipping!"
cmd="antsApplyTransforms -d 3 -e 0 -r $supp_dir/mni_icbm152_t1_tal_nlin_asym_09c_2mm.nii.gz -i $in_dir/T1_seed.nii.gz -t $in_dir/T12mni_0GenericAffine.mat -o $in_dir/T1_seed_mni_2mm.nii.gz -n NearestNeighbor"
[ ! -f $in_dir/T1_seed_mni_2mm.nii.gz ] && (echo $cmd && eval $cmd) || echo "prep_DT1.sh: T1w - Seeds transformed, skipping!"
cmd="antsApplyTransforms -d 3 -e 3 -r $supp_dir/mni_icbm152_t1_tal_nlin_asym_09c_2mm.nii.gz -i $in_dir/T1_5tt.nii.gz  -t $in_dir/T12mni_0GenericAffine.mat -o $in_dir/T1_5tt_mni_2mm.nii.gz  -n Linear"
[ ! -f $in_dir/T1_5tt_mni_2mm.nii.gz ] && (echo $cmd && eval $cmd) || echo "prep_DT1.sh: T1w - 5tt transformed, skipping!"

# Prep SLANT:
# - T1_slant.nii.gz
# - T1_slant_mni_2mm.nii.gz

echo "prep_DT1.sh: T1w - Preparing SLANT..."
cmd="python3 $src_dir/prep_slant.py $slant_file $in_dir/T1_slant.nii.gz"
[ ! -f $in_dir/T1_slant.nii.gz ] && (echo $cmd && eval $cmd) || echo "prep_DT1.sh: T1w - SLANT grouped, skipping!"
cmd="antsApplyTransforms -d 3 -e 3 -r $supp_dir/mni_icbm152_t1_tal_nlin_asym_09c_2mm.nii.gz -i $in_dir/T1_slant.nii.gz  -t $in_dir/T12mni_0GenericAffine.mat -o $in_dir/T1_slant_mni_2mm.nii.gz -n NearestNeighbor"
[ ! -f $in_dir/T1_slant_mni_2mm.nii.gz ] && (echo $cmd && eval $cmd) || echo "prep_DT1.sh: T1w - SLANT transformed, skipping!"

# Prep WML:
# - T1_tractseg.nii.gz
# - T1_tractseg_mni_2mm.nii.gz

echo "prep_DT1.sh: T1w - Preparing WML..."
cmd="fslmerge -t $in_dir/T1_tractseg.nii.gz $wml_dir/orig/*.nii.gz"
[ ! -f $in_dir/T1_tractseg.nii.gz ] && (echo $cmd && eval $cmd) || echo "prep_DT1.sh: T1w - WML merged, skipping!"
cmd="antsApplyTransforms -d 3 -e 3 -r $supp_dir/mni_icbm152_t1_tal_nlin_asym_09c_2mm.nii.gz -i $in_dir/T1_tractseg.nii.gz  -t $in_dir/T12mni_0GenericAffine.mat -o $in_dir/T1_tractseg_mni_2mm.nii.gz -n Linear"
[ ! -f $in_dir/T1_tractseg_mni_2mm.nii.gz ] && (echo $cmd && eval $cmd) || echo "prep_DT1.sh: T1w - WML transformed, skipping!"

# Prep dMRI

# Compute the average b0 from the diffusion data
# - dmri_b0.nii.gz
echo "prep_DT1.sh: dMRI - Compute the average b0 from the diffusion data..."
cmd="dwiextract $in_dir/dmri.nii.gz -fslgrad $in_dir/dmri.bvec $in_dir/dmri.bval - -bzero | mrmath - mean $in_dir/dmri_b0.nii.gz -axis 3"
[ ! -f $in_dir/dmri_b0.nii.gz ] && (echo $cmd && eval $cmd) || echo "prep_DT1.sh: dMRI - Average b0 computed, skipping!"

# Compute a rigid transform between the average b0 and T1 
# - dmri2T1_0GenericAffine.mat
echo "prep_DT1.sh: dMRI - Compute a rigid transform between the average b0 and T1..."
cmd="antsRegistrationSyN.sh -d 3 -m $in_dir/dmri_b0.nii.gz -f $in_dir/T1_N4.nii.gz -t r -o $in_dir/dmri2T1_"
[ ! -f $in_dir/dmri2T1_0GenericAffine.mat ] && (echo $cmd && eval $cmd) || echo "prep_DT1.sh: dMRI - Rigid transform computed, skipping!"
echo "prep_DT1.sh: dMRI - Delete unnecessary files"
cmd="rm $in_dir/dmri2T1_Warped.nii.gz $in_dir/dmri2T1_InverseWarped.nii.gz"
(echo $cmd && eval $cmd)

# Move the structural masks to diffusion space
# - dmri_mask.nii.gz
echo "prep_DT1.sh: dMRI - Move the structural masks to diffusion space..."
cmd="antsApplyTransforms -d 3 -e 0 -r $in_dir/dmri_b0.nii.gz -i $in_dir/T1_mask.nii.gz -t [$in_dir/dmri2T1_0GenericAffine.mat,1] -o $in_dir/dmri_mask.nii.gz -n NearestNeighbor"
[ ! -f $in_dir/dmri_mask.nii.gz ] && (echo $cmd && eval $cmd) || echo "prep_DT1.sh: dMRI - Transform computed, skipping!"

# Fit the diffusion data with FODs
# - dmri_fod.nii.gz
echo "prep_DT1.sh: dMRI - Fit the diffusion data with FODs..."
cmd="dwi2response tournier $in_dir/dmri.nii.gz $in_dir/dmri_tournier.txt -fslgrad $in_dir/dmri.bvec $in_dir/dmri.bval -mask $in_dir/dmri_mask.nii.gz"
[ ! -f $in_dir/dmri_tournier.txt ] && (echo $cmd && eval $cmd) || echo "prep_DT1.sh: dMRI - Response function computed, skipping!"
cmd="dwi2fod csd $in_dir/dmri.nii.gz $in_dir/dmri_tournier.txt $in_dir/dmri_fod.nii.gz -fslgrad $in_dir/dmri.bvec $in_dir/dmri.bval -mask $in_dir/dmri_mask.nii.gz"
[ ! -f $in_dir/dmri_fod.nii.gz ] && (echo $cmd && eval $cmd) || echo "prep_DT1.sh: dMRI - FODs fitted, skipping!"

# Register to MNI template:
# - T1_fod_mni_2mm.nii.gz
echo "prep_DT1.sh: dMRI - Moving FODs image to MNI space at 2mm isotropic..."
cmd="ConvertTransformFile 3 $in_dir/dmri2T1_0GenericAffine.mat $in_dir/dmri2T1_0GenericAffine.txt"
[ ! -f $in_dir/dmri2T1_0GenericAffine.txt ] && (echo $cmd && eval $cmd) || echo "prep_DT1.sh: dMRI - .mat converted, skipping!"
cmd="transformconvert $in_dir/dmri2T1_0GenericAffine.txt itk_import $in_dir/dmri2T1_0GenericAffine.txt -force"
(echo $cmd && eval $cmd)
cmd="ConvertTransformFile 3 $in_dir/T12mni_0GenericAffine.mat $in_dir/T12mni_0GenericAffine.txt"
[ ! -f $in_dir/T12mni_0GenericAffine.txt ] && (echo $cmd && eval $cmd) || echo "prep_DT1.sh: dMRI - .mat converted, skipping!"
cmd="transformconvert $in_dir/T12mni_0GenericAffine.txt itk_import $in_dir/T12mni_0GenericAffine.txt -force"
(echo $cmd && eval $cmd)
cmd="mrtransform -linear $in_dir/dmri2T1_0GenericAffine.txt -modulate fod -reorient_fod true $in_dir/dmri_fod.nii.gz - | mrtransform -linear $in_dir/T12mni_0GenericAffine.txt -interp linear -template $in_dir/T1_N4_mni_2mm.nii.gz -stride $in_dir/T1_N4_mni_2mm.nii.gz -modulate fod -reorient_fod true - $in_dir/T1_fod_mni_2mm.nii.gz"
[ ! -f $in_dir/T1_fod_mni_2mm.nii.gz ] && (echo $cmd && eval $cmd) || echo "prep_DT1.sh: dMRI - FODs transformed, skipping!"

# Wrap up

echo "prep_DT1.sh: Done!"
