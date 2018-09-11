'''Snakefile for Mendelian Randomization'''
# snakemake -s mr.smk

import os
RWD = os.getcwd()

## Configfile - different for each gwas
REF = '1_RawData/EUR_All_Chr'
ExposureCode = 'cpd'
OutcomeCode = ['load', 'aaos', 'ab42', 'ptau', 'tau', 'hipv', 'hipv2015']
Pthreshold = ['5e-6', '5e-8']
DataIn = '1_RawData/GWAS/'
traits = '1_RawData/MRTraits.csv'
DataOut = "2_DerivedData/"
rule all:
    input:
        expand("4_Output/{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_MR_Analaysis.html", ExposureCode=ExposureCode, OutcomeCode=OutcomeCode, Pthreshold=Pthreshold),

rule clump:
    input: DataIn + '{ExposureCode}_GWAS.Processed.gz'
    output: DataIn + '{ExposureCode}.clumped'
    params:
        ref = REF,
        out =  DataIn + '{ExposureCode}'
    shell:
        "plink --bfile {params.ref}  --clump {input}  --clump-r2 0.1 --clump-kb 250 --clump-p1 1 --clump-p2 1 --out {params.out}"

rule gzip:
    input: DataIn + '{ExposureCode}.clumped'
    output: DataIn + '{ExposureCode}.clumped.gz'
    shell: "gzip {input}"

rule ExposureSnps:
    input:
        script = '3_Scripts/ExposureData.R',
        summary = DataIn + '{ExposureCode}_GWAS.Processed.gz',
        ExposureClump = DataIn + '{ExposureCode}.clumped.gz'
    output:
        out = "2_DerivedData/{ExposureCode}/{ExposureCode}_{Pthreshold}_SNPs.txt"
    params:
        Pthreshold = '{Pthreshold}'
    shell:
        'Rscript {input.script} {input.summary} {params.Pthreshold} {input.ExposureClump} {output.out}'

rule OutcomeSnps:
    input:
        script = '3_Scripts/OutcomeData.R',
        ExposureSummary = "2_DerivedData/{ExposureCode}/{ExposureCode}_{Pthreshold}_SNPs.txt",
        OutcomeSummary = DataIn + "{OutcomeCode}_GWAS.Processed.gz"
    output:
        "2_DerivedData/{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_SNPs.txt",
        "2_DerivedData/{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_proxys.csv",
    params:
        Outcome = "2_DerivedData/{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}",
    shell:
        'Rscript {input.script} {input.ExposureSummary} {input.OutcomeSummary} {params.Outcome}'

rule Harmonize:
    input:
        script = '3_Scripts/DataHarmonization.R',
        ExposureSummary = "2_DerivedData/{ExposureCode}/{ExposureCode}_{Pthreshold}_SNPs.txt",
        OutcomeSummary = "2_DerivedData/{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_SNPs.txt"
    output:
        Harmonized = "2_DerivedData/{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_MRdat.csv"
    params:
        ExposureCode = '{ExposureCode}',
        OutcomeCode = '{OutcomeCode}'
    shell:
        'Rscript {input.script} {input.ExposureSummary} {input.OutcomeSummary} {params.ExposureCode} {params.OutcomeCode} {output.Harmonized}'

rule MrPresso:
    input:
        script = '3_Scripts/MRPRESSO.R',
        mrdat = "2_DerivedData/{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_MRdat.csv",
    output:
        "2_DerivedData/{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_mrpresso.txt",
        "2_DerivedData/{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_mrpresso_global.txt",
        "2_DerivedData/{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_mrpresso_MRdat.csv"
    params:
        out = "2_DerivedData/{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_mrpresso"
    shell:
        'Rscript {input.script} {input.mrdat} {params.out}'

rule html_Report:
    input:
        script = '3_Scripts/mr_report.Rmd',
        traits = traits,
        ExposureSnps = "2_DerivedData/{ExposureCode}/{ExposureCode}_{Pthreshold}_SNPs.txt",
        OutcomeSnps = "2_DerivedData/{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_SNPs.txt",
        ProxySnps = "2_DerivedData/{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_proxys.csv",
        HarmonizedDat = "2_DerivedData/{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_mrpresso_MRdat.csv",
        mrpresso_global = "2_DerivedData/{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_mrpresso_global.txt",
    output:
        "4_Output/{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_MR_Analaysis.html"
    params:
        rwd = RWD,
        output_dir = "4_Output/{ExposureCode}/{OutcomeCode}/",
        output_name = "4_Output/{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}",
        ExposureCode = '{ExposureCode}',
        OutcomeCode = '{OutcomeCode}',
        Pthreshold = "{Pthreshold}",
    shell:
        "R -e 'rmarkdown::render("
        """"{input.script}", output_file = "{output}", output_dir = "{params.output_dir}", \
params = list(rwd = "{params.rwd}", \
traits = "{input.traits}", \
exposure.snps = "{input.ExposureSnps}", \
outcome.snps = "{input.OutcomeSnps}", \
proxy.snps = "{input.ProxySnps}", \
harmonized.dat = "{input.HarmonizedDat}", \
mrpresso_global = "{input.mrpresso_global}", \
outcome.code = "{params.OutcomeCode}", \
exposure.code = "{params.ExposureCode}", \
p.threshold = "{params.Pthreshold}", \
out = "{params.output_name}"))' --slave
        """
