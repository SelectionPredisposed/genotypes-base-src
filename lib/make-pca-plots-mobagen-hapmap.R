#!/usr/bin/Rscript

################################################################################
#
# Script plots PCA plot with Study data and HapMap population from Eigenstrat
# PCA output. Requires PCA eigenvectors and HapMap population info
#
################################################################################

#----------------------------------Arugments-----------------------------------#
args <- commandArgs(TRUE)

# pca input hapmap + mobagen
#input.pca <- '/home/oyvind/hunt-cloud/mnt/archive/MOBAGENETICS/genotypes-base/aux/pca/hapmap-mobagen/hapmap-mobagen-merged-pca'
input.pca <- args[1]

# population list for hapmap samples
#input.pop <- '/home/oyvind/hunt-cloud/mnt/archive/helgeland/refdata/hapmap/relationships_w_pops_121708.txt'
input.pop <- args[2]

# output path for hapmap + mobagen plots
#output.path.hm <- '/home/oyvind/Downloads/pcatest/hm'
output.path.hm <- args[3]

# output path for mobagen core (incl. hapmap) plots
#output.path.mobagen <- '/home/oyvind/Downloads/pcatest/mobagen'
output.path.mobagen <- args[4]

# output file for ethnic core samples
output.core.list <- args[5]

# output.pc1.name <- args[4]
# output.pc2.name <- args[5]
# output.pc3.name <- args[6]
# output.pc4.name <- args[7]
# output.twofirst.pc <- args[8]
# output.fourfirst.pc <- args[9]

#----------------------------------Libraries-----------------------------------#
library(tidyr)
library(ggplot2)
library(cowplot)

#----------------------------------Script--------------------------------------#

# Load PCAs
pcahap <- read.table(input.pca, header = T, stringsAsFactors = F)

# Load Hapmap population info
hm.popinfo <- read.table(input.pop, header = T, stringsAsFactors = F) 

# Merge HapMap population info with PCAs and add MOBA to study samples
m <- merge(pcahap, hm.popinfo[,c('IID','population')], by='IID', all.x=T)
m[is.na(m$population),]$population <- 'MOBA'

# Convert population vector to factor and specify order. MOBA at the end to 
# order df by vector to plot MoBa samples last (on top in plot) 
m$population <- factor(m$population, levels = c('MOBA','ASW','CEU','CHB','CHD','GIH','JPT','LWK','MEX','MKK','TSI','YRI'))
m <- with(m, m[order(population),])

# Generate plots single PC plots for 5 first PCs
pc1 <- ggplot() + geom_point(data=m, aes(PC1,PC2, col=population)) + xlab('PC1') + ylab('PC2') + ggtitle('PC1 vs. PC2') + scale_color_brewer(palette="Paired")
pc2 <- ggplot() + geom_point(data=m, aes(PC2,PC3, col=population)) + xlab('PC2') + ylab('PC3') + ggtitle('PC2 vs. PC3') + scale_color_brewer(palette="Paired")
pc3 <- ggplot() + geom_point(data=m, aes(PC3,PC4, col=population)) + xlab('PC3') + ylab('PC4') + ggtitle('PC3 vs. PC4') + scale_color_brewer(palette="Paired")
pc4 <- ggplot() + geom_point(data=m, aes(PC4,PC5, col=population)) + xlab('PC4') + ylab('PC5') + ggtitle('PC4 vs. PC5') + scale_color_brewer(palette="Paired")

# Plot3d
# plot3d(m$PC1, m$PC2, m$PC3, col=as.numeric(m$population))

# Generate a plot grid with two first PC plots
pg1 <- plot_grid(
          pc1 + theme(legend.position="none"),
          pc2 + theme(legend.position="none"))

# Retrieve legend from one of the plots. Add it to the plot grid and give relative
# size to reduce the spacing for the legend
legend <- get_legend(pc1)
twopc <- plot_grid(pg1, legend,  rel_widths = c(2, 0.5), rel_heights = c(2, 0.1))

# Generate plot with first four PC plots. First create a row with the pc3 and pc4
# plots before adding to new grid
pg2 <- plot_grid(
  pc3 + theme(legend.position="none"),
  pc4 + theme(legend.position="none"))

# Add the two 2x1 plot grids to a 2x2 table
pg3 <- plot_grid(pg1,pg2, ncol=1, nrow=2)

# Add the legend to the 2x2 grid and specify relative height and weight
fourpc <- plot_grid(pg3, legend,  rel_widths = c(2, 0.5), rel_heights = c(2, 0.1))

