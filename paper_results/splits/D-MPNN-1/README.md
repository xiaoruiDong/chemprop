# Data splits used to train D-MPNN-1
Each pickle file contains a list of lists that contain the training, validation, and testing indices for each of the 5 folds.

These two files contain indices for the 11,200 forward and reverse reactions without resonance augmentation.
- `all_rxn_water_bidirection_nores_random_splits.pkl` is used to train the models in Table 4 (and the top left of Table 6).
- `all_rxn_water_bidirection_nores_cluster_splits.pkl` is used to train the models in Table 5 (and the top right of Table 6).

Here is some sample code to read in the indices:
```
with open('splits/D-MPNN-1/all_rxn_water_bidirection_nores_random_splits.pkl', 'rb') as f:
    splits = pkl.load(f)

# returns 5 since this stores the 5 folds
len(splits)  

# returns (3, 3, 3, 3, 3) since each fold contains indices for the training, validation and testing set
len(splits[0]), len(splits[1]), len(splits[2]), len(splits[3]), len(splits[4])

# returns (9486, 470, 1244)
len(splits[0][0]), len(splits[0][1]), len(splits[0][2])
```

These two files contain indices for the 46,584 forward and reverse reactions with resonance augmentation.
- `all_rxn_water_bidirection_res_random_splits.pkl` is used to train the models in the bottom left of Table 6.
- `all_rxn_water_bidirection_res_cluster_splits.pkl` is used to train the models in the bottom right of Table 6.

Here is some sample code to read in the indices:
```
with open('splits/D-MPNN-1/all_rxn_water_bidirection_res_random_splits.pkl', 'rb') as f:
    splits = pkl.load(f)

# returns 5 since this stores the 5 folds
len(splits)  

# returns (3, 3, 3, 3, 3) since each fold contains indices for the training, validation and testing set
len(splits[0]), len(splits[1]), len(splits[2]), len(splits[3]), len(splits[4])

# returns (40160, 2130, 4294)
len(splits[0][0]), len(splits[0][1]), len(splits[0][2])
```
