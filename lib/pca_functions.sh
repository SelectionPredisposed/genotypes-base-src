# Create param file for convertf
# Args:
# 1. Input path + stem (og ped/map fileset)
# 2. Output path + stem
# 3. Output path + filename of convertf param file
function create_convertf_paramfile {
    echo "genotypename:    $1.ped" > $3
    echo "snpname:         $1.pedsnp" >> $3
    echo "indivname:       $1.pedind" >> $3
    echo "outputformat:    EIGENSTRAT" >> $3
    echo "genotypeoutname: $2.geno" >> $3
    echo "snpoutname:      $2.snp" >> $3
    echo "indivoutname:    $2.ind" >> $3
    echo "familynames:     YES" >> $3
}

# Create param file for smartpca
# Args:
# 1. Input path + stem (og ped/map fileset)
# 2. Output path + stem
# 3. Output path + filename of param file
function create_smartpca_paramfile {
    echo "genotypename: $1.geno" > $3
    echo "snpname:      $1.snp" >> $3
    echo "indivname:    $1.ind" >> $3
    echo "evecoutname:  $2.pca.evec" >> $3
    echo "evaloutname:  $2.eval" >> $3
    echo "altnormstyle: NO" >> $3
    echo "numoutevec:   10" >> $3
    echo "numoutlieriter:   0" >> $3
    echo "numoutlierevec:   10" >> $3
    echo "outliersigmathresh: 6" >> $3
    echo "qtmode:       0" >> $3
    echo "fastmode:     YES" >> $3  
}

# Args:
# 1. Input bedset (needs to be pre-pruned)
# 2. Output path + prefix of PCA output
# 3. No of PCAs
# 4. Plot (YES/NO) - TODO implement
# 5. TMP folder
function pca {
    echo $1
    echo $2
    echo $3
    echo $4
    echo $5
    # Make sure output folder exists
    #mkdir -p $(dirname $2)
    echo "---"
    echo $5
    # Recode
    plink \
        --bfile $1 \
        --autosome \
        --recode \
        --out $5/pca_recoded_tmp

    # CONVERTF
    # Create convertf compliant fileset (pedsnp and pedind)
    cat $5/pca_recoded_tmp.map > $5/pca_recoded_tmp.pedsnp
    awk '{print $1" "$2" "$3" "$4" "$5" 1"}' $5/pca_recoded_tmp.ped > $5/pca_recoded_tmp.pedind

    create_convertf_paramfile \
        $5/pca_recoded_tmp \
        $5/pca_recoded_eig \
        $5/pca_convertf_params

    PATH=$PATH:bin/eigenstrat/
    convertf -p $5/pca_convertf_params

    # PCA
    create_smartpca_paramfile \
        $5/pca_recoded_eig \
        $2 \
        $5/merge-pca.par

    smartpca -p $5/merge-pca.par
}

# Takes a pre-pruned input dataset, merges with HapMap and runs PCA
# Args:
# 1. Input stem of bedset
# 2. Input stem of hapmap
# 3. Output path + prefix of PCA results
# 4. TMP-folder
function pca_with_hapmap {
    # Make sure output path exists
    mkdir -p `dirname $3`

    # Get list of all markers in input dataset
    awk '{print $2}' $1.bim > $4/pcain_pruned_markerlist

    # Extract markers in input dataset from HapMap data
    plink \
        --bfile $2 \
    --extract $4/pcain_pruned_markerlist \
        --make-bed \
        --out $4/hapmap_pruned

    # Check to see if multiple chromosomes are seen for single variant
    # Eg. if a variant got new position from b36 to b37
    # Result from this function is a markerset ok for merge and PCA
    awk '{n[$2]++} END{for(s in n) if(n[s]==1) print s}' \
        $4/hapmap_pruned.bim > $4/referencedata.studymarkers.tmp.prune.in
    numsnps_touse=`wc -l $4/referencedata.studymarkers.tmp.prune.in | cut -d ' ' -f1`
    #store "NSNP_TOBEUSEDINPCA" ${numsnps_touse}

    # Extract markers from study data
    plink \
        --bfile $1 \
        --extract $4/referencedata.studymarkers.tmp.prune.in \
        --make-bed \
        --out $4/studydata_refmarkers_ok

    # Extract markers from HapMap data
    plink \
        --bfile $2 \
        --extract $4/referencedata.studymarkers.tmp.prune.in \
        --make-bed \
        --out $4/refdata_refmarkers_ok

    # merge datasets the first time
    # || true not to trigger error if set -e
    plink \
        --bfile $4/refdata_refmarkers_ok \
        --allow-no-sex \
        --bmerge $4/studydata_refmarkers_ok \
        --make-bed \
        --out $4/first_merge_pca || true

    # remove markers with micmatching allele codes
    plink \
        --bfile $4/studydata_refmarkers_ok \
        --exclude $4/first_merge_pca-merge.missnp \
        --make-bed \
        --out $4/studydata

    plink \
        --bfile $4/refdata_refmarkers_ok \
        --exclude $4/first_merge_pca-merge.missnp \
        --make-bed \
        --out $4/refdata

    #remerge
    plink \
        --bfile $4/refdata \
        --allow-no-sex \
        --bmerge $4/studydata \
        --make-bed \
        --out $4/merge-pca

    #report_nsnps $4/merge-pca "MERGEDFORPCA"

    # recode to ped
    plink \
        --bfile $4/merge-pca \
        --recode \
        --out $4/merge-pca

    # Create files for convertf
    # Genotype file: use .ped
    # SNP-file:
    cat $4/merge-pca.map > $4/merge-pca.pedsnp
    # Indivfile
    awk '{print $1" "$2" "$3" "$4" "$5" 1"}' $4/merge-pca.ped > $4/merge-pca.pedind

    create_convertf_paramfile \
        $4/merge-pca \
        $4/merge-pca-eig \
        $4/merge_pca_convertf_params

    PATH=$PATH:bin/eigenstrat/
    convertf -p $4/merge_pca_convertf_params

    create_smartpca_paramfile \
        $4/merge-pca-eig \
        $3 \
        $4/merge-pca.par
    smartpca -p $4/merge-pca.par
    #log "Running PCA on merged studydata and HapMap"
}
