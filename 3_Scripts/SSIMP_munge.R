## p = allele frequency
## n = effective sample size
## z = Z score
z2se <- function(p, n, z){1/sqrt(2*p*(1-p)*(n+z^2))}


ggt <- read_table2('~/Dropbox/Research/PostDoc-MSSM/2_MR/1_RawData/GWAS/ggt_GWAS.Processed.gz') 
ggt.imp <- read_tsv('/Users/sheaandrews/LOAD_minerva/dummy/shea/bin/ssimp_software-master/output/ggt_ssimp.txt', col_names = F) %>% 
  rename(chr = X1, pos = X2, z_imp = X3, source = X4,  SNP = X5, other_allele = X6, effect_allele = X7, maf = X8, r2.pred = X9, lambda = X10, Z_reimputed = X11, r2_reimputed = X12, P.imp = X13, N.imp = X14, bst.imp = X15)


dat.imp <- ggt.imp %>% 
  filter(r2.pred > 0.3) %>% 
  filter(maf > 0.01) %>% 
  filter(nchar(effect_allele) == 1) %>%
  filter(nchar(other_allele) == 1) %>% 
  mutate(SE = z2se(maf, N.imp, z_imp)) %>% 
  mutate(Beta = z_imp*SE) %>% 
  rename(CHR = chr, POS = pos, Non_Effect_allele = other_allele, Effect_allele = effect_allele, r2 = r2.pred, N = N.imp, P = P.imp) %>% 
  left_join(select(hrc, ID, REF, ALT, AF), by = c('SNP' = 'ID')) %>% 
  mutate(EAF = findAF(Effect_allele, Non_Effect_allele, REF, ALT, AF)) %>% 
  select(SNP, CHR, POS, Effect_allele, Non_Effect_allele, maf, EAF, Beta, SE, P, r2, N, source) %>% 
  arrange(CHR, POS)
write_tsv(dat.imp, gzfile('~/Dropbox/Research/PostDoc-MSSM/2_MR/1_RawData/GWAS/ggtSSimp_GWAS.Processed.gz'))

count(dat.imp, EAF > 0.5)
count(dat.imp, maf > 0.5)
