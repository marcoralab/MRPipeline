'''Snakefile for Mendelian Randomization'''

import os
from itertools import product
RWD = os.getcwd()

shell.prefix('module load plink/1.90 R/3.4.3 curl/7.61.0; ')


REF = config['REF']
ExposureCode = config['ExposureCode']
OutcomeCode = config['OutcomeCode']
Pthreshold = config['Pthreshold']
DataIn = config['DataIn']
traits = config['traits']
DataOut = config['DataOut']

localrules: all, FindProxySnps

# Filter forbidden wild card combinations
## https://stackoverflow.com/questions/41185567/how-to-use-expand-in-snakemake-when-some-particular-combinations-of-wildcards-ar
def filter_combinator(combinator, blacklist):
    def filtered_combinator(*args, **kwargs):
        for wc_comb in combinator(*args, **kwargs):
            # Use frozenset instead of tuple
            # in order to accomodate
            # unpredictable wildcard order
            if frozenset(wc_comb) not in blacklist:
                yield wc_comb
    return filtered_combinator

forbidden = {frozenset(wc_comb.items()) for wc_comb in config["missing"]}
filtered_product = filter_combinator(product, forbidden)

rule all:
    input:
        expand('4_Output/plots/Manhattan/{ExposureCode}_ManhattanPlot.png', ExposureCode=ExposureCode),
        expand("4_Output/{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_MR_Analaysis.html", filtered_product, ExposureCode=ExposureCode, OutcomeCode=OutcomeCode, Pthreshold=Pthreshold),

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

rule manhattan_plot:
    input:
        script = '3_Scripts/manhattan_plot.R',
        ingwas = DataIn + '{ExposureCode}_GWAS.Processed.gz',
        inclump = DataIn + '{ExposureCode}.clumped.gz'
    params:
        PlotTitle = "{ExposureCode}"
    output:
        out = '4_Output/plots/Manhattan/{ExposureCode}_ManhattanPlot.png'
    shell:
        "Rscript {input.script} {input.ingwas} {input.inclump} {output.out} \"{params.PlotTitle}\""

rule OutcomeSnps:
    input:
        script = '3_Scripts/OutcomeData.R',
        ExposureSummary = "2_DerivedData/{ExposureCode}/{ExposureCode}_{Pthreshold}_SNPs.txt",
        OutcomeSummary = DataIn + "{OutcomeCode}_GWAS.Processed.gz"
    output:
        "2_DerivedData/{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_SNPs.txt",
    params:
        Outcome = "2_DerivedData/{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}",
    shell:
        'Rscript {input.script} {input.ExposureSummary} {input.OutcomeSummary} {params.Outcome}'

rule FindProxySnps:
    input:
        script = '3_Scripts/FindProxySNPs.R',
        OutcomeSummary = "2_DerivedData/{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_SNPs.txt"
    output:
        "2_DerivedData/{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_Proxys.txt",
    params:
        Outcome = "2_DerivedData/{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}",
    shell:
        'Rscript {input.script} {input.OutcomeSummary} {params.Outcome}'

rule ExtractProxySnps:
    input:
        script = '3_Scripts/ExtractProxySNPs.R',
        OutcomeSummary = DataIn + "{OutcomeCode}_GWAS.Processed.gz",
        OutcomeSNPs = "2_DerivedData/{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_SNPs.txt",
        OutcomeProxys = "2_DerivedData/{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_Proxys.txt"
    output:
        "2_DerivedData/{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_ProxySNPs.txt",
        "2_DerivedData/{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_MatchedProxys.csv",
    params:
        Outcome = "2_DerivedData/{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}",
    shell:
        'Rscript {input.script} {input.OutcomeSummary} {input.OutcomeProxys} {input.OutcomeSNPs} {params.Outcome}'

rule Harmonize:
    input:
        script = '3_Scripts/DataHarmonization.R',
        ExposureSummary = "2_DerivedData/{ExposureCode}/{ExposureCode}_{Pthreshold}_SNPs.txt",
        OutcomeSummary = "2_DerivedData/{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_ProxySNPs.txt"
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

rule MRPRESSO_wo_outliers:
    input:
        script = '3_Scripts/MRPRESSO_wo_outliers.R',
        mrdat = "2_DerivedData/{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_mrpresso_MRdat.csv",
    output:
        "2_DerivedData/{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_mrpresso_global_wo_outliers.txt",
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
        ProxySnps = "2_DerivedData/{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_MatchedProxys.csv",
        HarmonizedDat = "2_DerivedData/{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_mrpresso_MRdat.csv",
        mrpresso_global = "2_DerivedData/{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_mrpresso_global.txt",
        mrpresso_global_wo_outliers = "2_DerivedData/{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_mrpresso_global_wo_outliers.txt"
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
        """"{input.script}", clean = TRUE, intermediates_dir = "{params.output_dir}", output_file = "{output}", output_dir = "{params.output_dir}", \
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
