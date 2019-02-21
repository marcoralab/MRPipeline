library(tidyverse)
library(Hmisc)
library(TwoSampleMR)
library(gridExtra)
library(qvalue)


round_sci <- function(x){ifelse(x < 0.001, formatC(x, format = "e", digits = 2), round(x, 3))}

signif.num <- function(x) {
  symnum(x, corr = FALSE, na = FALSE, legend = FALSE,
         cutpoints = c(0, 0.001, 0.01, 0.05, 0.1, 1), 
         symbols = c("***", "**", "*", ".", " "))
}

myspread <- function(df, key, value) {
  # quote key
  keyq <- rlang::enquo(key)
  # break value vector into quotes
  valueq <- rlang::enquo(value)
  s <- rlang::quos(!!valueq)
  df %>% gather(variable, value, !!!s) %>%
    unite(temp, !!keyq, variable) %>%
    spread(temp, value)
}

## From Greenbrown package
AllEqual <- structure(function(x) {
  res <- FALSE
  x <- na.omit(as.vector(x))
  if (length(unique(x)) == 1 | length(x) == 0) res <- TRUE
  return(res)
},ex=function(){
  AllEqual(1:10)
  AllEqual(rep(0, 10))
  AllEqual(letters)
  AllEqual(rep(NA, 10))
})

passfunc <- function(ivw.p, ivw.b, mre.p, mre.b, wme.p, wme.b, wmb.p, wmb.b){
  ifelse(AllEqual(c(
    ifelse(ivw.p < 0.05, sign(ivw.b), NA), 
    ifelse(mre.p < 0.05, sign(mre.b), NA),
    ifelse(wme.p < 0.05, sign(wme.b), NA),
    ifelse(wmb.p < 0.05, sign(wmb.b), NA)
  )) == TRUE, 
  TRUE, FALSE)
}


##---------------------------------------## 
# Read in R datasets. 

outcomes = c('load', 'aaos', 'ab42', 'ptau', 'tau', 'npany', 'nft4', 'vbiany', 'hipv')
exposures = c("alccliu", "alcd", "audit", "bmi", "dbp", "dep", "diab", "educ", "hdl", "hear", "insom", "ldl", "mdd", "mvpa", "oilfish", "pp", "sbp", "sleepdoherty", "smkcpd", "smki", "sociso", "tc", "trig")

MR_results <- read_tsv('~/Dropbox/Research/PostDoc-MSSM/2_MR/2_DerivedData/Results/MR_results.txt.gz') %>% 
  filter(outcome %in% outcomes) %>% 
  filter(exposure %in% exposures) 

mrpresso_global_comb <- read_tsv('~/Dropbox/Research/PostDoc-MSSM/2_MR/2_DerivedData/Results/mrpresso_global_comb.txt.gz') %>% 
  filter(outcome %in% outcomes) %>% 
  filter(exposure %in% exposures) 

MRdat <- read_tsv('~/Dropbox/Research/PostDoc-MSSM/2_MR/2_DerivedData/Results/MR_mrpresso_MRdat.txt.gz') %>% 
  filter(outcome %in% outcomes) %>% 
  filter(exposure %in% exposures) 

egger_comb <- read_tsv('~/Dropbox/Research/PostDoc-MSSM/2_MR/2_DerivedData/Results/egger_comb.txt.gz') %>% 
  filter(outcome %in% outcomes) %>% 
  filter(exposure %in% exposures) 

##---------------------------------------## 
# Write out Harmondized Datasets

#MRdat %>% 
#  write_csv('~/Dropbox/Research/PostDoc-MSSM/2_MR/Drafts/Manuscript/TableS1.csv')


##---------------------------------------## 
# Merege datasets. 

