library(qvalue)
library(tidyverse)

## To pull the derived data sets from MR analysis and combine them into single dataframes
## Useful for reading into R Shiny 

## ===============================================## 
## Summary statistics for Exposure and outcome snps
summary_stats <- list.files('~/Dropbox/Research/PostDoc-MSSM/2_MR/2_DerivedData', recursive = T, pattern = '_SNPs.txt', 
           full.names = T) %>% 
  map(., function(x){
    dat.model <- tibble(file = x) %>% 
      mutate(file = str_replace(file, '/Users/sheaandrews/Dropbox/Research/PostDoc-MSSM/2_MR/2_DerivedData/', "")) %>%
      separate(file, c('exposure', 'outcome', 'file'), sep = '/', remove = F) %>% 
      mutate(file = ifelse(is.na(file), outcome, file)) %>% 
      mutate(outcome = ifelse(grepl('SNPs', outcome), NA, outcome)) %>% 
      separate(file, c('X1', 'pt', 'X2', 'X3'), sep = '_') %>% 
      select(-X1, -X2, -X3)
    datin <- read_tsv(x, col_types = list(Effect_allele = col_character(), 
                                          Non_Effect_allele = col_character())) %>% 
      mutate(exposure = dat.model$exposure) %>% 
      mutate(outcome = dat.model$outcome) %>% 
      mutate(pt = dat.model$pt)
  }) %>% 
  bind_rows() %>% 
  select(-P_GC_MA_adj, -Zscore)
write_tsv(summary_stats, gzfile('~/Dropbox/Research/PostDoc-MSSM/2_MR/Shiny/MR_summary_stats.txt.gz'))

## ===============================================## 
## Proxy SNPs for Exposure associated SNPs in Outcome
MatchedProxys <- list.files('~/Dropbox/Research/PostDoc-MSSM/2_MR/2_DerivedData', recursive = T, pattern = '_MatchedProxys.csv', 
                            full.names = T) %>% 
  map(., function(x){
    dat.model <- tibble(file = x) %>% 
      mutate(file = str_replace(file, '/Users/sheaandrews/Dropbox/Research/PostDoc-MSSM/2_MR/2_DerivedData/', "")) %>%
      separate(file, c('exposure', 'outcome', 'file'), sep = '/', remove = F) %>% 
      mutate(file = ifelse(is.na(file), outcome, file)) %>% 
      mutate(outcome = ifelse(grepl('SNPs', outcome), NA, outcome)) %>% 
      separate(file, c('X1', 'pt', 'X2', 'X3'), sep = '_') %>% 
      select(-X1, -X2, -X3)
    datin <- read_csv(x, col_types = list(Effect_allele = col_character(), 
                                          Non_Effect_allele = col_character(),
                                          ref = col_character(), 
                                          alt = col_character(),
                                          ref.proxy = col_character(), 
                                          alt.proxy = col_character(),
                                          Effect_allele.proxy = col_character(), 
                                          Zscore = col_character(),
                                          Non_Effect_allele.proxy = col_character())) %>% 
      mutate(exposure = dat.model$exposure) %>% 
      mutate(outcome = dat.model$outcome) %>% 
      mutate(pt = dat.model$pt)
  }) %>% 
  bind_rows() %>% select(-P_GC_MA_adj, -Zscore)
write_tsv(MatchedProxys, gzfile('~/Dropbox/Research/PostDoc-MSSM/2_MR/Shiny/MR_MatchedProxys.txt.gz'))

## ===============================================## 
## harmonized MR datasets with MR presso Results
mrpresso_MRdat <- list.files('~/Dropbox/Research/PostDoc-MSSM/2_MR/2_DerivedData', recursive = T, 
                             pattern = '_mrpresso_MRdat.csv', 
                            full.names = T) %>% 
  map(., function(x){
    dat.model <- tibble(file = x) %>% 
      mutate(file = str_replace(file, '/Users/sheaandrews/Dropbox/Research/PostDoc-MSSM/2_MR/2_DerivedData/', "")) %>%
      separate(file, c('exposure', 'outcome', 'file'), sep = '/', remove = F) %>% 
      mutate(file = ifelse(is.na(file), outcome, file)) %>% 
      mutate(outcome = ifelse(grepl('SNPs', outcome), NA, outcome)) %>% 
      separate(file, c('X1', 'pt', 'X2', 'X3'), sep = '_') %>% 
      select(-X1, -X2, -X3)
    datin <- read_csv(x, col_types = list(effect_allele.exposure = col_character(), 
                                          effect_allele.outcome = col_character(),
                                          mrpresso_RSSobs= col_character(), 
                                          mrpresso_pval= col_character())) %>% 
      mutate(pt = dat.model$pt)
  }) %>% 
  bind_rows()
write_tsv(mrpresso_MRdat, gzfile('~/Dropbox/Research/PostDoc-MSSM/2_MR/Shiny/MR_mrpresso_MRdat.txt.gz'))

