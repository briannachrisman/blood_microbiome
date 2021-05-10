## R CODE
library(decontam)

print('reading for_decontam_microbe.csv')
rm(list = setdiff(ls(), lsf.str()))
csv=read.csv('/home/groups/dpwall/briannac/blood_microbiome/intermediate_files/decontam/for_decontam_microbe.csv', row.names=1)
mat=as.matrix(csv[,1:(ncol(csv)-2)])

print('computing contaminants_microbe_product.csv')
contamdf.freq = isContaminant(mat, method="frequency", conc=csv$concentration, normalize=FALSE, batch=csv$batch, batch.combine='product')
write.csv(contamdf.freq,"/home/groups/dpwall/briannac/blood_microbiome/results/decontam/contaminants_microbe_product.csv", row.names = TRUE)

print('computing contaminants_microbe_fisher.csv')
contamdf.freq = isContaminant(mat, method="frequency", conc=csv$concentration, normalize=FALSE, batch=csv$batch, batch.combine='fisher')
write.csv(contamdf.freq,"/home/groups/dpwall/briannac/blood_microbiome/results/decontam/contaminants_microbe_fisher.csv", row.names = TRUE)

print('computing contaminants_microbe_minimum.csv')
contamdf.freq = isContaminant(mat, method="frequency", conc=csv$concentration, normalize=FALSE, batch=csv$batch, batch.combine='minimum', detailed=TRUE)
write.csv(contamdf.freq,"/home/groups/dpwall/briannac/blood_microbiome/results/decontam/contaminants_microbe_minimum.csv", row.names = TRUE)