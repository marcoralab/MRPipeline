suppressMessages(library(Hmisc))       ## Contains miscillaneous funtions
suppressMessages(library(tidyverse))

args = commandArgs(trailingOnly = TRUE) # Set arguments from the command line
summary.path = args[1] # Outcome Summary statistics
proxy.path = args[2] # prox snps
outcome.path = args[3]
out = args[4]

message("READING IN OUTCOME AND PROXY's \n")
summary.dat <- read_tsv(summary.path)
proxy.dat <- read_tsv(proxy.path)
outcome.raw <- read_tsv(outcome.path)

if(nrow(proxy.dat) >= 1){
  query_snps <- proxy.dat %>% filter(is_query_snp == 1) %>% select(query_snp_rsid, ref, alt)

  proxy.snps <- left_join(proxy.dat, summary.dat, by = c('rsID' = 'SNP')) %>% 
    filter(!is.na(Effect_allele)) %>%                 ## remove snps with missing information
    filter(is_query_snp == 0) %>%                     ## remove query snps
    group_by(query_snp_rsid) %>%                      ## by query snp
    arrange(-ld.r2) %>%                               ## arrange by ld
    slice(1) %>%                                      ## select top proxy snp
    ungroup() %>% 
    rename(Effect_allele.proxy = Effect_allele, 
           Non_Effect_allele.proxy = Non_Effect_allele) %>% 
    select(-chr, -pos_hg38, -is_query_snp) %>%              ## remove uneeded columns
    ## Join proxy snps to query snps
    left_join(query_snps, by = 'query_snp_rsid', suffix = c('.proxy', "")) %>% 
    ## for each proxy snp, coded correlated allels
    mutate(Effect_allele = ifelse(Effect_allele.proxy == ref.proxy, ref, alt)) %>%
    mutate(Non_Effect_allele = ifelse(Non_Effect_allele.proxy == ref.proxy, ref, alt)) %>% 
    rename(SNP = query_snp_rsid) 
  
  outcome.dat <- outcome.raw %>%
    filter(SNP %nin% proxy.snps$SNP) %>%
    bind_rows(select(proxy.snps, SNP, CHR, POS, Effect_allele, Non_Effect_allele, EAF, Beta, SE, P, r2, N)) %>%
    arrange(CHR, POS)
}

message("\n EXPORTING \n")
## Write out outcomes SNPs
write_tsv(outcome.dat, paste0(out, '_ProxySNPs.txt'))

## Write out Proxy SNPs
if(nrow(proxy.dat) >= 1){
  left_join(select(query_snps, query_snp_rsid), proxy.snps, 
            by = c('query_snp_rsid' = 'SNP')) %>% 
    write_csv(paste0(out, '_MatchedProxys.csv'))
}else{
  tibble(SNP = NA, rsID = NA, ld.r2 = NA, Dprime = NA, ref.proxy = NA, alt.proxy = NA, 
         CHR = NA, POS = NA, Effect_allele.proxy = NA, Non_Effect_allele.proxy = NA, 
         EAF = NA, Beta = NA, SE = NA, P = NA, r2 = NA, N = NA, ref = NA, alt = NA, 
         Effect_allele = NA, Non_Effect_allele = NA) %>% 
    write_csv(paste0(out, '_MatchedProxys.csv'))
}

