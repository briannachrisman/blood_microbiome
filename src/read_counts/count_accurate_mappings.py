from collections import Counter
import pysam
import sys
import glob

# Set up file names etc.
sample = sys.argv[1]
batch = sys.argv[2]

file_path_out = '/scratch/users/briannac/blood_microbiome/intermediate_files/read_counts'
single_reads_file = 's3://ihart-ms2/unmapped/%s/%s/%s.final.paired.aln_all.bam' % (batch, sample.replace('_LCL', '-LCL'), sample.replace('_LCL', '-LCL'))
paired_reads_file = 's3://ihart-ms2/unmapped/%s/%s/%s.final.single.aln_all.bam' % (batch, sample.replace('_LCL', '-LCL'), sample.replace('_LCL', '-LCL'))

AS_thresh = 100
MAPQ_thresh = 1

# Read in interesting contigs
with open('%s/alt_hap_contigs.txt' % file_path_out) as f:
    alt_hap_contigs = f.read().split(',')
with open('%s/virus_contigs.txt' % file_path_out) as f:
    virus_contigs = f.read().split(',')
with open('%s/bacteria_contigs.txt' % file_path_out) as f:
    bact_contigs = f.read().split(',')

    
for contig_type, contigs in zip(['bacteria', 'virus', 'alt_hap'],[bact_contigs, virus_contigs, alt_hap_contigs]):
    if len(glob.glob('%s/%s.%s.txt' % (file_path_out, sample, contig_type)))>0: 
        print(glob.glob('%s/%s.%s.txt' % (file_path_out, sample, contig_type))[0], ' exists')
        continue
    print(contig_type)
    with pysam.AlignmentFile(single_reads_file) as samfile:
        reads_1 = [r for c in contigs for r in samfile.fetch(c) if (~r.is_supplementary & ~r.is_secondary)]
    with pysam.AlignmentFile(paired_reads_file) as samfile:
        reads_2 = [r for c in contigs for r in samfile.fetch(c) if (~r.is_supplementary & ~r.is_secondary)]
    reads = reads_1 + reads_2

    # Compute accurate mappings/inaccurate mappings.
    high_AS = [r for r in reads if (r.get_tag('AS')>=AS_thresh)]
    unmapped = {r for r in reads if r.get_tag('AS')<AS_thresh}
    accurate_mapping = {r.query_name:r for r in high_AS if r.mapq>=MAPQ_thresh}
    ambig_mapping = {r for r in high_AS if r.mapq<MAPQ_thresh}
    accurate_mate_mapping = {r for r in ambig_mapping if (r.query_name in accurate_mapping.keys()) & (r.is_proper_pair)}.union(
                             {r for r in unmapped if (r.query_name in accurate_mapping.keys()) & (r.is_proper_pair)})
    unmapped_new = unmapped.difference(accurate_mate_mapping)
    ambig_mapping_new = ambig_mapping.difference(accurate_mate_mapping)
    accurate_mapping_new = accurate_mate_mapping.union(set(accurate_mapping.values()))

    # Create counts of each microbe & write to file.
    counter = Counter()
    idx = contigs + ['ambig', 'poor_align']
    counter.update({x:0 for x in idx})
    counter = counter + Counter([r.reference_name for r in accurate_mapping_new]) + Counter(['ambig' for r in ambig_mapping_new]) + Counter(['poor_align' for r in unmapped_new])
    to_write = [sample] + [str(counter[i]) for i in idx]
    with open('%s/%s.%s.txt' % (file_path_out, sample, contig_type) , "w+") as file_out:
        file_out.write(','.join(to_write))