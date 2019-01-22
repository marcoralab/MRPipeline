# snakemake -s ssimp.smk --configfile ssimp_config.yaml
# snakejob -s ssimp.smk --configfile ssimp_config.yaml -j 250 --max-jobs-per-second 1

CHUNKS = config['chunks']
GWAS = config['GWAS']
DATAOUT = config['DataOut']

rule all:
    input:
        expand(DATAOUT + "ssimp_{chunks}.txt", chunks=CHUNKS),

rule ssimp:
    input:
        gwas = GWAS,
    output: DATAOUT + "ssimp_{chunks}.txt"
    params:
        imp_range = '{chunks}'
    shell:
        '/sc/orga/projects/LOAD/shea/bin/ssimp_software-master/ssimp \
        --gwas {input.gwas} \
        --ref ~/reference_panels/1000genomes/ALL.chr{{CHRM}}.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz \
        --out {output} \
        --impute.range {params.imp_range} \
        --reimpute.tags'

# cat /sc/orga/projects/LOAD/shea/bin/ssimp_software-master/output/ggt_* >> /sc/orga/projects/LOAD/shea/bin/ssimp_software-master/output/merged_ggt.txt
# grep -v "chr" /sc/orga/projects/LOAD/shea/bin/ssimp_software-master/output/merged_ggt.txt > temp && mv temp ggt_ssimp.txt
