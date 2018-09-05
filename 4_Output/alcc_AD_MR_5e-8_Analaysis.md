---
output:
  html_document:
    keep_md: true
    df_print: paged
    toc: true
    number_sections: false
    toc_depth: 4
    toc_float:
      collapsed: false
      smooth_scroll: false
params:
  rwd: rwd
  trait.blurb: trait.blurb
  trait.name: trait.name
  trait.code: trait.code
  load.summary: load.summary
  aaos.summary: aaos.summary
  ab42.summary: ab42.summary
  ptau.summary: ptau.summary
  tau.summary: tau.summary
  hipv.summary: hipv.summary
  trait.summary: trait.summary
  trait.clump: trait.clump
  out.path: out.path
  trait_load.path: trait_load.path
  trait_aaos.path: trait_aaos.path
  trait_ab42.path: trait_ab42.path
  trait_ptau.path: trait_ptau.path
  trait_tau.path: trait_tau.path
  trait_hipv.path: trait_hipv.path
  p.threshold: p.threshold
---

#Mendelian Randomization Analysis: Alcohol Consumption and Alzheimer\'s Disease
By Dr. Shea Andrews, generated on 2018-09-05

---


```
## [1] FALSE
```



## Data sources
***Alcohol Consumption*** (Clarke et al 2017): SNPs associated with alcohol consumption were selected from a GWAS of alcohol consumption (drinks per week adjusted for sex, age and weight) performed in 112,117 individuals from the UK Biobank [29]. Participants were of European ancestry, mean age was 59.6 and 52.7% of the cohort was female.

***Late Onset Alzheimer's disease*** [Lambert et al 2013](https://doi.org/10.1038/ng.2802): The International Genomics of Alzheimer’s Project (IGAP) is a meta-analysis of 4 previously published GWAS datasets: the European Alzheimer’s Disease Imitative (EADI), the Alzheimer Disease Genetics Consortium (ADGC), Cohorts for Heart and Aging Research in Genomic Epidemiology (CHARGE), and Genetic and Environmental Risk in AD (GERAD) and includes a sample of 17,008 LOAD cases and 37,154 cognitively normal elder controls. Participants in IGAP were of European ancestry, the average age was 71 and 58.4% of participants were women.

***Alzheimer's Age of Onset Surivial*** [Huang et al 2017](https://doi.org/10.1038/nn.4587): A GWAS of age of onset in LOAD was conducted in 14,406 AD case samples and 25,849 control samples from the IGAP using Cox proportional hazard regressions. Participants were of European ancestry, in cases the the average AAO was 74.8 and 61.7% were women, in controls the average AAE was 79.0 and 59.6% were women.

