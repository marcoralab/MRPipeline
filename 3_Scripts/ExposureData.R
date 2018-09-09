#!/usr/bin/Rscript

### ===== Command Line Arguments ===== ##
args = commandArgs(trailingOnly = TRUE) # Set arguments from the command line

exposure.summary = args[1] # Exposure summary statistics
p.threshold = args[2]
exposure.clump = args[3]
out.file = args[4] # SPECIFY THE OUTPUT FILE

### ===== Load packages ===== ###
suppressMessages(library(tidyverse))   ## For data wrangling

### ===== Read in Data ===== ###
message("READING IN EXPOSURE \n")
exposure.dat <- read_tsv(exposure.summary) %>%
  filter(P < as.numeric(p.threshold))

### ===== Clump Exposure ===== ###
message("CLUMPING EXPOSURE SNPS \n")

## Plink Pre-clumped
mr_exposure.dat_ld <- read_table2(exposure.clump) %>% 
  filter(!is.na(CHR)) %>% 
  select(CHR, F, SNP, BP, P, TOTAL, NSIG)

# Filter exposure data for clumped SNPs
exposure.dat <- exposure.dat %>% filter(SNP %in% mr_exposure.dat_ld$SNP)

### ===== Write Out Exposure ===== ###
message("Writing Out Exposure \n")

write_tsv(exposure.dat, out.file)
