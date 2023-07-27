library(igraph)

args <- commandArgs(trailingOnly = T)

ks <- as.numeric(unlist(strsplit(args[1],",")))

data <- read.csv("data/41587_2019_100_MOESM3_ESM.csv")

#create contig x cluster binary matrix
contig_ids <- sort(unique(data[,2]))
clusters <- unique(data[,4])

N <- length(contig_ids)
M <- length(clusters)

X <- matrix(0, N, M)
rownames(X) <- contig_ids
colnames(X) <- clusters
for(i in 1:nrow(data)){
  contig_id_to_idx <- which(contig_ids==data[i,2])
  cluster_to_idx <- which(clusters==data[i,4])
  X[contig_id_to_idx, cluster_to_idx] <- 1
}

#create similarity matrix based on Jaccard index
GSN <- matrix(0, N, N)
for(i in 1:(N-1)){
  print(i)
  for(j in (i+1):N){
    GSN[i,j] <- sum(X[i,]&X[j,])/sum(X[i,]|X[j,]) #sum(X[i,]+X[j,]==2) / sum(X[i,]+X[j,]!=0)
    GSN[j,i] <- GSN[i,j]
  }
}

#knn graph
make.knn.graph<-function(SSG,k){
  diag(SSG) <- 0
  edges <- mat.or.vec(0,2)
  for (i in 1:nrow(SSG)){
    matches <- setdiff(order(SSG[i,], decreasing = TRUE)[1:k], which(SSG[i,]==0))
    edges <- rbind(edges,cbind(rep(i,min(k,length(matches))),matches))  
  }
  graph <- graph_from_edgelist(edges,directed=F)
  return(graph)        
}

for(k in ks){
  g <- make.knn.graph(GSN,k)
  tmp <- components(g)
  
  A <- as.matrix(as_adjacency_matrix(g))
  a <- which(tmp$membership==1)
  A <- A[a,a]
  
  write.table(A, paste0("data/A_k",k,".txt"), col.names=F, row.names=F)
  write.table(contig_ids[a], paste0("data/contig_ids_k",k,".txt"), col.names=F, row.names=F) 
}
