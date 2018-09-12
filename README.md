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

## Output
The ```MR Summary``` R script can be used to creat Dot-and-Whisker plots and export a summary table of aggregate results across mutltiple causal models.
```r
# A tibble: 70 x 16
   exposure outcome pt    nsnp  IVW_b.se     IVW_pval `MR Egger_b.se` `MR Egger_pval` `Weighted median_b.se` `Weighted median_pval` `Weighted mode_b.se` `Weighted mode_pval` violated.HeterogeneityIVW violated.HeterogeneityEgger violated.Egger violated.mrpresso
   <chr>    <chr>   <chr> <chr> <chr>        <chr>    <chr>           <chr>           <chr>                  <chr>                  <chr>                <chr>                <lgl>                     <lgl>                       <lgl>          <lgl>
 1 alcc     aaos    5e-6  56    0.1 (0.16)   0.5378   -0.49 (0.82)    0.5491          -0.01 (0.26)           0.9761                 -0.07 (0.27)         0.7974               TRUE                      TRUE                        FALSE          TRUE
 2 alcc     aaos    5e-8  15    -0.14 (0.26) 0.5833   0.62 (1.43)     0.6703          0.02 (0.35)            0.9619                 0.05 (0.27)          0.8612               FALSE                     FALSE                       FALSE          FALSE
 3 cpd      aaos    5e-6  53    0.02 (0.09)  0.8164   0.16 (0.19)     0.3997          -0.04 (0.14)           0.7765                 -0.06 (0.13)         0.6445               FALSE                     FALSE                       FALSE          FALSE
 4 cpd      aaos    5e-8  21    -0.06 (0.12) 0.631    -0.14 (0.3)     0.6402          -0.04 (0.15)           0.7822                 -0.05 (0.14)         0.7484               FALSE                     FALSE                       FALSE          FALSE
 5 diab     aaos    5e-6  433   0.06 (0.01)  0        0.08 (0.04)     0.0531          0.05 (0.03)            0.0801                 0.07 (0.04)          0.0605               TRUE                      TRUE                        FALSE          TRUE
 6 diab     aaos    5e-8  189   0.07 (0.02)  1e-04    0.05 (0.05)     0.2863          0.05 (0.03)            0.1111                 0.06 (0.04)          0.1002               TRUE                      TRUE                        FALSE          TRUE
 7 hdl      aaos    5e-6  366   -0.05 (0.02) 0.0384   -0.16 (0.1)     0.0959          0.03 (0.04)            0.4947                 0.01 (0.05)          0.758                TRUE                      TRUE                        FALSE          TRUE
 8 hdl      aaos    5e-8  245   -0.07 (0.03) 0.0068   -0.18 (0.12)    0.1459          0.03 (0.04)            0.4974                 0.01 (0.05)          0.8358               TRUE                      TRUE                        FALSE          TRUE
 9 ldl      aaos    5e-6  319   0.27 (0.02)  0        0.5 (0.09)      0               0 (0.04)               0.9075                 -0.02 (0.04)         0.6019               TRUE                      TRUE                        TRUE           TRUE
10 ldl      aaos    5e-8  210   0.28 (0.02)  0        0.58 (0.11)     0               0.01 (0.04)            0.8493                 -0.02 (0.04)         0.6374               TRUE                      TRUE                        TRUE           TRUE
# ... with 60 more rows
```