MRsummary <- MR_results  %>% 
  mutate(method = str_replace(method, "Inverse variance weighted \\(fixed effects\\)", 'IVW')) %>%
  mutate(method = str_replace(method, "MR Egger", 'MR_Egger')) %>%
  mutate(method = str_replace(method, "Weighted median", 'Weighted_median')) %>%
  mutate(method = str_replace(method, "Weighted mode", 'Weighted_mode')) %>%
  rename(MR.pval = pval) %>%
  left_join(select(mrpresso_global_comb, outcome, exposure, pt, n_outliers, RSSobs, pval, outliers_removed), 
            by = c('outcome', 'exposure', 'pt', 'MR_PRESSO' = 'outliers_removed')) %>% 
  rename(MRPRESSO.pval = pval) %>% 
  left_join(select(egger_comb, outcome, exposure, pt, egger_intercept, egger_se, pval, outliers_removed), 
            by = c('outcome', 'exposure', 'pt', 'MR_PRESSO' = 'outliers_removed')) %>% 
  rename(Egger.pval = pval) %>% 
  select(outcome, exposure, pt, method, MR_PRESSO, nsnp, n_outliers, b, se, MR.pval, 
         RSSobs, MRPRESSO.pval, egger_intercept, egger_se, Egger.pval) %>% 
  arrange(outcome, exposure, pt, method, MR_PRESSO) 

##---------------------------------------## 
# Spread Results
## Spread Methods

mrresults.methods <- MRsummary %>% 
  mutate(b = signif(b, 2), se = signif(se, 2), MR.pval = signif(MR.pval, 2), RSSobs = round(RSSobs, 1), egger_intercept = signif(egger_intercept, 3), egger_se = signif(egger_se, 2), Egger.pval = signif(Egger.pval, 2)) %>%
  myspread(method, c(b, se, MR.pval)) %>% 
  mutate(IVW_Signif = as.character(signif.num(IVW_MR.pval))) %>% 
  mutate(MR_Egger_Signif = as.character(signif.num(MR_Egger_MR.pval))) %>% 
  mutate(Weighted_median_Signif = as.character(signif.num(Weighted_median_MR.pval))) %>%
  mutate(Weighted_mode_Signif = as.character(signif.num(Weighted_mode_MR.pval)))