## ===============================================## 
## MR-PRESSO Global results  
mrpresso_global <- list.files('~/Dropbox/Research/PostDoc-MSSM/2_MR/2_DerivedData', recursive = T, 
                             pattern = '_mrpresso_global.txt', 
                             full.names = T) %>% 
  map(., function(x){
    dat.model <- tibble(file = x) %>% 
      mutate(file = str_replace(file, '/Users/sheaandrews/Dropbox/Research/PostDoc-MSSM/2_MR/2_DerivedData/', "")) %>%
      separate(file, c('exposure', 'outcome', 'file'), sep = '/', remove = F) %>% 
      mutate(file = ifelse(is.na(file), outcome, file)) %>% 
      mutate(outcome = ifelse(grepl('SNPs', outcome), NA, outcome)) %>% 
      separate(file, c('X1', 'pt', 'X2', 'X3'), sep = '_') %>% 
      select(-X1, -X2, -X3)
    datin <- read_tsv(x, col_types = list(pval = col_character())) %>% 
      mutate(pt = dat.model$pt)
  }) %>% 
  bind_rows() %>% 
  mutate(violated = pval < 0.05)

write_tsv(mrpresso_global, gzfile('~/Dropbox/Research/PostDoc-MSSM/2_MR/Shiny/mrpresso_global.txt.gz'))

## ===============================================## 
## MR results - w/ outliers
MRdat_results <- list.files('~/Dropbox/Research/PostDoc-MSSM/2_MR/4_Output', recursive = T, 
                             pattern = '_MR_Results.csv', 
                             full.names = T) %>% 
  map(., function(x){
    dat.model <- tibble(file = x) %>% 
      mutate(file = str_replace(file, '/Users/sheaandrews/Dropbox/Research/PostDoc-MSSM/2_MR/4_Output/', "")) %>%
      separate(file, c('exposure', 'outcome', 'file'), sep = '/', remove = F) %>% 
      mutate(file = ifelse(is.na(file), outcome, file)) %>% 
      mutate(outcome = ifelse(grepl('SNPs', outcome), NA, outcome)) %>% 
      separate(file, c('X1', 'pt', 'X2', 'X3'), sep = '_') %>% 
      select(-X1, -X2, -X3)
    datin <- read_csv(x) %>% 
      mutate(pt = dat.model$pt)
  }) %>% 
  bind_rows()

write_tsv(MRdat_results, '~/Dropbox/Research/PostDoc-MSSM/2_MR/Shiny/MRdat_results.txt')

## ===============================================## 
## MR results - w/o outliers
MRPRESSO_results <- list.files('~/Dropbox/Research/PostDoc-MSSM/2_MR/4_Output', recursive = T, 
                            pattern = '_MRPRESSO_Results.csv', 
                            full.names = T) %>% 
  map(., function(x){
    dat.model <- tibble(file = x) %>% 
      mutate(file = str_replace(file, '/Users/sheaandrews/Dropbox/Research/PostDoc-MSSM/2_MR/4_Output/', "")) %>%
      separate(file, c('exposure', 'outcome', 'file'), sep = '/', remove = F) %>% 
      mutate(file = ifelse(is.na(file), outcome, file)) %>% 
      mutate(outcome = ifelse(grepl('SNPs', outcome), NA, outcome)) %>% 
      separate(file, c('X1', 'pt', 'X2', 'X3'), sep = '_') %>% 
      select(-X1, -X2, -X3)
    datin <- read_csv(x, col_types = list(nsnp = col_character(), b = col_character(), 
                                          se = col_character(), pval = col_character())) %>% 
      mutate(pt = dat.model$pt)
  }) %>% 
  bind_rows() %>% 
  filter(!is.na(b)) %>% 
  mutate(nsnp = as.numeric(nsnp), b = as.numeric(b), se = as.numeric(se), pval = as.numeric(pval))

write_tsv(MRPRESSO_results, '~/Dropbox/Research/PostDoc-MSSM/2_MR/Shiny/MRPRESSO_results.txt')

## ===============================================## 
## Heterogenity
heterogenity <- list.files('~/Dropbox/Research/PostDoc-MSSM/2_MR/4_Output', recursive = T, 
                            pattern = '_MR_heterogenity.csv', 
                            full.names = T) %>% 
  map(., function(x){
    dat.model <- tibble(file = x) %>% 
      mutate(file = str_replace(file, '/Users/sheaandrews/Dropbox/Research/PostDoc-MSSM/2_MR/4_Output/', "")) %>%
      separate(file, c('exposure', 'outcome', 'file'), sep = '/', remove = F) %>% 
      mutate(file = ifelse(is.na(file), outcome, file)) %>% 
      mutate(outcome = ifelse(grepl('SNPs', outcome), NA, outcome)) %>% 
      separate(file, c('X1', 'pt', 'X2', 'X3'), sep = '_') %>% 
      select(-X1, -X2, -X3)
    datin <- read_csv(x) %>% 
      mutate(pt = dat.model$pt)
  }) %>% 
  bind_rows() %>% 
  mutate(method = str_replace_all(method, c("Inverse variance weighted" = 'IVW',
                                            "MR Egger" = "Egger"))) %>% 
  select(-id.exposure, -id.outcome, -date) %>% 
  mutate(violated = Q_pval < 0.05)

