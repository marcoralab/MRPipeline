# snakemake -s ssimp.smk

CHUNKS = ['22:17000000-22:17500000', '22:17500001-22:18000000', '22:18000001-22:18500000', '22:18500001-22:19000000']

rule all:
    input:
        expand("/sc/orga/projects/LOAD/shea/bin/ssimp_software/output/ssimp_{chunks}.txt", chunks=CHUNKS),

rule ssimp:
    input: "/sc/orga/projects/LOAD/shea/bin/ssimp_software/gwas/small.random.txt",
    output: "/sc/orga/projects/LOAD/shea/bin/ssimp_software/output/ssimp_{chunks}.txt"
    params:
        imp_range = '{chunks}'
    shell:
        '/sc/orga/projects/LOAD/shea/bin/ssimp_software/ssimp \
        --gwas {input} \
        --ref ~/reference_panels/1000genomes/ALL.chr{{CHRM}}.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz \
        --out {output} \
        --impute.range {params.imp_range} \
        --reimpute.tags'

#    '/sc/orga/projects/LOAD/shea/bin/ssimp_software/ssimp \
#    --gwas {input} \
#    --ref ~/reference_panels/1000genomes/ALL.chr{CHRM}.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz \
#    --out {output} \
#    --sample.names ~/reference_panels/1000genomes/integrated_call_samples_v3.20130502.ALL.panel/sample/super_pop=EUR \
#    --impute.range {params.imp_range} \
#    --reimpute.tags'
