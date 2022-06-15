#!/bin/bash
#SBATCH --job-name=call_virus_variants
#SBATCH --partition=owners
#SBATCH --output=/scratch/users/briannac/logs/call_virus_variants.out
#SBATCH --error=/scratch/users/briannac/logs/call_virus_variants.err
#SBATCH --time=40:00:00
#SBATCH --mem=100GB
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

## FILE IN sbatch $MY_HOME/blood_microbiome/src/viral_integration/call_virus_variants.sh

ml bcftools
cd /home/groups/dpwall/briannac/blood_microbiome/intermediate_files/herpesvirus
#for FILE in *paired_aligned_to_hg38_herpes.sam ; do
#    echo $FILE
#    samtools sort $FILE -o sorted/$FILE
#done


# Call variants (output VCF)

#bcftools mpileup -f  /home/groups/dpwall/briannac/blood_microbiome/data/reference_genomes/hg38_and_herpes.fa *.paired_aligned_to_hg38_herpes.sam | #bcftools call --ploidy 1 -m -Ov -o variants.vcf


## This didnt work 
# gatk FastaAlternateReferenceMaker \
#   -R /home/groups/dpwall/briannac/blood_microbiome/data/reference_genomes/hg38_and_herpes.fa \
#   -O  /home/groups/dpwall/briannac/blood_microbiome/results/herpesvirus/constructed_seqs.fasta \
#   -L  "kraken:taxid|32603|NC_001664.4" -L "kraken:taxid|32604|NC_000898.1" -L "kraken:taxid|10372|NC_001716.2" \
#   -V /home/groups/dpwall/briannac/blood_microbiome/results/herpesvirus/variants.vcf 
   


# Split variants into HHV-6A, HHV-6B, and HHV-7 specific vcfs.
#cd /home/groups/dpwall/briannac/blood_microbiome/results/herpesvirus 

echo "Splitting vcfs..."
cd /home/groups/dpwall/briannac/blood_microbiome/intermediate_files/herpesvirus
#bgzip -c variants.vcf > variants.vcf.gz
#tabix -p vcf variants.vcf.gz
#tabix -h variants.vcf.gz "kraken:taxid|32603|NC_001664.4" > hhv6A.vcf
#tabix -h variants.vcf.gz "kraken:taxid|32604|NC_000898.1" > hhv6B.vcf
#tabix -h variants.vcf.gz "kraken:taxid|10372|NC_001716.2" > hhv7.vcf


# Reconstruct the FASTA files and realign.
#echo "reconstructing and realigning hhv 6a..."
#bcftools view -S ^<(paste <(bcftools query -f '[%SAMPLE\t]\n' hhv6A.vcf | head -1 | tr '\t' '\n') <(bcftools query -f '[%GT\t]\n' hhv6A.vcf | awk -v OFS="\t" '{for (i=1;i<=NF;i++) if ($i == ".") sum[i]+=1 } END {for (i in sum) print i, sum[i] / NR }' | sort -k1,1n | cut -f 2) | awk '{ if ($2 > .5) print $1 }') hhv6A.vcf  > hhv6A_filt.vcf

#python $MY_HOME/blood_microbiome/src/viral_integration/vcf2phylip.py --input hhv6A_filt.vcf -m 0  --fasta --output-prefix hhv6A_reconstructed

/oak/stanford/groups/dpwall/computeEnvironments/mafft-7.453-without-extensions/bin/mafft  hhv6A_reconstructed.min0.fasta > hhv_6A_aligned.fa


#echo "reconstructing and realigning hhv 6B..."
#bcftools view -S ^<(paste <(bcftools query -f '[%SAMPLE\t]\n' hhv6B.vcf | head -1 | tr '\t' '\n') <(bcftools query -f '[%GT\t]\n' hhv6B.vcf | awk -v OFS="\t" '{for (i=1;i<=NF;i++) if ($i == ".") sum[i]+=1 } END {for (i in sum) print i, sum[i] / NR }' | sort -k1,1n | cut -f 2) | awk '{ if ($2 > .5) print $1 }') hhv6B.vcf  > hhv6B_filt.vcf

#python $MY_HOME/blood_microbiome/src/viral_integration/vcf2phylip.py --input hhv6B_filt.vcf  -m 0  --fasta --output-prefix hhv6B_reconstructed

/oak/stanford/groups/dpwall/computeEnvironments/mafft-7.453-without-extensions/bin/mafft  hhv6B_reconstructed.min0.fasta > hhv_6B_aligned.fa


#echo "reconstructing and realigning hhv 7..."
#bcftools view -S ^<(paste <(bcftools query -f '[%SAMPLE\t]\n' hhv7.vcf | head -1 | tr '\t' '\n') <(bcftools query -f '[%GT\t]\n' hhv7.vcf | awk -v OFS="\t" '{for (i=1;i<=NF;i++) if ($i == ".") sum[i]+=1 } END {for (i in sum) print i, sum[i] / NR }' | sort -k1,1n | cut -f 2) | awk '{ if ($2 > .5) print $1 }') hhv7.vcf  > hhv7_filt.vcf

#python $MY_HOME/blood_microbiome/src/viral_integration/vcf2phylip.py --input hhv7_filt.vcf  -m 0 --fasta --output-prefix hhv7_reconstructed

/oak/stanford/groups/dpwall/computeEnvironments/mafft-7.453-without-extensions/bin/mafft  hhv7_reconstructed.min0.fasta > hhv_7_aligned.fa
echo "Moving..."
mv *_aligned.fa $MY_HOME/blood_microbiome/results/herpesvirus
