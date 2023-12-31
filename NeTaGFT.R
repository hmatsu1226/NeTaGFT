library(RSpectra)

sym_normalized_graph_laplacian <- function(A){
  N <- nrow(A)
  D <- diag(rowSums(A))
  Dmsqrt <- rowSums(A)**(-0.5)
  L <- D - A
  
  DmsqrtL <- matrix(0, N, N)
  for(i in 1:N){
    DmsqrtL[i,] <- Dmsqrt[i] * L[i,]
  }
  
  DmsqrtLDmsqrt <- matrix(0, N, N)
  for(i in 1:N){
    DmsqrtLDmsqrt[,i] <- DmsqrtL[,i] * Dmsqrt[i]
  }
  
  return(DmsqrtLDmsqrt)
}

graph_laplacian_regularizer <- function(x, U, eigenvalues){
  x <- x - mean(x)
  x <- x/sqrt(sum(x**2))
  f <- t(U) %*% x
  
  ret <- sum((f**2 * eigenvalues))
  #correspond to remaining eigenvalues
  ret <- ret + (1-sum(f**2))*max(eigenvalues)
  return(ret)
}

graph_fourier_transform <- function(L,X,m){
  tmp <- eigs_sym(L, m, opts = list(retvec = TRUE), which="SA")
  U <- tmp$vectors[,m:1]
  eigenvalues <- tmp$values[m:1]
  hF <- t(U) %*% X
  tF <- t(abs(U)) %*% abs(X)
  return(list(U=U, eigenvalues=eigenvalues, hF=hF, tF=tF))
}

barplot_gfdomain <- function(hF, tF, i){
  M <- ncol(hF)
  
  par(las=2)
  myxlim <- c(-1,1) #range(hF[-1,])*1.15
  
  barplot(hF[i,M:1], horiz=T, cex.names=0.7, main=i, xlim=myxlim, col="#c8c8cb", border="black")
  for(j in 1:M){
    a <- 1.20
    b <- heat.colors(101)[101-as.integer(tF[i,M-j+1]*100)]
    rect(myxlim[1]+0.06,(j-1)*a+0.2,myxlim[1]+0.01,j*a, col=b, lwd=1)
  }
}

plot_hF_with_shuffleddata <- function(hF, X, i){
  hF_shuffles <- matrix(0, ncol(X), 100)
  for(j in 1:ncol(X)){
    for(ite in 1:100){
      hF_shuffles[j,ite] <- t(U[,i]) %*% sample(X[,j])
    }
  }
  
  plot(0,0,type="n",xlim=c(0.5,ncol(X)+0.5), ylim=range(c(hF,hF_shuffles)),xlab="",ylab="", axes = FALSE, las=1, cex.lab=1, cex.axis=1, main=paste0("hF_",i))
  boxplot(t(hF[i,]), boxwex = 0.1, at=c(1:ncol(X))-0.2, add=TRUE, names=colnames(X), las=2, border="red")
  boxplot(t(hF_shuffles), boxwex = 0.1, at=c(1:ncol(X))+0.0, add=TRUE, names=rep("shuffle",ncol(X)), las=2, ann=F)
  boxplot(hF[-i,], boxwex = 0.1, at=c(1:ncol(X))+0.2, add=TRUE, names=rep("the others",ncol(X)), las=2, ann=F)
}

plot_tF_with_shuffleddata <- function(tF, X, i){
  tF_shuffles <- matrix(0, ncol(X), 100)
  for(j in 1:ncol(X)){
    for(ite in 1:100){
      tF_shuffles[j,ite] <- t(abs(U[,i])) %*% sample(abs(X[,j]))
    }
  }

  plot(0,0,type="n",xlim=c(0.5,ncol(X)+0.5), ylim=range(c(tF,tF_shuffles)),xlab="",ylab="", axes = FALSE, las=1, cex.lab=1, cex.axis=1, main=paste0("tF_",i))
  boxplot(t(tF[i,]), boxwex = 0.1, at=c(1:ncol(X))-0.2, add=TRUE, names=colnames(X), las=2, border="red")
  boxplot(t(tF_shuffles), boxwex = 0.1, at=c(1:ncol(X))+0.0, add=TRUE, names=rep("shuffle",ncol(X)), las=2, ann=F)
  boxplot(tF[-i,], boxwex = 0.1, at=c(1:ncol(X))+0.2, add=TRUE, names=rep("the others",ncol(X)), las=2, ann=F)
}


plot_aGLR <- function(X, U, shuffle_num=100){
  aGLRs <- rep(0, ncol(X))
  names(aGLRs) <- colnames(X)
  for(i in 1:ncol(X)){
    aGLRs[i] <- graph_laplacian_regularizer(X[,i], U, eigenvalues)
  }
  
  aGLRs_shuffle <- rep(0, shuffle_num)
  for(i in 1:length(aGLRs_shuffle)){
    x <- sample(X[,sample(1:ncol(X))[1]])
    aGLRs_shuffle[i] <- graph_laplacian_regularizer(x, U, eigenvalues)
  }
  
  par(cex=0.9)
  boxplot(t(sort(aGLRs, decreasing=TRUE)), horizontal=FALSE, col=0, border=0, ylab="aGLR", ylim=c(0,1), names=FALSE)
  
  for(i in 1:length(aGLRs)){
    tmpname <- names(aGLRs)[order(aGLRs, decreasing=TRUE)[i]]
    mtext(tmpname, side=1, line=1, at=length(aGLRs)-i+1, las=2, font=1, cex=.8)
  }
  
  lines(c(-1,length(aGLRs)+2), c(mean(aGLRs_shuffle),mean(aGLRs_shuffle)), col="red")
  par(new=TRUE)
  plot(1:ncol(X), sort(aGLRs, decreasing=FALSE), ylim=c(0,1), xlim=c(0.5,ncol(X)+0.5), ann=FALSE, axes=FALSE, cex=1.1, lwd=2)
}
