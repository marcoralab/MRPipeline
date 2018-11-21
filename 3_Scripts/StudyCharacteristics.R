###	Calculating the weighted means of multiple samples
#Fomula: ((N1*M1) + (N2*M2)) / (N1 + N2)


## Huang et al 2017 
### Age
((14406*74.8) + (25849*79)) / 40255

### Gender
((14406*61.7) + (25849*59.6)) / 40255

## Deming et al 2017 
### Age
deming <- tibble(cohort = c('Knight', 'ADNI1', 'ADNI2', 'BIOCARD', 'HB', 'MAYO', 'SWEDEN', 'UPENN', 'UW'),
n = c(805, 390, 397, 184, 105, 433, 293, 164, 375), 
Age = c(70.39, 77.89, 73.28, 62.10, 67.52, 78.73, 75.15, 71.60, 62.35), 
Male = c(46.09, 60, 54.91, 41.53, 54.29, 60.51, 37.54, 41.46, 50.67), 
cases = c(29.34, 71, 71, 5.43, 0, 22.17, 100, 62.8, 33.33))

### Age
sum(deming$n * deming$Age) / sum(deming$n)

### Gender
sum(deming$n * deming$Male) / sum(deming$n)

### Gender
(sum(deming$n * deming$cases) / sum(deming$n))/100 * 3146

## Beecham et al 2014 
beecham <- tibble(cohort = c('ACT', 'ADC', 'OHSU', 'MAYO', 'MBB', 'NIA-LOAD', 'ROSMAP', 'TGEN2', 'UMVUMSS1', 'UMVUMSS2', 'UP'), 
	cases = c(63, 3201, 12, 221, 50, 424, 148, 668, 54, 21, 211), 
	controls = c(116, 141, 23, 209, 60, 45, 80, 353, 1, 1, 2), 
	case_females = c(68.3, 54.3, 66.7, 49.8, 76.0, 65.1, 66.9, 64.8, 70.4, 57.1, 57.3), 
	control_female = c(75.8, 48.2, 65.2, 37.8, 46.7, 64.4, 65.0, 48.2, 0, 0, 0), 
	aao = c(84.67, 72.86, 89.50, 73.63, 78.66, 74.13, 85.12, 74.88, 71.81, 71.67, 71.01), 
	aae = c(82.96, 82.45, 89.52, 71.64, 79.08, 86.67, 84.25, 79.81, 0, 0, 0), 
	NFT4 = c(272, 2484, 35, 437, 72, 277, 321, 581, 47, 17, 192), 
	case_NP = c(202, 2388, 19, 239, 59, 173, 205, 141, 0, 0, 0),
	control_NP = c(70, 98, 19, 198, 45, 34, 119, 37, 0, 0, 0),
	case_VBI = c(142, 756, 16, 0, 24, 0, 0, 0, 0, 0, 54),
	control_VBI = c(115, 1439, 14, 0, 106, 0, 0, 0, 0, 0, 98),
	case_HS = c(17, 201, 0, 0, 0, 0, 67, 0, 0, 0, 25), 
	control_HS = c(236, 1928, 0, 0, 0, 0, 255, 0, 0, 0, 157))
	
### Age
(sum(beecham$cases * beecham$aao) + sum(beecham$controls * beecham$aae)) / (sum(beecham$cases) + sum(beecham$controls))

### Gender
(sum(beecham$cases * beecham$case_females) + sum(beecham$controls * beecham$control_female)) / (sum(beecham$cases) + sum(beecham$controls))

## Hibar 2015 