het <- left_join(filter(heterogenity, method == 'Egger'), 
                 filter(heterogenity, method == 'IVW'), 
                 by = c('exposure', 'outcome', 'pt'), suffix = c('.Egger', '.IVW')) %>% 
  select(-method.Egger, -method.IVW)

## ===============================================## 
## Egger Pleitropy
egger <- list.files('~/Dropbox/Research/PostDoc-MSSM/2_MR/4_Output', recursive = T, 
                           pattern = '_MR_egger_plei.csv', 
                           full.names = T) %>% 
  map(., function(x){
    dat.model <- tibble(file = x) %>% 
      mutate(file = str_replace(file, '/Users/sheaandrews/Dropbox/Research/PostDoc-MSSM/2_MR/4_Output/', "")) %>%
      separate(file, c('exposure', 'outcome', 'file'), sep = '/', remove = F) %>% 
      mutate(file = ifelse(is.na(file), outcome, file)) %>% 
      mutate(outcome = ifelse(grepl('SNPs', outcome), NA, outcome)) %>% 
      separate(file, c('X1', 'pt', 'X2', 'X3'), sep = '_') %>% 
      select(-X1, -X2, -X3)
    datin <- read_csv(x) %>% 
      mutate(pt = dat.model$pt)
  }) %>% 
  bind_rows() %>% 
  select(exposure, outcome, pt, egger_intercept, se, pval) %>% 
  mutate(violated = pval < 0.05)

## ===============================================## 
## Mean F statistic
mf <- list.files('~/Dropbox/Research/PostDoc-MSSM/2_MR/4_Output', recursive = T, 
                    pattern = '_mean_F.csv', 
                    full.names = T) %>% 
  map(., function(x){
    dat.model <- tibble(file = x) %>% 
      mutate(file = str_replace(file, '/Users/sheaandrews/Dropbox/Research/PostDoc-MSSM/2_MR/4_Output/', "")) %>%
      separate(file, c('exposure', 'outcome', 'file'), sep = '/', remove = F) %>% 
      mutate(file = ifelse(is.na(file), outcome, file)) %>% 
      mutate(outcome = ifelse(grepl('SNPs', outcome), NA, outcome)) %>% 
      separate(file, c('X1', 'pt', 'X2', 'X3'), sep = '_') %>% 
      select(-X1, -X2, -X3)
    datin <- read_csv(x) %>% 
      mutate(pt = dat.model$pt)
  }) %>% 
  bind_rows() %>% 
  select(exposure, outcome, pt, nsnps, mean_F) 


## ===============================================## 
## Combine Results together
## ===============================================## 

MRsummary <- MRdat_results  %>% 
  mutate(MR_PRESSO = FALSE) %>% 
  bind_rows(MRPRESSO_results) %>% 
  mutate(MR_PRESSO = ifelse(is.na(MR_PRESSO), TRUE, MR_PRESSO)) %>%
  select(-id.exposure, -id.outcome, -date) %>% 
  mutate(method = str_replace(method, "Inverse variance weighted \\(fixed effects\\)", 'IVW')) %>%
  left_join(select(het, outcome, exposure, pt, violated.Egger, violated.IVW),  
            by = c('outcome', 'exposure', 'pt')) %>% 
  rename(violated.Q.Egger = violated.Egger, violated.Q.IVW = violated.IVW) %>% 
  left_join(select(mrpresso_global, outcome, exposure, pt, n_outliers, violated), 
            by = c('outcome', 'exposure', 'pt')) %>% 
  rename(violated.MRPRESSO = violated) %>% 
  left_join(select(egger, outcome, exposure, pt, violated), 
            by = c('outcome', 'exposure', 'pt')) %>% 
  rename(violated.Egger = violated) %>% 
  mutate(violated.Q.Egger = ifelse(method == 'IVW', violated.Q.Egger, NA)) %>% 
  mutate(violated.Q.IVW = ifelse(method == 'IVW', violated.Q.IVW, NA)) %>% 
  mutate(n_outliers = ifelse(method == 'IVW', n_outliers, NA)) %>% 
  mutate(violated.MRPRESSO = ifelse(method == 'IVW', violated.MRPRESSO, NA)) %>% 
  mutate(violated.Egger = ifelse(method == 'IVW', violated.Egger, NA)) %>% 
  select(outcome, exposure, pt, method, MR_PRESSO, nsnp, b, se, pval, n_outliers, 
         violated.MRPRESSO, violated.Egger, violated.Q.Egger, violated.Q.IVW) %>% 
  arrange(outcome, exposure, pt, method, MR_PRESSO)
  
write_tsv(MRsummary, '~/Dropbox/Research/PostDoc-MSSM/2_MR/Shiny/MR_Results_summary.txt')









































