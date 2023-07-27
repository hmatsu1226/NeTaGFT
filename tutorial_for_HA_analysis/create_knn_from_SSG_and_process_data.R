library(igraph)

args <- commandArgs(trailingOnly = T)

fssg <- args[1]
ftrait <- args[2]
foutdir <- args[3]
ks <- as.numeric(unlist(strsplit(args[4],",")))
thresh <- as.numeric(args[5])

#SSG
SSG <- as.matrix(read.table(fssg))
diag(SSG) <- 0

#traint
X <- as.matrix(read.csv(ftrait, row.names=1))

#filter outlier sequences
tmp <- which(rowSums(SSG) < thresh)
if(length(tmp) > 0){
  SSG <- SSG[-tmp,-tmp]
  X <- X[-tmp,]
}

#traits data processing
#remove year data
X <- X[,-33]

#to binary
for(i in 1:dim(X)[1]){
  X[i,] <- as.integer(X[i,] >= 1)
}

#remove no data col
X <- X[,-which(colSums(X)==0)]

foutX = paste0(foutdir,"/X.txt")
write.table(X, foutX, row.names=F, sep="\t") 

#make knn graph
make.knn.graph<-function(D,k){
  edges <- mat.or.vec(0,2)
  for (i in 1:nrow(D)){
    matches <- order(D[i,],decreasing = F)[1:k]
    edges <- rbind(edges,cbind(rep(i,min(k,length(matches))),matches))  
  }
  # create a graph from the edgelist
  graph <- graph_from_edgelist(edges,directed=F)
  return(graph)        
}

D <- -log(SSG)
diag(D) <- Inf

for(k in ks){
  g <- make.knn.graph(D,k)
  A <- as.matrix(as_adjacency_matrix(g))
  
  foutA = paste0(foutdir,"/A_k",k,".txt")
  write.table(A, foutA, col.names=F, row.names=F, sep="\t")
}


