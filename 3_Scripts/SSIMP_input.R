ggt <- read_table2('/Users/sheaandrews/LOAD_minerva/dummy/shea/bin/ssimp_software/gwas/ggt_GWAS.Processed') 
ggt.imp <- read_tsv('/Users/sheaandrews/LOAD_minerva/dummy/shea/bin/ssimp_software/output/outputfile_ggt_ssimp_fixed.txt', col_names = F) %>% 
  rename(chr = X1, pos = X2, z_imp = X3, source = X4,  SNP = X5, other_allele = X6, effect_allele = X7, maf = X8, r2.pred = X9, lambda = X10, Z_reimputed = X11, r2_reimputed = X12, P.imp = X13, N.imp = X14, bst.imp = X15)

ggt.imp %>% count(source)
ggt.imp %>% filter(source == 'SSIMP') %>% count(r2.pred > 0.3)
ggt.imp %>% filter(source == 'SSIMP') %>% filter(r2.pred > 0.3)
ggt.imp %>% filter(source == 'GWAS')

dat.imp <- ggt.imp %>% filter(source == "GWAS") %>% 
  rename(Allele1 = effect_allele, Allele2 = other_allele) %>%
  select(SNP, Allele1, Allele2, z_imp, maf, r2.pred, Z_reimputed, r2_reimputed, P.imp)
dat <- ggt %>% 
  mutate(Z = b/se) %>%
  rename(SNP = snp, Z.GWAS = Z, Allele1.GWAS = effect_allele, Allele2.GWAS=other_allele, P.GWAS = p) %>% 
  select(SNP, Z.GWAS, Allele1.GWAS, Allele2.GWAS, P.GWAS)

## merge
dat.merge <- dat.imp %>% 
  left_join(dat, by = "SNP") %>% 
  mutate(Z.GWAS = ifelse(Allele1.GWAS != Allele1 & Allele2.GWAS != Allele2, (-1) * Z.GWAS, Z.GWAS)) %>% ## we only swap the sign of the Z stats
  mutate(maf_cut = cut(maf, breaks=c(-Inf, 0.01, 0.05, 0.5), include.lowest=TRUE)) %>% 
  mutate(r2_cut = cut(r2_reimputed, breaks=c(-Inf, 0.3, 0.7, Inf), include.lowest=TRUE)) %>% 
  mutate(p_cut = ifelse(P.GWAS < 0.005, 1, 0))

write_tsv(dat.merge, '~/Dropbox/ggt_imp.txt')
dat.merge <- read_tsv(dat.merge, '~/Dropbox/ggt_imp.txt')

## Whole dataset
ggplot(dat.merge, aes(x = Z.GWAS, y = Z_reimputed, color = r2_reimputed)) + geom_point() + coord_fixed(ratio = 1) + theme_bw() + 
  geom_abline(slope = 1, intercept = 0, colour = 'red', linetype = 2)
ggsave('~/Dropbox/ggt_whole.png', device = 'png', units = 'in', width = 9, height = 5)
cor.test(dat.merge$Z.GWAS, dat.merge$Z_reimputed, method = "pearson") ## Pearson Correlation

## Split by MAF and R2
ggplot(dat.merge, aes(x = Z.GWAS, y = Z_reimputed, color = r2_reimputed)) + geom_point() + coord_fixed(ratio = 1) + 
  theme_bw() + facet_grid(r2_cut ~ maf_cut) + 
  geom_abline(slope = 1, intercept = 0, colour = 'red', linetype = 2) 
ggsave('~/Dropbox/ggt_maf_r2.png', device = 'png', units = 'in', width = 9, height = 5)

## Correlation for MAF 0.05 - 0.5 and r2 > 0.7
ggplot(test, aes(x = b, y = b_reimputed)) + geom_point() + coord_fixed(ratio = 1) + 
  theme_bw() + facet_grid(r2_cut ~ maf_cut) + 
  geom_abline(slope = 1, intercept = 0, colour = 'red', linetype = 2) 

cor.test(filter(dat.merge, maf_cut == '(0.05,0.5]' & r2_cut == '(0.7, Inf]')$Z.GWAS, filter(dat.merge, maf_cut == '(0.05,0.5]' & r2_cut == '(0.7, Inf]')$Z_reimputed, method = "pearson")
cor.test(filter(dat.merge, maf_cut == '[-Inf,0.01]' & r2_cut == '[-Inf,0.3]')$Z.GWAS, filter(dat.merge, maf_cut == '[-Inf,0.01]' & r2_cut == '[-Inf,0.3]')$Z_reimputed, method = "pearson")


## Whole dataset
dat.sig <- dat.merge %>% 
  mutate(p_cut = ifelse(P.GWAS < 5e-8, 1, 0))

ggplot(filter(dat.sig, p_cut == 1), aes(x = Z.GWAS, y = Z_reimputed, color = r2_reimputed)) + geom_point() + coord_fixed(ratio = 1) + theme_bw() + 
  geom_abline(slope = 1, intercept = 0, colour = 'red', linetype = 2) 
ggsave('~/Dropbox/ggt_sig.png', device = 'png', units = 'in', width = 9, height = 5)

ggplot(filter(dat.sig, p_cut == 0), aes(x = Z.GWAS, y = Z_reimputed, color = r2_reimputed)) + geom_point() + coord_fixed(ratio = 1) + 
  theme_bw() + facet_grid(r2_cut ~ maf_cut) + 
  geom_abline(slope = 1, intercept = 0, colour = 'red', linetype = 2) 
ggsave('~/Dropbox/ggt_maf_r2_nonsig.png', device = 'png', units = 'in', width = 9, height = 5)

with(filter(dat.sig, p_cut == 1), cor.test(Z.GWAS, Z_reimputed, method = "pearson")) ## Pearson Correlation

ggplot(filter(dat.sig, p_cut == 0), aes(x = Z.GWAS, y = Z_reimputed, color = r2_reimputed)) + geom_point() + coord_fixed(ratio = 1) + theme_bw() + 
  geom_abline(slope = 1, intercept = 0, colour = 'red', linetype = 2) 
ggsave('~/Dropbox/ggt_nonsig.png', device = 'png', units = 'in', width = 9, height = 5)
with(filter(dat.sig, p_cut == 0), cor.test(Z.GWAS, Z_reimputed, method = "pearson")) ## Pearson Correlation

ggt %>% filter(chr == 20) %>% filter(between(POS, 15500000, 15750000)) %>% write_tsv('~/LOAD_minerva/dummy/shea/bin/ssimp_software/gwas/ggt_chr20_14to18.txt')
15500000-15750000