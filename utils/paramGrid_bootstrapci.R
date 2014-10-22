
args <- commandArgs(trailingOnly = TRUE)

seed <- as.numeric(args[1]):as.numeric(args[2]);
B <- as.numeric(args[3]);
pair <- c('CHFUSD','EURUSD','GBPUSD','JPYUSD')

out <- expand.grid(pair,seed,B)
write.table(cbind(out,TRUE), "paramGrid_bootstrapci.txt",row.names = FALSE, col.names = FALSE,quote=F)