***CSF Ab42, tau & ptau*** [Deming et al 2017](https://doi.org/10.1007/s00401-017-1685-y): A GWAS of CSF AB42, ptau and tau levels (pg/mL) was conducted in 3,146 participants. Participants were of Eurpean ancestry.

***Hippocampal Volume*** [Hibar et al 2017](https://doi.org/10.1038/ncomms13624): A GWAS of hippocampal volume perfomed in 26,814 (ENIGMA and CHARGE consortiums) individules of European Ancestry discovered 9 independent loci.






## Instrumental Variables
**LD Clumping:** For standard two sample MR it is important to ensure that the instruments for the exposure are independent. LD clumping can be performed using the data_clump function from the TwoSampleMR package, which uses EUR samples from the 1000 genomes project to estimate LD between SNPs and amonst SNPs that have and LD above a given threshold, only the SNP with the lowest p-value will be retained.
<br>

**Proxy SNPs:** SNPs associated with Alcohol Consumption were extracted from the GWAS of LOAD, AAOS, AB42, ptau and tau. Where SNPs were not available in the outcome GWAS, the EUR thousand genomes was queried to identified potential proxy SNPs that are in linkage disequilibrium (r2 > 0.8) of the missing SNP.

### Alcohol Consumption


Alcohol Consumption: 414 SNPs (Table 1) were assoicated with were associated with Alcohol Consumption at p < 5e-8. After LD clumping, 403 of 414 SNPs were removed.
<br>

**Table 1:** Independent SNPS associated with Alcohol Consumption
<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["SNP"],"name":[1],"type":["chr"],"align":["left"]},{"label":["CHR"],"name":[2],"type":["int"],"align":["right"]},{"label":["POS"],"name":[3],"type":["int"],"align":["right"]},{"label":["Effect_allele"],"name":[4],"type":["chr"],"align":["left"]},{"label":["Non_Effect_allele"],"name":[5],"type":["chr"],"align":["left"]},{"label":["EAF"],"name":[6],"type":["dbl"],"align":["right"]},{"label":["Beta"],"name":[7],"type":["dbl"],"align":["right"]},{"label":["SE"],"name":[8],"type":["dbl"],"align":["right"]},{"label":["P"],"name":[9],"type":["dbl"],"align":["right"]},{"label":["r2"],"name":[10],"type":["dbl"],"align":["right"]},{"label":["N"],"name":[11],"type":["int"],"align":["right"]}],"data":[{"1":"rs1260326","2":"2","3":"27730940","4":"T","5":"C","6":"0.393400","7":"-0.02839","8":"0.002973","9":"1.341e-21","10":"3.846782e-04","11":"112176"},{"1":"rs13006480","2":"2","3":"27987221","4":"G","5":"C","6":"0.164000","7":"-0.01721","8":"0.003017","9":"1.170e-08","10":"8.121605e-05","11":"108886"},{"1":"rs13078384","2":"3","3":"85264266","4":"A","5":"G","6":"0.311600","7":"0.01853","8":"0.002982","9":"5.171e-10","10":"1.473056e-04","11":"111539"},{"1":"rs9841829","2":"3","3":"85569361","4":"G","5":"T","6":"0.226900","7":"0.01869","8":"0.002976","9":"3.359e-10","10":"1.225515e-04","11":"111977"},{"1":"rs11940694","2":"4","3":"39414993","4":"A","5":"G","6":"0.393700","7":"-0.02694","8":"0.003042","9":"8.430e-19","10":"3.464800e-04","11":"107311"},{"1":"rs193099203","2":"4","3":"99630017","4":"T","5":"C","6":"0.007120","7":"-0.03105","8":"0.002996","9":"3.787e-25","10":"1.363107e-05","11":"110458"},{"1":"rs62325470","2":"4","3":"99644166","4":"T","5":"C","6":"0.007253","7":"-0.01783","8":"0.002980","9":"2.170e-09","10":"4.578139e-06","11":"111745"},{"1":"rs146788033","2":"4","3":"99941138","4":"G","5":"A","6":"0.013410","7":"-0.02845","8":"0.002993","9":"2.053e-21","10":"2.141707e-05","11":"110683"},{"1":"rs145452708","2":"4","3":"100248642","4":"C","5":"G","6":"0.009985","7":"-0.03427","8":"0.002976","9":"1.148e-30","10":"2.321924e-05","11":"112071"},{"1":"rs2298755","2":"4","3":"100261038","4":"G","5":"C","6":"0.413000","7":"0.01793","8":"0.003004","9":"2.399e-09","10":"1.558758e-04","11":"110134"},{"1":"rs74764239","2":"4","3":"100618891","4":"T","5":"A","6":"0.018880","7":"-0.01697","8":"0.002976","9":"1.192e-08","10":"1.066885e-05","11":"112011"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>
<br>

### LOAD


Of the the 11 SNPs associated with Alcohol Consumption, 8 were available in the LOAD GWAS (Table 2).


**Table 2:** SNPS associated with Alcohol Consumption avalible in LOAD GWAS
<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["SNP"],"name":[1],"type":["chr"],"align":["left"]},{"label":["CHR"],"name":[2],"type":["int"],"align":["right"]},{"label":["POS"],"name":[3],"type":["int"],"align":["right"]},{"label":["Effect_allele"],"name":[4],"type":["chr"],"align":["left"]},{"label":["Non_Effect_allele"],"name":[5],"type":["chr"],"align":["left"]},{"label":["EAF"],"name":[6],"type":["dbl"],"align":["right"]},{"label":["Beta"],"name":[7],"type":["dbl"],"align":["right"]},{"label":["SE"],"name":[8],"type":["dbl"],"align":["right"]},{"label":["P"],"name":[9],"type":["dbl"],"align":["right"]},{"label":["r2"],"name":[10],"type":["dbl"],"align":["right"]},{"label":["N"],"name":[11],"type":["int"],"align":["right"]}],"data":[{"1":"rs1260326","2":"2","3":"27730940","4":"T","5":"C","6":"0.4232","7":"-0.0008","8":"0.0161","9":"0.96080","10":"3.124503e-07","11":"54162"},{"1":"rs13006480","2":"2","3":"27987221","4":"G","5":"C","6":"0.8170","7":"-0.0014","8":"0.0249","9":"0.95640","10":"5.860831e-07","11":"54162"},{"1":"rs13078384","2":"3","3":"85264266","4":"A","5":"G","6":"0.3238","7":"-0.0098","8":"0.0182","9":"0.58970","10":"4.205660e-05","11":"54162"},{"1":"rs9841829","2":"3","3":"85569361","4":"G","5":"T","6":"0.7642","7":"-0.0191","8":"0.0185","9":"0.30320","10":"1.314763e-04","11":"54162"},{"1":"rs11940694","2":"4","3":"39414993","4":"A","5":"G","6":"0.4189","7":"-0.0363","8":"0.0167","9":"0.02941","10":"6.415116e-04","11":"54162"},{"1":"rs62325470","2":"4","3":"99644166","4":"T","5":"C","6":"0.0149","7":"0.1208","8":"0.0723","9":"0.09467","10":"4.283812e-04","11":"54162"},{"1":"rs145452708","2":"4","3":"100248642","4":"C","5":"G","6":"0.0228","7":"0.0107","8":"0.0580","9":"0.85340","10":"5.101711e-06","11":"54162"},{"1":"rs2298755","2":"4","3":"100263834","4":"G","5":"C","6":"0.3863","7":"0.0089","8":"0.0159","9":"0.57860","10":"3.755700e-05","11":"54162"},{"1":"rs74764239","2":"4","3":"100618891","4":"T","5":"A","6":"0.9676","7":"-0.0003","8":"0.0428","9":"0.99530","10":"5.643043e-09","11":"54162"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>
<br>

### AAOS



Of the the 11 SNPs associated with Alcohol Consumption, 11 were available in the AAOS GWAS (Table 3).

**Table 3:** SNPS associated with <trait> available in AAOS GWAS
<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["SNP"],"name":[1],"type":["chr"],"align":["left"]},{"label":["CHR"],"name":[2],"type":["int"],"align":["right"]},{"label":["POS"],"name":[3],"type":["int"],"align":["right"]},{"label":["Effect_allele"],"name":[4],"type":["chr"],"align":["left"]},{"label":["Non_Effect_allele"],"name":[5],"type":["chr"],"align":["left"]},{"label":["EAF"],"name":[6],"type":["dbl"],"align":["right"]},{"label":["Beta"],"name":[7],"type":["dbl"],"align":["right"]},{"label":["SE"],"name":[8],"type":["dbl"],"align":["right"]},{"label":["P"],"name":[9],"type":["dbl"],"align":["right"]},{"label":["r2"],"name":[10],"type":["dbl"],"align":["right"]},{"label":["N"],"name":[11],"type":["int"],"align":["right"]}],"data":[{"1":"rs1260326","2":"2","3":"27730940","4":"T","5":"C","6":"0.4232","7":"-0.0007","8":"0.0123","9":"0.9537","10":"2.392197e-07","11":"40255"},{"1":"rs13006480","2":"2","3":"27987221","4":"C","5":"G","6":"0.8170","7":"-0.0144","8":"0.0250","9":"0.5638","10":"6.200520e-05","11":"40255"},{"1":"rs13078384","2":"3","3":"85264266","4":"A","5":"G","6":"0.3238","7":"-0.0137","8":"0.0131","9":"0.2964","10":"8.219079e-05","11":"40255"},{"1":"rs9841829","2":"3","3":"85569361","4":"T","5":"G","6":"0.7642","7":"0.0049","8":"0.0143","9":"0.7331","10":"8.653125e-06","11":"40255"},{"1":"rs11940694","2":"4","3":"39414993","4":"A","5":"G","6":"0.4189","7":"-0.0149","8":"0.0139","9":"0.2837","10":"1.080846e-04","11":"40255"},{"1":"rs193099203","2":"4","3":"99630017","4":"T","5":"C","6":"0.0227","7":"0.1129","8":"0.1139","9":"0.3214","10":"5.655508e-04","11":"40255"},{"1":"rs62325470","2":"4","3":"99644166","4":"T","5":"C","6":"0.0149","7":"0.1635","8":"0.1218","9":"0.1795","10":"7.847514e-04","11":"40255"},{"1":"rs146788033","2":"4","3":"99941138","4":"A","5":"G","6":"0.9682","7":"-0.1120","8":"0.0875","9":"0.2007","10":"7.724284e-04","11":"40255"},{"1":"rs145452708","2":"4","3":"100248642","4":"C","5":"G","6":"0.0228","7":"0.1068","8":"0.0870","9":"0.2198","10":"5.082657e-04","11":"40255"},{"1":"rs2298755","2":"4","3":"100261038","4":"C","5":"G","6":"0.6070","7":"-0.0163","8":"0.0194","9":"0.4004","10":"1.267612e-04","11":"40255"},{"1":"rs74764239","2":"4","3":"100618891","4":"A","5":"T","6":"0.9676","7":"-0.0979","8":"0.0709","9":"0.1671","10":"6.009471e-04","11":"40255"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>
<br>

### AB42



Of the the 11 SNPs associated with Alcohol Consumption, 8 were available in the CSF AB42 GWAS (Table 4).


**Table 4:** SNPS associated with Alcohol Consumption avalible in ab42 GWAS
<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["SNP"],"name":[1],"type":["chr"],"align":["left"]},{"label":["CHR"],"name":[2],"type":["int"],"align":["right"]},{"label":["POS"],"name":[3],"type":["int"],"align":["right"]},{"label":["Effect_allele"],"name":[4],"type":["chr"],"align":["left"]},{"label":["Non_Effect_allele"],"name":[5],"type":["chr"],"align":["left"]},{"label":["EAF"],"name":[6],"type":["dbl"],"align":["right"]},{"label":["Beta"],"name":[7],"type":["dbl"],"align":["right"]},{"label":["SE"],"name":[8],"type":["dbl"],"align":["right"]},{"label":["P"],"name":[9],"type":["dbl"],"align":["right"]},{"label":["r2"],"name":[10],"type":["dbl"],"align":["right"]},{"label":["N"],"name":[11],"type":["int"],"align":["right"]}],"data":[{"1":"rs1260326","2":"2","3":"27730940","4":"T","5":"C","6":"0.4048200","7":"0.002212","8":"0.004110","9":"0.590400","10":"2.357819e-06","11":"3115"},{"1":"rs13006480","2":"2","3":"27987221","4":"G","5":"C","6":"0.1986450","7":"-0.003989","8":"0.005237","9":"0.446400","10":"5.065947e-06","11":"2999"},{"1":"rs13078384","2":"3","3":"85264266","4":"A","5":"G","6":"0.3015860","7":"-0.003516","8":"0.004403","9":"0.424600","10":"5.207771e-06","11":"3070"},{"1":"rs9841829","2":"3","3":"85569361","4":"G","5":"T","6":"0.2228980","7":"0.005628","8":"0.004810","9":"0.242100","10":"1.097292e-05","11":"3108"},{"1":"rs11940694","2":"4","3":"39423789","4":"G","5":"A","6":"0.3763780","7":"0.003275","8":"0.004145","9":"0.429500","10":"5.034986e-06","11":"3093"},{"1":"rs146788033","2":"4","3":"99941138","4":"G","5":"A","6":"0.0224515","7":"0.004287","8":"0.012800","9":"0.737800","10":"8.067159e-07","11":"2618"},{"1":"rs145452708","2":"4","3":"100248642","4":"C","5":"G","6":"0.0178472","7":"0.028050","8":"0.013330","9":"0.035380","10":"2.758321e-05","11":"3109"},{"1":"rs2298755","2":"4","3":"100261038","4":"G","5":"C","6":"0.3977980","7":"-0.005725","8":"0.004142","9":"0.167000","10":"1.570311e-05","11":"3108"},{"1":"rs74764239","2":"4","3":"100618891","4":"T","5":"A","6":"0.0257622","7":"0.031160","8":"0.011420","9":"0.006408","10":"4.873857e-05","11":"3113"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>
<br>

### Ptau



Of the the 11 SNPs associated with Alcohol Consumption, 9 were available in the CSF Ptau GWAS (Table 5).


**Table 5:** SNPS associated with Alcohol Consumption avalible in Ptau GWAS
<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["SNP"],"name":[1],"type":["chr"],"align":["left"]},{"label":["CHR"],"name":[2],"type":["int"],"align":["right"]},{"label":["POS"],"name":[3],"type":["int"],"align":["right"]},{"label":["Effect_allele"],"name":[4],"type":["chr"],"align":["left"]},{"label":["Non_Effect_allele"],"name":[5],"type":["chr"],"align":["left"]},{"label":["EAF"],"name":[6],"type":["dbl"],"align":["right"]},{"label":["Beta"],"name":[7],"type":["dbl"],"align":["right"]},{"label":["SE"],"name":[8],"type":["dbl"],"align":["right"]},{"label":["P"],"name":[9],"type":["dbl"],"align":["right"]},{"label":["r2"],"name":[10],"type":["dbl"],"align":["right"]},{"label":["N"],"name":[11],"type":["int"],"align":["right"]}],"data":[{"1":"rs1260326","2":"2","3":"27730940","4":"T","5":"C","6":"0.4048200","7":"-0.0051210","8":"0.005377","9":"0.34100","10":"1.263717e-05","11":"2833"},{"1":"rs13006480","2":"2","3":"27987221","4":"G","5":"C","6":"0.1986450","7":"-0.0003821","8":"0.006823","9":"0.95530","10":"4.648220e-08","11":"2734"},{"1":"rs13078384","2":"3","3":"85264266","4":"A","5":"G","6":"0.3015860","7":"0.0117300","8":"0.005766","9":"0.04203","10":"5.796290e-05","11":"2794"},{"1":"rs9841829","2":"3","3":"85569361","4":"G","5":"T","6":"0.2228980","7":"0.0052410","8":"0.006310","9":"0.40630","10":"9.515739e-06","11":"2826"},{"1":"rs11940694","2":"4","3":"39414993","4":"A","5":"G","6":"0.4051590","7":"-0.0060930","8":"0.005791","9":"0.29280","10":"1.789447e-05","11":"2197"},{"1":"rs146788033","2":"4","3":"99941138","4":"G","5":"A","6":"0.0224515","7":"0.0146800","8":"0.017780","9":"0.40900","10":"9.459448e-06","11":"2347"},{"1":"rs145452708","2":"4","3":"100248642","4":"C","5":"G","6":"0.0178472","7":"0.0067390","8":"0.017130","9":"0.69410","10":"1.592099e-06","11":"2827"},{"1":"rs2298755","2":"4","3":"100261038","4":"G","5":"C","6":"0.3977980","7":"0.0042170","8":"0.005459","9":"0.43980","10":"8.520047e-06","11":"2829"},{"1":"rs74764239","2":"4","3":"100618891","4":"T","5":"A","6":"0.0257622","7":"0.0108600","8":"0.014540","9":"0.45510","10":"5.920216e-06","11":"2831"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>
<br>

### Tau



Of the the 11 SNPs associated with Alcohol Consumption, 8 were available in the CSF Tau GWAS (Table 6).


**Table 6:** SNPS associated with Alcohol Consumption avalible in tau GWAS
<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["SNP"],"name":[1],"type":["chr"],"align":["left"]},{"label":["CHR"],"name":[2],"type":["int"],"align":["right"]},{"label":["POS"],"name":[3],"type":["int"],"align":["right"]},{"label":["Effect_allele"],"name":[4],"type":["chr"],"align":["left"]},{"label":["Non_Effect_allele"],"name":[5],"type":["chr"],"align":["left"]},{"label":["EAF"],"name":[6],"type":["dbl"],"align":["right"]},{"label":["Beta"],"name":[7],"type":["dbl"],"align":["right"]},{"label":["SE"],"name":[8],"type":["dbl"],"align":["right"]},{"label":["P"],"name":[9],"type":["dbl"],"align":["right"]},{"label":["r2"],"name":[10],"type":["dbl"],"align":["right"]},{"label":["N"],"name":[11],"type":["int"],"align":["right"]}],"data":[{"1":"rs1260326","2":"2","3":"27730940","4":"T","5":"C","6":"0.4048200","7":"-0.0020610","8":"0.005737","9":"0.7194","10":"2.046898e-06","11":"3108"},{"1":"rs13006480","2":"2","3":"27987221","4":"G","5":"C","6":"0.1986450","7":"-0.0007751","8":"0.007325","9":"0.9157","10":"1.912705e-07","11":"2991"},{"1":"rs13078384","2":"3","3":"85264266","4":"A","5":"G","6":"0.3015860","7":"0.0055420","8":"0.006124","9":"0.3655","10":"1.293860e-05","11":"3062"},{"1":"rs9841829","2":"3","3":"85569361","4":"G","5":"T","6":"0.2228980","7":"0.0055590","8":"0.006701","9":"0.4068","10":"1.070551e-05","11":"3101"},{"1":"rs11940694","2":"4","3":"39423789","4":"G","5":"A","6":"0.3763780","7":"-0.0090120","8":"0.005791","9":"0.1198","10":"3.812572e-05","11":"3087"},{"1":"rs146788033","2":"4","3":"99941138","4":"G","5":"A","6":"0.0224515","7":"0.0288900","8":"0.018510","9":"0.1188","10":"3.663606e-05","11":"2614"},{"1":"rs145452708","2":"4","3":"100248642","4":"C","5":"G","6":"0.0178472","7":"0.0078660","8":"0.018600","9":"0.6724","10":"2.169137e-06","11":"3102"},{"1":"rs2298755","2":"4","3":"100261038","4":"G","5":"C","6":"0.3977980","7":"0.0083500","8":"0.005789","9":"0.1493","10":"3.340471e-05","11":"3101"},{"1":"rs74764239","2":"4","3":"100618891","4":"T","5":"A","6":"0.0257622","7":"0.0077290","8":"0.015950","9":"0.6280","10":"2.998641e-06","11":"3106"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>
<br>

### Hippocampal volume



Of the the 11 SNPs associated with Alcohol Consumption, 9 were available in the Hippocampal volume (Table 7).


**Table 7:** SNPS associated with Alcohol Consumption avalible in Hippocampal volume GWAS
<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["SNP"],"name":[1],"type":["chr"],"align":["left"]},{"label":["CHR"],"name":[2],"type":["int"],"align":["right"]},{"label":["POS"],"name":[3],"type":["int"],"align":["right"]},{"label":["Effect_allele"],"name":[4],"type":["chr"],"align":["left"]},{"label":["Non_Effect_allele"],"name":[5],"type":["chr"],"align":["left"]},{"label":["EAF"],"name":[6],"type":["dbl"],"align":["right"]},{"label":["Zscore"],"name":[7],"type":["dbl"],"align":["right"]},{"label":["Beta"],"name":[8],"type":["dbl"],"align":["right"]},{"label":["SE"],"name":[9],"type":["dbl"],"align":["right"]},{"label":["P"],"name":[10],"type":["dbl"],"align":["right"]},{"label":["r2"],"name":[11],"type":["dbl"],"align":["right"]},{"label":["N"],"name":[12],"type":["int"],"align":["right"]}],"data":[{"1":"rs1260326","2":"2","3":"27730940","4":"T","5":"C","6":"0.4008","7":"0.535","8":"0.004731768","9":"0.008844426","10":"0.5927","11":"1.075416e-05","12":"26615"},{"1":"rs13006480","2":"2","3":"27987221","4":"C","5":"G","6":"0.8254","7":"0.346","8":"0.003935727","9":"0.011374934","10":"0.7292","11":"4.464663e-06","12":"26814"},{"1":"rs13078384","2":"3","3":"85264266","4":"A","5":"G","6":"0.3195","7":"-0.115","8":"-0.001065007","9":"0.009260930","10":"0.9086","11":"4.932123e-07","12":"26814"},{"1":"rs9841829","2":"3","3":"85569361","4":"T","5":"G","6":"0.7691","7":"0.861","8":"0.008822628","9":"0.010246955","10":"0.3894","11":"2.764602e-05","12":"26814"},{"1":"rs11940694","2":"4","3":"39414993","4":"A","5":"G","6":"0.4138","7":"0.715","8":"0.006268851","9":"0.008767624","10":"0.4746","11":"1.906524e-05","12":"26814"},{"1":"rs62325470","2":"4","3":"99644166","4":"T","5":"C","6":"0.0131","7":"0.037","8":"0.001416107","9":"0.038273163","10":"0.9702","11":"5.185213e-08","12":"26402"},{"1":"rs145452708","2":"4","3":"100248642","4":"C","5":"G","6":"0.0168","7":"1.073","8":"0.038744020","9":"0.036108127","10":"0.2834","11":"4.958959e-05","12":"23216"},{"1":"rs2298755","2":"4","3":"100261038","4":"C","5":"G","6":"0.5903","7":"0.342","8":"0.003003032","9":"0.008780796","10":"0.7327","11":"4.362031e-06","12":"26814"},{"1":"rs74764239","2":"4","3":"100618891","4":"A","5":"T","6":"0.9749","7":"0.913","8":"0.025202947","9":"0.027604542","10":"0.3610","11":"3.108611e-05","12":"26814"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>
<br>

## Data harmonization
Harmonize the exposure and outcome datasets so that the effect of a SNP on the exposure and the effect of that SNP on the outcome correspond to the same allele. The harmonise_data function from the TwoSampleMR package can be used to perform the harmonization step, by default it try's to infer the forward strand alleles using allele frequency information. EAF were not availbe in the IGAP summary statisitics, as such the allele frequencies reported in the AAOS anaylsis were used.
<br>



### Alcohol Consumption ~ LOAD


**Table 8:** Harmonized Alcohol Consumption and LOAD datasets
<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["SNP"],"name":[1],"type":["fctr"],"align":["left"]},{"label":["effect_allele.exposure"],"name":[2],"type":["fctr"],"align":["left"]},{"label":["other_allele.exposure"],"name":[3],"type":["fctr"],"align":["left"]},{"label":["effect_allele.outcome"],"name":[4],"type":["fctr"],"align":["left"]},{"label":["other_allele.outcome"],"name":[5],"type":["fctr"],"align":["left"]},{"label":["beta.exposure"],"name":[6],"type":["dbl"],"align":["right"]},{"label":["beta.outcome"],"name":[7],"type":["dbl"],"align":["right"]},{"label":["eaf.exposure"],"name":[8],"type":["dbl"],"align":["right"]},{"label":["eaf.outcome"],"name":[9],"type":["dbl"],"align":["right"]},{"label":["se.outcome"],"name":[10],"type":["dbl"],"align":["right"]},{"label":["pval.outcome"],"name":[11],"type":["dbl"],"align":["right"]},{"label":["se.exposure"],"name":[12],"type":["dbl"],"align":["right"]},{"label":["pval.exposure"],"name":[13],"type":["dbl"],"align":["right"]}],"data":[{"1":"rs11940694","2":"A","3":"G","4":"A","5":"G","6":"-0.02694","7":"-0.0363","8":"0.393700","9":"0.4189","10":"0.0167","11":"0.02941","12":"0.003042","13":"8.430e-19"},{"1":"rs1260326","2":"T","3":"C","4":"T","5":"C","6":"-0.02839","7":"-0.0008","8":"0.393400","9":"0.4232","10":"0.0161","11":"0.96080","12":"0.002973","13":"1.341e-21"},{"1":"rs13006480","2":"G","3":"C","4":"G","5":"C","6":"-0.01721","7":"0.0014","8":"0.164000","9":"0.1830","10":"0.0249","11":"0.95640","12":"0.003017","13":"1.170e-08"},{"1":"rs13078384","2":"A","3":"G","4":"A","5":"G","6":"0.01853","7":"-0.0098","8":"0.311600","9":"0.3238","10":"0.0182","11":"0.58970","12":"0.002982","13":"5.171e-10"},{"1":"rs145452708","2":"C","3":"G","4":"C","5":"G","6":"-0.03427","7":"0.0107","8":"0.009985","9":"0.0228","10":"0.0580","11":"0.85340","12":"0.002976","13":"1.148e-30"},{"1":"rs2298755","2":"G","3":"C","4":"G","5":"C","6":"0.01793","7":"0.0089","8":"0.413000","9":"0.3863","10":"0.0159","11":"0.57860","12":"0.003004","13":"2.399e-09"},{"1":"rs62325470","2":"T","3":"C","4":"T","5":"C","6":"-0.01783","7":"0.1208","8":"0.007253","9":"0.0149","10":"0.0723","11":"0.09467","12":"0.002980","13":"2.170e-09"},{"1":"rs74764239","2":"T","3":"A","4":"T","5":"A","6":"-0.01697","7":"0.0003","8":"0.018880","9":"0.0324","10":"0.0428","11":"0.99530","12":"0.002976","13":"1.192e-08"},{"1":"rs9841829","2":"G","3":"T","4":"G","5":"T","6":"0.01869","7":"-0.0191","8":"0.226900","9":"0.7642","10":"0.0185","11":"0.30320","12":"0.002976","13":"3.359e-10"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>
<br>

### Alcohol Consumption ~ AAOS


**Table 9:** Harmonized Alcohol Consumption and AAOS datasets
<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["SNP"],"name":[1],"type":["fctr"],"align":["left"]},{"label":["effect_allele.exposure"],"name":[2],"type":["fctr"],"align":["left"]},{"label":["other_allele.exposure"],"name":[3],"type":["fctr"],"align":["left"]},{"label":["effect_allele.outcome"],"name":[4],"type":["fctr"],"align":["left"]},{"label":["other_allele.outcome"],"name":[5],"type":["fctr"],"align":["left"]},{"label":["beta.exposure"],"name":[6],"type":["dbl"],"align":["right"]},{"label":["beta.outcome"],"name":[7],"type":["dbl"],"align":["right"]},{"label":["eaf.exposure"],"name":[8],"type":["dbl"],"align":["right"]},{"label":["eaf.outcome"],"name":[9],"type":["dbl"],"align":["right"]},{"label":["se.outcome"],"name":[10],"type":["dbl"],"align":["right"]},{"label":["pval.outcome"],"name":[11],"type":["dbl"],"align":["right"]},{"label":["se.exposure"],"name":[12],"type":["dbl"],"align":["right"]},{"label":["pval.exposure"],"name":[13],"type":["dbl"],"align":["right"]}],"data":[{"1":"rs11940694","2":"A","3":"G","4":"A","5":"G","6":"-0.02694","7":"-0.0149","8":"0.393700","9":"0.4189","10":"0.0139","11":"0.2837","12":"0.003042","13":"8.430e-19"},{"1":"rs1260326","2":"T","3":"C","4":"T","5":"C","6":"-0.02839","7":"-0.0007","8":"0.393400","9":"0.4232","10":"0.0123","11":"0.9537","12":"0.002973","13":"1.341e-21"},{"1":"rs13006480","2":"G","3":"C","4":"G","5":"C","6":"-0.01721","7":"0.0144","8":"0.164000","9":"0.1830","10":"0.0250","11":"0.5638","12":"0.003017","13":"1.170e-08"},{"1":"rs13078384","2":"A","3":"G","4":"A","5":"G","6":"0.01853","7":"-0.0137","8":"0.311600","9":"0.3238","10":"0.0131","11":"0.2964","12":"0.002982","13":"5.171e-10"},{"1":"rs145452708","2":"C","3":"G","4":"C","5":"G","6":"-0.03427","7":"0.1068","8":"0.009985","9":"0.0228","10":"0.0870","11":"0.2198","12":"0.002976","13":"1.148e-30"},{"1":"rs146788033","2":"G","3":"A","4":"G","5":"A","6":"-0.02845","7":"0.1120","8":"0.013410","9":"0.0318","10":"0.0875","11":"0.2007","12":"0.002993","13":"2.053e-21"},{"1":"rs193099203","2":"T","3":"C","4":"T","5":"C","6":"-0.03105","7":"0.1129","8":"0.007120","9":"0.0227","10":"0.1139","11":"0.3214","12":"0.002996","13":"3.787e-25"},{"1":"rs2298755","2":"G","3":"C","4":"G","5":"C","6":"0.01793","7":"0.0163","8":"0.413000","9":"0.3930","10":"0.0194","11":"0.4004","12":"0.003004","13":"2.399e-09"},{"1":"rs62325470","2":"T","3":"C","4":"T","5":"C","6":"-0.01783","7":"0.1635","8":"0.007253","9":"0.0149","10":"0.1218","11":"0.1795","12":"0.002980","13":"2.170e-09"},{"1":"rs74764239","2":"T","3":"A","4":"T","5":"A","6":"-0.01697","7":"0.0979","8":"0.018880","9":"0.0324","10":"0.0709","11":"0.1671","12":"0.002976","13":"1.192e-08"},{"1":"rs9841829","2":"G","3":"T","4":"G","5":"T","6":"0.01869","7":"-0.0049","8":"0.226900","9":"0.2358","10":"0.0143","11":"0.7331","12":"0.002976","13":"3.359e-10"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>
<br>

### Alcohol Consumption ~ AB42


**Table 10:** Harmonized Alcohol Consumption and AB42 datasets
<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["SNP"],"name":[1],"type":["fctr"],"align":["left"]},{"label":["effect_allele.exposure"],"name":[2],"type":["fctr"],"align":["left"]},{"label":["other_allele.exposure"],"name":[3],"type":["fctr"],"align":["left"]},{"label":["effect_allele.outcome"],"name":[4],"type":["fctr"],"align":["left"]},{"label":["other_allele.outcome"],"name":[5],"type":["fctr"],"align":["left"]},{"label":["beta.exposure"],"name":[6],"type":["dbl"],"align":["right"]},{"label":["beta.outcome"],"name":[7],"type":["dbl"],"align":["right"]},{"label":["eaf.exposure"],"name":[8],"type":["dbl"],"align":["right"]},{"label":["eaf.outcome"],"name":[9],"type":["dbl"],"align":["right"]},{"label":["se.outcome"],"name":[10],"type":["dbl"],"align":["right"]},{"label":["pval.outcome"],"name":[11],"type":["dbl"],"align":["right"]},{"label":["se.exposure"],"name":[12],"type":["dbl"],"align":["right"]},{"label":["pval.exposure"],"name":[13],"type":["dbl"],"align":["right"]}],"data":[{"1":"rs11940694","2":"A","3":"G","4":"A","5":"G","6":"-0.02694","7":"-0.003275","8":"0.393700","9":"0.6236220","10":"0.004145","11":"0.429500","12":"0.003042","13":"8.430e-19"},{"1":"rs1260326","2":"T","3":"C","4":"T","5":"C","6":"-0.02839","7":"0.002212","8":"0.393400","9":"0.4048200","10":"0.004110","11":"0.590400","12":"0.002973","13":"1.341e-21"},{"1":"rs13006480","2":"G","3":"C","4":"G","5":"C","6":"-0.01721","7":"-0.003989","8":"0.164000","9":"0.1986450","10":"0.005237","11":"0.446400","12":"0.003017","13":"1.170e-08"},{"1":"rs13078384","2":"A","3":"G","4":"A","5":"G","6":"0.01853","7":"-0.003516","8":"0.311600","9":"0.3015860","10":"0.004403","11":"0.424600","12":"0.002982","13":"5.171e-10"},{"1":"rs145452708","2":"C","3":"G","4":"C","5":"G","6":"-0.03427","7":"0.028050","8":"0.009985","9":"0.0178472","10":"0.013330","11":"0.035380","12":"0.002976","13":"1.148e-30"},{"1":"rs146788033","2":"G","3":"A","4":"G","5":"A","6":"-0.02845","7":"0.004287","8":"0.013410","9":"0.0224515","10":"0.012800","11":"0.737800","12":"0.002993","13":"2.053e-21"},{"1":"rs2298755","2":"G","3":"C","4":"G","5":"C","6":"0.01793","7":"-0.005725","8":"0.413000","9":"0.3977980","10":"0.004142","11":"0.167000","12":"0.003004","13":"2.399e-09"},{"1":"rs74764239","2":"T","3":"A","4":"T","5":"A","6":"-0.01697","7":"0.031160","8":"0.018880","9":"0.0257622","10":"0.011420","11":"0.006408","12":"0.002976","13":"1.192e-08"},{"1":"rs9841829","2":"G","3":"T","4":"G","5":"T","6":"0.01869","7":"0.005628","8":"0.226900","9":"0.2228980","10":"0.004810","11":"0.242100","12":"0.002976","13":"3.359e-10"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>
<br>

### Alcohol Consumption ~ Ptau


**Table 11:** Harmonized Alcohol Consumption and Ptau datasets
<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["SNP"],"name":[1],"type":["fctr"],"align":["left"]},{"label":["effect_allele.exposure"],"name":[2],"type":["fctr"],"align":["left"]},{"label":["other_allele.exposure"],"name":[3],"type":["fctr"],"align":["left"]},{"label":["effect_allele.outcome"],"name":[4],"type":["fctr"],"align":["left"]},{"label":["other_allele.outcome"],"name":[5],"type":["fctr"],"align":["left"]},{"label":["beta.exposure"],"name":[6],"type":["dbl"],"align":["right"]},{"label":["beta.outcome"],"name":[7],"type":["dbl"],"align":["right"]},{"label":["eaf.exposure"],"name":[8],"type":["dbl"],"align":["right"]},{"label":["eaf.outcome"],"name":[9],"type":["dbl"],"align":["right"]},{"label":["se.outcome"],"name":[10],"type":["dbl"],"align":["right"]},{"label":["pval.outcome"],"name":[11],"type":["dbl"],"align":["right"]},{"label":["se.exposure"],"name":[12],"type":["dbl"],"align":["right"]},{"label":["pval.exposure"],"name":[13],"type":["dbl"],"align":["right"]}],"data":[{"1":"rs11940694","2":"A","3":"G","4":"A","5":"G","6":"-0.02694","7":"-0.0060930","8":"0.393700","9":"0.4051590","10":"0.005791","11":"0.29280","12":"0.003042","13":"8.430e-19"},{"1":"rs1260326","2":"T","3":"C","4":"T","5":"C","6":"-0.02839","7":"-0.0051210","8":"0.393400","9":"0.4048200","10":"0.005377","11":"0.34100","12":"0.002973","13":"1.341e-21"},{"1":"rs13006480","2":"G","3":"C","4":"G","5":"C","6":"-0.01721","7":"-0.0003821","8":"0.164000","9":"0.1986450","10":"0.006823","11":"0.95530","12":"0.003017","13":"1.170e-08"},{"1":"rs13078384","2":"A","3":"G","4":"A","5":"G","6":"0.01853","7":"0.0117300","8":"0.311600","9":"0.3015860","10":"0.005766","11":"0.04203","12":"0.002982","13":"5.171e-10"},{"1":"rs145452708","2":"C","3":"G","4":"C","5":"G","6":"-0.03427","7":"0.0067390","8":"0.009985","9":"0.0178472","10":"0.017130","11":"0.69410","12":"0.002976","13":"1.148e-30"},{"1":"rs146788033","2":"G","3":"A","4":"G","5":"A","6":"-0.02845","7":"0.0146800","8":"0.013410","9":"0.0224515","10":"0.017780","11":"0.40900","12":"0.002993","13":"2.053e-21"},{"1":"rs2298755","2":"G","3":"C","4":"G","5":"C","6":"0.01793","7":"0.0042170","8":"0.413000","9":"0.3977980","10":"0.005459","11":"0.43980","12":"0.003004","13":"2.399e-09"},{"1":"rs74764239","2":"T","3":"A","4":"T","5":"A","6":"-0.01697","7":"0.0108600","8":"0.018880","9":"0.0257622","10":"0.014540","11":"0.45510","12":"0.002976","13":"1.192e-08"},{"1":"rs9841829","2":"G","3":"T","4":"G","5":"T","6":"0.01869","7":"0.0052410","8":"0.226900","9":"0.2228980","10":"0.006310","11":"0.40630","12":"0.002976","13":"3.359e-10"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>
<br>

### Alcohol Consumption ~ Tau


**Table 12:** Harmonized Alcohol Consumption and Tau datasets
<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["SNP"],"name":[1],"type":["fctr"],"align":["left"]},{"label":["effect_allele.exposure"],"name":[2],"type":["fctr"],"align":["left"]},{"label":["other_allele.exposure"],"name":[3],"type":["fctr"],"align":["left"]},{"label":["effect_allele.outcome"],"name":[4],"type":["fctr"],"align":["left"]},{"label":["other_allele.outcome"],"name":[5],"type":["fctr"],"align":["left"]},{"label":["beta.exposure"],"name":[6],"type":["dbl"],"align":["right"]},{"label":["beta.outcome"],"name":[7],"type":["dbl"],"align":["right"]},{"label":["eaf.exposure"],"name":[8],"type":["dbl"],"align":["right"]},{"label":["eaf.outcome"],"name":[9],"type":["dbl"],"align":["right"]},{"label":["se.outcome"],"name":[10],"type":["dbl"],"align":["right"]},{"label":["pval.outcome"],"name":[11],"type":["dbl"],"align":["right"]},{"label":["se.exposure"],"name":[12],"type":["dbl"],"align":["right"]},{"label":["pval.exposure"],"name":[13],"type":["dbl"],"align":["right"]}],"data":[{"1":"rs11940694","2":"A","3":"G","4":"A","5":"G","6":"-0.02694","7":"0.0090120","8":"0.393700","9":"0.6236220","10":"0.005791","11":"0.1198","12":"0.003042","13":"8.430e-19"},{"1":"rs1260326","2":"T","3":"C","4":"T","5":"C","6":"-0.02839","7":"-0.0020610","8":"0.393400","9":"0.4048200","10":"0.005737","11":"0.7194","12":"0.002973","13":"1.341e-21"},{"1":"rs13006480","2":"G","3":"C","4":"G","5":"C","6":"-0.01721","7":"-0.0007751","8":"0.164000","9":"0.1986450","10":"0.007325","11":"0.9157","12":"0.003017","13":"1.170e-08"},{"1":"rs13078384","2":"A","3":"G","4":"A","5":"G","6":"0.01853","7":"0.0055420","8":"0.311600","9":"0.3015860","10":"0.006124","11":"0.3655","12":"0.002982","13":"5.171e-10"},{"1":"rs145452708","2":"C","3":"G","4":"C","5":"G","6":"-0.03427","7":"0.0078660","8":"0.009985","9":"0.0178472","10":"0.018600","11":"0.6724","12":"0.002976","13":"1.148e-30"},{"1":"rs146788033","2":"G","3":"A","4":"G","5":"A","6":"-0.02845","7":"0.0288900","8":"0.013410","9":"0.0224515","10":"0.018510","11":"0.1188","12":"0.002993","13":"2.053e-21"},{"1":"rs2298755","2":"G","3":"C","4":"G","5":"C","6":"0.01793","7":"0.0083500","8":"0.413000","9":"0.3977980","10":"0.005789","11":"0.1493","12":"0.003004","13":"2.399e-09"},{"1":"rs74764239","2":"T","3":"A","4":"T","5":"A","6":"-0.01697","7":"0.0077290","8":"0.018880","9":"0.0257622","10":"0.015950","11":"0.6280","12":"0.002976","13":"1.192e-08"},{"1":"rs9841829","2":"G","3":"T","4":"G","5":"T","6":"0.01869","7":"0.0055590","8":"0.226900","9":"0.2228980","10":"0.006701","11":"0.4068","12":"0.002976","13":"3.359e-10"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>
<br>

### Alcohol Consumption ~ Hippocampal Volume


**Table 13:** Harmonized Alcohol Consumption and Hippocampal Volume datasets
<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["SNP"],"name":[1],"type":["fctr"],"align":["left"]},{"label":["effect_allele.exposure"],"name":[2],"type":["fctr"],"align":["left"]},{"label":["other_allele.exposure"],"name":[3],"type":["fctr"],"align":["left"]},{"label":["effect_allele.outcome"],"name":[4],"type":["fctr"],"align":["left"]},{"label":["other_allele.outcome"],"name":[5],"type":["fctr"],"align":["left"]},{"label":["beta.exposure"],"name":[6],"type":["dbl"],"align":["right"]},{"label":["beta.outcome"],"name":[7],"type":["dbl"],"align":["right"]},{"label":["eaf.exposure"],"name":[8],"type":["dbl"],"align":["right"]},{"label":["eaf.outcome"],"name":[9],"type":["dbl"],"align":["right"]},{"label":["se.outcome"],"name":[10],"type":["dbl"],"align":["right"]},{"label":["pval.outcome"],"name":[11],"type":["dbl"],"align":["right"]},{"label":["se.exposure"],"name":[12],"type":["dbl"],"align":["right"]},{"label":["pval.exposure"],"name":[13],"type":["dbl"],"align":["right"]}],"data":[{"1":"rs11940694","2":"A","3":"G","4":"A","5":"G","6":"-0.02694","7":"0.006268851","8":"0.393700","9":"0.4138","10":"0.008767624","11":"0.4746","12":"0.003042","13":"8.430e-19"},{"1":"rs1260326","2":"T","3":"C","4":"T","5":"C","6":"-0.02839","7":"0.004731768","8":"0.393400","9":"0.4008","10":"0.008844426","11":"0.5927","12":"0.002973","13":"1.341e-21"},{"1":"rs13006480","2":"G","3":"C","4":"G","5":"C","6":"-0.01721","7":"-0.003935727","8":"0.164000","9":"0.1746","10":"0.011374934","11":"0.7292","12":"0.003017","13":"1.170e-08"},{"1":"rs13078384","2":"A","3":"G","4":"A","5":"G","6":"0.01853","7":"-0.001065007","8":"0.311600","9":"0.3195","10":"0.009260930","11":"0.9086","12":"0.002982","13":"5.171e-10"},{"1":"rs145452708","2":"C","3":"G","4":"C","5":"G","6":"-0.03427","7":"0.038744020","8":"0.009985","9":"0.0168","10":"0.036108127","11":"0.2834","12":"0.002976","13":"1.148e-30"},{"1":"rs2298755","2":"G","3":"C","4":"G","5":"C","6":"0.01793","7":"-0.003003032","8":"0.413000","9":"0.4097","10":"0.008780796","11":"0.7327","12":"0.003004","13":"2.399e-09"},{"1":"rs62325470","2":"T","3":"C","4":"T","5":"C","6":"-0.01783","7":"0.001416107","8":"0.007253","9":"0.0131","10":"0.038273163","11":"0.9702","12":"0.002980","13":"2.170e-09"},{"1":"rs74764239","2":"T","3":"A","4":"T","5":"A","6":"-0.01697","7":"-0.025202947","8":"0.018880","9":"0.0251","10":"0.027604542","11":"0.3610","12":"0.002976","13":"1.192e-08"},{"1":"rs9841829","2":"G","3":"T","4":"G","5":"T","6":"0.01869","7":"-0.008822628","8":"0.226900","9":"0.2309","10":"0.010246955","11":"0.3894","12":"0.002976","13":"3.359e-10"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>
<br>




\








## Pleiotropy 
Pleiotropy was assesed using Mendelian Randomization Pleiotropy RESidual Sum and Outlier (MR-PRESSO), that allows for the evlation of evaluation of horizontal pleiotropy in a standared MR model. MR-PRESSO performs a global test for detection of horizontal pleiotropy and correction of pleiotropy via outlier removal. 
<br> 



**Alcohol Consumption ~ LOAD:** The MR-PRESSO global test for pleiotropy was non-significant 
<br> 



**Alcohol Consumption ~ AAOS:** The MR-PRESSO global test for pleiotropy was non-significant. 
<br> 



**Alcohol Consumption ~ AB42:** The MR-PRESSO global test for pleiotropy was non-significant. 
<br> 



**Alcohol Consumption ~ Ptau:** The MR-PRESSO global test for pleiotropy was non-significant. 
<br> 



**Alcohol Consumption ~ Tau:** The MR-PRESSO global test for pleiotropy was non-significant.. 
<br> 



**Alcohol Consumption ~ hippocampal volume:** The MR-PRESSO global test for pleiotropy was non-significant 
<br> 
  
##  Mendelian Randomization Analysis 
To obtain an overall estimate of causal effect, the SNP-exposure (Major Depressive Disorder) and SNP-outcome coefficients (Alzheimer’s disease and Alzheimer's Age of Onset) were combined in 1) a random-effects meta-analysis using an inverse-variance weighted approach (IVW); 2) a Weighted Median approach; 3) and Egger Regression. IVW is equivalent to a weighted regression of the SNP-outcome coefficients on the SNP-exposure coefficients with the intercept constrained to zero. This method assumes that all variants are valid instrumental variables based on the Mendelian randomization assumptions. The causal estimate of the IVW analysis expresses the causal increase in the outcome (or log odds of the outcome for a binary outcome) per unit change in the exposure. Weighted median MR allows for 50% of the instrumental variables to be invalid. MR-Egger regression allows all the instrumental variables to be subject to direct effects (i.e. horizontal pleiotropy), with the intercept representing bias in the causal estimate due to pleiotropy and the slope representing the causal estimate.

### Alcohol Consumption ~ LOAD

\

Figure 1 illustrates the SNP-specific associations with Alcohol Consumption versus the association between each SNP and risk of LOAD.

<div class="figure" style="text-align: center">
<img src="/Users/sheaandrews/Dropbox/Research/PostDoc-MSSM/2_MR/4_Output/alcc_AD_MR_5e-8_Analaysis_files/figure-html/scatter_plot LOAD-1.png" alt="Fig. 1: Scatterplot of SNP effects for the association of Trait and LOAD"  />
<p class="caption">Fig. 1: Scatterplot of SNP effects for the association of Trait and LOAD</p>
</div>
\

Figure 2 and Table 1 shows the SNP-specific effects and overall IVW, weighted median and Egger regression causal estimates of genetically predicted Alcohol Consumption on risk of LOAD.

<div class="figure" style="text-align: center">
<img src="/Users/sheaandrews/Dropbox/Research/PostDoc-MSSM/2_MR/4_Output/alcc_AD_MR_5e-8_Analaysis_files/figure-html/forrest_plot LOAD-1.png" alt="Fig. 2: Forrest plot of Wald ratios and 95% CIs for SNP-specific and overall IVW, Weighted median and Egger associations"  />
<p class="caption">Fig. 2: Forrest plot of Wald ratios and 95% CIs for SNP-specific and overall IVW, Weighted median and Egger associations</p>
</div>
<br>

**Table 1:** MR estimates for Alcohol Consumption and LOAD
<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":[""],"name":["_rn_"],"type":[""],"align":["left"]},{"label":["SNP"],"name":[1],"type":["fctr"],"align":["left"]},{"label":["b"],"name":[2],"type":["dbl"],"align":["right"]},{"label":["se"],"name":[3],"type":["dbl"],"align":["right"]},{"label":["p"],"name":[4],"type":["dbl"],"align":["right"]}],"data":[{"1":"rs11940694","2":"1.34743875","3":"0.6198961","4":"0.02973123","_rn_":"1"},{"1":"rs1260326","2":"0.02817894","3":"0.5671011","4":"0.96036987","_rn_":"2"},{"1":"rs13006480","2":"-0.08134805","3":"1.4468332","4":"0.95516265","_rn_":"3"},{"1":"rs13078384","2":"-0.52887210","3":"0.9821910","4":"0.59025845","_rn_":"4"},{"1":"rs145452708","2":"-0.31222644","3":"1.6924424","4":"0.85363475","_rn_":"5"},{"1":"rs2298755","2":"0.49637479","3":"0.8867819","4":"0.57565105","_rn_":"6"},{"1":"rs62325470","2":"-6.77509815","3":"4.0549635","4":"0.09475802","_rn_":"7"},{"1":"rs74764239","2":"-0.01767826","3":"2.5220978","4":"0.99440740","_rn_":"8"},{"1":"rs9841829","2":"-1.02193686","3":"0.9898341","4":"0.30186959","_rn_":"9"},{"1":"All - Inverse variance weighted (fixed effects)","2":"0.20538092","3":"0.3148848","4":"0.51424535","_rn_":"10"},{"1":"All - Weighted median","2":"0.09804080","3":"0.4433487","4":"0.82498575","_rn_":"11"},{"1":"All - MR Egger","2":"1.84190041","3":"1.4933179","4":"0.25722279","_rn_":"12"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>
\

Figure 3 shows a funnel plot to detect pleiotropy and Table 2 show the results of Cochrans Q heterogeneity test to assess for the presence of pleiotropy. 

<div class="figure" style="text-align: center">
<img src="/Users/sheaandrews/Dropbox/Research/PostDoc-MSSM/2_MR/4_Output/alcc_AD_MR_5e-8_Analaysis_files/figure-html/funnel_plot LOAD-1.png" alt="Fig. 3: Funnel plot of the Trait – LOAD causal estimates against their precession"  />
<p class="caption">Fig. 3: Funnel plot of the Trait – LOAD causal estimates against their precession</p>
</div>
<br>

**Table 2:** Heterogenity tests for Alcohol Consumption and LOAD
<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["exposure"],"name":[1],"type":["fctr"],"align":["left"]},{"label":["outcome"],"name":[2],"type":["fctr"],"align":["left"]},{"label":["method"],"name":[3],"type":["fctr"],"align":["left"]},{"label":["Q"],"name":[4],"type":["dbl"],"align":["right"]},{"label":["Q_df"],"name":[5],"type":["dbl"],"align":["right"]},{"label":["Q_pval"],"name":[6],"type":["dbl"],"align":["right"]}],"data":[{"1":"alcc","2":"LOAD","3":"MR Egger","4":"7.456880","5":"7","6":"0.3829066"},{"1":"alcc","2":"LOAD","3":"Inverse variance weighted","4":"8.799862","5":"8","6":"0.3594598"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

**Table 3:** Test for directional pleitropy for Alcohol Consumption and LOAD
<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["id.exposure"],"name":[1],"type":["chr"],"align":["left"]},{"label":["id.outcome"],"name":[2],"type":["chr"],"align":["left"]},{"label":["outcome"],"name":[3],"type":["fctr"],"align":["left"]},{"label":["exposure"],"name":[4],"type":["fctr"],"align":["left"]},{"label":["egger_intercept"],"name":[5],"type":["dbl"],"align":["right"]},{"label":["se"],"name":[6],"type":["dbl"],"align":["right"]},{"label":["pval"],"name":[7],"type":["dbl"],"align":["right"]}],"data":[{"1":"pvZhpK","2":"JANYq4","3":"LOAD","4":"alcc","5":"-0.03766433","6":"0.03354475","7":"0.2985483"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

### Alcohol Consumption ~ AAOS


\

Figure 4 illustrates the SNP-specific associations with Alcohol Consumption versus the association between each SNP and AAOS.

<div class="figure" style="text-align: center">
<img src="/Users/sheaandrews/Dropbox/Research/PostDoc-MSSM/2_MR/4_Output/alcc_AD_MR_5e-8_Analaysis_files/figure-html/scatter_plot AAOS-1.png" alt="Fig. 4: Scatterplot of SNP effects for the association of Trait and AAOS"  />
<p class="caption">Fig. 4: Scatterplot of SNP effects for the association of Trait and AAOS</p>
</div>
\

Figure 5 and Table 4 shows the SNP-specific effects and overall IVW, weighted median and Egger regression causal estimates of genetically predicted Alcohol Consumption on AAOS.

<div class="figure" style="text-align: center">
<img src="/Users/sheaandrews/Dropbox/Research/PostDoc-MSSM/2_MR/4_Output/alcc_AD_MR_5e-8_Analaysis_files/figure-html/forrest_plot AAOS-1.png" alt="Fig. 5: Forrest plot of Wald ratios and 95% CIs for SNP-specific and overall IVW, Weighted median and Egger associations"  />
<p class="caption">Fig. 5: Forrest plot of Wald ratios and 95% CIs for SNP-specific and overall IVW, Weighted median and Egger associations</p>
</div>
<br>

**Table 4:** MR estimates for Alcohol Consumption and AAOS
<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":[""],"name":["_rn_"],"type":[""],"align":["left"]},{"label":["SNP"],"name":[1],"type":["fctr"],"align":["left"]},{"label":["b"],"name":[2],"type":["dbl"],"align":["right"]},{"label":["se"],"name":[3],"type":["dbl"],"align":["right"]},{"label":["p"],"name":[4],"type":["dbl"],"align":["right"]}],"data":[{"1":"rs11940694","2":"0.55308092","3":"0.5159614","4":"0.2837459","_rn_":"1"},{"1":"rs1260326","2":"0.02465657","3":"0.4332511","4":"0.9546164","_rn_":"2"},{"1":"rs13006480","2":"-0.83672284","3":"1.4526438","4":"0.5646152","_rn_":"3"},{"1":"rs13078384","2":"-0.73934161","3":"0.7069617","4":"0.2956527","_rn_":"4"},{"1":"rs145452708","2":"-3.11642836","3":"2.5386636","4":"0.2196023","_rn_":"5"},{"1":"rs146788033","2":"-3.93673111","3":"3.0755712","4":"0.2005451","_rn_":"6"},{"1":"rs193099203","2":"-3.63607085","3":"3.6682770","4":"0.3215780","_rn_":"7"},{"1":"rs2298755","2":"0.90909091","3":"1.0819855","4":"0.4007928","_rn_":"8"},{"1":"rs62325470","2":"-9.16993831","3":"6.8311834","4":"0.1794778","_rn_":"9"},{"1":"rs74764239","2":"-5.76900412","3":"4.1779611","4":"0.1673349","_rn_":"10"},{"1":"rs9841829","2":"-0.26217228","3":"0.7651150","4":"0.7318563","_rn_":"11"},{"1":"All - Inverse variance weighted (fixed effects)","2":"-0.07121889","3":"0.2622977","4":"0.7859917","_rn_":"12"},{"1":"All - Weighted median","2":"0.02561095","3":"0.3396715","4":"0.9398971","_rn_":"13"},{"1":"All - MR Egger","2":"0.85063722","3":"1.3669891","4":"0.5492023","_rn_":"14"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>
\

Figure 6 shows a funnel plot to detect pleiotropy and Table 5 show the results of Cochrans Q heterogeneity test to assess for the presence of pleiotropy. 

<div class="figure" style="text-align: center">
<img src="/Users/sheaandrews/Dropbox/Research/PostDoc-MSSM/2_MR/4_Output/alcc_AD_MR_5e-8_Analaysis_files/figure-html/funnel_plot AAOS-1.png" alt="Fig. 6:  Funnel plot of the traitohol Conumption – AAOS causal estimates against their precession"  />
<p class="caption">Fig. 6:  Funnel plot of the traitohol Conumption – AAOS causal estimates against their precession</p>
</div>
<br>

**Table 5:** Heterogenity tests for Alcohol Consumption and AAOS
<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["exposure"],"name":[1],"type":["fctr"],"align":["left"]},{"label":["outcome"],"name":[2],"type":["fctr"],"align":["left"]},{"label":["method"],"name":[3],"type":["fctr"],"align":["left"]},{"label":["Q"],"name":[4],"type":["dbl"],"align":["right"]},{"label":["Q_df"],"name":[5],"type":["dbl"],"align":["right"]},{"label":["Q_pval"],"name":[6],"type":["dbl"],"align":["right"]}],"data":[{"1":"alcc","2":"AAOS","3":"MR Egger","4":"10.60379","5":"9","6":"0.3038473"},{"1":"alcc","2":"AAOS","3":"Inverse variance weighted","4":"11.16390","5":"10","6":"0.3448921"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

**Table 6:** Test for directional pleitropy for Alcohol Consumption and AAOS
<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["id.exposure"],"name":[1],"type":["chr"],"align":["left"]},{"label":["id.outcome"],"name":[2],"type":["chr"],"align":["left"]},{"label":["outcome"],"name":[3],"type":["fctr"],"align":["left"]},{"label":["exposure"],"name":[4],"type":["fctr"],"align":["left"]},{"label":["egger_intercept"],"name":[5],"type":["dbl"],"align":["right"]},{"label":["se"],"name":[6],"type":["dbl"],"align":["right"]},{"label":["pval"],"name":[7],"type":["dbl"],"align":["right"]}],"data":[{"1":"pvZhpK","2":"DxVcLO","3":"AAOS","4":"alcc","5":"-0.02172162","6":"0.03150389","7":"0.5079004"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

### Alcohol Consumption ~ AB42

\

Figure 1 illustrates the SNP-specific associations with Alcohol Consumption versus the association between each SNP and AB42.

<div class="figure" style="text-align: center">
<img src="/Users/sheaandrews/Dropbox/Research/PostDoc-MSSM/2_MR/4_Output/alcc_AD_MR_5e-8_Analaysis_files/figure-html/scatter_plot AB42-1.png" alt="Fig. 1: Scatterplot of SNP effects for the association of trait and AB42"  />
<p class="caption">Fig. 1: Scatterplot of SNP effects for the association of trait and AB42</p>
</div>
\

Figure 2 and Table 7 shows the SNP-specific effects and overall IVW, weighted median and Egger regression causal estimates of genetically predicted Alcohol Consumption CSF AB42 levels.

<div class="figure" style="text-align: center">
<img src="/Users/sheaandrews/Dropbox/Research/PostDoc-MSSM/2_MR/4_Output/alcc_AD_MR_5e-8_Analaysis_files/figure-html/forrest_plot AB42-1.png" alt="Fig. 2: Forrest plot of Wald ratios and 95% CIs for SNP-specific and overall IVW, Weighted median and Egger associations"  />
<p class="caption">Fig. 2: Forrest plot of Wald ratios and 95% CIs for SNP-specific and overall IVW, Weighted median and Egger associations</p>
</div>
<br>

**Table 7:** MR estimates for Alcohol Consumption and AB42
<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":[""],"name":["_rn_"],"type":[""],"align":["left"]},{"label":["SNP"],"name":[1],"type":["fctr"],"align":["left"]},{"label":["b"],"name":[2],"type":["dbl"],"align":["right"]},{"label":["se"],"name":[3],"type":["dbl"],"align":["right"]},{"label":["p"],"name":[4],"type":["dbl"],"align":["right"]}],"data":[{"1":"rs11940694","2":"0.12156644","3":"0.15386043","4":"0.429464369","_rn_":"1"},{"1":"rs1260326","2":"-0.07791476","3":"0.14476928","4":"0.590439316","_rn_":"2"},{"1":"rs13006480","2":"0.23178385","3":"0.30429983","4":"0.446241686","_rn_":"3"},{"1":"rs13078384","2":"-0.18974636","3":"0.23761468","4":"0.424553452","_rn_":"4"},{"1":"rs145452708","2":"-0.81850015","3":"0.38896994","4":"0.035354372","_rn_":"5"},{"1":"rs146788033","2":"-0.15068541","3":"0.44991213","4":"0.737684020","_rn_":"6"},{"1":"rs2298755","2":"-0.31929727","3":"0.23100948","4":"0.166915666","_rn_":"7"},{"1":"rs74764239","2":"-1.83618150","3":"0.67295227","4":"0.006361414","_rn_":"8"},{"1":"rs9841829","2":"0.30112360","3":"0.25735688","4":"0.241975870","_rn_":"9"},{"1":"All - Inverse variance weighted (fixed effects)","2":"-0.06675594","3":"0.07760057","4":"0.389650937","_rn_":"10"},{"1":"All - Weighted median","2":"-0.03605482","3":"0.10397524","4":"0.728768974","_rn_":"11"},{"1":"All - MR Egger","2":"-0.03870842","3":"0.54426212","4":"0.945290817","_rn_":"12"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>
\

Figure 3 shows a funnel plot to detect pleiotropy and Table 8 show the results of Cochrans Q heterogeneity test to assess for the presence of pleiotropy. 

<div class="figure" style="text-align: center">
<img src="/Users/sheaandrews/Dropbox/Research/PostDoc-MSSM/2_MR/4_Output/alcc_AD_MR_5e-8_Analaysis_files/figure-html/funnel_plot AB42-1.png" alt="Fig. 3: Funnel plot of the trait – AB42 causal estimates against their precession"  />
<p class="caption">Fig. 3: Funnel plot of the trait – AB42 causal estimates against their precession</p>
</div>
<br>

**Table 8:** Heterogenity tests for Alcohol Consumption and AB42
<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["exposure"],"name":[1],"type":["fctr"],"align":["left"]},{"label":["outcome"],"name":[2],"type":["fctr"],"align":["left"]},{"label":["method"],"name":[3],"type":["fctr"],"align":["left"]},{"label":["Q"],"name":[4],"type":["dbl"],"align":["right"]},{"label":["Q_df"],"name":[5],"type":["dbl"],"align":["right"]},{"label":["Q_pval"],"name":[6],"type":["dbl"],"align":["right"]}],"data":[{"1":"alcc","2":"ab42","3":"MR Egger","4":"16.64971","5":"7","6":"0.01980005"},{"1":"alcc","2":"ab42","3":"Inverse variance weighted","4":"16.65635","5":"8","6":"0.03389323"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

**Table 9:** Test for directional pleitropy for Alcohol Consumption and AB42
<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["id.exposure"],"name":[1],"type":["chr"],"align":["left"]},{"label":["id.outcome"],"name":[2],"type":["chr"],"align":["left"]},{"label":["outcome"],"name":[3],"type":["fctr"],"align":["left"]},{"label":["exposure"],"name":[4],"type":["fctr"],"align":["left"]},{"label":["egger_intercept"],"name":[5],"type":["dbl"],"align":["right"]},{"label":["se"],"name":[6],"type":["dbl"],"align":["right"]},{"label":["pval"],"name":[7],"type":["dbl"],"align":["right"]}],"data":[{"1":"pvZhpK","2":"EYRewW","3":"ab42","4":"alcc","5":"-0.0006485526","6":"0.01227713","7":"0.9593464"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

### Alcohol Consumption ~ Ptau

\

Figure 1 illustrates the SNP-specific associations with Alcohol Consumption versus the association between each SNP and risk of Ptau.

<div class="figure" style="text-align: center">
<img src="/Users/sheaandrews/Dropbox/Research/PostDoc-MSSM/2_MR/4_Output/alcc_AD_MR_5e-8_Analaysis_files/figure-html/scatter_plot Ptau-1.png" alt="Fig. 1: Scatterplot of SNP effects for the association of trait and Ptau"  />
<p class="caption">Fig. 1: Scatterplot of SNP effects for the association of trait and Ptau</p>
</div>
\

Figure 2 and Table 9 shows the SNP-specific effects and overall IVW, weighted median and Egger regression causal estimates of genetically predicted Alcohol Consumption on risk of Ptau.

<div class="figure" style="text-align: center">
<img src="/Users/sheaandrews/Dropbox/Research/PostDoc-MSSM/2_MR/4_Output/alcc_AD_MR_5e-8_Analaysis_files/figure-html/forrest_plot Ptau-1.png" alt="Fig. 2: Forrest plot of Wald ratios and 95% CIs for SNP-specific and overall IVW, Weighted median and Egger associations"  />
<p class="caption">Fig. 2: Forrest plot of Wald ratios and 95% CIs for SNP-specific and overall IVW, Weighted median and Egger associations</p>
</div>
<br>

**Table 9:** MR estimates for Alcohol Consumption and Ptau
<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":[""],"name":["_rn_"],"type":[""],"align":["left"]},{"label":["SNP"],"name":[1],"type":["fctr"],"align":["left"]},{"label":["b"],"name":[2],"type":["dbl"],"align":["right"]},{"label":["se"],"name":[3],"type":["dbl"],"align":["right"]},{"label":["p"],"name":[4],"type":["dbl"],"align":["right"]}],"data":[{"1":"rs11940694","2":"0.22616927","3":"0.2149592","4":"0.29273079","_rn_":"1"},{"1":"rs1260326","2":"0.18038042","3":"0.1893977","4":"0.34089933","_rn_":"2"},{"1":"rs13006480","2":"0.02220221","3":"0.3964555","4":"0.95534041","_rn_":"3"},{"1":"rs13078384","2":"0.63302752","3":"0.3111711","4":"0.04191740","_rn_":"4"},{"1":"rs145452708","2":"-0.19664430","3":"0.4998541","4":"0.69402157","_rn_":"5"},{"1":"rs146788033","2":"-0.51599297","3":"0.6249561","4":"0.40900448","_rn_":"6"},{"1":"rs2298755","2":"0.23519241","3":"0.3044618","4":"0.43982675","_rn_":"7"},{"1":"rs74764239","2":"-0.63995286","3":"0.8568061","4":"0.45512085","_rn_":"8"},{"1":"rs9841829","2":"0.28041734","3":"0.3376137","4":"0.40620734","_rn_":"9"},{"1":"All - Inverse variance weighted (fixed effects)","2":"0.19872633","3":"0.1033100","4":"0.05440578","_rn_":"10"},{"1":"All - Weighted median","2":"0.21374323","3":"0.1301713","4":"0.10058693","_rn_":"11"},{"1":"All - MR Egger","2":"-0.10329190","3":"0.4668534","4":"0.83121227","_rn_":"12"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>
\

Figure 3 shows a funnel plot to detect pleiotropy and Table 10 show the results of Cochrans Q heterogeneity test to assess for the presence of pleiotropy. 

<div class="figure" style="text-align: center">
<img src="/Users/sheaandrews/Dropbox/Research/PostDoc-MSSM/2_MR/4_Output/alcc_AD_MR_5e-8_Analaysis_files/figure-html/funnel_plot Ptau-1.png" alt="Fig. 3: Funnel plot of the trait – Ptau causal estimates against their precession"  />
<p class="caption">Fig. 3: Funnel plot of the trait – Ptau causal estimates against their precession</p>
</div>
<br>

**Table 10:** Heterogenity tests for Alcohol Consumption and Ptau
<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["exposure"],"name":[1],"type":["fctr"],"align":["left"]},{"label":["outcome"],"name":[2],"type":["fctr"],"align":["left"]},{"label":["method"],"name":[3],"type":["fctr"],"align":["left"]},{"label":["Q"],"name":[4],"type":["dbl"],"align":["right"]},{"label":["Q_df"],"name":[5],"type":["dbl"],"align":["right"]},{"label":["Q_pval"],"name":[6],"type":["dbl"],"align":["right"]}],"data":[{"1":"alcc","2":"ptau","3":"MR Egger","4":"4.696408","5":"7","6":"0.6969554"},{"1":"alcc","2":"ptau","3":"Inverse variance weighted","4":"5.136467","5":"8","6":"0.7428958"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

**Table 11:** Test for directional pleitropy for Alcohol Consumption and Ptau
<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["id.exposure"],"name":[1],"type":["chr"],"align":["left"]},{"label":["id.outcome"],"name":[2],"type":["chr"],"align":["left"]},{"label":["outcome"],"name":[3],"type":["fctr"],"align":["left"]},{"label":["exposure"],"name":[4],"type":["fctr"],"align":["left"]},{"label":["egger_intercept"],"name":[5],"type":["dbl"],"align":["right"]},{"label":["se"],"name":[6],"type":["dbl"],"align":["right"]},{"label":["pval"],"name":[7],"type":["dbl"],"align":["right"]}],"data":[{"1":"pvZhpK","2":"hP4xXq","3":"ptau","4":"alcc","5":"0.006951985","6":"0.01047981","7":"0.5283278"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>


### Alcohol Consumption ~ Tau

\

Figure 1 illustrates the SNP-specific associations with Alcohol Consumption versus the association between each SNP and CSF Tau levels.

<div class="figure" style="text-align: center">
<img src="/Users/sheaandrews/Dropbox/Research/PostDoc-MSSM/2_MR/4_Output/alcc_AD_MR_5e-8_Analaysis_files/figure-html/scatter_plot Tau-1.png" alt="Fig. 1: Scatterplot of SNP effects for the association of trait and Tau"  />
<p class="caption">Fig. 1: Scatterplot of SNP effects for the association of trait and Tau</p>
</div>
\

Figure 2 and Table 12 shows the SNP-specific effects and overall IVW, weighted median and Egger regression causal estimates of genetically predicted Alcohol Consumption on risk of Tau.

<div class="figure" style="text-align: center">
<img src="/Users/sheaandrews/Dropbox/Research/PostDoc-MSSM/2_MR/4_Output/alcc_AD_MR_5e-8_Analaysis_files/figure-html/forrest_plot Tau-1.png" alt="Fig. 2: Forrest plot of Wald ratios and 95% CIs for SNP-specific and overall IVW, Weighted median and Egger associations"  />
<p class="caption">Fig. 2: Forrest plot of Wald ratios and 95% CIs for SNP-specific and overall IVW, Weighted median and Egger associations</p>
</div>
<br>

**Table 12:** MR estimates for Alcohol Consumption and Tau
<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":[""],"name":["_rn_"],"type":[""],"align":["left"]},{"label":["SNP"],"name":[1],"type":["fctr"],"align":["left"]},{"label":["b"],"name":[2],"type":["dbl"],"align":["right"]},{"label":["se"],"name":[3],"type":["dbl"],"align":["right"]},{"label":["p"],"name":[4],"type":["dbl"],"align":["right"]}],"data":[{"1":"rs11940694","2":"-0.334521158","3":"0.2149592","4":"0.1196587","_rn_":"1"},{"1":"rs1260326","2":"0.072595985","3":"0.2020782","4":"0.7194103","_rn_":"2"},{"1":"rs13006480","2":"0.045037769","3":"0.4256246","4":"0.9157286","_rn_":"3"},{"1":"rs13078384","2":"0.299082569","3":"0.3304911","4":"0.3654844","_rn_":"4"},{"1":"rs145452708","2":"-0.229530201","3":"0.5427488","4":"0.6723659","_rn_":"5"},{"1":"rs146788033","2":"-1.015465729","3":"0.6506151","4":"0.1185761","_rn_":"6"},{"1":"rs2298755","2":"0.465699944","3":"0.3228667","4":"0.1491922","_rn_":"7"},{"1":"rs74764239","2":"-0.455450796","3":"0.9398939","4":"0.6279766","_rn_":"8"},{"1":"rs9841829","2":"0.297431782","3":"0.3585340","4":"0.4067776","_rn_":"9"},{"1":"All - Inverse variance weighted (fixed effects)","2":"0.007201849","3":"0.1084226","4":"0.9470404","_rn_":"10"},{"1":"All - Weighted median","2":"0.065561154","3":"0.1518767","4":"0.6659788","_rn_":"11"},{"1":"All - MR Egger","2":"-0.876149875","3":"0.4931857","4":"0.1188997","_rn_":"12"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>
\

Figure 3 shows a funnel plot to detect pleiotropy and Table 13 show the results of Cochrans Q heterogeneity test to assess for the presence of pleiotropy. 

<div class="figure" style="text-align: center">
<img src="/Users/sheaandrews/Dropbox/Research/PostDoc-MSSM/2_MR/4_Output/alcc_AD_MR_5e-8_Analaysis_files/figure-html/funnel_plot Tau-1.png" alt="Fig. 3: Funnel plot of the trait – Tau causal estimates against their precession"  />
<p class="caption">Fig. 3: Funnel plot of the trait – Tau causal estimates against their precession</p>
</div>
<br>

**Table 14:** Heterogenity tests for Alcohol Consumption and Tau
<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["exposure"],"name":[1],"type":["fctr"],"align":["left"]},{"label":["outcome"],"name":[2],"type":["fctr"],"align":["left"]},{"label":["method"],"name":[3],"type":["fctr"],"align":["left"]},{"label":["Q"],"name":[4],"type":["dbl"],"align":["right"]},{"label":["Q_df"],"name":[5],"type":["dbl"],"align":["right"]},{"label":["Q_pval"],"name":[6],"type":["dbl"],"align":["right"]}],"data":[{"1":"alcc","2":"tau","3":"MR Egger","4":"5.623956","5":"7","6":"0.5842776"},{"1":"alcc","2":"tau","3":"Inverse variance weighted","4":"8.994966","5":"8","6":"0.3427208"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

**Table 15:** Test for directional pleitropy for Alcohol Consumption and Tau
<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["id.exposure"],"name":[1],"type":["chr"],"align":["left"]},{"label":["id.outcome"],"name":[2],"type":["chr"],"align":["left"]},{"label":["outcome"],"name":[3],"type":["fctr"],"align":["left"]},{"label":["exposure"],"name":[4],"type":["fctr"],"align":["left"]},{"label":["egger_intercept"],"name":[5],"type":["dbl"],"align":["right"]},{"label":["se"],"name":[6],"type":["dbl"],"align":["right"]},{"label":["pval"],"name":[7],"type":["dbl"],"align":["right"]}],"data":[{"1":"pvZhpK","2":"psuzzi","3":"tau","4":"alcc","5":"0.02041521","6":"0.0111192","7":"0.1089774"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

### Alcohol Consumption ~ hippocampal volume

\

Figure 1 illustrates the SNP-specific associations with Alcohol Consumption versus the association between each SNP and hippocampal volume.

<div class="figure" style="text-align: center">
<img src="/Users/sheaandrews/Dropbox/Research/PostDoc-MSSM/2_MR/4_Output/alcc_AD_MR_5e-8_Analaysis_files/figure-html/scatter_plot Hipv-1.png" alt="Fig. 1: Scatterplot of SNP effects for the association of trait and hippocampal volume"  />
<p class="caption">Fig. 1: Scatterplot of SNP effects for the association of trait and hippocampal volume</p>
</div>
\

Figure 2 and Table 12 shows the SNP-specific effects and overall IVW, weighted median and Egger regression causal estimates of genetically predicted Alcohol Consumption on risk of hippocampal volume.

<div class="figure" style="text-align: center">
<img src="/Users/sheaandrews/Dropbox/Research/PostDoc-MSSM/2_MR/4_Output/alcc_AD_MR_5e-8_Analaysis_files/figure-html/forrest_plot hipv-1.png" alt="Fig. 2: Forrest plot of Wald ratios and 95% CIs for SNP-specific and overall IVW, Weighted median and Egger associations"  />
<p class="caption">Fig. 2: Forrest plot of Wald ratios and 95% CIs for SNP-specific and overall IVW, Weighted median and Egger associations</p>
</div>
<br>
  
  **Table 12:** MR estimates for Alcohol Consumption and hippocampal volume
<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":[""],"name":["_rn_"],"type":[""],"align":["left"]},{"label":["SNP"],"name":[1],"type":["fctr"],"align":["left"]},{"label":["b"],"name":[2],"type":["dbl"],"align":["right"]},{"label":["se"],"name":[3],"type":["dbl"],"align":["right"]},{"label":["p"],"name":[4],"type":["dbl"],"align":["right"]}],"data":[{"1":"rs11940694","2":"-0.23269677","3":"0.3254500","4":"0.4746090","_rn_":"1"},{"1":"rs1260326","2":"-0.16667024","3":"0.3115332","4":"0.5926499","_rn_":"2"},{"1":"rs13006480","2":"0.22868838","3":"0.6609491","4":"0.7293427","_rn_":"3"},{"1":"rs13078384","2":"-0.05747474","3":"0.4997804","4":"0.9084451","_rn_":"4"},{"1":"rs145452708","2":"-1.13055209","3":"1.0536366","4":"0.2832711","_rn_":"5"},{"1":"rs2298755","2":"-0.16748646","3":"0.4897265","4":"0.7323509","_rn_":"6"},{"1":"rs62325470","2":"-0.07942272","3":"2.1465599","4":"0.9704850","_rn_":"7"},{"1":"rs74764239","2":"1.48514716","3":"1.6266672","4":"0.3612425","_rn_":"8"},{"1":"rs9841829","2":"-0.47205073","3":"0.5482587","4":"0.3892380","_rn_":"9"},{"1":"All - Inverse variance weighted (fixed effects)","2":"-0.18167451","3":"0.1689592","4":"0.2822598","_rn_":"10"},{"1":"All - Weighted median","2":"-0.16728272","3":"0.1951901","4":"0.3914313","_rn_":"11"},{"1":"All - MR Egger","2":"-0.63517074","3":"0.7824624","4":"0.4436535","_rn_":"12"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>
\

Figure 3 shows a funnel plot to detect pleiotropy and Table 13 show the results of Cochrans Q heterogeneity test to assess for the presence of pleiotropy. 

<div class="figure" style="text-align: center">
<img src="/Users/sheaandrews/Dropbox/Research/PostDoc-MSSM/2_MR/4_Output/alcc_AD_MR_5e-8_Analaysis_files/figure-html/funnel_plot hipv-1.png" alt="Fig. 3: Funnel plot of the trait – hippocampal volume causal estimates against their precession"  />
<p class="caption">Fig. 3: Funnel plot of the trait – hippocampal volume causal estimates against their precession</p>
</div>
<br>
  
  **Table 14:** Heterogenity tests for Alcohol Consumption and hippocampal volume
<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["exposure"],"name":[1],"type":["fctr"],"align":["left"]},{"label":["outcome"],"name":[2],"type":["fctr"],"align":["left"]},{"label":["method"],"name":[3],"type":["fctr"],"align":["left"]},{"label":["Q"],"name":[4],"type":["dbl"],"align":["right"]},{"label":["Q_df"],"name":[5],"type":["dbl"],"align":["right"]},{"label":["Q_pval"],"name":[6],"type":["dbl"],"align":["right"]}],"data":[{"1":"alcc","2":"hipv","3":"MR Egger","4":"2.266430","5":"7","6":"0.9436357"},{"1":"alcc","2":"hipv","3":"Inverse variance weighted","4":"2.618766","5":"8","6":"0.9559625"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

**Table 15:** Test for directional pleitropy for Alcohol Consumption and hippocampal volume
<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["id.exposure"],"name":[1],"type":["chr"],"align":["left"]},{"label":["id.outcome"],"name":[2],"type":["chr"],"align":["left"]},{"label":["outcome"],"name":[3],"type":["fctr"],"align":["left"]},{"label":["exposure"],"name":[4],"type":["fctr"],"align":["left"]},{"label":["egger_intercept"],"name":[5],"type":["dbl"],"align":["right"]},{"label":["se"],"name":[6],"type":["dbl"],"align":["right"]},{"label":["pval"],"name":[7],"type":["dbl"],"align":["right"]}],"data":[{"1":"pvZhpK","2":"USbv2G","3":"hipv","4":"alcc","5":"0.01035765","6":"0.01744948","7":"0.5714672"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>


## MR analysis results
<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["exposure"],"name":[1],"type":["fctr"],"align":["left"]},{"label":["outcome"],"name":[2],"type":["chr"],"align":["left"]},{"label":["method"],"name":[3],"type":["chr"],"align":["left"]},{"label":["nsnp"],"name":[4],"type":["int"],"align":["right"]},{"label":["b"],"name":[5],"type":["dbl"],"align":["right"]},{"label":["se"],"name":[6],"type":["dbl"],"align":["right"]},{"label":["pval"],"name":[7],"type":["dbl"],"align":["right"]},{"label":["Signif"],"name":[8],"type":["S3: noquote"],"align":["right"]}],"data":[{"1":"alcc","2":"LOAD","3":"IVW","4":"9","5":"0.205380923","6":"0.31488475","7":"0.51424535","8":""},{"1":"alcc","2":"LOAD","3":"Weighted median","4":"9","5":"0.098040801","6":"0.43917570","7":"0.82335011","8":""},{"1":"alcc","2":"LOAD","3":"MR Egger","4":"9","5":"1.841900412","6":"1.49331785","7":"0.25722279","8":""},{"1":"alcc","2":"AAOS","3":"IVW","4":"11","5":"-0.071218887","6":"0.26229770","7":"0.78599166","8":""},{"1":"alcc","2":"AAOS","3":"Weighted median","4":"11","5":"0.025610952","6":"0.34413593","7":"0.94067537","8":""},{"1":"alcc","2":"AAOS","3":"MR Egger","4":"11","5":"0.850637221","6":"1.36698913","7":"0.54920229","8":""},{"1":"alcc","2":"ab42","3":"IVW","4":"9","5":"-0.066755935","6":"0.07760057","7":"0.38965094","8":""},{"1":"alcc","2":"ab42","3":"Weighted median","4":"9","5":"-0.036054823","6":"0.10390663","7":"0.72859695","8":""},{"1":"alcc","2":"ab42","3":"MR Egger","4":"9","5":"-0.038708419","6":"0.54426212","7":"0.94529082","8":""},{"1":"alcc","2":"ptau","3":"IVW","4":"9","5":"0.198726329","6":"0.10331003","7":"0.05440578","8":"."},{"1":"alcc","2":"ptau","3":"Weighted median","4":"9","5":"0.213743233","6":"0.13162082","7":"0.10439037","8":""},{"1":"alcc","2":"ptau","3":"MR Egger","4":"9","5":"-0.103291905","6":"0.46685336","7":"0.83121227","8":""},{"1":"alcc","2":"tau","3":"IVW","4":"9","5":"0.007201849","6":"0.10842258","7":"0.94704035","8":""},{"1":"alcc","2":"tau","3":"Weighted median","4":"9","5":"0.065561154","6":"0.14899136","7":"0.65991301","8":""},{"1":"alcc","2":"tau","3":"MR Egger","4":"9","5":"-0.876149875","6":"0.49318571","7":"0.11889975","8":""},{"1":"alcc","2":"hipv","3":"IVW","4":"9","5":"-0.181674514","6":"0.16895920","7":"0.28225981","8":""},{"1":"alcc","2":"hipv","3":"Weighted median","4":"9","5":"-0.167282725","6":"0.20269527","7":"0.40920600","8":""},{"1":"alcc","2":"hipv","3":"MR Egger","4":"9","5":"-0.635170737","6":"0.78246236","7":"0.44365351","8":""}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>
























