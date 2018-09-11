# Mendelian Randomziation in Alzheimer's Disease
Estimating causal Association of environmental and lifestyle risk factors on risk of Alzheimer's disease and Alzheimer's endophenotypes.

---

**mr.smk** is a snakemake/R pipeline for estimating the causal association of a given exposure with an outcome using the [TwoSampleMR](https://mrcieu.github.io/TwoSampleMR) R package. The steps in the pipeline include:

1. Clump GWAS summary statistics using clumping window of 250kb, r2 of 0.1 and significance level of 1 was used for the index and secondary SNPs.
2. Obstain genetic variants (Instruments) below a given P<sub>T</sub> from the exposure GWAS.
3. Extract SNP effects from the outcome GWAS, and if exposure instrument is not avaliable in the outcome GWAS then look for LD proxies in the 1000 genomes EUR samples.
4. Harmonize exposure and outcome effects using ```TwoSampleMR::harmonise_data```
5. Perform a Global Test of Pelietropy and idenfity outliers using ```MR-PRESSO```
6. Run MR analysis, senstivity analysis and write a Rmarkdown html report.

<img align="center" src=dag_mr.svg alt="DAG">


## Getting Started
### Installation
Be sure to download and install the latest versions of the following software packages:
1. [Python 3](https://www.python.org/downloads/)
2. [Snakemake](https://snakemake.readthedocs.io/en/stable/getting_started/installation.html)
3. [R](https://cran.r-project.org/)
4. [Rstudio](https://www.rstudio.com/products/rstudio/download/)
5. [PLINK](https://www.cog-genomics.org/plink2)

Plink should be located within the the /usr/local/bin/ directory. The following code can be used to move the executibles: ```cp </path/to/executible> /usr/local/bin/```

The following R packages are also required:
1. [tidyverse](https://www.tidyverse.org/packages/)
2. [rmarkdown](https://cran.r-project.org/web/packages/rmarkdown/index.html)
3. [Hmisc](https://cran.r-project.org/web/packages/Hmisc/index.html)
4. [TwoSampleMR](https://github.com/MRCIEU/TwoSampleMR)
5. [MR-PRESSO](https://github.com/rondolab/MR-PRESSO)
6. [haploR](https://cran.r-project.org/web/packages/haploR/index.html)

```r
## Install tidyverse, rmarkdown, and devtools
install.packages(c("tidyverse", "Hmisc", "rmarkdown", "devtools", "haploR"))

## Install TwoSampleMR and ggforce
devtools::install_github(c("MRCIEU/TwoSampleMR", '"rondolab/MR-PRESSO"'))
```

Once all the prerequiste software is isntalled, MitoImpute can be installed on a git-enabled machine by typeing:

```bash
git clone https://github.com/marcoralab/MendelianRandomization.git
```

### Formatting GWAS Summary Statistics
To run this pipeline GWAS summary statistics need to formatted in the following way:

```bash
SNP: rs ID
CHR: Chromosome number
POS: base pair possition
Effect_allele: GWAS effect allele
Non_Effect_allele: GWAS Non effect allele
EAF: Effect allele frequency
Beta: beta estimate
SE: Standard Error
P: P value
r2: Variance Explained
N: Sample size
```

An example of correctly formated formated data.
```r
# A tibble: 7,055,881 x 11
   SNP           CHR    POS Effect_allele Non_Effect_allele     EAF    Beta     SE     P         r2     N
   <chr>       <int>  <int> <chr>         <chr>               <dbl>   <dbl>  <dbl> <dbl>      <dbl> <int>
 1 rs28544273      1 751343 A             T                 NA      -0.0146 0.0338 0.665 NA         54162
 2 rs143225517     1 751756 C             T                  0.847  -0.0146 0.0338 0.665  0.0000552 54162
 3 rs3094315       1 752566 G             A                  0.826  -0.0122 0.0294 0.677  0.0000427 54162
 4 rs61770173      1 753405 C             A                  0.824  -0.0126 0.0339 0.710  0.0000461 54162
 5 rs2977608       1 768253 A             C                  0.267  -0.0394 0.0261 0.131  0.000607  54162
 6 rs77786510      1 768448 A             G                 NA      -0.0385 0.0303 0.203 NA         54162
 7 rs7518545       1 769963 A             G                  0.0927 -0.0471 0.036  0.190  0.000373  54162
 8 rs112856858     1 845274 T             G                  0.221   0.0234 0.0329 0.477  0.000188  54162
 9 rs117086422     1 845635 T             C                  0.187   0.0317 0.0303 0.294  0.000306  54162
10 rs57760052      1 845938 A             G                  0.232   0.0307 0.0295 0.297  0.000336  54162
# ... with 7,055,871 more rows
```

Where summary statistics are missing allele frequencies, this can be filled in using 1000 Genomes.

See the ```3_Scripts/MrMungeSummaryStats.Rmd``` file for R code to munge summary statistics into the correct format.

#### Further Reading on formating summary statistics
1. [Tips for Formatting A Lot of GWAS Summary Association Statistics Data](http://huwenboshi.github.io/data%20management/2017/11/23/tips-for-formatting-gwas-summary-stats.html)
2. [Across-cohort QC analyses of GWAS summary statistics from complex traits](https://doi.org/10.1038/ejhg.2016.106)
