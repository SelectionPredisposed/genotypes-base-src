# EIGENSTRAT HELPER FUNCTIONS
# 
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
# 4. txt list of anchor populations
function create_smartpca_paramfile {
    echo "genotypename: $1.geno" > $3
    echo "snpname:      $1.snp" >> $3
    echo "indivname:    $1.ind" >> $3
    echo "evecoutname:  $2.pca.evec" >> $3
    echo "evaloutname:  $2.eval" >> $3
    if [ ! -z ${4:-} ]
    then
        echo "poplistname:  $4" >> $3
    else
        echo "fastmode:     YES" >> $3
    fi
    echo "altnormstyle: NO" >> $3
    echo "numoutevec:   10" >> $3
    echo "numoutlieriter:   0" >> $3
    echo "numoutlierevec:   10" >> $3
    echo "outliersigmathresh: 6" >> $3
    echo "qtmode:       0" >> $3
}

# Args:
# 1. Input bedset (needs to be pre-pruned)
# 2. Output path + prefix of PCA output
# 3. TMP folder
function pca {
    # Make sure output folder exists
    mkdir -p `dirname $2`

    # Recode
    plink \
        --bfile $1 \
        --autosome \
        --recode \
        --out $3/pca_recoded_tmp

    # CONVERTF
    # Create convertf compliant fileset (pedsnp and pedind)
    cat $3/pca_recoded_tmp.map > $3/pca_recoded_tmp.pedsnp
    awk '{print $1" "$2" "$3" "$4" "$5" 1"}' $3/pca_recoded_tmp.ped > $3/pca_recoded_tmp.pedind

    create_convertf_paramfile \
        $3/pca_recoded_tmp \
        $3/pca_recoded_eig \
        $3/pca_convertf_params

    PATH=$PATH:bin/eigenstrat/
    convertf -p $3/pca_convertf_params

    # PCA
    create_smartpca_paramfile \
        $3/pca_recoded_eig \
        $2 \
        $3/merge-pca.par

    smartpca -p $3/merge-pca.par
}
