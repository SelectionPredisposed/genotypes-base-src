#!/usr/bin/Rscript

library(ggplot2)
library(rgl)
library(tidyr)
library(dplyr)
library(ggpubr)

# Load hapmap ancestries
rel <- read.table('/home/oyvind/hunt-cloud/mnt/archive/HARVEST/genotypes-base-src/resources/relationships_w_pops_121708.txt', header = T, stringsAsFactors = F)

# Load PCA for Moba Genetics
pca <- read.table('/home/oyvind/hunt-cloud/mnt/archive/MOBAGENETICS/genotypes-base/pca/mobagenetics_hapmap.pca.evec', header = F, stringsAsFactors = T)
names(pca) <- c('SentrixID','PC1','PC2','PC3','PC4','PC5','PC6','PC7','PC8','PC9','PC10','control')
pca <- separate(data = pca,col = SentrixID, into = c('FID','IID'), remove = T, convert = F,sep = ':')

# Merge with population info
pca2 <- merge(pca,rel[,c('IID','population')], by='IID', all.x=T)

# Add MoBa to populations
pca2[is.na(pca2$population),]$population <- 'MOBA'

# 3D plot after changing default palette
palette(rainbow(length(levels(as.factor(pca2$population)))))
plot3d(pca2$PC1, pca2$PC2, pca2$PC3, col=as.numeric(as.factor(pca2$population)))
legend3d("topright", legend = levels(as.factor(pca2$population)), pch = 16, cex=1, inset=c(0.02))

# 3D plot with alpha level
plot3d(pca2$PC1, pca2$PC2, pca2$PC3, col=as.numeric(as.factor(pca2$population)), alpha=0.2)

# ggplot2
pc1_2 <- ggplot(data=pca2) + geom_point(aes(PC1,PC2, col=population))
pc2_3 <- ggplot(data=pca2) + geom_point(aes(PC2,PC3, col=population))
pc3_4 <- ggplot(data=pca2) + geom_point(aes(PC3,PC4, col=population))
pc4_5 <- ggplot(data=pca2) + geom_point(aes(PC4,PC5, col=population))

fig <- ggarrange(pc1_2,pc2_3,pc3_4,pc4_5, labels=c('A','B','C','D'))
annotate_figure(fig, top = text_grob("Principal component 1-5, Harvest + Rot1", color = "blue", face = "bold", size = 14))

# Select Moba samples to include based on eyeballing hard thresholds (remove the most obvious outliers)
pca3 <- pca2 %>% mutate(population=replace(population, PC1>0.015 & PC2>0.025, 'MOBAINC'))

# Plot after highlighting samples to include
pc1_2 <- ggplot(data=pca3) + geom_point(aes(PC1,PC2, col=population))
pc2_3 <- ggplot(data=pca3) + geom_point(aes(PC2,PC3, col=population))
pc3_4 <- ggplot(data=pca3) + geom_point(aes(PC3,PC4, col=population))
pc4_5 <- ggplot(data=pca3) + geom_point(aes(PC4,PC5, col=population))

fig <- ggarrange(pc1_2,pc2_3,pc3_4,pc4_5, labels=c('A','B','C','D'))
annotate_figure(fig, top = text_grob("Principal component 1-5, Harvest + Rot1", color = "blue", face = "bold", size = 14))

# Samples removed/included
nrow(subset(pca3, !pca3$population=='MOBAINC'))
nrow(subset(pca3, pca3$population=='MOBAINC'))

# Clustering tests
# get samples in mobainc
mobainc <- subset(pca3, population=="MOBAINC")

# add rownames to comply with tclust format
rownames(mobainc) <- mobainc$IID

# Run kmeans clustering per PCA pair
alphalevel=0.04
clus <- tkmeans (mobainc[,c('PC1','PC2')], k = 1, alpha = alphalevel, equal.weights = F)
mobainc$cluster12 <- clus$cluster

clus <- tkmeans (mobainc[,c('PC2','PC3')], k = 1, alpha = alphalevel, equal.weights = F)
mobainc$cluster23 <- clus$cluster

clus <- tkmeans (mobainc[,c('PC3','PC4')], k = 1, alpha = alphalevel, equal.weights = F)
mobainc$cluster34 <- clus$cluster

clus <- tkmeans (mobainc[,c('PC4','PC5')], k = 1, alpha = alphalevel, equal.weights = F)
mobainc$cluster45 <- clus$cluster

# Label all samples included in all PC combinations
mob <- mobainc %>% rowwise() %>% mutate(sum=sum(cluster12, cluster23, cluster34, cluster45)) %>% 
  mutate(status = ifelse(sum==4, "include","exclude")) %>% arrange(status)

table(mob$status)

# plot after clustering performed
pc1_2 <- ggplot(data=mob) + geom_point(aes(PC1,PC2, col=status))
pc2_3 <- ggplot(data=mob) + geom_point(aes(PC2,PC3, col=status))
pc3_4 <- ggplot(data=mob) + geom_point(aes(PC3,PC4, col=status))
pc4_5 <- ggplot(data=mob) + geom_point(aes(PC4,PC5, col=status))

fig <- ggarrange(pc1_2,pc2_3,pc3_4,pc4_5, labels=c('A','B','C','D'))
annotate_figure(fig, top = text_grob("Principal component 1-5, Harvest + Rot1", color = "blue", face = "bold", size = 14))

# Make a 3D plot of all samples
plot3d(mob$PC1, mob$PC2, mob$PC3,  col=as.numeric(as.factor(mob$status)))

# Check that alle samples in centre of cluster12 is included
ggplot(subset(mobainc,cluster12==0)) + geom_point(aes(PC1,PC2,col=cluster12))

# Plot excluding the included samples
# plot after clustering performed
mob2 <- subset(mob, status=='exclude')
pc1_2 <- ggplot(data=mob2) + geom_point(aes(PC1,PC2, col=status))
pc2_3 <- ggplot(data=mob2) + geom_point(aes(PC2,PC3, col=status))
pc3_4 <- ggplot(data=mob2) + geom_point(aes(PC3,PC4, col=status))
pc4_5 <- ggplot(data=mob2) + geom_point(aes(PC4,PC5, col=status))

fig <- ggarrange(pc1_2,pc2_3,pc3_4,pc4_5, labels=c('A','B','C','D'))
annotate_figure(fig, top = text_grob("Principal component 1-5, Harvest + Rot1", color = "blue", face = "bold", size = 14))


plot3d(mob2$PC1, mob2$PC2, mob2$PC3,  col=as.numeric(as.factor(mob$status)))


# Test - select samples for testing GRM exclusions
ggplot(data=pca2) + 
  geom_point(aes(PC1,PC2, col=population)) + 
  geom_hline(yintercept = 0.025) + 
  geom_vline(xintercept = 0.005)

sub1 <- subset(pca2, PC1>0.005 & PC2>0.025 & population=="MOBA")

write.table(x = sub1[,c('IID','FID')], 
            file = '/home/oyvind/hunt-cloud/mnt/archive/helgeland/tmp/test-gcta-grm-filtering/ceu-wide-moba.txt', 
            col.names = F, 
            row.names = F, 
            quote = F)
