This tutorial provides a step-by-step guide to implementing a series of influenza analysis procedures as described in the NeTaGFT paper. Here, we focus on the analysis of hemagglutinin (HA) sequences and associated trait data.

## Download Influenza Data
First, download influenza data from the following URL:
```
https://www.ncbi.nlm.nih.gov/genomes/FLU/Database/nph-select.cgi?go=database
```

- For the 'Type' category, select 'A'. For the 'Host' category, choose 'Avian', 'Swine', and 'Human'. In the 'Protein' category, select 'HA'. Leave all other fields as 'any'.
- Click the "Add query" button.
- Select "Protein(FASTA)" and click "Download result" to download the fasta file ("FASTA.fa").
- Choose "Result set(CSV)" and click "Download result" to download the metadata file ("flu.txt").
- Move the two files you just downloaded to the "data" directory.

## Download Contry Information Table
Download "all.csv" from the following URL:
```
https://github.com/lukes/ISO-3166-Countries-with-Regional-Codes
```

This file is used to categorize the countries where influenza sequences were detected into regions: Africa, Americas, Asia, Europe, and Oceania.

## Cluster Similar Sequences
We use cd-hit to cluster similar sequences as follows:

```
cd-hit -i data/FASTA.fa -o data/FASTA_cdhit.fa -c 0.98
```

This command clusters the 112,965 sequences into 5,109 clusters (FASTA_cdhit.fa.clstr). The representative sequences for each cluster are output in FASTA_cdhit.fa.

## Calculate All-to-All Pairwise Alignment Score
We use MMSeqs2 for all-to-all pairwise sequence alignments, calculating alignment bit scores as follows:
```
mkdir data/mmseqs
mmseqs createdb data/FASTA_cdhit.fa data/mmseqs/targetDB
mmseqs createindex data/mmseqs/targetDB data/mmseqs/tmp
mmseqs easy-search --search-type 1 data/FASTA_cdhit.fa data/mmseqs/targetDB data/mmseqs/alnRes data/mmseqs/tmp
```

Note 1: To reduce file size, only "data/mmseqs/alnRes", which is used in subsequent steps, is provided on GitHub. In reality, other files are also generated.

Note 2: Depending on the version of MMSeqs2 used, there may be subtle differences, such as whether or not alignment pairs are detected. However, in several trials, these differences did not significantly affect the overall results.

## Extract Trait Data Corresponding to the data/FASTA_cdhit.fa
Run the following command:
```
ruby extract_traitsdata.rb data/FASTA_cdhit.fa.clstr data/FASTA_cdhit.fa data/flu.txt data/all.csv data/traits_cdhit.txt data/names_cdhit.txt 5109
```
- data/FASTA_cdhit.fa.clstr	: output file of cd-hit
- data/FASTA_cdhit.fa : output file of cd-hit about representative sequence
- data/flu.txt : metadata downloaded from the NCBI Influenza virus resource as described above.
- data/all.csv : Country to region table file as described above.
- data/traits_cdhit.txt : output file that have trait information
- data/names_cdhit.txt : output file that have accession number and corresponding cluster in cd-hit
- 5109 : the number of sequences

## Create Sequence Similarity Graph (SSG) from MMSeqs2 Result
Run the following command:
```
ruby create_SSG_from_mmseqs.rb data/names_cdhit.txt data/mmseqs/alnRes data/SSG.txt 5109
```
- data/names_cdhit.txt : output file of the "extract_traitsdata.rb
- data/mmseqs/alnRes : output file of mmseqs
- data/SSG.txt : output file of SSG matrix
- 5109 : the number of sequences

## Create k-Nearest Neighbor Graph (kNNG), Including Removing Outliers, and Save Processed Data
Run the following command:
```
Rscript create_knn_from_SSG_and_process_data.R data/SSG.txt data/traits_cdhit.txt data 50,100,200,500,1000 100
```
- data/SSG.txt : the file obtained from "create_SSG_from_mmseqs.rb"
- data/traits_cdhit.txt : the file obutained from "extract_traitsdata.rb"
- data : the directory where the adjacency matrix and trait data are saved, the kNNGs are saved as data/A_k200.txt, for example, and the trait data is saved as data/X.txt
- 50,100,200,500,1000 : the list of value of 'k' in kNNG
- 100 : the value to filter outlier sequences

## validate k with aGLR
Validation of k value in kNNG based on the aGLR values. See the Jupyter notebook titled evaluation_of_k.ipynb for this step.

## Run NeTaGFT Analysis
Run NeTaGFT for a kNNG (data/A_k200.txt) and trait data (data/X.txt). Refer to the Jupyter notebook titled analysis.ipynb to perform the NeTaGFT analysis.

