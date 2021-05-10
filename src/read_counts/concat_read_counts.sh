#mv /scratch/users/briannac/blood_microbiome/make_microbe_mats/* /scratch/users/briannac/blood_microbiome/intermediate_files/read_counts
cd /scratch/users/briannac/blood_microbiome/intermediate_files/read_counts/


# Virus
sed  '1s/^/sample,/' virus_contigs.txt > virus_contigs.tmp.txt
echo -n ",ambig,poorly_aligned" >> virus_contigs.tmp.txt
echo "" >> virus_contigs.tmp.txt
\rm virus.tmp.txt
for f in *.virus.txt ; do (cat "${f}"; echo) >> virus.tmp.txt; done
cat virus_contigs.tmp.txt virus.tmp.txt > virus.all.csv
\rm virus_contigs.tmp.txt
\rm virus.tmp.txt
#\rm virus.all.csv

# Bacteria
cd /scratch/users/briannac/blood_microbiome/intermediate_files/read_counts/
sed  '1s/^/sample,/' bacteria_contigs.txt > bacteria_contigs.tmp.txt
echo -n ",ambig,poorly_aligned" >> bacteria_contigs.tmp.txt
echo "" >> bacteria_contigs.tmp.txt
\rm bacteria.tmp.txt
for f in *.bacteria.txt ; do (cat "${f}"; echo) >> bacteria.tmp.txt; done
cat bacteria_contigs.tmp.txt bacteria.tmp.txt > bacteria.all.csv
\rm bacteria_contigs.tmp.txt
\rm bacteria.tmp.txt
#\rm bacteria.all.csv

# Alt hap.
cd /scratch/users/briannac/blood_microbiome/intermediate_files/read_counts/
sed  '1s/^/sample,/' alt_hap_contigs.txt > alt_hap_contigs.tmp.txt
echo -n ",ambig,poorly_aligned" >> alt_hap_contigs.tmp.txt
echo "" >> alt_hap_contigs.tmp.txt
\rm alt_hap.tmp.txt
for f in *.alt_hap.txt ; do (cat "${f}"; echo) >> alt_hap.tmp.txt; done
cat alt_hap_contigs.tmp.txt alt_hap.tmp.txt > alt_hap.all.csv

\rm alt_hap_contigs.tmp.txt
\rm alt_hap.tmp.txt
#\rm alt_hap.all.csv

# Unmapped.
\rm unmapped.all.txt
cat *.unmapped.txt > unmapped.all.txt
cp unmapped.all.txt /home/groups/dpwall/briannac/blood_microbiome/data/unmapped.tsv