#!/usr/bin/Rscript

library(data.table)

chrom = seq(1,4,1)

mobagen     <- '/mnt/archive/MOBAGENETICS/genotypes-base/aux/markerinfo/'
harvest     <- '/mnt/archive/HARVEST/genotypes-base/aux/markerinfo/'
rotterdam1  <- '/mnt/archive/ROTTERDAM1/genotypes-base/aux/markerinfo/'
rotterdam2  <- '/mnt/archive/ROTTERDAM2/genotypes-base/aux/markerinfo/'
ted         <- '/mnt/archive/TED/genotypes-base/aux/markerinfo/'
jan15       <- '/mnt/archive/NORMENT1/genotypes-base/jan15/aux/markerinfo/'
# jun15       <- '/mnt/archive/NORMENT1/genotypes-base/jun15/aux/markerinfo/'
may16       <- '/mnt/archive/NORMENT1/genotypes-base/may16/aux/markerinfo/'
feb18       <- '/mnt/archive/NORMENT1/genotypes-base/feb18/aux/markerinfo/'

batches <- c('harvest','rotterdam1','rotterdam2','ted','jan15','jun15','may16','feb18')
#batches <- c('harvest','rotterdam1')

for(c in chrom){
  for(b in batches){
    print(b)
    # Get the path to the info files for the batch
    df <- get(b)
  
    # Get the markerinfo file for the chromosome
    df2 <- file.path(df,paste0(c,'-markerinfo.gz'))
    #print(df2)
  
    # Create a variable name to store the df with the info scores for the batch + chromosome
    indf <- paste0(b,'.temp')
    #print(indf)
  
    # Load the markerinfo
    tmpdf <- fread(file=df2, header = T, stringsAsFactors = F, data.table = F)
    print(nrow(tmpdf))
  
    # Make headers to suffix typed and infoscore column
    typed = paste0('TYPED','_', b)
    infoscore <- paste0('INFO','_', b)
  
    # Update column names
    names(tmpdf) <- c('CHROM','POS','RSID','REF','ALT', typed, infoscore, 'RefPanelAF')
  
    # Assign the loaded df to variable
    assign(x = indf, value = tmpdf)
  }
  # merge all batches for the chromosome
  out <- Reduce(function(x, y) merge(x, y, all=TRUE), list(harvest.temp, rotterdam1.temp, rotterdam2.temp, ted.temp, jan15.temp, jun15.temp, may16.temp, feb18.temp))
  
  # debugging
  print(nrow(out))
  head(out)
  
  # write file to drive
  write.table(x = out, file = paste0('mobagen','-chr',c,'.txt'), col.names = T, row.names = F, quote = F)
}


#head(harvest.chr)  
