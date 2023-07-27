This tutorial provides a step-by-step guide to implementing a series of Virome Genome dataset analysis procedures as described in the NeTaGFT paper.

## Download Virome Genome data
Start by downloading the Supplementary Table 1 and 2 data from https://www.nature.com/articles/s41587-019-0100-8.
```
wget -P data https://static-content.springer.com/esm/art%3A10.1038%2Fs41587-019-0100-8/MediaObjects/41587_2019_100_MOESM3_ESM.csv
wget -P data https://static-content.springer.com/esm/art%3A10.1038%2Fs41587-019-0100-8/MediaObjects/41587_2019_100_MOESM4_ESM.xlsx
```
Next, convert the 41587_2019_100_MOESM4_ESM.xlsx file into a tab-delimited ".txt" file and save it as "41587_2019_100_MOESM4_ESM.txt".


## Create kNN from GSN
Generate a gene sharing network (GSN) from "41587_2019_100_MOESM3_ESM.csv" and then create a k-nearest neighbors graph (kNNG) from the GSN.
```
Rscript create_GSN_and_knn.R 50,100,200,500,1000
```

- 50,100,200,500,1000 : These are the values for 'k' in kNNG. The kNNGs are saved as data/A_k200.txt, for example.

## Extract trait data
Extract family, subfamily, and genus data from "41587_2019_100_MOESM4_ESM.txt".
```
Rscript create_traitdata.R 50,100,200,500,1000
```

- 50,100,200,500,1000 : Again, these are the values for 'k' in kNNG. The trait data files are saved as data/X_k200.txt, for example.

## Validate k with aGLR
Validate the value of 'k' in kNNG based on the aGLR values. This step can be performed using the Jupyter notebook titled "evaluation_of_k.ipynb".

## Run NeTaGFT Analysis
Run the NeTaGFT analysis for a kNNG (data/A_k200.txt) and trait data (data/X_k200.txt). Refer to the Jupyter notebook titled "analysis.ipynb" to conduct the NeTaGFT analysis.