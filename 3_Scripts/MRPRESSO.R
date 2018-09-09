#!/usr/bin/Rscript

### ===== Command Line Arguments ===== ##
args = commandArgs(trailingOnly = TRUE) # Set arguments from the command line

infile = args[1] # Exposure summary statistics
out.txt = args[2] # SPECIFY THE OUTPUT FILE
out.rds = args[3] # SPECIFY THE OUTPUT FILE

### ===== Load packages ===== ###
suppressMessages(library(tidyverse))   ## For data wrangling
suppressMessages(library(MRPRESSO)) ## For detecting pleitropy

### ===== Proxy SNPs ===== ###
message("\n READING IN HARMONIZED MR DATA \n")
mrdat <- read_csv(infile)

## Data Frame of nsnps and number of iterations 
df.NbD <- data.frame(n = c(10, 50, 100, 500, 1000, 1500, 2000),
                     NbDistribution = c(1000, 5000, 10000, 25000, 50000, 75000, 100000))

nsnps <- nrow(mrdat)
NbDistribution <- df.NbD[which.min(abs(df.NbD$n - nsnps)), 2]

### ===== Proxy SNPs ===== ###
message("\n CALCULATING PLEITROPY \n")

mrpresso.out <- mr_presso(BetaOutcome = "beta.outcome",
                               BetaExposure = "beta.exposure",
                               SdOutcome = "se.outcome",
                               SdExposure = "se.exposure",
                               OUTLIERtest = TRUE,
                               DISTORTIONtest = TRUE,
                               data = as.data.frame(mrdat),
                               NbDistribution = NbDistribution,
                               SignifThreshold = 0.05)

### ===== EXPORTING ===== ###
message("\n EXPORTING REPORTS \n")
sink(out.txt, append=FALSE, split=FALSE)
mrpresso.out
sink()

saveRDS(mrpresso.out, file = out.rds)