## Spread MR-PRESSO
mrresults.methods_presso <- mrresults.methods %>% 
  myspread(MR_PRESSO, c(nsnp, n_outliers, RSSobs, MRPRESSO.pval, egger_intercept, egger_se, Egger.pval, IVW_b, IVW_MR.pval, IVW_se, MR_Egger_b, MR_Egger_MR.pval, MR_Egger_se, Weighted_median_b, Weighted_median_MR.pval, Weighted_median_se, Weighted_mode_b, Weighted_mode_MR.pval, Weighted_mode_se, IVW_Signif, MR_Egger_Signif, Weighted_median_Signif, Weighted_mode_Signif)) %>% 
  arrange(pt, outcome, exposure) %>% 
  mutate(outcome = fct_relevel(outcome, 'load', 'aaos', 'ab42', 'ptau', 'tau', 'npany', 'nft4', 'vbiany', 'hipv')) %>% 
  mutate(exposure = fct_relevel(exposure, 'alccliu', 'alcd', 'audit', 'smki', 'smkcpd', 'dbp', 'sbp', 'pp', "hdl", "ldl", "tc", "trig", 'educ', 'bmi', 'diab', "oilfish", "hear", "insom", "sleepdoherty", "mvpa", "dep", 'mdd', "sociso")) %>% 
  mutate(exposure = fct_recode(exposure, 
                               "Alcohol Consumption" = "alccliu", 
                               "Alcohol Dependence" = "alcd", 
                               "AUDIT" = "audit", 
                               "Smoking Initiation" = "smki", 
                               "Cigarettes per Day" = "smkcpd", 
                               "Diastolic Blood Pressure" = "dbp", 
                               "Depressive Symptoms" = "dep", 
                               'BMI' = "bmi", 
                               "Type 2 Diabetes" = "diab", 
                               "Educational Attainment" = "educ", 
                               "Oily Fish Intake" = "oilfish",
                               "High-density lipoproteins" = "hdl", 
                               "Hearing Problems" = "hear", 
                               "Insomnia Symptoms" = "insom", 
                               "Low-density lipoproteins" = "ldl", 
                               "Major Depressive Disorder" = "mdd", 
                               "Moderate-to-vigorous PA" = "mvpa",
                               "Pulse Pressure" = "pp", 
                               "Systolic Blood Pressure" = "sbp", 
                               "Social Isolation" = "sociso", 
                               "Sleep Duration" = "sleepdoherty",
                               "Total Cholesterol" = "tc", 
                               "Triglycerides" = "trig")) %>% 
  mutate(outcome = fct_recode(outcome, 
                              "LOAD" = "load", 
                              "AAOS" = "aaos", 
                              "CSF Ab42" = "ab42", 
                              "CSF Tau" = "tau", 
                              "CSF Ptau" = "ptau", 
                              "Hippocampul Volume" = "hipv",
                              "Neuritic Plaques" = "npany",
                              "Neurofibrillary Tangles" = "nft4",
                              "Vascular Brain Injury" = "vbiany")) %>%
  arrange(outcome, exposure, pt) %>% 
  select(outcome, exposure, pt, FALSE_nsnp, FALSE_n_outliers,
         FALSE_IVW_b, FALSE_IVW_se, FALSE_IVW_MR.pval, FALSE_IVW_Signif,
         FALSE_MR_Egger_b, FALSE_MR_Egger_se, FALSE_MR_Egger_MR.pval, FALSE_MR_Egger_Signif,  
         FALSE_Weighted_median_b, FALSE_Weighted_median_se, FALSE_Weighted_median_MR.pval, FALSE_Weighted_median_Signif, 
         FALSE_Weighted_mode_b, FALSE_Weighted_mode_se, FALSE_Weighted_mode_MR.pval, FALSE_Weighted_mode_Signif, 
         FALSE_RSSobs, FALSE_MRPRESSO.pval, FALSE_egger_intercept, FALSE_egger_se, FALSE_Egger.pval, 
         TRUE_IVW_b, TRUE_IVW_se, TRUE_IVW_MR.pval, TRUE_IVW_Signif, 
         TRUE_MR_Egger_b, TRUE_MR_Egger_se, TRUE_MR_Egger_MR.pval, TRUE_MR_Egger_Signif, 
         TRUE_Weighted_median_b, TRUE_Weighted_median_se, TRUE_Weighted_median_MR.pval, TRUE_Weighted_median_Signif, 
         TRUE_Weighted_mode_b, TRUE_Weighted_mode_se, TRUE_Weighted_mode_MR.pval, TRUE_Weighted_mode_Signif,
         TRUE_RSSobs, TRUE_MRPRESSO.pval, TRUE_egger_intercept, TRUE_egger_se, TRUE_Egger.pval)

#mrresults.methods_presso %>% 
#  write_csv('~/Dropbox/Research/PostDoc-MSSM/2_MR/Drafts/Manuscript/TableS2.csv')

##---------------------------------------## 
# Filter results for MR-PRESSO and best PT

mr_best <- MRsummary %>% 
  filter(method == 'IVW') %>% 
  #filter(outcome %nin% c('npany', 'nft4', 'vbiany')) %>% 
  group_by(outcome, exposure) %>% 
  filter(MR_PRESSO == ifelse(TRUE %in% MR_PRESSO, TRUE, FALSE)) %>% 
  ungroup()

qobj <- qvalue(p = mr_best$MR.pval, fdr.level = 0.1)
qvales.df <- tibble(pvalues = qobj$pvalues, lfdr = qobj$lfdr, qval = qobj$qvalues, significant = qobj$significant)

mr_best <- mr_best %>% 
  bind_cols(select(qvales.df, qval)) %>% 
  group_by(outcome, exposure) %>% 
  arrange(MR.pval) %>% 
  slice(1) %>% 
  ungroup() %>%
  mutate(Signif = symnum(qval, corr = FALSE, na = FALSE,
                         cutpoints = c(0, 0.001, 0.01, 0.05, 0.1, 1),
                         symbols = c("***", "**", "*", ".", " "))) %>% 
  mutate(Signif = as.character(Signif)) 

##---------------------------------------------##
# Tabulated Results 

