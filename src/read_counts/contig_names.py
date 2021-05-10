import pysam

test_file = 's3://ihart-ms2/unmapped/batch_00927/02C10540/02C10540.final.paired.aln_all.bam'
file_path_out = '/scratch/users/briannac/blood_microbiome/intermediate_files/read_counts'
with pysam.AlignmentFile(test_file) as samfile:
    ref_names = samfile.references
bact_contigs = [r for r in ref_names if ('BACT' in r) | ('EUKY' in r) | ('ARCH' == r[:4])]
virus_contigs = [r for r in ref_names if ('VIR' == r[:3]) | ('NC_' in r[:3])]
alt_hap_contigs = [r for r in ref_names if r[:2]=='MH']
with open('%s/virus_contigs.txt' % file_path_out, 'w') as f:
    f.write(','.join(virus_contigs))
with open('%s/bacteria_contigs.txt' % file_path_out, 'w') as f:
    f.write(','.join(bact_contigs))
with open('%s/alt_hap_contigs.txt' % file_path_out, 'w') as f:
    f.write(','.join(alt_hap_contigs))