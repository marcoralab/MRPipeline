# conda activate ldsc
import os
from itertools import product
RWD = os.getcwd()

sstat = ['alcc', 'alcd', 'audit', 'bmi', 'cpd', 'dep', 'diab', 'educ', 'educall', 'fish',
'hdl', 'insom', 'ldl', 'mdd', 'mvpa', 'sleep', 'smkukbb', 'evrsmk', 'sociso',
'tc', 'trig', 'dbp', 'sbp', 'pp', 'hear', 'as', 'ais', 'ces', 'las', 'svs',
'load', 'aaos', 'ab42', 'ptau', 'tau', 'hipv', 'hipv2015', 'npany', 'nft4',
'hips', 'vbiany']
sstat2 = ['alcc', 'alcd', 'audit', 'bmi', 'cpd', 'dep', 'diab', 'educ', 'educall','fish',
'hdl', 'insom', 'ldl', 'mdd', 'mvpa', 'sleep', 'smkukbb', 'evrsmk', 'sociso',
'tc', 'trig', 'dbp', 'sbp', 'pp', 'hear', 'as', 'ais', 'ces', 'las', 'svs',
'load', 'aaos', 'ab42', 'ptau', 'tau', 'hipv', 'hipv2015', 'npany', 'nft4',
'hips', 'vbiany']
#sstat = ['bmi']
#sstat2 = ['dbp']
DataIn = '1_RawData/GWAS/'
DataOut = '1_RawData/LDSC/'
ldscLoc = '/Users/sheaandrews/Programs/ldsc/'

rule all:
    input:
        expand('1_RawData/LDSC/{sstat}_GWAS.sumstats.gz', sstat=sstat),
        expand('2_DerivedData/LDSC/{sstat}_{sstat2}.log', sstat=sstat, sstat2=sstat2),
        expand('2_DerivedData/LDSC/{sstat}_{sstat2}.tsv', sstat=sstat, sstat2=sstat2)


rule munge:
    input: DataIn + '{sstat}_GWAS.Processed.gz'
    output: '1_RawData/LDSC/' + '{sstat}_GWAS.sumstats.gz'
    params:
        out = '1_RawData/LDSC/' + '{sstat}_GWAS',
        script = ldscLoc + 'munge_sumstats.py'
    conda:
        ldscLoc + 'environment.yml'
    shell:
        "{params.script} \
  --sumstats {input} \
  --out {params.out} \
  --snp SNP \
  --N-col N \
  --a1 Effect_allele \
  --a2 Non_Effect_allele \
  --p P \
  --frq EAF \
  --ignore Z,Zscore,MarkerName \
  --merge-alleles /Users/sheaandrews/Programs/ldsc/w_hm3.snplist"

rule ldsc:
    input:
        sstat1 = '1_RawData/LDSC/' + '{sstat}_GWAS.sumstats.gz',
        sstat2 = '1_RawData/LDSC/' + '{sstat2}_GWAS.sumstats.gz'
    output: '2_DerivedData/LDSC/' + '{sstat}_{sstat2}.log'
    params:
        out = '2_DerivedData/LDSC/' + '{sstat}_{sstat2}',
        script = ldscLoc + 'ldsc.py'
    conda:
        ldscLoc + 'environment.yml'
    shell:
        "{params.script} \
        --rg  {input.sstat1},{input.sstat2}\
        --ref-ld-chr /Users/sheaandrews/Programs/ldsc/eur_w_ld_chr/ \
        --w-ld-chr /Users/sheaandrews/Programs/ldsc/eur_w_ld_chr/ \
        --out {params.out}"


rule extract_rg:
    input:  '2_DerivedData/LDSC/' + '{sstat}_{sstat2}.log'
    output: '2_DerivedData/LDSC/' + '{sstat}_{sstat2}.tsv'
    shell:
        "Rscript 3_Scripts/extract_rg.R {input} {output}"