# Write single plots as png and pdf
for(i in seq(1,4)){
  for(dev in c('png','pdf')){
    ggsave(plot = get(paste0('pc',i)), 
           filename = paste0('pcaplot',i,'.',dev),
           path = output.path.hm,
           device = dev,
           width = 12,
           height = 8,
           units = 'in')
  }
}

# Write grid plots to png and pdf
for(i in c('twopc','fourpc')){
  for(dev in c('png','pdf')){
    ggsave(plot = get(i), 
           filename = paste0('pcaplot-',i,'.',dev),
           path = output.path.hm,
           device = dev,
           width = 12,
           height = 8,
           units = 'in')
  }
}


### EXTRACT ETHNIC CORE SAMPLES

# Extract samples in ethnic core
ethnic.core <- subset(m, population=="MOBA" & PC1 > 0.15 & PC1 < 0.3 & PC2 > -0.4 & PC2< -0.19 & PC3 > -0.015 & PC3 < 0.1)

# Mark CORE samples in pca df
m$CORE <- ifelse(m$IID %in% core.ethnic$IID,1,0)

# Change population to CORE in pca df
m$population <- apply(m, 1, function(x){ ifelse(x['CORE']==1,'CORE',x['population'])})
m$population <- factor(m$population, levels = c('MOBA','CORE','ASW','CEU','CHB','CHD','GIH','JPT','LWK','MEX','MKK','TSI','YRI'))

m2 <- with(m, m[order(population),])

# Make a palette with 13 colors
pal1 <- rainbow(13)

# Interpolate color palette to add 13 distinct colors
colourCount = length(unique(m$population))
getPalette = colorRampPalette(brewer.pal(9, "Paired"))

# Make pc plots
pc1.core <- ggplot() + geom_point(data=m2, aes(PC1,PC2, col=as.factor(population))) + xlab('PC1') + ylab('PC2') + ggtitle('PC1 vs. PC2') + scale_color_manual(values = getPalette(13))
pc2.core <- ggplot() + geom_point(data=m2, aes(PC2,PC3, col=as.factor(population))) + xlab('PC2') + ylab('PC3') + ggtitle('PC2 vs. PC3') + scale_color_manual(values = getPalette(13))
pc3.core <- ggplot() + geom_point(data=m2, aes(PC3,PC4, col=as.factor(population))) + xlab('PC3') + ylab('PC4') + ggtitle('PC3 vs. PC4') + scale_color_manual(values = getPalette(13))
pc4.core <- ggplot() + geom_point(data=m2, aes(PC4,PC5, col=as.factor(population))) + xlab('PC4') + ylab('PC5') + ggtitle('PC4 vs. PC5') + scale_color_manual(values = getPalette(13))

# Generate a plot grid with two first PC plots
pg1.core <- plot_grid(
  pc1.core + theme(legend.position="none"),
  pc2.core + theme(legend.position="none"))

# Retrieve legend from one of the plots. Add it to the plot grid and give relative
# size to reduce the spacing for the legend
legend <- get_legend(pc1.core)
twopc.core <- plot_grid(pg1.core, legend,  rel_widths = c(2, 0.5), rel_heights = c(2, 0.1))

# Generate plot with first four PC plots. First create a row with the pc3 and pc4
# plots before adding to new grid
pg2.core <- plot_grid(
  pc3.core + theme(legend.position="none"),
  pc4.core + theme(legend.position="none"))

# Add the two 2x1 plot grids to a 2x2 table
pg3.core <- plot_grid(pg1.core,pg2.core, ncol=1, nrow=2)

# Add the legend to the 2x2 grid and specify relative height and weight
fourpc.core <- plot_grid(pg3.core, legend,  rel_widths = c(2, 0.5), rel_heights = c(2, 0.1))

# Write single plots as png and pdf
for(i in seq(1,4)){
  for(dev in c('png','pdf')){
    ggsave(plot = get(paste0('pc',i,'.core')), 
           filename = paste0('pcaplot',i,'.',dev),
           path = output.path.mobagen,
           device = dev,
           width = 12,
           height = 8,
           units = 'in')
  }
}

# Write grid plots to png and pdf
for(i in c('twopc.core','fourpc.core')){
  for(dev in c('png','pdf')){
    ggsave(plot = get(i), 
           filename = paste0('pcaplot-',i,'.',dev),
           path = output.path.mobagen,
           device = dev,
           width = 12,
           height = 8,
           units = 'in')
  }
}

# Output list with core ethnic moba samples
write.table(x = ethnic.core$IID, 
            file = '/home/oyvind/tmp/ethnic_core', 
            quote = F, 
            row.names = F, 
            col.names = F)
