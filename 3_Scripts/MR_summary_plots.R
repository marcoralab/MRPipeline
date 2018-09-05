library(tidyverse)
library(dotwhisker)
library(Hmisc)
path <- '/Users/sheaandrews/Dropbox/Research/PostDoc-MSSM/2_MR/2_DerivedData/'
filenames <- list.files(path, pattern="*_MR_Results.csv", recursive = T)
files.gws <- paste0(path, grep('5e-8', filenames, value = T))
files.gns <- paste0(path, grep('5e-6', filenames, value = T))

## Genome Nominal significance results 
res.gns <- map(files.gns, read_csv) %>%
  bind_rows() %>% 
  mutate(z = b/se) %>% 
  filter(exposure %nin% c( "load", "aaos", "ab42", "ptau", "tau")) %>% 
  filter(outcome %in% c( "LOAD", "AAOS", "ab42", "ptau", "tau")) %>% 
  mutate(p = '5e-6') %>%
  mutate(exposure = str_replace_all(exposure, c("alcd" = "Alcohol Dependence",
                                                        "alcc" = "Alcohol Consumption", 
                                                        "audit" = "AUDIT", 
                                                        "dep" = 'Depressive Symptoms',
                                                        'diab' = 'Type 2 Diabetes', 
                                                        'fish' = 'Oily Fish Intake', 
                                                        'hdl' = 'HDL Cholesterol', 
                                                        'ldl' = 'LDL Cholesterol', 
                                                        'tc' = 'Total Cholesterol', 
                                                        'trig' = 'Triglycerides', 
                                                        'insom' = 'Insomnia', 
                                                        'sleep' = 'Sleep Duration', 
                                                        'mdd' = 'Major Depression Disorder', 
                                                        'mvpa' = 'Moderate to Vigorous PA', 
                                                        'smkukbb' = 'Smoking Status', 
                                                        'sociso' = 'Social Isolation', 
                                                        'bmi' = 'BMI',
                                                        'educ' = 'Educational Attainment')))
 


## Genome Wide significant results 
res.gws <- map(files.gws, read_csv) %>%
  bind_rows() %>% 
  mutate(z = b/se) %>% 
  filter(exposure %nin% c( "load", "aaos", "ab42", "ptau", "tau")) %>% 
  filter(outcome %in% c( "LOAD", "AAOS", "ab42", "ptau", "tau")) %>% 
  mutate(p = '5e-8') %>%
  mutate(exposure = str_replace_all(exposure, c("alcd" = "Alcohol Dependence",
                                                        "alcc" = "Alcohol Consumption", 
                                                        "audit" = "AUDIT", 
                                                        "dep" = 'Depressive Symptoms',
                                                        'diab' = 'Type 2 Diabetes', 
                                                        'fish' = 'Oily Fish Intake', 
                                                        'hdl' = 'HDL Cholesterol', 
                                                        'ldl' = 'LDL Cholesterol', 
                                                        'tc' = 'Total Cholesterol', 
                                                        'trig' = 'Triglycerides', 
                                                        'insom' = 'Insomnia', 
                                                        'sleep' = 'Sleep Duration', 
                                                        'mdd' = 'Major Depression Disorder', 
                                                        'mvpa' = 'Moderate to Vigorous PA', 
                                                        'smkukbb' = 'Smoking Status', 
                                                        'sociso' = 'Social Isolation', 
                                                        'bmi' = 'BMI',
                                                        'educ' = 'Educational Attainment')))


## Join Results
res.all <- bind_rows(res.gns, res.gws)

## Plot LOAD results - IVW, all 
res.all %>% 
  filter(outcome == c("LOAD"), method == 'IVW') %>% 
  rename(term = exposure, estimate = b, std.error = se, p.value = pval, model = p) %>% 
  dwplot(.) + theme_bw() + geom_vline(xintercept = 0, colour = 'grey', linetype = 2)
ggsave('~/Dropbox/Research/PostDoc-MSSM/2_MR/load.png', width = 8.5, height = 4.5, units = 'in')

## Plot AAOS results - IVW, all 
res.all %>% 
  filter(outcome == c("AAOS"), method == 'IVW') %>% 
  rename(term = exposure, estimate = b, std.error = se, p.value = pval, model = p) %>% 
  dwplot(.) + theme_bw() + geom_vline(xintercept = 0, colour = 'grey', linetype = 2) 
ggsave('~/Dropbox/Research/PostDoc-MSSM/2_MR/aaos.png', width = 8.5, height = 4.5, units = 'in')
  
## Plot AB42 results - IVW, all 
res.all %>% 
  filter(outcome == c("ab42"), method == 'IVW') %>% 
  rename(term = exposure, estimate = b, std.error = se, p.value = pval, model = p) %>% 
  dwplot(.) + theme_bw() + geom_vline(xintercept = 0, colour = 'grey', linetype = 2) 
