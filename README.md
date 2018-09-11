# Mendelian Randomziation in Alzheimer's Disease
Estimating causal Association of environmental and lifestyle risk factors on risk of Alzheimer's disease and Alzheimer's endophenotypes.

---

**mr.smk** is a snakemake/R pipeline for estimating the causal association of a given exposure with an outcome using the [TwoSampleMR](https://mrcieu.github.io/TwoSampleMR) R package. The steps in the pipeline include:

1. Clump GWAS summary statistics

<img align="center" src=dag_mr.svg alt="DAG">
