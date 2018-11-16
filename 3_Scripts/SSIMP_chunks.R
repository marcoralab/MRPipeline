
## From SSIMP
uk10k.chunks.from.to <- function(ref.file = NULL, nbr.chunks = 1) ## returns "chr:pos.start-chr:pos.end"
{
  
  ## estimate the fraction each chromosome occupies
  #frac.chr <- ddply(ref.file, .(X1), function(x) nrow(x)/nrow(ref.file))
  
  ## translate the fraction into number of chunks per chromosome
  #frac.chr <- mutate(frac.chr, nbr.chunks = round(V1 * nbr.chunks))
  
  cat(nrow(ref.file), "\n")
  cat(nbr.chunks, "\n")
  
  ## build chunks
  ind <- round(seq(1, nrow(ref.file), length.out = nbr.chunks)) ## make sure its integers
  ind[length(ind)] <- nrow(ref.file)+1 ## replace by nrow, just to be sure that all pos are included from 1:nrow
  cat(paste(ind, collapse = " "), "\n")
  
  from <- ref.file[ind[-length(ind)],] %>% plyr::summarise(vector=paste(X1, X2, sep=":"))
  to <- ref.file[ind[-1]-1,] %>% plyr::summarise(vector=paste(X1, X2, sep=":")) ## chr:(pos-1)
  from.to <- paste0(c(from, recursive = TRUE), "-", c(to, recursive = TRUE))
  return(from.to) ## vector with "chr:pos.start-chr:pos.end" entries
  
}

## Load HRC files 
hrc.raw <- read_tsv('~/Dropbox/Research/Data/Summary_Statisitics/HRC/HRC_AF.tsv.gz', col_types = cols(CHROM = col_character())) %>% 
  select(CHROM, POS) %>% filter(CHROM %in% 1:22) %>% 
  rename(X1 = CHROM, X2 = POS) %>% 
  group_by(X1)

## Split by CHR
hrc.ls <- split(hrc.raw, hrc.raw$X1)

## Define chunks as 1mb
mb <- 2000000
chunks <- map(hrc.ls, function(x){
  nbr.chunks = round(as.numeric((x[nrow(x), 'X2'] - x[1, 'X2']) / mb))
  impute.range <- uk10k.chunks.from.to(ref.file=x, nbr.chunks = nbr.chunks) 
  impute.range
})


out <- paste(unlist(chunks), collapse = "', '")
write_file(out, '/Users/sheaandrews/LOAD_minerva/dummy/shea/bin/ssimp_software/chunks.txt')

ouput <- read_table2('~/Desktop/ggt_ssimp.txt')
filter(ouput, source == 'GWAS')

ggt <- read_table2('/Users/sheaandrews/LOAD_minerva/dummy/shea/bin/ssimp_software/gwas/ggt_GWAS.Processed') %>% 
  filter(!is.na(chr)) %>% 
  filter(!is.na(POS))

write_tsv(ggt, '/Users/sheaandrews/LOAD_minerva/dummy/shea/bin/ssimp_software/gwas/ggt_GWAS.Processed')

ggt %>% filter(snp == 'rs10747254')
ggt %>% count(is.na(POS))

ggt %>% filter(chr == 12 & between(POS, 44996575, 45983297)) %>% print(n = Inf)
