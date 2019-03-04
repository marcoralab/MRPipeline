suppressMessages(library(Hmisc))       ## Contains miscillaneous funtions
suppressMessages(library(plyr))
suppressMessages(library(tidyverse))

args = commandArgs(trailingOnly = TRUE) # Set arguments from the command line
summary.path = args[1] # Outcome Summary statistics
proxy.path = args[2] # prox snps
outcome.path = args[3]
out = args[4]

message("READING IN OUTCOME AND PROXY's \n")
summary.dat <- read_tsv(summary.path)
proxy.dat <- read_table2(proxy.path) 
outcome.raw <- read_tsv(outcome.path)

if(empty(proxy.dat)){
  message("NO PROXY SNPS AVALIABLE \n")
  outcome.dat <- outcome.raw
} else if (empty(filter(proxy.dat, SNP_A != SNP_B))){
  message("NO PROXY SNPS AVALIABLE \n")
  outcome.dat <- outcome.raw %>% filter(!is.na(CHR))
  query_snps <- proxy.dat %>%
    filter(SNP_A == SNP_B)
} else {
  message("WRANGLING TARGET AND PROXY SNPs \n")
  ## Filter Query SNPs
  query_snps <- proxy.dat %>%
    filter(SNP_A == SNP_B) %>%
    select(CHR_A, BP_A, SNP_A, PHASE)

  ## Filter Proxy SNPs
  proxy.snps <- proxy.dat %>%
    filter(SNP_A != SNP_B) %>%                        ## remove query snps
    left_join(summary.dat, by = c('SNP_B' = 'SNP')) %>%
    filter(!is.na(Effect_allele)) %>%                 ## remove snps with missing information
    group_by(SNP_A) %>%                      ## by query snp
    arrange(-R2) %>%                                  ## arrange by ld
    slice(1) %>%                                      ## select top proxy snp
    ungroup() %>%
    rename(Effect_allele.proxy = Effect_allele,
           Non_Effect_allele.proxy = Non_Effect_allele) %>%
    select(-CHR_A, -CHR_B, -BP_A, -BP_B, -MAF_A, -MAF_B, -R2, -DP)            ## remove uneeded columns

  ## Select correlated alleles
  alleles <- proxy.snps %>% select(PHASE) %>%
    mutate(PHASE = str_replace(PHASE, "/", ""))
  alleles <- str_split(alleles$PHASE, "", n = 4, simplify = T)
  colnames(alleles) <- c('ref', 'ref.proxy', 'alt', 'alt.proxy')
  alleles <- as_tibble(alleles)

  ## Bind Proxy SNPs and correlated alleles
  proxy.out <- proxy.snps %>%
    bind_cols(alleles) %>%
    rename(SNP = SNP_A) %>%
    mutate(Effect_allele = ifelse(Effect_allele.proxy == ref.proxy, ref, alt)) %>%
    mutate(Non_Effect_allele = ifelse(Non_Effect_allele.proxy == ref.proxy, ref, alt))

  ## Outcome data
  outcome.dat <- outcome.raw %>%
    filter(SNP %nin% proxy.out$SNP) %>%
    bind_rows(select(proxy.out, SNP, CHR, POS, Effect_allele, Non_Effect_allele, EAF, Beta, SE, P, r2, N)) %>%
    arrange(CHR, POS) %>%
    filter(!is.na(CHR))

}

message("\n EXPORTING \n")
## Write out outcomes SNPs
write_tsv(outcome.dat, paste0(out, '_ProxySNPs.txt'))

## Write out Proxy SNPs
if(empty(proxy.dat)){
  tibble(proxy.outcome = NA, target_snp = NA, proxy_snp = NA, ld.r2 = NA, Dprime = NA, ref.proxy = NA, alt.proxy = NA,
         CHR = NA, POS = NA, Effect_allele.proxy = NA, Non_Effect_allele.proxy = NA,
         EAF = NA, Beta = NA, SE = NA, P = NA, r2 = NA, N = NA, ref = NA, alt = NA,
         Effect_allele = NA, Non_Effect_allele = NA, PHASE = NA) %>%
    write_csv(paste0(out, '_MatchedProxys.csv'))
} else if (empty(filter(proxy.dat, SNP_A != SNP_B))){
  tibble(proxy.outcome = NA, target_snp = query_snps$SNP_A, proxy_snp = NA, ld.r2 = NA, Dprime = NA, ref.proxy = NA, alt.proxy = NA,
         CHR = NA, POS = NA, Effect_allele.proxy = NA, Non_Effect_allele.proxy = NA,
         EAF = NA, Beta = NA, SE = NA, P = NA, r2 = NA, N = NA, ref = NA, alt = NA,
         Effect_allele = NA, Non_Effect_allele = NA, PHASE = NA) %>%
    write_csv(paste0(out, '_MatchedProxys.csv'))
}else{
  proxy.dat %>%
    select(SNP_A, SNP_B, R2, DP) %>%
    inner_join(proxy.out, by = c('SNP_A' = 'SNP', 'SNP_B')) %>%
    rename(target_snp = SNP_A, proxy_snp = SNP_B, ld.r2 = R2, Dprime = DP) %>%
    mutate(proxy.outcome = TRUE) %>%
    full_join(select(query_snps, SNP_A), by = c('target_snp' = 'SNP_A')) %>%
    write_csv(paste0(out, '_MatchedProxys.csv'))
}