# Filtering MR-PRESSO
out <- mr_best %>% 
  select(outcome, exposure, pt, MR_PRESSO, qval) %>%
  left_join(mrresults.methods, by = c('outcome', 'exposure', 'pt', 'MR_PRESSO')) %>%  
  mutate(MRPRESSO.pval_rm = as.numeric(str_replace(MRPRESSO.pval, '<', ""))) %>% 
  mutate(pass = ifelse(qval > 0.05, FALSE,
                       ifelse(MRPRESSO.pval_rm > 0.05 & Egger.pval > 0.05, TRUE,
                              ifelse(MR_Egger_MR.pval < 0.05 | Weighted_median_MR.pval < 0.05 | Weighted_mode_MR.pval < 0.05, TRUE, FALSE))))

out <- lapply(1:nrow(out), function(x){
  slice(out, x) %>%
    mutate(pass = ifelse(pass == FALSE, FALSE, passfunc(IVW_MR.pval, IVW_b, 
                                                        MR_Egger_MR.pval, MR_Egger_b, 
                                                        Weighted_median_MR.pval, Weighted_median_b, 
                                                        Weighted_mode_MR.pval, Weighted_mode_b)))
 }) %>% bind_rows(.) 

  
  
out.final <- out %>% 
  mutate(IVW = paste0(IVW_b, '\n(',IVW_se, ')')) %>% 
  mutate(`MR-Egger` = paste0(MR_Egger_b, '\n(', MR_Egger_se, ')', MR_Egger_Signif)) %>% 
  mutate(`Weighted median` = paste0(Weighted_median_b, '\n(',Weighted_median_se, ')', Weighted_median_Signif)) %>%
  mutate(`Weighted mode` = paste0(Weighted_mode_b, '\n(',Weighted_mode_se, ')', Weighted_mode_Signif)) %>%
  select(outcome, exposure, pt, nsnp, n_outliers, IVW, qval, `MR-Egger`, `Weighted median`, `Weighted mode`, MRPRESSO.pval, Egger.pval, pass) %>% 
  mutate(Egger.pval = round_sci(Egger.pval)) %>%
  mutate(qval = round_sci(qval)) %>%
  arrange(outcome, exposure) %>% 
  mutate(nsnp = nsnp + n_outliers) %>%
  mutate(outcome = fct_relevel(outcome, 'load', 'aaos', 'ab42', 'ptau', 'tau', 'npany', 'nft4', 'vbiany', 'hipv')) %>% 
  mutate(exposure = fct_relevel(exposure, 'alccliu', 'alcd', 'audit', 'smki', 'smkcpd', 'dbp', 'sbp', 'pp', "hdl", "ldl", "tc", "trig", 'educ', 'bmi', 'diab', "oilfish", "hear", "insom", "sleepdoherty", "mvpa", "dep", 'mdd', "sociso")) %>% 
  mutate(exposure = fct_recode(exposure, 
                               "Alcohol Consumption" = "alccliu", 
                               "Alcohol Dependence" = "alcd", 
                               "AUDIT" = "audit", 
                               "Smoking Initiation" = "smki", 
                               "Cigarettes per Day" = "smkcpd", 
                               "Diastolic Blood Pressure" = "dbp", 
                               "Depressive Symptoms" = "dep", 
                               'BMI' = "bmi", 
                               "Type 2 Diabetes" = "diab", 
                               "Educational Attainment" = "educ", 
                               "Oily Fish Intake" = "oilfish",
                               "High-density lipoproteins" = "hdl", 
                               "Hearing Problems" = "hear", 
                               "Insomnia Symptoms" = "insom", 
                               "Low-density lipoproteins" = "ldl", 
                               "Major Depressive Disorder" = "mdd", 
                               "Moderate-to-vigorous PA" = "mvpa",
                               "Pulse Pressure" = "pp", 
                               "Systolic Blood Pressure" = "sbp", 
                               "Social Isolation" = "sociso", 
                               "Sleep Duration" = "sleepdoherty",
                               "Total Cholesterol" = "tc", 
                               "Triglycerides" = "trig")) %>% 
  mutate(outcome = fct_recode(outcome, 
                              "LOAD" = "load", 
                              "AAOS" = "aaos", 
                              "CSF Ab42" = "ab42", 
                              "CSF Tau" = "tau", 
                              "CSF Ptau" = "ptau", 
                              "Hippocampul Volume" = "hipv",
                              "Neuritic Plaques" = "npany",
                              "Neurofibrillary Tangles" = "nft4",
                              "Vascular Brain Injury" = "vbiany")) %>% 
  #filter(qval < 0.05) %>% 
  filter(pass == TRUE) %>% arrange(outcome, exposure)

