# File structure

HOME_DIRECTORY:/home/groups/dpwall/briannac/blood_microbiome
OAK_DIRECTORY:/oak/stanford/groups/dpwall/users/briannac/blood_microbiome
SCRATCH_DIRECTORY:/scratch/groups/dpwall/briannac/blood_microbiome


- Data (OAK_DIRECTORY/data, symlinked to HOME_DIRECTORY/data)
    - bam_mappings.csv:
    - hmp_project_catalog.csv:
- Code (/src): python code, scripts, and ipython notebooks.
    - read_counts:
    - read_distributions:
    - abundances:
    - family_associations:
    - contaminants:
    - sex_association:
    - y_chromosome_contigs:
    - viral_integration:
- Intermdiate Outputs (/intermediate_files): intermediate_files_from_various_pipelines
- Results (/results): symlinks to output tables and figures saved in /oak/stanford/groups/dpwall/users/briannac/blood_microbiome/results
    - read_distributions: 
    - abundances:
    - family_associations:
    - contaminants:
    - sex_association:
    - y_chromosome_contigs:
    - viral_integration:
