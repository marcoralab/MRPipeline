#snakemake -s mrpresso.smk --configfile test.yaml

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
        expand("2_DerivedData/{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_mrpresso_global_wo_outliers.txt", filtered_product, ExposureCode=ExposureCode, OutcomeCode=OutcomeCode, Pthreshold=Pthreshold),

rule MrPresso:
    input:
        script = '3_Scripts/MRPRESSO_wo_outliers.R',
        mrdat = "2_DerivedData/{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_mrpresso_MRdat.csv",
    output:
        "2_DerivedData/{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_mrpresso_global_wo_outliers.txt",
    params:
        out = "2_DerivedData/{ExposureCode}/{OutcomeCode}/{ExposureCode}_{Pthreshold}_{OutcomeCode}_mrpresso"
    shell:
        'Rscript {input.script} {input.mrdat} {params.out}'
