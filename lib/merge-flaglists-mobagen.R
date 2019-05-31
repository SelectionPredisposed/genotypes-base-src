#!/usr/bin/Rscript

# Library loading
library(dplyr)

pathprefix <- '/home/oyvind/hunt-cloud/'

# Specify flag-lists
harvest.flaglist <- file.path(pathprefix, '/mnt/archive/HARVEST/delivery-fhi/data/aux/flag-list/sample_flag_list-22-05-17.txt')
rot1.flaglist <- file.path(pathprefix, '/mnt/archive/ROTTERDAM1/delivery-fhi/data/aux/flag-list/sample_flag_list.txt')
rot2.flaglist <- file.path(pathprefix, '/mnt/archive/ROTTERDAM2/delivery-fhi/data/aux/flag-list/sample_flag_list.txt')
ted.flaglist <- file.path(pathprefix, '/mnt/archive/TED/delivery-fhi/data/aux/flag-list/sample_flag_list.txt')
feb18.flaglist <- file.path(pathprefix, '/mnt/archive/NORMENT1/delivery-fhi/data/aux/flag-list/feb18/sample_flag_list.txt')
may16.flaglist <- file.path(pathprefix, '/mnt/archive/NORMENT1/delivery-fhi/data/aux/flag-list/may16/sample_flag_list.txt')
jun15.flaglist <- file.path(pathprefix, '/mnt/archive/NORMENT1/delivery-fhi/data/aux/flag-list/jun15/sample_flag_list.txt')
jan15.flaglist <- file.path(pathprefix, '/mnt/archive/NORMENT1/delivery-fhi/data/aux/flag-list/jan15/sample_flag_list.txt')

# Read flag-lists
harvest <- read.table(harvest.flaglist, header = T, stringsAsFactors = F)
rot1 <- read.table(rot1.flaglist, header = T, stringsAsFactors = F)
rot2 <- read.table(rot2.flaglist, header = T, stringsAsFactors = F)
ted <- read.table(ted.flaglist, header = T, stringsAsFactors = F)
feb18 <- read.table(feb18.flaglist, header = T, stringsAsFactors = F)
may16 <- read.table(may16.flaglist, header = T, stringsAsFactors = F)
jun15 <- read.table(jun15.flaglist, header = T, stringsAsFactors = F)
jan15 <- read.table(jan15.flaglist, header = T, stringsAsFactors = F)

# Select columns
harvest.sub <- harvest %>% select(IID, BATCH, ROLE, genotypesOK, coreOK, phenotypesOK) %>% rename(coreUNRELATED = coreOK, phenoOK = phenotypesOK) %>% mutate(ROLE = ifelse(ROLE=='PARENT','FOUNDER','OFFSPRING'))
rot1.sub <- rot1 %>% select(IID, genotypesOK, coreUNRELATED, phenoOK, ROLE) %>% mutate(BATCH = 'ROT1')
rot2.sub <- rot2 %>% select(IID, genotypesOK, coreUNRELATED, phenoOK, ROLE) %>% mutate(BATCH = 'ROT2')
ted.sub <- ted %>% select(IID, genotypesOK, coreUNRELATED, phenoOK, ROLE) %>% mutate(BATCH = 'TED')
feb18.sub <- feb18 %>% select(IID, genotypesOK, coreUNRELATED, phenoOK, ROLE) %>% mutate(BATCH = 'FEB18')
may16.sub <- may16 %>% select(IID, genotypesOK, coreUNRELATED, phenoOK, ROLE) %>% mutate(BATCH = 'MAY16')
jun15.sub <- jun15 %>% select(IID, genotypesOK, coreUNRELATED, phenoOK, ROLE) %>% mutate(BATCH = 'JUN15')
jan15.sub <- jan15 %>% select(IID, genotypesOK, coreUNRELATED, phenoOK, ROLE) %>% mutate(BATCH = 'JAN15')

# Rbind lists
mobagen <- do.call("rbind", list(harvest.sub, rot1.sub, rot2.sub, ted.sub, feb18.sub, may16.sub, jun15.sub, jan15.sub))

# Write merged list to file
write.table(x = mobagen, 
            file = file.path(pathprefix, paste0('/mnt/archive/MOBAGENETICS/genotypes-base/aux/flaglist-merged/mobagen-flaglist','-n',nrow(mobagen),'.txt')), 
            row.names = F, 
            col.names = T, 
            quote = F, 
            sep = '\t')

# TEST
king <- read.table('/home/oyvind/hunt-cloud/mnt/archive/helgeland/tmp/king.kin0', header = T, stringsAsFactors = F)
king.po <- subset(king, InfType=="PO")

subset(mobagen, IID %in% king.po$ID2)

# load core founders
core.founders <- read.table('/home/oyvind/hunt-cloud/mnt/archive/HARVEST/genotypes-base-src/resources/core-founders-mobagen-merge-plink', header = F, stringsAsFactors = F)
