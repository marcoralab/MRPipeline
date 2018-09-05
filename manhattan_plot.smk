'''Snakefile for Manhattan Plot'''
# snakemake -s manhattan_plot.smk
# snakemake -s mr.smk --dag | dot -Tsvg > dag_mr.svg

import os
RWD = os.getcwd()

REF = '/Users/sheaandrews/Documents/0_Data/1000genomes/EUR/EUR_All_Chr'

TraitCode = ["aaos", "ab42", "acc425", "accave", "alcc", "alcd", "audit", "bmi",
"dep", "diab", "evrsmk", "fish", "hdl", "insom", "ldl", "load", "mdd", "mvpa",
"ptau", "sleep", "smkukbb", "sociso", "ssoe", "tau", "tc", "trig", "vpa"]
PlotTitle = "LDL Cholesterol - Willer 2013"

rule all:
    input:
        expand(RWD + '/4_output/{TraitCode}_ManhattanPlot.png', TraitCode=TraitCode),
        expand('2_DerivedData/{TraitCode}.clumped.gz', TraitCode=TraitCode)

rule clump:
    input: '2_DerivedData/{TraitCode}_GWAS.Processed.gz'
    output: '2_DerivedData/{TraitCode}.clumped'
    params:
        ref = REF,
        out = '2_DerivedData/{TraitCode}'
    shell:
        "plink --bfile {params.ref}  --clump {input}  --clump-r2 0.1 --clump-kb 250 --clump-p1 1 --clump-p2 1 --out {params.out}"

rule gzip:
    input: '2_DerivedData/{TraitCode}.clumped'
    output: '2_DerivedData/{TraitCode}.clumped.gz'
    shell: "gzip {input}"

rule manhattan_plot:
    input:
        script = '3_Scripts/manhattan_plot.R',
        ingwas = '2_DerivedData/{TraitCode}_GWAS.Processed.gz',
        inclump = '2_DerivedData/{TraitCode}.clumped.gz',
    params:
        PlotTitle = "{TraitCode}"
    output:
        out = RWD + '/4_output/{TraitCode}_ManhattanPlot.png'
    shell:
        "Rscript {input.script} {input.ingwas} {input.inclump} {output.out} \"{params.PlotTitle}\""
