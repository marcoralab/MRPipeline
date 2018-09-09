#!/usr/bin/Rscript

### ===== Command Line Arguments ===== ##
args = commandArgs(trailingOnly = TRUE) # Set arguments from the command line

exposure.summary = args[1] # Exposure summary statistics
outcome.summary = args[2] # Outcome Summary statistics
exposure.code = args[3]
outcome.code = args[4]
out.harmonized = args[5] # SPECIFY THE OUTPUT FILE


### ===== Load packages ===== ###
suppressMessages(library(tidyverse))   ## For data wrangling
suppressMessages(library(Hmisc))       ## Contains miscillaneous funtions
suppressMessages(library(TwoSampleMR)) ## For conducting MR https://mrcieu.github.io/TwoSampleMR/

### ===== Proxy SNPs ===== ###
message("READING IN EXPOSURE \n")
exposure.dat <- read_tsv(exposure.summary)

message("READING IN OUTCOME \n")
outcome.dat <- read_tsv(outcome.summary)


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

# harmonize LOAD
harmonized.MRdat <- harmonise_data(mr_exposure.dat, mr_outcome.dat)

## Write out Harmonized data
write_csv(harmonized.MRdat, out.harmonized)











