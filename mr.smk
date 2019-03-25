'''Snakefile for Mendelian Randomization'''

import os
from itertools import product
RWD = os.getcwd()

shell.prefix('module load plink/1.90 R/3.5.1; ')


REF = config['REF']
r2 = config['clumpr2']
kb = config['clumpkb']
ExposureCode = config['ExposureCode']
OutcomeCode = config['OutcomeCode']
Pthreshold = config['Pthreshold']
DataIn = config['DataIn']
traits = config['traits']
DataOut = config['DataOut']
DataOutput = config['DataOutput']

localrules: all

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
        expand(DataOutput + 'plots/Manhattan/{ExposureCode}_ManhattanPlot.png', ExposureCode=ExposureCode),
        expand(DataOutput + "{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_MR_Analaysis.html", filtered_product, ExposureCode=ExposureCode, OutcomeCode=OutcomeCode, Pthreshold=Pthreshold),

rule clump:
    input: DataIn + '{ExposureCode}_GWAS.Processed.gz'
    output: DataOut + '{ExposureCode}/{ExposureCode}.clumped'
    params:
        ref = REF,
        out =  DataOut + '{ExposureCode}/{ExposureCode}',
        r2 = r2,
        kb = kb
    shell:
        "plink --bfile {params.ref} --keep-allele-order --clump {input}  --clump-r2 {params.r2} --clump-kb {params.kb} --clump-p1 1 --clump-p2 1 --out {params.out}"

rule gzip:
    input: DataOut + '{ExposureCode}/{ExposureCode}.clumped'
    output: DataOut + '{ExposureCode}/{ExposureCode}.clumped.gz'
    shell: "gzip {input}"

rule ExposureSnps:
    input:
        script = '3_Scripts/ExposureData.R',
        summary = DataIn + '{ExposureCode}_GWAS.Processed.gz',
        ExposureClump = DataOut + '{ExposureCode}/{ExposureCode}.clumped.gz'
    output:
        out = DataOut + "{ExposureCode}/{ExposureCode}_{Pthreshold}_SNPs.txt"
    params:
        Pthreshold = '{Pthreshold}'
    shell:
        'Rscript {input.script} {input.summary} {params.Pthreshold} {input.ExposureClump} {output.out}'

rule manhattan_plot:
    input:
        script = '3_Scripts/manhattan_plot.R',
        ingwas = DataIn + '{ExposureCode}_GWAS.Processed.gz',
        inclump = DataOut + '{ExposureCode}/{ExposureCode}.clumped.gz'
    params:
        PlotTitle = "{ExposureCode}"
    output:
        out = DataOutput + 'plots/Manhattan/{ExposureCode}_ManhattanPlot.png'
    shell:
        "Rscript {input.script} {input.ingwas} {input.inclump} {output.out} \"{params.PlotTitle}\""

rule OutcomeSnps:
    input:
        script = '3_Scripts/OutcomeData.R',
        ExposureSummary = DataOut + "{ExposureCode}/{ExposureCode}_{Pthreshold}_SNPs.txt",
        OutcomeSummary = DataIn + "{OutcomeCode}_GWAS.Processed.gz"
    output:
        DataOut + "{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_SNPs.txt",
        DataOut + "{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_MissingSNPs.txt",
    params:
        Outcome = DataOut + "{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}",
    shell:
        'Rscript {input.script} {input.ExposureSummary} {input.OutcomeSummary} {params.Outcome}'

rule FindProxySnps:
    input:
        MissingSNPs = DataOut + "{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_MissingSNPs.txt"
    output:
        ProxyList = DataOut + "{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_Proxys.ld",
    params:
        Outcome = DataOut + "{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_Proxys",
        ref = REF
    shell:
        """
        if [ $(wc -l < {input.MissingSNPs}) -eq 0 ]; then
            touch {output.ProxyList}
          else
           plink --bfile {params.ref} \
           --keep-allele-order \
           --r2 dprime in-phase with-freqs \
           --ld-snp-list {input.MissingSNPs} \
           --ld-window-r2 0.8 --ld-window-kb 500 --ld-window 1000 --out {params.Outcome}
          fi
"""

rule ExtractProxySnps:
    input:
        script = '3_Scripts/ExtractProxySNPs.R',
        OutcomeSummary = DataIn + "{OutcomeCode}_GWAS.Processed.gz",
        OutcomeSNPs = DataOut + "{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_SNPs.txt",
        OutcomeProxys = DataOut + "{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_Proxys.ld"
    output:
        DataOut + "{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_ProxySNPs.txt",
        DataOut + "{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_MatchedProxys.csv",
    params:
        Outcome = DataOut + "{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}",
    shell:
        'Rscript {input.script} {input.OutcomeSummary} {input.OutcomeProxys} {input.OutcomeSNPs} {params.Outcome}'

rule Harmonize:
    input:
        script = '3_Scripts/DataHarmonization.R',
        ExposureSummary = DataOut + "{ExposureCode}/{ExposureCode}_{Pthreshold}_SNPs.txt",
        OutcomeSummary = DataOut + "{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_ProxySNPs.txt",
        ProxySNPs = DataOut + "{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_MatchedProxys.csv"
    output:
        Harmonized = DataOut + "{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_MRdat.csv"
    params:
        ExposureCode = '{ExposureCode}',
        OutcomeCode = '{OutcomeCode}'
    shell:
        'Rscript {input.script} {input.ExposureSummary} {input.OutcomeSummary} {params.ExposureCode} {params.OutcomeCode} {input.ProxySNPs} {output.Harmonized}'

rule MrPresso:
    input:
        script = '3_Scripts/MRPRESSO.R',
        mrdat = DataOut + "{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_MRdat.csv",
    output:
        DataOut + "{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_mrpresso.txt",
        DataOut + "{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_mrpresso_global.txt",
        DataOut + "{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_mrpresso_MRdat.csv"
    params:
        out = DataOut + "{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_mrpresso"
    shell:
        'Rscript {input.script} {input.mrdat} {params.out}'

rule MRPRESSO_wo_outliers:
    input:
        script = '3_Scripts/MRPRESSO_wo_outliers.R',
        mrdat = DataOut + "{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_mrpresso_MRdat.csv",
    output:
        DataOut + "{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_mrpresso_global_wo_outliers.txt",
    params:
        out = DataOut + "{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_mrpresso"
    shell:
        'Rscript {input.script} {input.mrdat} {params.out}'

rule html_Report:
    input:
        script = '3_Scripts/mr_report.Rmd',
        traits = traits,
        ExposureSnps = DataOut + "{ExposureCode}/{ExposureCode}_{Pthreshold}_SNPs.txt",
        OutcomeSnps = DataOut + "{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_SNPs.txt",
        ProxySnps = DataOut + "{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_MatchedProxys.csv",
        HarmonizedDat = DataOut + "{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_mrpresso_MRdat.csv",
        mrpresso_global = DataOut + "{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_mrpresso_global.txt",
        mrpresso_global_wo_outliers = DataOut + "{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_mrpresso_global_wo_outliers.txt"
    output:
        DataOutput + "{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_MR_Analaysis.html"
    params:
        rwd = RWD,
        output_dir = DataOutput + "{ExposureCode}/{OutcomeCode}/",
        output_name = DataOutput + "{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}",
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