ggsave('~/Dropbox/Research/PostDoc-MSSM/2_MR/ab42.png', width = 8.5, height = 4.5, units = 'in')

## Plot Ptau results - IVW, all 
res.all %>% 
  filter(outcome == c("ptau"), method == 'IVW') %>% 
  rename(term = exposure, estimate = b, std.error = se, p.value = pval, model = p) %>% 
  dwplot(.) + theme_bw() + geom_vline(xintercept = 0, colour = 'grey', linetype = 2) 
ggsave('~/Dropbox/Research/PostDoc-MSSM/2_MR/ptau.png', width = 8.5, height = 4.5, units = 'in')

## Plot Tau results - IVW, all 
res.all %>% 
  filter(outcome == c("tau"), method == 'IVW') %>% 
  rename(term = exposure, estimate = b, std.error = se, p.value = pval, model = p) %>% 
  dwplot(.) + theme_bw() + geom_vline(xintercept = 0, colour = 'grey', linetype = 2) 
ggsave('~/Dropbox/Research/PostDoc-MSSM/2_MR/tau.png', width = 8.5, height = 4.5, units = 'in')

## Plot LOAD results with MR models 
res.gns %>% 
  filter(exposure %nin% c( "load", "aaos", "ab42", "ptau", "tau")) %>% 
  filter(outcome == c("LOAD")) %>% 
  rename(term = exposure, estimate = b, std.error = se, p.value = pval, model = method) %>% 
  dwplot(.) + theme_bw()


## Plot all IVW results - gns 
res.gns %>% 
  filter(exposure %nin% c( "load", "aaos", "ab42", "ptau", "tau")) %>% 
  filter(method == c("IVW")) %>% 
  rename(term = exposure, estimate = b, std.error = se, p.value = pval, model = outcome) %>% 
  dwplot(.) + theme_bw()

## Plot all IVW results - gws 
res.gws %>% 
  filter(exposure %nin% c( "load", "aaos", "ab42", "ptau", "tau")) %>% 
  filter(method == c("IVW")) %>% 
  rename(term = exposure, estimate = b, std.error = se, p.value = pval, model = outcome) %>% 
  dwplot(.) + theme_bw()


forest_plot_1_to_many(filter(res.gns, outcome == 'LOAD'),b="b.gns",se="se.gns",
                      exponentiate=F,ao_slc=F,Lo=-1,Up=1,
                      TraitM="outcome",width1=1.2,by=NULL,
                      trans="identity")

res.gws <- Sort.1.to.many(as.data.frame(res),b="b.gws",Sort.action=4)
forest_plot_1_to_many(filter(res.gws, outcome == 'LOAD'),b="b.gws",se="se.gws",
                      exponentiate=F,ao_slc=F,Lo=-1,Up=1,
                      TraitM="outcome",width1=1.2,by=NULL,
                      trans="identity")


ggplot(filter(res.all, method == 'IVW', p == '5e-6'), aes(x = exposure, y = outcome, size = -log10(pval), label = Signif)) + 
  geom_tile(fill = 'white', alpha = 0.5) + 
  geom_point(aes(color = z), shape = 15) +
  geom_text(size = 8) + 
  coord_equal() + 
  scale_color_gradient2(low="blue", high="red", mid = "white") + 
  geom_vline(xintercept=seq(0.5, 15.5, 1),color="#DEEBF7") +
  geom_hline(yintercept=seq(0.5, 5.5, 1),color="#DEEBF7") +
  theme_classic() + 
  scale_size(range = c(1, 15)) + 
  theme(legend.position = 'none', axis.text.x = element_text(angle = 45, hjust = 1))
ggsave('~/Dropbox/Research/PostDoc-MSSM/2_MR/gns.png', width = 8.5, height = 4.5, units = 'in')

ggplot(filter(res.all, method == 'IVW', p == '5e-8'), aes(x = exposure, y = outcome, size = -log10(pval), label = Signif)) + 
  geom_tile(fill = 'white', alpha = 0.5) + 
  geom_point(aes(color = z), shape = 15) +
  geom_text(size = 8) + 
  coord_equal() + 
  scale_color_gradient2(low="blue", high="red", mid = "white") + 
  geom_vline(xintercept=seq(0.5, 15.5, 1),color="#DEEBF7") +
  geom_hline(yintercept=seq(0.5, 5.5, 1),color="#DEEBF7") +
  theme_classic() + 
  scale_size(range = c(1, 15)) + 
  theme(legend.position = 'none', axis.text.x = element_text(angle = 45, hjust = 1))
ggsave('~/Dropbox/Research/PostDoc-MSSM/2_MR/gws.png', width = 8.5, height = 4.5, units = 'in')


















