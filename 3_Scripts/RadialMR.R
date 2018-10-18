library(RadialMR)
library(TwoSampleMR)
library(tidyverse)
## For testing 
exposure.code <- 'mvpa'
outcome.code <- 'load'
p.threshold <- '5e-8'

traits <- '~/LOAD_minerva/dummy/shea/Projects/2_MR/1_RawData/MRTraits.csv'

harmonized.dat <- paste0('~/Dropbox/Research/PostDoc-MSSM/2_MR/2_DerivedData/', 
                         exposure.code, '/', outcome.code, '/', 
                         exposure.code, '_', p.threshold, '_', outcome.code, '_mrpresso_MRdat.csv')

mrdat.raw <- read_csv(harmonized.dat)
mrdat <- mrdat.raw %>% filter(mr_keep == TRUE) %>% filter(mrpresso_keep == TRUE)
res.mr <- mr(mrdat, method_list = c('mr_ivw', "mr_ivw_fe", 'mr_ivw_radial',  "mr_egger_regression"))
scatter_plot <- mr_scatter_plot(res.mr, mrdat)
scatter_plot[[1]] + theme_bw() 

mrdat <- mrdat.raw %>% filter(mr_keep == TRUE)
mrdat <- mrdat.raw %>% filter(mr_keep == TRUE) %>% filter(mrpresso_keep == TRUE)
dat <- format_radial(mrdat$beta.exposure,mrdat$beta.outcome, mrdat$se.exposure, mrdat$se.outcome, mrdat$SNP)

res.ivw <- ivw_radial(dat, alpha = 0.05, weights = 1)
res.ivw <- ivw_radial(dat, alpha = 0.05/nrow(dat), weights = 1)
res.ivw$coef
count(res.ivw$data, Outliers); count(mrdat, mrpresso_keep)
plot_radial(res.ivw, radial_scale = T)
plot_radial(res.ivw, radial_scale = F)
funnel_radial(res.ivw)

res.mr.plei <- mr(filter(mrdat, SNP %nin% res.ivw$outliers$SNP), 
             method_list = c("mr_ivw_fe", "mr_weighted_median", 
                             "mr_weighted_mode", "mr_egger_regression"))


res.egger <- egger_radial(dat, alpha = 0.05/nrow(dat), weights = 1)
res.egger$coef
plot_radial(res.egger)
plot_radial(res.egger, radial_scale = T)
funnel_radial(res.egger)


plot_radial(c(res.ivw, res.egger), radial_scale = F)
