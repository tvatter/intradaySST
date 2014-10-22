
args <- commandArgs(trailingOnly = TRUE)

pair <- args[1]
seed <- as.numeric(args[2]):as.numeric(args[3]);
B <- as.numeric(args[4]);
n <- c(50,150)
method <- c('sst','fff')

out <- expand.grid(pair,seed,B,n,method)
write.table(out, "paramGrid_simul.txt",row.names = FALSE, col.names = FALSE,quote=F)
