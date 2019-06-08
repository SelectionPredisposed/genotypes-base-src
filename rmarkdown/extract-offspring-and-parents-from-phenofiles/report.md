Extract parents and offspring in MobaGen
================

``` r
library(data.table)
library(dplyr)
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:data.table':
    ## 
    ##     between, first, last

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
library(tidyr)
```

``` r
# Load IDs from phenofile
if (Sys.info()['nodename'] == "harvest-home-snapshot-2018-07-02") {
  message("SYS IS SERVER")
  ids <- fread('/mnt/archive/moba/pheno/v10/V10_1.0.0-190506/id.gz', header = T, stringsAsFactors = F, data.table = F)
} else {
  ids <- fread('/home/oyvind/hunt-cloud/mnt/archive/moba/pheno/v10/V10_1.0.0-190506/id.gz', header = T, stringsAsFactors = F, data.table = F)
}
```

``` r
#' For a given data frame with multiple non-NA entries per row
#' selects the first non-NA entry from left to right (first used)
#' @df data frame with one sample per row
get.unique.samples <- function(df){
  first.sentrix.index <- max.col(!is.na(df), "first")

  # Generate a filtration matrix
  i=cbind(1:nrow(df),first.sentrix.index)

  # Grab the sentrixids using the filtration matrix
  no.duplicates <- df[i]
  
  return(no.duplicates)
}
```

``` r
### CHILDREN ###

# Select children and add counts to find duplicated samples
all.offspring <- ids %>% select(
  child_Harvest_SentrixID, 
  child_Rotterdam1_SentrixID,
  child_Rotterdam2_SentrixID,
  child_NormentMay16_SentrixID,
  child_NormentFeb18_SentrixID,
  child_Ted_SentrixID) %>% 
  filter_all(any_vars(!is.na(.))) %>% 
  mutate(counts = rowSums( !is.na(.)))

# Number of duplicated samples
table(all.offspring$counts)
```

    ## 
    ##     1     2 
    ## 31134   657

``` r
# Get the first sentrixID where there are multiple entries (duplicated samples) 
all.offspring.no.duplicates <- get.unique.samples(all.offspring)

# Print number of unique offspring (NB. Includes all ethnicities)
length(all.offspring.no.duplicates)
```

    ## [1] 31791

``` r
### MOTHERS
all.mothers <- ids %>% select(
  mother_Harvest_SentrixID, 
  mother_Rotterdam1_SentrixID,
  mother_Rotterdam2_SentrixID,
  mother_NormentMay16_SentrixID,
  mother_NormentFeb18_SentrixID,
  mother_NormentJun15_SentrixID,
  mother_NormentJan15_SentrixID,
  mother_Ted_SentrixID) %>% 
  filter_all(any_vars(!is.na(.))) %>% 
  mutate(counts = rowSums( !is.na(.)))

# Number of duplicated samples
table(all.mothers$counts)
```

    ## 
    ##     1     2     3 
    ## 30358   872     8

``` r
# Get the first sentrixID where there are multiple entries (duplicated samples) 
all.mothers.no.duplicates <- get.unique.samples(all.mothers)

# Print number of unique offspring (NB. Includes all ethnicities)
length(all.mothers.no.duplicates)
```

    ## [1] 31238

``` r
### FATHERS
all.fathers <- ids %>% select(
  father_Harvest_SentrixID, 
  father_Rotterdam1_SentrixID,
  father_Rotterdam2_SentrixID,
  father_NormentMay16_SentrixID,
  father_NormentFeb18_SentrixID,
  father_NormentJun15_SentrixID,
  father_NormentJan15_SentrixID,
  father_Ted_SentrixID) %>% 
  filter_all(any_vars(!is.na(.))) %>% 
  mutate(counts = rowSums( !is.na(.)))

# Number of duplicated samples
table(all.fathers$counts)
```

    ## 
    ##     1     2     3 
    ## 28264  1135    11

``` r
# Get the first sentrixID where there are multiple entries (duplicated samples) 
all.fathers.no.duplicates <- get.unique.samples(all.fathers)

# Print number of unique offspring (NB. Includes all ethnicities)
length(all.fathers.no.duplicates)
```

    ## [1] 29410

``` r
# TMP: Get placenta pheno

# Load IDs from phenofile
if (Sys.info()['nodename'] == "harvest-home-snapshot-2018-07-02") {
  delivery <- fread('/mnt/archive/moba/pheno/v10/V10_1.0.0-190506/delivery.gz', header = T, stringsAsFactors = F, data.table = F)
  pregnancy <- fread('/mnt/archive/moba/pheno/v10/V10_1.0.0-190506/pregnancy.gz', header = T, stringsAsFactors = F, data.table = F) 
  placenta.file.out = '/mnt/archive/helgeland/tmp/bolt-test/placenta/pheno-placenta-helgeland-8jun19'
} else {
  delivery <- fread('/home/oyvind/hunt-cloud/mnt/archive/moba/pheno/v10/V10_1.0.0-190506/delivery.gz', header = T, stringsAsFactors = F, data.table = F)
  pregnancy <- fread('/home/oyvind/hunt-cloud/mnt/archive/moba/pheno/v10/V10_1.0.0-190506/pregnancy.gz', header = T, stringsAsFactors = F, data.table = F) 
  placenta.file.out = '/home/oyvind/hunt-cloud/mnt/archive/helgeland/tmp/bolt-test/placenta/pheno-placenta-helgeland-8jun19'
}

delivery.sub <- delivery %>% 
  select(child_id, ends_with('SentrixID'), placenta_weight, sex) %>% 
  select(starts_with('child'), placenta_weight, sex) %>% 
  gather(key='cohort', value = 'sentrix', ends_with('SentrixID')) %>%
  filter(!is.na(sentrix)) %>% filter(sentrix %in% all.offspring.no.duplicates)

pregnancy.sub <- pregnancy %>% 
  select(child_id, ends_with('SentrixID'), pregnancy_duration) %>% 
  select(starts_with('child'), pregnancy_duration) %>% 
  gather(key='cohort', value = 'sentrix', ends_with('SentrixID')) %>%
  filter(!is.na(sentrix)) %>% filter(sentrix %in% all.offspring.no.duplicates)

pheno.out <- merge(delivery.sub, pregnancy.sub, by='sentrix') %>% mutate(FID = sentrix, IID = sentrix) %>% select(FID,IID, sex, placenta_weight, pregnancy_duration)

# Samples in offspring placenta pheno file
print(nrow(pheno.out))
```

    ## [1] 31791

``` r
write.table(pheno.out, file = placenta.file.out, col.names = T, row.names = F, quote = F)
```
