
# Get founders
for i in $(seq 1 22);
do
    # FOUNDER + genotypesOK==TRUE + coreOK==TRUE
    awk '$3=="PARENT" && $20=="TRUE" && $21=="TRUE" {print $1}' /mnt/archive/HARVEST/delivery-fhi/data/aux/flag-list/sample_flag_list-22-05-17.txt > /mnt/scratch/helgeland/harvest-base-tmp//founders-freq-include-${i}

    plink2 \
        --vcf /mnt/archive/HARVEST/genotypes-base/imputed/all/${i}.vcf.gz \
        --keep /mnt/scratch/helgeland/harvest-base-tmp//founders-freq-include-${i} \
        --geno-counts \
        --threads 32 \
        --out /mnt/archive/HARVEST/genotypes-base/aux/freq/${i}-freq
done