#write_csv(out.final, '~/Dropbox/Research/PostDoc-MSSM/2_MR/Drafts/Manuscript/Table_2.csv')

##---------------------------------------------##
# Writen Report 

## Generate Odds ratios
res_odds <- mr_best %>% 
  left_join(select(out, outcome, exposure, pt, MR_PRESSO, pass, MR_Egger_MR.pval, Weighted_median_MR.pval, Weighted_mode_MR.pval)) %>% 
  mutate(MRPRESSO.pval = as.numeric(str_replace(MRPRESSO.pval, '<', ""))) %>% 
  rename(pval = MR.pval) %>%
  filter(qval < 0.05) %>% 
  filter(pass == TRUE) %>%
  select(-nsnp, -n_outliers, -Signif, -pass, -RSSobs, -egger_intercept, -egger_se) %>%
  generate_odds_ratios(.) %>% 
  mutate(out = ifelse(outcome %in% c('load', 'aaos', 'npany', 'nft4', 'vbiany'), 
                      paste0(round(or, 2), ' [', round(or_lci95, 2), ', ', round(or_uci95, 2), ']'),
                      paste0(round(b, 2), ' [', round(lo_ci, 2), ', ', round(up_ci, 2), ']'))) %>% 
  print(n = Inf)

test <- res_odds %>% #filter(outcome %in% c('load', 'aaos')) %>%
  mutate(exposure = fct_relevel(exposure, 'alccliu', 'alcd', 'audit', 'smki', 'smkcpd', 'dbp', 'sbp', 'pp', "hdl", "ldl", "tc", "trig", 'educ', 'bmi', 'diab', "oilfish", "hear", "insom", "sleepdoherty", "mvpa", "dep", 'mdd', "sociso")) %>% 
  mutate(exposure = fct_recode(exposure, 
                               "alcohol consumption" = "alccliu", 
                               "alcohol dependence" = "alcd", 
                               "AUDIT" = "audit", 
                               "smoking initiation" = "smki", 
                               "cigarettes per day" = "smkcpd", 
                               "diastolic blood pressure" = "dbp", 
                               "depressive symptoms" = "dep", 
                               'BMI' = "bmi", 
                               "Type 2 Diabetes" = "diab", 
                               "educational attainment" = "educ", 
                               "oily fish intake" = "oilfish",
                               "HDL-cholesterol" = "hdl", 
                               "hearing difficulties" = "hear", 
                               "insomnia symptoms" = "insom", 
                               "LDL-cholesterol" = "ldl", 
                               "Major Depressive Disorder" = "mdd", 
                               "moderate-to-vigorous physcial activity" = "mvpa",
                               "pulse pressure" = "pp", 
                               "systolic blood pressure" = "sbp", 
                               "social isolation" = "sociso", 
                               "sleep duration" = "sleepdoherty",
                               "total cholesterol" = "tc", 
                               "triglycerides" = "trig"))


