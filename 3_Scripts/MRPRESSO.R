#!/usr/bin/Rscript

### ===== Command Line Arguments ===== ##
args = commandArgs(trailingOnly = TRUE) # Set arguments from the command line

infile = args[1] # Exposure summary statistics
out = args[2]

### ===== Load packages ===== ###
suppressMessages(library(tidyverse))   ## For data wrangling
suppressMessages(library(MRPRESSO)) ## For detecting pleitropy

### ===== READ IN DATA ===== ###
message("\n READING IN HARMONIZED MR DATA \n")
mrdat <- read_csv(infile)

## Data Frame of nsnps and number of iterations 
df.NbD <- data.frame(n = c(10, 50, 100, 500, 1000, 1500, 2000),
                     NbDistribution = c(1000, 5000, 10000, 25000, 50000, 75000, 100000))

nsnps <- nrow(mrdat)
NbDistribution <- df.NbD[which.min(abs(df.NbD$n - nsnps)), 2]

### ===== MR-PRESSO ===== ###
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

### ===== FORMAT DATA ===== ###
## extract RSSobs and Pvalue 
if("Global Test" %in% names(mrpresso.out$`MR-PRESSO results`)){
  mrpresso.p <- mrpresso.out$`MR-PRESSO results`$`Global Test`$Pvalue
  RSSobs <- mrpresso.out$`MR-PRESSO results`$`Global Test`$RSSobs
} else {
  mrpresso.p <- mrpresso.out$`MR-PRESSO results`$Pvalue
  RSSobs <- mrpresso.out$`MR-PRESSO results`$RSSobs
}

# Write RSSobs and Pvalue to tibble
mrpresso.dat <- tibble(id.exposure = as.character(mrdat[1,'id.exposure']), 
       id.outcome = as.character(mrdat[1,'id.outcome']), 
       outcome = as.character(mrdat[1,'outcome']), 
       exposure = as.character(mrdat[1,'exposure']) , RSSobs = RSSobs,
       pval = mrpresso.p)

## If Global test is significant, append outlier tests to mrdat
if("Outlier Test" %in% names(mrpresso.out$`MR-PRESSO results`)){
  mrdat.out <- mrdat %>% 
    bind_cols(mrpresso.out$`MR-PRESSO results`$`Outlier Test`) %>% 
    rename(mrpresso_RSSobs = RSSobs, mrpresso_pval = Pvalue) %>% 
    mutate(mrpresso_keep = mrpresso_pval > 0.05) 
} else {
  mrdat.out <- mrdat %>% 
    mutate(mrpresso_RSSobs = NA, mrpresso_pval = NA, mrpresso_keep = TRUE)
}

### ===== EXPORTING ===== ###
message("\n EXPORTING REPORTS \n")
sink(paste0(out, '.txt'), append=FALSE, split=FALSE)
mrpresso.out
sink()

write_tsv(mrpresso.dat, paste0(out, '_global.txt'))
write_csv(mrdat.out, paste0(out, '_MRdat.csv'))
