traits <- c('alcc', 'alcd', 'audit', 'bmi', 'cpd', 'evrsmk', 'dep', 
            'diab', 'educall', 'fish', 'hdl', 'insom', 'ldl', 
            'mdd', 'mvpa', 'sleep', 'sociso', 
            'tc', 'trig', 'dbp', 'sbp', 'pp', 'hear',
            'load', 'aaos', 'hipv')

#'ab42', 'ptau', 'tau', 
#'hipv', 'hipv2015', 
#'npany', 'nft4', 'hips', 'vbiany'

# Get upper triangle of the correlation matrix
get_upper_tri <- function(cormat){
  cormat[lower.tri(cormat)]<- NA
  return(cormat)
}

reorder_cormat <- function(cormat){
  # Use correlation between variables as distance
  dd <- as.dist((1-cormat)/2)
  hc <- hclust(dd)
  cormat <-cormat[hc$order, hc$order]
}

summary_stats <- list.files('~/Dropbox/Research/PostDoc-MSSM/2_MR/2_DerivedData/LDSC', recursive = T, pattern = '.tsv', 
                            full.names = T) %>% 
  map(., read_tsv) %>% 
  bind_rows() %>%
  filter(p1 %in% traits) %>% 
  filter(p2 %in% traits) %>% 
  mutate(rg = round(rg, 2)) %>% 
  mutate(p1 = fct_recode(p1, 
                               "Alcohol Consumption" = "alcc", 
                               "Alcohol Dependence" = "alcd", 
                               "AUDIT" = "audit", 'BMI' = "bmi", 
                               "Cigarettes per Day" = "cpd", 
                               "Ever Smoker" = "evrsmk", 
                               "Diastolic Blood Pressure" = "dbp", 
                               "Depressive Symptoms" = "dep", 
                               "Type 2 Diabetes" = "diab", 
                               "Educational Attainment" = "educ", 
                               "Educational Attainment" = "educall", 
                               "Oily Fish Intake" = "oilfish",
                               "High-density lipoproteins" = "hdl", 
                               "Hearing Problems" = "hear", 
                               "Insomnia" = "insom", 
                               "Low-density lipoproteins" = "ldl", 
                               "Major Depressive Disorder" = "mdd", 
                               "Moderate-to-vigorous PA" = "mvpa",
                               "Pulse Pressure" = "pp", 
                               "Systolic Blood Pressure" = "sbp", 
                               "Social Isolation" = "sociso", 
                               "Total Cholesterol" = "tc", 
                               "Triglycerides" = "trig", 
                               "LOAD" = "load", 
                               "AAOS" = "aaos", 
                               "CSF Ab42" = "ab42", 
                               "Hipp. Vol." = "hipv",
                               "CSF Tau" = "tau", 
                               "CSF Ptau" = "ptau")) %>% 
  mutate(p2 = fct_recode(p2, 
                               "Alcohol Consumption" = "alcc", 
                               "Alcohol Dependence" = "alcd", 
                               "AUDIT" = "audit", 'BMI' = "bmi", 
                               "Cigarettes per Day" = "cpd", 
                               "Ever Smoker" = "evrsmk", 
                               "Diastolic Blood Pressure" = "dbp", 
                               "Depressive Symptoms" = "dep", 
                               "Type 2 Diabetes" = "diab", 
                               "Educational Attainment" = "educ", 
                         "Educational Attainment" = "educall", 
                               "Oily Fish Intake" = "oilfish",
                               "High-density lipoproteins" = "hdl", 
                               "Hearing Problems" = "hear", 
                               "Insomnia" = "insom", 
                               "Low-density lipoproteins" = "ldl", 
                               "Major Depressive Disorder" = "mdd", 
                               "Moderate-to-vigorous PA" = "mvpa",
                               "Pulse Pressure" = "pp", 
                               "Systolic Blood Pressure" = "sbp", 
                               "Social Isolation" = "sociso", 
                               "Total Cholesterol" = "tc", 
                               "Triglycerides" = "trig", 
                               "LOAD" = "load", 
                               "AAOS" = "aaos", 
                               "CSF Ab42" = "ab42", 
                               "Hipp. Vol." = "hipv",
                               "CSF Tau" = "tau", 
                               "CSF Ptau" = "ptau"))