mr_senseitivy <- function(x){
  senesetivy_p <- select(x, MR_Egger_MR.pval, Weighted_median_MR.pval, Weighted_mode_MR.pval)
  y <- which(senesetivy_p <= 0.05)
  y <- str_replace(y, "1", 'MR-Egger')
  y <- str_replace(y, "2", 'Weighted median')
  y <- str_replace(y, "3", 'Weighted mode')
  
  sensetivity_out <- if(length(y) == 1){
    paste0(y,  " sensitivity analysis.")
  } else if(length(y) == 2){
    paste0(y[1], ' and ', y[2], " sensitivity analyses.")
  } else if(length(y) == 3){
    paste0(y[1], ', ', y[2], ' and ', y[3], " sensitivity analyses.")
  }
  
  with(x, if(MRPRESSO.pval > 0.05 & Egger.pval > 0.05){
    "There was no evidence of heterogeneity or directional pleiotropy."
  } else if(MRPRESSO.pval < 0.05 & Egger.pval < 0.05){
    paste0("There was evidence of heterogeneity and directional pleiotropy, however, the associations were consistent in the ", 
           sensetivity_out)
  } else if(MRPRESSO.pval < 0.05 & Egger.pval > 0.05){
    paste0("There was evidence of heterogeneity, but not of directional pleiotropy, however, the associations were consistent in the ", 
           sensetivity_out)
  } else if(MRPRESSO.pval > 0.05 & Egger.pval < 0.05){
    paste0("There was evidence of directional pleiotropy, but not of heterogeneity, however, the associations were consistent in the ", 
           sensetivity_out)
  })
}


written_res <- lapply(1:nrow(test), function(x){
  exposure_out <- test %>% slice(x)
  if(exposure_out$outcome == 'load'){
    with(exposure_out, paste0("Genetically predicted ", exposure, " was associated with significantly ", 
                              ifelse(or < 1, 'lower odds', 'increased odds'), 
                              " of Alzheimer's disease ", 
                              ifelse(MR_PRESSO == TRUE, 'after outlier removal ', ""), 
                              '(OR [CI]: ', out, "). ", mr_senseitivy(exposure_out)))
  } else if(exposure_out$outcome == 'npany'){
    with(exposure_out, paste0("Genetically predicted ", exposure, " was associated with significantly ", 
                              ifelse(or < 1, 'lower odds', 'increased odds'), 
                              " of Neuritic Plaques ", 
                              ifelse(MR_PRESSO == TRUE, 'after outlier removal ', ""), 
                              '(OR [CI]: ', out, "). ", mr_senseitivy(exposure_out)))
  } else if(exposure_out$outcome == 'nft4'){
    with(exposure_out, paste0("Genetically predicted ", exposure, " was associated with significantly ", 
                              ifelse(or < 1, 'lower odds', 'increased odds'), 
                              " of Neurofibilary Tangles ", 
                              ifelse(MR_PRESSO == TRUE, 'after outlier removal ', ""), 
                              '(OR [CI]: ', out, "). ", mr_senseitivy(exposure_out)))
  } else if(exposure_out$outcome == 'vbiany'){
    with(exposure_out, paste0("Genetically predicted ", exposure, " was associated with significantly ", 
                              ifelse(or < 1, 'lower odds', 'increased odds'), 
                              " of vascurlar brain injury ", 
                              ifelse(MR_PRESSO == TRUE, 'after outlier removal ', ""), 
                              '(OR [CI]: ', out, "). ", mr_senseitivy(exposure_out)))
  } else if(exposure_out$outcome == 'aaos'){
    with(exposure_out, paste0("Genetically predicted ", exposure, " was associated with significantly ", 
                              ifelse(or < 1, 'later', 'earlier'), 
                              " Alzheimer's age of onset ", 
                              ifelse(MR_PRESSO == TRUE, 'after outlier removal ', ""), 
                              '(HR [CI]: ', out, "). ", mr_senseitivy(exposure_out)))
  } else if(exposure_out$outcome == 'hipv'){
    with(exposure_out, paste0("Genetically predicted ", exposure, " was associated with significantly ", 
                              ifelse(b < 0, 'reduced', 'increased'), 
                              " hippocampal volume ", 
                              ifelse(MR_PRESSO == TRUE, 'after outlier removal ', ""), 
                              '(β [CI]: ', out, "). ", mr_senseitivy(exposure_out)))
  } else if(exposure_out$outcome == 'ab42'){
    with(exposure_out, paste0("Genetically predicted ", exposure, " was associated with significantly ", 
                              ifelse(b < 0, 'reduced', 'increased'), 
                              " Aβ42 ", 
                              ifelse(MR_PRESSO == TRUE, 'after outlier removal ', ""), 
                              '(β [CI]: ', out, "). ", mr_senseitivy(exposure_out)))
  } else if(exposure_out$outcome == 'ptau'){
    with(exposure_out, paste0("Genetically predicted ", exposure, " was associated with significantly ", 
                              ifelse(b < 0, 'reduced', 'increased'), 
                              " Ptau181 ", 
                              ifelse(MR_PRESSO == TRUE, 'after outlier removal ', ""), 
                              '(β [CI]: ', out, "). ", mr_senseitivy(exposure_out)))
  } else if(exposure_out$outcome == 'tau'){
    with(exposure_out, paste0("Genetically predicted ", exposure, " was associated with significantly ", 
                              ifelse(b < 0, 'reduced', 'increased'), 
                              " Tau ", 
                              ifelse(MR_PRESSO == TRUE, 'after outlier removal ', ""), 
                              '(β [CI]: ', out, "). ", mr_senseitivy(exposure_out)))
  }
  
})


