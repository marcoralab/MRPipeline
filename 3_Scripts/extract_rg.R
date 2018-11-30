#!/usr/bin/Rscript

suppressMessages(library(tidyverse))

### ===== Command Line Arguments ===== ##
args = commandArgs(trailingOnly = TRUE) # Set arguments from the command line

intput = args[1] # Outcome Summary statistics
output = args[2]


dat <- read_lines(intput) 
ln <- which(str_detect(dat, "Summary of Genetic Correlation Results")) 

headers = str_split(dat[ln + 1], pattern = " ")[[1]]
headers = headers[headers != ""]

rg = str_split(dat[ln + 2], pattern = " ")[[1]]
rg = rg[rg != ""]

out <- t(as.data.frame(x = rg))
colnames(out) <- headers

out <- out %>% 
	as.tibble() %>% 
	mutate(p1 = gsub(".*/\\s*|_.*", "", p1)) %>% 
	mutate(p2 = gsub(".*/\\s*|_.*", "", p2))
	
write_tsv(out, output)	


