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
\
\

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