##---------------------------------------## 
# Heat Maps of Best Results


dat.plot <- mr_best %>%
  mutate(z = b/se) %>% 
  mutate(outcome = fct_relevel(outcome, 'load', 'aaos', 'ab42', 'ptau', 'tau', 'npany', 'nft4', 'vbiany', 'hipv')) %>% 
  mutate(exposure = fct_relevel(exposure, 'alccliu', 'alcd', 'audit', 'smki', 'smkcpd', 'dbp', 'sbp', 'pp', "hdl", "ldl", "tc", "trig", 'educ', 'bmi', 'diab', "oilfish", "hear", "insom", "sleepdoherty", "mvpa", "dep", 'mdd', "sociso")) %>% 
  mutate(exposure = fct_recode(exposure, 
                               "Alcohol Consumption" = "alccliu", 
                               "Alcohol Dependence" = "alcd", 
                               "AUDIT" = "audit", 
                               "Smoking Initiation" = "smki", 
                               "Cigarettes per Day" = "smkcpd", 
                               "Diastolic Blood Pressure" = "dbp", 
                               "Depressive Symptoms" = "dep", 
                               'BMI' = "bmi", 
                               "Type 2 Diabetes" = "diab", 
                               "Educational Attainment" = "educ", 
                               "Oily Fish Intake" = "oilfish",
                               "High-density lipoproteins" = "hdl", 
                               "Hearing Problems" = "hear", 
                               "Insomnia Symptoms" = "insom", 
                               "Low-density lipoproteins" = "ldl", 
                               "Major Depressive Disorder" = "mdd", 
                               "Moderate-to-vigorous PA" = "mvpa",
                               "Pulse Pressure" = "pp", 
                               "Systolic Blood Pressure" = "sbp", 
                               "Social Isolation" = "sociso", 
                               "Sleep Duration" = "sleepdoherty",
                               "Total Cholesterol" = "tc", 
                               "Triglycerides" = "trig")) %>% 
  mutate(outcome = fct_recode(outcome, 
                              "LOAD" = "load", 
                              "AAOS" = "aaos", 
                              "CSF Ab42" = "ab42", 
                              "CSF Tau" = "tau", 
                              "CSF Ptau" = "ptau", 
                              "Hippocampul Volume" = "hipv",
                              "Neuritic Plaques" = "npany",
                              "Neurofibrillary Tangles" = "nft4",
                              "Vascular Brain Injury" = "vbiany")) 


