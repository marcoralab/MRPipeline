'''Snakefile for Mendelian Randomization'''
# snakemake -s test.smk

import os
RWD = os.getcwd()

## Configfile - different for each gwas
REF = '/Users/sheaandrews/Documents/0_Data/1000genomes/EUR/EUR_All_Chr'
ExposureCode = 'cpd'
OutcomeCode = ['load', 'aaos', 'ab42', 'ptau', 'tau', 'hipv']
Pthreshold = '5e-8'
DataIn = '2_DerivedData/'

rule all:
    input:
        expand("2_DerivedData/test/{ExposureCode}_{Pthreshold}_SNPs.txt", ExposureCode=ExposureCode, Pthreshold=Pthreshold),
        expand("2_DerivedData/test/{ExposureCode}_{OutcomeCode}_{Pthreshold}_SNPs.txt", ExposureCode=ExposureCode, OutcomeCode=OutcomeCode, Pthreshold=Pthreshold),
        expand("2_DerivedData/test/{ExposureCode}_{OutcomeCode}_{Pthreshold}_MRdat.csv", ExposureCode=ExposureCode, OutcomeCode=OutcomeCode, Pthreshold=Pthreshold),
        expand("2_DerivedData/test/{ExposureCode}_{OutcomeCode}_{Pthreshold}_mrpresso.txt", ExposureCode=ExposureCode, OutcomeCode=OutcomeCode, Pthreshold=Pthreshold),
        expand("2_DerivedData/test/{ExposureCode}_{OutcomeCode}_{Pthreshold}_mrpresso.rds", ExposureCode=ExposureCode, OutcomeCode=OutcomeCode, Pthreshold=Pthreshold),

rule clump:
    input: DataIn + '{ExposureCode}_GWAS.Processed.gz'
    output: DataIn + 'test/{ExposureCode}.clumped'
    params:
        ref = REF,
        out = '2_DerivedData/test/{ExposureCode}'
    shell:
        "plink --bfile {params.ref}  --clump {input}  --clump-r2 0.1 --clump-kb 250 --clump-p1 1 --clump-p2 1 --out {params.out}"

rule gzip:
    input: DataIn + 'test/{ExposureCode}.clumped'
    output: DataIn + 'test/{ExposureCode}.clumped.gz'
    shell: "gzip {input}"

rule ExposureSnps:
    input:
        script = '3_Scripts/ExposureData.R',
        summary = DataIn + '{ExposureCode}_GWAS.Processed.gz',
        ExposureClump = DataIn + 'test/{ExposureCode}.clumped.gz'
    output:
        out = "2_DerivedData/test/{ExposureCode}_{Pthreshold}_SNPs.txt"
    params:
        Pthreshold = '{Pthreshold}'
    shell:
        'Rscript {input.script} {input.summary} {params.Pthreshold} {input.ExposureClump} {output.out}'

rule OutcomeSnps:
    input:
        script = '3_Scripts/OutcomeData.R',
        ExposureSummary = DataIn + 'test/{ExposureCode}_{Pthreshold}_SNPs.txt',
        OutcomeSummary = DataIn + '{OutcomeCode}_GWAS.Processed.gz'
    output:
        Outcome = DataIn + "test/{ExposureCode}_{OutcomeCode}_{Pthreshold}_SNPs.txt",
    shell:
        'Rscript {input.script} {input.ExposureSummary} {input.OutcomeSummary} {output.Outcome}'

rule Harmonize:
    input:
        script = '3_Scripts/DataHarmonization.R',
        ExposureSummary = DataIn + 'test/{ExposureCode}_{Pthreshold}_SNPs.txt',
        OutcomeSummary = DataIn + "test/{ExposureCode}_{OutcomeCode}_{Pthreshold}_SNPs.txt"
    output:
        Harmonized = DataIn + "test/{ExposureCode}_{OutcomeCode}_{Pthreshold}_MRdat.csv"
    params:
        ExposureCode = '{ExposureCode}',
        OutcomeCode = '{OutcomeCode}'
    shell:
        'Rscript {input.script} {input.ExposureSummary} {input.OutcomeSummary} {params.ExposureCode} {params.OutcomeCode} {output.Harmonized}'

rule MrPresso:
    input:
        script = '3_Scripts/MRPRESSO.R',
        mrdat = DataIn + "test/{ExposureCode}_{OutcomeCode}_{Pthreshold}_MRdat.csv",
    output:
        mpressoTXT = DataIn + "test/{ExposureCode}_{OutcomeCode}_{Pthreshold}_mrpresso.txt",
        mpressoRDS = DataIn + "test/{ExposureCode}_{OutcomeCode}_{Pthreshold}_mrpresso.rds"
    shell:
        'Rscript {input.script} {input.mrdat} {output.mpressoTXT} {output.mpressoRDS}'
