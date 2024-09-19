# Data splits used to train D-MPNN-2
Each pickle file contains a list of lists that contain the training, validation, and testing indices for each of the 5 folds.

These two files contain indices for the 1,863,360 forward and reverse reactions with resonance augmentation in all 40 solvents.
- `all_rxn_all_solvent_bidirection_res_random_splits.pkl` is used to train the models in Table 9.
- `all_rxn_all_solvent_bidirection_res_cluster_splits.pkl` is used to train the models in Tables 8 and 9.

Here is some sample code to read in the indices:
```
with open('splits/D-MPNN-2/all_rxn_all_solvent_bidirection_res_cluster_splits.pkl', 'rb') as f:
    splits = pkl.load(f)

# returns 5 since this stores the 5 folds
len(splits)  

# returns (3, 3, 3, 3, 3) since each fold contains indices for the training, validation and testing set
len(splits[0]), len(splits[1]), len(splits[2]), len(splits[3]), len(splits[4])

# returns (1621120, 156400, 85840)
len(splits[0][0]), len(splits[0][1]), len(splits[0][2])
```