frames <- mr_best %>% 
  select(outcome, exposure, pt, MR_PRESSO, qval) %>%
  left_join(mrresults.methods, by = c('outcome', 'exposure', 'pt', 'MR_PRESSO')) %>% 
  mutate(outcome = fct_relevel(outcome, 'load', 'aaos', 'ab42', 'ptau', 'tau', 'npany', 'nft4', 'vbiany', 'hipv')) %>% 
  mutate(exposure = fct_relevel(exposure, 'alccliu', 'alcd', 'audit', 'smki', 'smkcpd', 'dbp', 'sbp', 'pp', "hdl", "ldl", "tc", "trig", 'educ', 'bmi', 'diab', "oilfish", "hear", "insom", "sleepdoherty", "mvpa", "dep", 'mdd', "sociso")) %>%
  mutate(MRPRESSO.pval = as.numeric(str_replace(MRPRESSO.pval, '<', ""))) %>% 
  select(outcome, exposure, pt, MR_PRESSO, qval, MRPRESSO.pval, Egger.pval, IVW_b, IVW_MR.pval, MR_Egger_b, MR_Egger_MR.pval, Weighted_median_b, Weighted_median_MR.pval, Weighted_mode_b, Weighted_mode_MR.pval) %>% 
  mutate(pass = ifelse(qval > 0.05, FALSE,
                       ifelse(MRPRESSO.pval > 0.05 & Egger.pval > 0.05, TRUE,
                              ifelse(MR_Egger_MR.pval < 0.05 | Weighted_median_MR.pval < 0.05 | Weighted_mode_MR.pval < 0.05, TRUE, FALSE)))) %>%
  mutate(pass_0.1 = ifelse(qval > 0.1 | qval < 0.05, FALSE,
                       ifelse(MRPRESSO.pval > 0.05 & Egger.pval > 0.05, TRUE,
                              ifelse(MR_Egger_MR.pval < 0.05 | Weighted_median_MR.pval < 0.05 | Weighted_mode_MR.pval < 0.05, TRUE, FALSE)))) %>%
  mutate(outcome1 = as.integer(outcome)) %>% 
  mutate(exposure1 = as.integer(exposure))

frames <- lapply(1:nrow(frames), function(x){
  slice(frames, x) %>%
    mutate(pass = ifelse(pass == FALSE, FALSE, passfunc(IVW_MR.pval, IVW_b, 
                                                         MR_Egger_MR.pval, MR_Egger_b, 
                                                         Weighted_median_MR.pval, Weighted_median_b, 
                                                         Weighted_mode_MR.pval, Weighted_mode_b))) %>% 
    mutate(pass_0.1 = ifelse(pass_0.1 == FALSE, FALSE, passfunc(IVW_MR.pval, IVW_b, 
                                                        MR_Egger_MR.pval, MR_Egger_b, 
                                                        Weighted_median_MR.pval, Weighted_median_b, 
                                                        Weighted_mode_MR.pval, Weighted_mode_b)))
}) %>% bind_rows(.) 

x.outcome <- 'npany'
y.exposure <- 'tc'
filter(frames, outcome == x.outcome & exposure == y.exposure)
filter(mr_best, outcome == x.outcome & exposure == y.exposure)
filter(MRsummary, outcome == x.outcome & exposure == y.exposure) %>% print(n = Inf)

p1 <- ggplot(dat.plot) + 
  geom_raster(aes(x = exposure, y = outcome, fill = z)) + 
  geom_text(data = dat.plot, size = 6, aes(label = Signif, x = exposure, y = outcome)) +
  scale_fill_gradient2(low="steelblue", high="firebrick", mid = "white") + 
  coord_equal() + theme_classic() +
  geom_vline(xintercept=seq(0.5, 23.5, 1),color="white") +
  geom_hline(yintercept=seq(0.5, 11.5, 1),color="white") +
  geom_rect(data=filter(frames, pass_0.1 == TRUE), size=0.5, fill=NA, colour="orange",
            aes(xmin=exposure1 - 0.5, xmax=exposure1 + 0.5, ymin=outcome1 - 0.5, ymax=outcome1 + 0.5)) + 
  geom_rect(data=filter(frames, pass == TRUE), size=0.5, fill=NA, colour="red",
            aes(xmin=exposure1 - 0.5, xmax=exposure1 + 0.5, ymin=outcome1 - 0.5, ymax=outcome1 + 0.5)) + 
  theme(legend.position = 'none', axis.text.x = element_text(angle = 45, hjust = 1)) 
p1
ggsave('~/Dropbox/Research/PostDoc-MSSM/2_MR/Drafts/Figures/w_apoe_heatmap.pdf', plot = p1, width = 190, height =  120, units = 'mm')
ggsave('~/Dropbox/Research/PostDoc-MSSM/2_MR/Drafts/Figures/w_apoe_heatmap.png', plot = p1, width = 190, height =  120, units = 'mm')
























