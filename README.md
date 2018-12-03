# genotype-base-src
### Background
Currently there are two available samples with genotyping in MoBa, HARVEST and ROTTERDAM1. These samples were QC'ed and imputed separately. The resulting VCFs from the Sanger Imputation Server require additional curation before they are ready for downstream analyses. This workflow generates a baseline dataset for the respective samples and merges the two into a single dataset for unified analyses.

The workflow uses Snakemake workflow manager. The files located in snakefiles/ contain scripts for handling specific parts of the data curation and extracting useful metadata from the dataset.  

## generate-base.snake
- Merges sub-batches within each sample (HARVEST only, ref. moba12 and moba24 within HARVEST) 
- Update markers without an rsID to rsID if found in dbSNP (v.151) reference. 
- Markers with no rsID in dbsnp are given a marker name on the format chr<CHR>:<POS>_<REF>/<ALT>
- Common markers (MAF > 0.001) are extracted and located in imputed/common/ whereas the full dataset is located in imputed/all/
- A PLINK bedset (bed/bim/fam) are generated for the common markers for convenience, located in imputed/common-bedset/

## generate-core.snake
- Generates PCAs for core samples (unrelated Norwegian ancestry with IBD PIHAT < 0.1)
- Spits out core lists for parents and offspring

## generate-aux.snake
### Generates auxilliary files useful for downstream analyses
### Rule: extract_info_score
Extracts marker information for all markers in the imputed dataset. Note that this is performed on the dataset after converting to unique rsIDs but before filtering on MAF. Hence, approx 40M markers available in this file.
Information extracted are:

 - Chromosome
 - Position
 - rsID (or EPACTS)
 - Reference allele
 - Alternative allele
 - Genotyped/non-genotyped status
 - Info score (imputation quality score)
 - Reference panel allele frequency

Files are located in: ???

### Rule: extract_sample_order
Some tooles, eg. SNPTEST, need the phenofile to have the same number of samples in the exact same order as they appear in the VCF files used for analysis. This rule extracts the sample order from 1) the autosomal files and 2) the X-chromosome separately, as these have differing number of samples

## generate-core.snake
MoBa contains various ethnicities. In order to generate a clean ethnic core set for downstream analysis, this workflow identifies and ethnic core set of samples and provide lists of samples defined as the *CORE*. Note that core sets are generated for parents and offspring separately. An ethnically Norwegian parent can exist in a core but not it's (half-ethnic) offspring.

### Rule: merge_genotyped_only
I use the clean genotyped dataset sent to phasing/imputation to identify the core set. This dataset differs slightly from the QC'ed dataset containing all markers as some markers (primarily rare and markers not in the HRC ref. panel) were removed prior to phasing/imputation. This rule merges M12 and M24 prior to core set identification.

### Rule: identify_core
Core sets were identifed as part of the QC with the sample flag list specifying whether the samples were in the core set or not. As QC was performed on M12 and M24 separately, some families overlapping the two batches were not excluded by the IBD filters during QC. This rule use extracts the core identified as part of the QC and runs an additional IBD filter removing samples with PI_HAT > 0.01. The rule outputs two lists 1) Core parents and 2) core offspring to be used in downstream analyses.

### Rule: generate_pca_covariates
Generates 10 principal components for the core lists to be used in downstream analyses, again for parents and offspring separately.