## convert to matrix
sum_mat <- summary_stats %>% 
  select(p1, p2, rg) %>% 
  spread(p2, rg) %>% 
  column_to_rownames('p1') %>% 
  as.matrix()
sum_mat[is.na(sum_mat)] <- 0

pmat <- summary_stats %>% 
  select(p1, p2, p) %>% 
  spread(p2, p) %>% 
  column_to_rownames('p1') %>% 
  as.matrix()
pmat[is.na(pmat)] <- 0


cormat <- reorder_cormat(sum_mat)
upper_tri <- get_upper_tri(cormat)
melted_cormat <- melt(upper_tri, na.rm = TRUE)

filter(summary_stats, p1 == 'hipv' ) %>% print(n = Inf)
filter(summary_stats, p1 == 'load' & p2 == 'aaos')
filter(summary_stats, p1 == 'sociso' & p2 == 'mdd')
filter(summary_stats, p1 == 'mdd' & p2 == 'evrsmk')

##=======================================+##
## basic plot

ggplot(data = summary_stats, aes(x=p1, y=p2, fill=rg)) + 
  geom_tile(color = "white") + 
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                       midpoint = 0, limit = c(-1,1), space = "Lab", 
                       name="Genetic\nCorrelation") +
  theme_minimal() + 
  theme(axis.text.x = element_text(angle = 45, vjust = 1, size = 10, hjust = 1)) +
  coord_fixed() 

## Matrix 

ggheatmap <- ggplot(melted_cormat, aes(Var2, Var1, fill = value))+
  geom_tile(color = "white")+
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                       midpoint = 0, limit = c(-1,1), space = "Lab", 
                       name="Genetic\nCorrelation") +
  theme_minimal()+ # minimal theme
  theme(axis.text.x = element_text(angle = 45, vjust = 1,  size = 10, hjust = 1)) +
  coord_fixed()
# Print the heatmap
print(ggheatmap)

ggheatmap + 
  geom_text(aes(Var2, Var1, label = value), color = "black", size = 4) +
  theme(
    axis.title.x = element_blank(),
    axis.title.y = element_blank(),
    panel.grid.major = element_blank(),
    panel.border = element_blank(),
    panel.background = element_blank(),
    axis.ticks = element_blank(),
    legend.justification = c(1, 0),
    legend.position = c(0.6, 0.7),
    legend.direction = "horizontal")+
  guides(fill = guide_colorbar(barwidth = 7, barheight = 1, title.position = "top", title.hjust = 0.5))


ggcorrplot(sum_mat, hc.order = TRUE, type = "lower",  outline.col = "white", method = "circle", insig = 'blank', p.mat = pmat)
ggsave('~/Dropbox/Research/PostDoc-MSSM/2_MR/4_Output/plots/MR/ldsc_circ.png', width = 20, height = 20, units = 'cm')
ggcorrplot(sum_mat, hc.order = TRUE, type = "lower",  outline.col = "white", lab = TRUE)
ggcorrplot(sum_mat, hc.order = TRUE, type = "lower",  outline.col = "white", insig = 'blank', p.mat = pmat) + 
  theme(text = element_text(size=10))
ggsave('~/Dropbox/Research/PostDoc-MSSM/2_MR/4_Output/plots/MR/ldsc_sig.png', width = 20, height = 20, units = 'cm')
ggcorrplot(sum_mat, hc.order = TRUE, type = "lower",  outline.col = "white", insig = 'pch') + 
  theme(text = element_text(size=10))
ggsave('~/Dropbox/Research/PostDoc-MSSM/2_MR/4_Output/plots/MR/ldsc_all.png', width = 20, height = 20, units = 'cm')



































