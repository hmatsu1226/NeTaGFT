args <- commandArgs(trailingOnly = T)

ks <- as.numeric(unlist(strsplit(args[1],",")))

for(k in ks){
  A <- as.matrix(read.table(paste0("data/A_k",k,".txt")))
  contig_ids <- read.table(paste0("data/contig_ids_k",k,".txt"))[,1]
  N <- length(contig_ids)
  
  data <- read.table("data/41587_2019_100_MOESM4_ESM.txt", header=TRUE, sep="\t")
  
  all_family <- sort(setdiff(unique(data[,7]), ""))
  X1 <- matrix(0, N, length(all_family))
  colnames(X1) <- all_family
  for(i in 1:N){
    print(i)
    idx <- which(data[,1] == contig_ids[i])
    idx2 <- which(all_family == data[idx,7])
    
    if(length(idx) != 0){
      X1[i, idx2] <- 1
    }
  }
  X1 <- X1[,colSums(X1)>100]
  
  all_subfamily <- sort(setdiff(unique(data[,8]), ""))
  X2 <- matrix(0, N, length(all_subfamily))
  colnames(X2) <- all_subfamily
  for(i in 1:N){
    print(i)
    idx <- which(data[,1] == contig_ids[i])
    idx2 <- which(all_subfamily == data[idx,8])
    
    if(length(idx) != 0){
      X2[i, idx2] <- 1
    }
  }
  plot(colSums(X2))
  X2 <- X2[,colSums(X2)>10]
  
  
  all_genus <- sort(setdiff(unique(data[,9]), ""))
  X3 <- matrix(0, N, length(all_genus))
  colnames(X3) <- all_genus
  for(i in 1:N){
    print(i)
    idx <- which(data[,1] == contig_ids[i])
    idx2 <- which(all_genus == data[idx,9])
    
    if(length(idx) != 0){
      X3[i, idx2] <- 1
    }
  }
  plot(colSums(X3))
  X3 <- X3[,colSums(X3)>15]
  
  write.table(cbind(X1,X2,X3), paste0("data/X_k",k,".txt"), sep="\t", row.names=F) 
}
