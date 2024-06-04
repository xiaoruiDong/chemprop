#!/bin/bash -l

paper_results_dir=$(dirname $(dirname "$(realpath "$0")"))

####### Input Parameters ########

# Input file
# A csv file containing reaction SMILES
test_path=example_reactions.csv
rxn_column="rxn_smiles"
solv_column="solvent_smiles"
# Input file example: using a file in datasets folder as an example
test_path="$paper_results_dir/datasets/all_rxn_water_forward_noresonance.csv"
rxn_column="rxn_smi"
solv_column="solvent_smi"

# Output file
# filename used to save predictions
preds_path=pred.csv

# Model weights
# Model weights corresponding to strategy 5 are distributed with the code
# by default, use the ensemble model from KMeans splits to make the prediction
# chemprop's predict script will automatically calculate the mean +- 1 std across the 5 folds
# if using models from random split, replace "kmeans_split" with "random_split"
checkpoint_dir="$paper_results_dir/model_weights/D-MPNN-2/kmeans_split/"

# Conda environment name
# No need to change if you installed chemprop following the default procedures
chemprop_env="chemprop"

# Path to your chemprop installation
# Comment out the line below and set the CHEMPROP path manually
# if you want to use a different chemprop installation
chemprop_dir=$(dirname $paper_results_dir)
# CHEMPROP=/SAMPLE/PATH/chemprop

# GPU usage
# A GPU can be used by assigning the index of the GPU (e.g., gpu=0).
# To only use a CPU, set gpu=-1
gpu=-1

# Number of cpus used to parallelize when loading in the data
num_workers=2

# Batch size used during inference
batch_size=32

####### End of Input Parameters ########

# Print configuration
echo "Predict Gibbs free energy of activation and of reaction using D-MPNN-1\n"
echo "input reaction smiles: $test_path (column: $rxn_column)"
echo "output file path: $preds_path"

echo "model weights path: $checkpoint_dir"
gas_checkpoint_dir="$checkpoint_dir/gas"
echo "model weights for solv-ag models: $gas_checkpoint_dir"
solv_checkpoint_dir="$checkpoint_dir/solv"
echo "model weights for solv-dep models: $solv_checkpoint_dir"

echo "chemprop conda environment: $chemprop_env"
echo "chemprop installation: $chemprop_dir"
if [ "$gpu" -e -1 ]; then
    echo "device: cpu"
else
    echo "device: cuda:$gpu"
fi
echo "number of dataloader workers: $num_workers"
echo "batch size: $batch_size"

echo "\nActivate chemprop environment"

conda activate "$chemprop_env"
export PYTHONPATH=$chemprop_dir:$PYTHONPATH
echo "python path: $(which python)"
python -c "import torch;print('number of available GPUs:', torch.cuda.device_count());print('GPU is available:', torch.cuda.is_available())"

cmd_gas="python -u \"$chemprop_dir/predict.py\" \
    --test_path \"$test_path\" \
    --preds_path \"$preds_path.gas\" \
    --smiles_columns \"$rxn_column\" \
    --num_workers $num_workers \
    --drop_extra_columns \
    --checkpoint_dir \"$gas_checkpoint_dir\" \
    --batch_size $batch_size \
    --no_features_scaling \
    --ensemble_variance \
    --individual_ensemble_predictions"

if [ "$gpu" -ne -1 ]; then
    cmd_gas="$cmd_gas --gpu $gpu"
fi

# Run the final command
echo "\nRunning the prediction for gas phase Gibbs free energies:"
echo "$cmd_gas"
eval "$cmd_gas"


cmd_solv="python -u \"$chemprop_dir/predict.py\" \
    --test_path \"$test_path\" \
    --preds_path \"$preds_path.solv\" \
    --number_of_molecules 2 \
    --smiles_columns \"$rxn_column\" \"$solv_column\" \
    --num_workers $num_workers \
    --drop_extra_columns \
    --checkpoint_dir \"$gas_checkpoint_dir\" \
    --batch_size $batch_size \
    --no_features_scaling \
    --ensemble_variance \
    --individual_ensemble_predictions"

if [ "$gpu" -ne -1 ]; then
    cmd_solv="$cmd_solv --gpu $gpu"
fi

# Run the final command
echo "\nRunning the prediction for Gibbs free energy solvation corrections:"
echo "$cmd_solv"
eval "$cmd_solv"


echo "\nMerging gas phase barrier height prediction with solvation corrections"
echo "Saving predictions to $preds_path"
python merge_data.py $preds_path $rxn_column

echo "Predictions finished. Results can be found at $preds_path"