hibar2015 <- tibble(cohort = c("AddNeuroMed", "ADNI", "ADNI2GO", "Betula", "BFS", "BIG", "BrainSCALE", "BRCDECC", "EPIGEN", "GIG", "GSP", "HUBIN", "IMAGEN", "MCIC", "MooDS", "MPIP", "NCNG", "NESDA", "neuroIMAGE", "NTR - Adults", "OATS", "PAFIP ", "QTIM", "SHIP", "SHIP-TREND", "Sydney MAS", "TOP", "UMCU"), 
n = c(357, 747, 362, 353, 220, 1300, 277, 169, 233, 299, 442, 200, 1765, 170, 311, 550, 327, 231, 154, 400, 364, 117, 845, 966, 858, 543, 849, 279), 
n_females = c(204, 302, 203, 185, 115, 747, 147, 105, 138, 179, 251, 70, 895, 58, 164, 318, 223, 153, 23, 238, 238, 45, 527, 507, 477, 297, 407, 73), 
age = c("74.4 (6.4)", "75.4 (6.9)", "72.8 (7.4)", "62.3 (13.3)", "24 (7.9)", "22.9 (3.8)", "10.0 (1.3)", "49.9 (8.6)", "38.5 (12.7)", "24.2 (2.4)", "21.4 (3.2)", "41.8 (8.1)", "14.6 (0.4)", "34.0 (11.2)", "33.4 (9.8)", "48.3 (13.3)", "51.8 (16.7)", "37.8 (10.1)", "17.0 (2.5)", "29.7 (10.7)", "70.5 (5.1)", "28.4 (8.1)", "22.5 (3.2)", "56.4 (12.6)", "50.0 (13.5)", "78.4 (4.7)", "34.0 (10.4)", "31.9 (11.7)")) %>% separate(age, c('age', 'se'), sep = " ") %>% mutate(age = as.numeric(age))

### Age
sum(hibar2015$n * hibar2015$age) / sum(hibar2015$n)
### Gender
sum(hibar2015$n_females) / sum(hibar2015$n)

## Hibar 2017

hibar2017 <- tibble(
cohort = c("AddNeuroMed", "ADNI", "ADNI2GO", "Betula", "BFS", "BIG", "BrainSCALE", "BRCDECC", "EPIGEN", "GIG", "GSP", "HUBIN", "IMAGEN", "LBC1936", "MCIC", "MooDS", "MPIP", "NCNG", "NESDA", "neuroIMAGE", "NTR - Adults", "OATS", "PAFIP ", "QTIM", "SHIP", "SHIP-TREND", "Sydney MAS", "TOP", "UMCU", "3C-Dijon", "AGES", "ARIC", "ASPS", "ASPSFam", "CHS", "ERF", "FHS", "GeneSTAR", "LLS", "PROSPER", "RSI", "RSII", "RSIII", "RSIx", "ROSMAP1", "ROSMAP2"), 
n = c(357,747,362,353,220,1300,277,169,233,299,442,200,1765,612,170,311,550,327,231,154,400,364,117,845,966,858,543,849,279,1403,2510,413,172,339,648,118,938,441,355,315,939,1077,2397,432,184,106), 
n_females = c(204,302,203,185,115,747,147,105,138,179,251,70,895,289,58,164,318,223,153,23,238,238,45,527,507,477,297,407,73,882,1506,253,120,205,398,60,534,237,187,150,544,569,1333,224,138,83),
age = c("74.4 (6.4)", "75.4 (6.9)", "72.8 (7.4)", "62.3 (13.3)", "24 (7.9)", "22.9 (3.8)", "10.0 (1.3)", "49.9 (8.6)", "38.5 (12.7)", "24.2 (2.4)", "21.4 (3.2)", "41.8 (8.1)", "14.6 (0.4)", "72.7 (0.7)", "34.0 (11.2)", "33.4 (9.8)", "48.3 (13.3)", "51.8 (16.7)", "37.8 (10.1)", "17.0 (2.5)", "29.7 (10.7)", "70.5 (5.1)", "28.4 (8.1)", "22.5 (3.2)", "56.4 (12.6)", "50.0 (13.5)", "78.4 (4.7)", "34.0 (10.4)", "31.9 (11.7)", "72.2 (4.1)", "75.95 (5.30)", "72.71 (4.33)", "69.8 (6.7)", "65.2 (10.5)", "78.89 (4.2)", "64.3 (4.5)", "58.47 (8.04)", "50.9 (10.6)", "65.54 (6.65)", "75.09 (3.21)", "78.9 (4.9)", "69.4 (6.0)", "57.0 (6.3)", "72.82 (7.90)", "83.19 (6.32)", "80.56 (6.88)")
) %>% separate(age, c('age', 'se'), sep = " ") %>% mutate(age = as.numeric(age))

### Age
sum(hibar2017$n * hibar2017$age) / sum(hibar2017$n)
### Gender
sum(hibar2017$n_females) / sum(hibar2017$n)

