#!/usr/bin/Rscript
message("Begining Harmonization \n")
### ===== Command Line Arguments ===== ##
args = commandArgs(trailingOnly = TRUE) # Set arguments from the command line

exposure.summary = args[1] # Exposure summary statistics
outcome.summary = args[2] # Outcome Summary statistics
exposure.code = args[3]
outcome.code = args[4]
proxy.snps = args[5]
out.harmonized = args[6] # SPECIFY THE OUTPUT FILE


### ===== Load packages ===== ###
suppressMessages(library(plyr))
suppressMessages(library(tidyverse))   ## For data wrangling
suppressMessages(library(TwoSampleMR)) ## For conducting MR https://mrcieu.github.io/TwoSampleMR/

### ===== Read In Data ===== ###
message("READING IN EXPOSURE \n")
exposure.dat <- read_tsv(exposure.summary)

message("READING IN OUTCOME \n")
outcome.dat <- read_tsv(outcome.summary)

message("READING IN PROXY SNPs \n")
proxy.dat <- read_csv(proxy.snps) %>%
  filter(proxy.outcome == TRUE) %>%
  select(proxy.outcome, target_snp, proxy_snp, Effect_allele, Non_Effect_allele, Effect_allele.proxy, Non_Effect_allele.proxy) %>%
  mutate(SNP = target_snp) %>%
  rename(target_snp.outcome = target_snp, proxy_snp.outcome = proxy_snp, target_a1.outcome = Effect_allele, target_a2.outcome = Non_Effect_allele, proxy_a1.outcome = Effect_allele.proxy, proxy_a2.outcome = Non_Effect_allele.proxy)


### ===== Harmonization ===== ###
message("Harmonizing Exposure and Outcome \n")
mr_exposure.dat <- format_data(exposure.dat, type = 'exposure',
                            snp_col = 'SNP',
                            beta_col = "Beta",
                            se_col = "SE",
                            eaf_col = "EAF",
                            effect_allele_col = "Effect_allele",
                            other_allele_col = "Non_Effect_allele",
                            pval_col = "P")
mr_exposure.dat <- mutate(mr_exposure.dat, exposure = exposure.code)

# Format LOAD
mr_outcome.dat <- format_data(outcome.dat, type = 'outcome',
                                 snp_col = 'SNP',
                                 beta_col = "Beta",
                                 se_col = "SE",
                                 eaf_col = "EAF",
                                 effect_allele_col = "Effect_allele",
                                 other_allele_col = "Non_Effect_allele",
                                 pval_col = "P")
mr_outcome.dat <- mutate(mr_outcome.dat, outcome = outcome.code)

if(empty(proxy.dat) == FALSE){
  mr_outcome.dat <- left_join(mr_outcome.dat, proxy.dat, by = 'SNP')
}


# harmonize LOAD
harmonized.MRdat <- harmonise_data(mr_exposure.dat, mr_outcome.dat)

## Write out Harmonized data
write_csv(harmonized.MRdat, out.harmonized)
