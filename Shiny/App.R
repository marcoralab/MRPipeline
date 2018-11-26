library(tidyverse)   ## For data wrangling 
library(TwoSampleMR) ## For conducting MR https://mrcieu.github.io/TwoSampleMR/ 
library(RadialMR)    ## For Radial MR plots  
library(ggplot2)     ## For plotting 
library(qvalue)

# library(shiny)
# setwd('~/Dropbox/Research/PostDoc-MSSM/2_MR/Shiny/')
# runApp()

# Read in Data
## Summary Statistics
ss <- read_tsv('MR_summary_stats.txt.gz')
## Proxy SNPs
px <- read_tsv('MR_MatchedProxys.txt.gz')
## Harmonized data 
dat <- read_tsv('MR_mrpresso_MRdat.txt.gz')
## MR Results - w/ outliers
dat_res <- read_tsv('MRdat_results.txt')
## MR-PRESSO global 
mrpresso <- read_tsv('mrpresso_global.txt.gz')
## MR summary
MRsummary <- read_tsv('MR_Results_summary.txt')
## Blurbs
traits <- read_csv('~/Dropbox/Research/PostDoc-MSSM/2_MR/1_RawData/MRTraits.csv')

exposures <- c('alcc', 'alcd', 'audit', 'bmi', 'cpd', 'dep', 
                        'diab', 'educ', 'fish', 'hdl', 'insom', 'ldl', 
                        'mdd', 'mvpa', 'sleep', 'smkukbb', 'sociso', 
                        'tc', 'trig', 'dbp', 'sbp', 'pp', 'hear')

## LOAD, CSF and Neuropath
outcomes <- c('load', 'aaos', 
                       'ab42', 'ptau', 'tau', 
                       'hipv', 'hipv2015', 
                       'npany', 'nft4', 'hips', 'vbiany')

# Define UI for app that draws a histogram ----
ui <- fluidPage(
  
  # App title ----
  titlePanel("Causal Relationships in the Alzheimer's endophenome"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      
      # Input: Dropdown for exposure ----
      selectInput("exposure", label = h3("Select Exposure"), 
                  choices = list("Alcohol Consumption" = "alcc", 
                                 "Alcohol Dependence" = "alcd", 
                                 "AUDIT" = "audit", 'BMI' = "bmi", 
                                 "Cigarettes per Day" = "cpd", 
                                 "Diastolic Blood Pressure" = "dbp", 
                                 "Depressive Symptoms" = "dep", 
                                 "Type 2 Diabetes" = "diab", 
                                 "Educational Attainment" = "educ", 
                                 "Oily Fish Intake" = "fish", 
                                 "High-density lipoproteins" = "hdl", 
                                 "Hearing Problems" = "hear", 
                                 "Insomnia" = "insom", 
                                 "Low-density lipoproteins" = "ldl", 
                                 "Major Depressive Disorder" = "mdd", 
                                 "Moderate-to-vigorous PA" = "mvpa",
                                 "Pulse Pressure" = "pp", 
                                 "Systolic Blood Pressure" = "sbp", 
                                 "Sleep duration" = "sleep", 
                                 "Smoking Status" = "smkukbb", 
                                 "Social Isolation" = "sociso", 
                                 "Total Cholesterol" = "tc", 
                                 "Triglycerides" = "trig"), 
                  selected = 'alcc'),
      
      # Input: Dropdown for outcome ----
      selectInput("outcome", label = h3("Select Outcome"), 
                  choices = list("Late-Onset Alzheimer's disease" = "load", 
                                 "Alzheimer's Age of Onset" = "aaos", 
                                 "CSF Ab42" = "ab42", 
                                 "Hippocampul Sclerosis" = "hips", 
                                 "Hippocampul Volume - 2017" = "hipv",
                                 "Hippocampul Volume - 2015" = "hipv2015", 
                                 "Neurofibrillary tangles" = "nft4", 
                                 "Neuritic Plaques" = "npany", 
                                 "CSF Tau" = "tau", 
                                 "CSF Ptau" = "ptau", 
                                 "Vascular Brain Injury" = "vbiany"), 
                  selected = 'load'), 
      
      radioButtons("pt", label = h3("Pvalue Threshold"),
                   choices = list("5e-8" = 1, "5e-6" = 2), 
                   selected = 1),
      
      checkboxInput("checkbox", label = "Best Model", value = FALSE) 
      #checkboxInput("single_ex", label = "Single Exposure", value = FALSE)
      
      
    ),
    
  
    # Main panel for displaying outputs ----
    mainPanel(
      
      # Output: Tabset w/ plot, summary, and table ----
      tabsetPanel(type = "tabs",
                  tabPanel("Summary",
                           plotOutput(outputId = "mr_summaryPlot"), 
                           htmlOutput("SummaryTabText"),
                           DT::dataTableOutput("SummaryTab"), 
                           htmlOutput("SummaryTabPRESSOText"),
                           DT::dataTableOutput("SummaryPRESSOTab")),
                  tabPanel("Instruments", 
                           htmlOutput("exposure_blurb"),
                           htmlOutput("tab1"),
                           DT::dataTableOutput("exposure_instruments"), 
                           htmlOutput("outcome_blurb"),
                           htmlOutput("tab2"),
                           DT::dataTableOutput("outcome_instruments"), 
                           htmlOutput("tab3"),
                           DT::dataTableOutput("proxy_tab")),
                  tabPanel("MR analysis", 
                           htmlOutput("mr_scatterText"),
                           plotOutput(outputId = "mr_scatterPlot"), 
                           htmlOutput("mr_tabText"),
                           DT::dataTableOutput("mr_res")), 
                  tabPanel("Pleitropy", 
                           htmlOutput("mr_QText"),
                           DT::dataTableOutput("mr_Q"), 
                           htmlOutput("mr_FunnelText"),
                           plotOutput(outputId = "mr_FunnelPlot"),
                           htmlOutput("mr_RadialText"),
                           plotOutput(outputId = "mr_RadialPlot"),
                           htmlOutput("mr_EggerText"),
                           DT::dataTableOutput("mr_Egger"),
                           htmlOutput("mr_PressoGloablText"),
                           DT::dataTableOutput("mr_PressoGloabl")),
                  tabPanel("Outlier Removal", 
                           htmlOutput("mr_PressoPlotText"),
                           plotOutput("mr_PressoPlot"),
                           htmlOutput("mr_PressoTabText"),
                           DT::dataTableOutput("mr_PressoRes"),
                           htmlOutput("mrpresso_QText"),
                           DT::dataTableOutput("mrpresso_Q"),
                           htmlOutput("mrpresso_EggerText"),
                           DT::dataTableOutput("mrpresso_Egger"))
                           
      )
    )
  )
)

# Define server logic required to draw a histogram ----
server <- function(input, output) {
  
  ## Exract exposure and outcome names/blurbs
  exposure.name <- reactive({as.character(traits[grep(paste0("\\b", input$exposure, "\\b"), traits$code), 'name'])})
  exposure.blurb <- reactive({as.character(traits[grep(paste0("\\b", input$exposure, "\\b"), traits$code), 'blurb'])})
  outcome.name <- reactive({as.character(traits[grep(paste0("\\b", input$outcome, "\\b"), traits$code), 'name'])})
  outcome.blurb <- reactive({as.character(traits[grep(paste0("\\b", input$outcome, "\\b"), traits$code), 'blurb'])})
  
  ## Extract exposure - outcome data
  mrdat <- reactive({
    input_exposure <- input$exposure
    input_outcome <- input$outcome
    input_pt <- ifelse(input$pt == 1, 5e-8, 5e-6)
    dat %>% 
      filter(exposure == input_exposure) %>% 
      filter(outcome == input_outcome) %>% 
      filter(pt == input_pt)
   })
  
  ## Calculate mr results - main
  res <- reactive({
      mr(mrdat(), method_list = c("mr_ivw_fe", "mr_weighted_median", "mr_weighted_mode", "mr_egger_regression"))
  })
  
  ## Calculate mr results - main
  res_single <- reactive({ 
      mr_singlesnp(mrdat(),
                   single_method = 'mr_wald_ratio',
                   all_method=c("mr_ivw_fe", "mr_weighted_median", "mr_weighted_mode", "mr_egger_regression"))
  })
  
  res_mrpresso <- reactive({
    if(nrow(mrdat()) - sum(mrdat()$mrpresso_keep, na.rm=TRUE) >= 1){
      mrdat() %>% filter(mrpresso_keep == T) %>%
        mr(., method_list = c("mr_ivw_fe", "mr_weighted_median", "mr_weighted_mode", "mr_egger_regression"))
    }else{
      data.frame(id.exposure = as.character(mrdat()[1,'id.exposure']),
                 id.outcome = as.character(mrdat()[1,'id.outcome']), 
                 outcome = as.character(mrdat()[1,'outcome']), 
                 exposure = as.character(mrdat()[1,'exposure']),
                 method = 'mrpresso', 
                 nsnp = NA,
                 b = NA,
                 se = NA,
                 pval = NA)
    }    
    
  })
  
  output$exposure_blurb = renderText({
    HTML(paste0( tags$br(), h4(exposure.name()), exposure.blurb(), tags$br(), tags$br()))
   })
  
  output$outcome_blurb = renderText({
    HTML(paste0(tags$br(), h4(outcome.name()),outcome.blurb(), tags$br(), tags$br()))
   })
  
  ##=======================================##
  mr_best <- reactive({
    mr_best <- MRsummary %>% 
      filter(outcome %in% outcomes) %>% 
      filter(exposure %in% exposures) %>%
      filter(method == 'IVW') %>% 
      group_by(outcome, exposure) %>% 
      filter(MR_PRESSO == ifelse(TRUE %in% MR_PRESSO, TRUE, FALSE)) %>% 
      ungroup()
    
    qobj <- qvalue(p = mr_best$pval, fdr.level = 0.1)
    qvales.df <- tibble(pvalues = qobj$pvalues, lfdr = qobj$lfdr, qval = qobj$qvalues, significant = qobj$significant)
    
    mr_best <- mr_best %>% 
      bind_cols(select(qvales.df, qval)) %>% 
      group_by(outcome, exposure) %>% 
      arrange(pval) %>% 
      slice(1) %>% 
      ungroup() %>%
      rename(v.MRPRESSO = violated.MRPRESSO, v.Egger = violated.Egger, 
             v.Q.Egger = violated.Q.Egger, v.Q.IVW = violated.Q.IVW) %>%
      select(outcome, exposure, pt, MR_PRESSO, nsnp, n_outliers, b, se, pval, qval, 
             v.MRPRESSO, v.Egger, v.Q.Egger, v.Q.IVW)
    
  })
  
  ##===============================================##  
  ## Summary
  ##===============================================## 
    
  output$mr_summaryPlot <- renderPlot({
    input_outcome <- input$outcome
    input_pt <- ifelse(input$pt == 1, 5e-8, 5e-6)
    
    trans = ifelse(input_outcome %in% c('load', 'aaos', 'nft4', 'npany', 'hips', 'vbiany'), 'log2', 'identity')
    exponentiate = ifelse(input_outcome %in% c('load', 'aaos', 'nft4', 'npany', 'hips', 'vbiany'), TRUE, FALSE)
    
    if(input$checkbox == FALSE){
      res.load <- MRsummary %>% 
        filter(outcome %in% outcomes) %>% 
        filter(exposure %in% exposures) %>%
        filter(outcome == input_outcome) %>% 
        filter(MR_PRESSO == F) %>%
        filter(method == 'IVW') %>% 
        filter(pt == input_pt) %>% 
        arrange(-b) %>%
        left_join(select(traits, code, name), by = c('exposure' = 'code')) %>%
        as.data.frame()
      
      forest_plot_1_to_many(res.load,b="b",se="se",
                            exponentiate=exponentiate,ao_slc=F, by = NULL,
                            TraitM="name", 
                            col1_title="Risk factor",
                            trans=trans)
    } else {
      res.plot <- mr_best() %>% 
        filter(outcome == input_outcome) %>% 
        mutate(b = round(b, 2)) %>% 
        mutate(se = round(se, 2)) %>% 
        mutate(sig = ifelse(pval > 0.0001, round(pval, 4), format(pval, digits = 2, scientific = TRUE))) %>%
        mutate(sig = ifelse(qval < 0.05, paste0(sig, ' †'), sig)) %>% 
        left_join(select(traits, code, name), by = c('exposure' = 'code')) %>% 
        mutate(name = ifelse(MR_PRESSO == FALSE, name, paste0(name, '*'))) %>% 
        arrange(-b) %>%
        as.data.frame()
      
      forest_plot_1_to_many(res.plot,b="b",se="se",
                            exponentiate=exponentiate,ao_slc=F, by = NULL,
                            TraitM="name", col1_title="Risk factor", col1_width = 1.1,
                            trans=trans, 
                            addcols=c('pt', "nsnp", 'sig'), 
                            addcol_widths=c(0.5,0.75,0.75), addcol_titles=c("Pt", "No. SNPs","P-value"))
      
    }
    
  })
    
  output$SummaryTabText = renderUI({
   
      HTML(paste0(tags$br(), "Causal associations of modifiable risk factors with ", outcome.name()))
    
  })
  
   output$SummaryTab <- DT::renderDataTable(DT::datatable({
    input_outcome <- input$outcome
    input_pt <- ifelse(input$pt == 1, 5e-8, 5e-6)
    #input_exposure <- ifelse(input$single_ex == FALSE, input$exposure, exposures)
    input_exposure <- exposures
    
    if(input$checkbox == FALSE){
      MRsummary %>% 
        filter(outcome %in% outcomes) %>% 
        filter(exposure %in% input_exposure) %>%
        filter(outcome == input_outcome) %>% 
        filter(MR_PRESSO == FALSE) %>% 
        filter(pt == input_pt) %>% 
        mutate(b = round(b, 3)) %>% 
        mutate(se = round(se, 3)) %>% 
        mutate(pval = ifelse(pval > 0.0001, round(pval, 4), format(pval, digits = 2, scientific = TRUE))) %>%
        mutate(method = as.factor(method)) %>%
        left_join(select(traits, code, name), by = c('exposure' = 'code')) %>%
        select(-exposure, -pt, -outcome) %>% 
        rename(v.MRPRESSO = violated.MRPRESSO, v.Egger = violated.Egger, 
               v.Q.Egger = violated.Q.Egger, v.Q.IVW = violated.Q.IVW, exposure = name) %>% 
        mutate(exposure = as.factor(exposure)) %>%
        select(exposure, method, nsnp, n_outliers, b, se, pval)
    } else {
      mr_best() %>% 
        filter(outcome == input_outcome) %>% 
        filter(exposure %in% input_exposure) %>% 
        mutate(b = round(b, 3)) %>% 
        mutate(se = round(se, 3)) %>% 
        mutate(pt = ifelse(pt == 5e-6, '5e-6', '5e-8')) %>% 
        mutate(pval = ifelse(pval > 0.0001, round(pval, 4), format(pval, digits = 2, scientific = TRUE))) %>%
        left_join(select(traits, code, name), by = c('exposure' = 'code')) %>% 
        select(-exposure) %>%
        rename(exposure = name) %>% 
        mutate(exposure = as.factor(exposure)) %>% 
        select(exposure, pt, MR_PRESSO, nsnp, b, se, pval)
    }
       

  }, filter = 'top', rownames = FALSE
  ))
 
  
   output$SummaryTabPRESSOText = renderUI({
     if(input$checkbox == FALSE){
       HTML(paste0(tags$br(), "Causal associations of modifiable risk factors with ", outcome.name(), " after outlier removal"))
     }
   })
   
   output$SummaryPRESSOTab <- DT::renderDataTable(DT::datatable({
     input_outcome <- input$outcome
     input_pt <- ifelse(input$pt == 1, 5e-8, 5e-6)
     
     if(input$checkbox == FALSE){
     MRsummary %>% 
       filter(outcome %in% outcomes) %>% 
       filter(exposure %in% exposures) %>%
       filter(outcome == input_outcome) %>% 
       filter(MR_PRESSO == TRUE) %>%
       filter(pt == input_pt) %>% 
       mutate(b = round(b, 3)) %>% 
       mutate(se = round(se, 3)) %>% 
       mutate(pval = round(pval, 4)) %>% 
       mutate(exposure = as.factor(exposure)) %>%
       mutate(method = as.factor(method)) %>%
       left_join(select(traits, code, name), by = c('exposure' = 'code')) %>%
       select(-exposure, -pt, -outcome) %>% 
       rename(exposure = name) %>%
       select(exposure, method, nsnp, b, se, pval)
     }

   }, filter = 'top', rownames = FALSE
   ))
   
  ##===============================================##  
  ## Instruments
  ##===============================================## 
  
  output$tab1 = renderUI({
    HTML(paste0("Table 1: Independent SNPs associated with ", exposure.name()))
  })
  
  output$exposure_instruments <- DT::renderDataTable(DT::datatable({
    input_exposure <- input$exposure
    input_pt <- ifelse(input$pt == 1, 5e-8, 5e-6)
    ss %>% 
      filter(exposure == input_exposure) %>% 
      filter(is.na(outcome)) %>% 
      filter(pt == input_pt) %>% 
      rename(EA = Effect_allele, NEA = Non_Effect_allele) %>% 
      select(-exposure, -outcome, -pt, -r2)
  }))
  
  output$tab2 = renderUI({
    HTML(paste0("Table 2: Independent SNPs associated with ", outcome.name()))
  })
  
  output$outcome_instruments <- DT::renderDataTable(DT::datatable({
    input_exposure <- input$exposure
    input_outcome <- input$outcome
    input_pt <- ifelse(input$pt == 1, 5e-8, 5e-6)
    ss %>% 
      filter(exposure == input_exposure) %>% 
      filter(outcome == input_outcome) %>% 
      filter(pt == input_pt) %>% 
      rename(EA = Effect_allele, NEA = Non_Effect_allele) %>% 
      select(-exposure, -outcome, -pt, -r2)
  }))


  output$tab3 = renderUI({
    HTML(paste0(tags$br(), "Table 3: Proxy SNPs for ", outcome.name()))
  })
  
  output$proxy_tab <- DT::renderDataTable(DT::datatable({
    input_exposure <- input$exposure
    input_outcome <- input$outcome
    input_pt <- ifelse(input$pt == 1, 5e-8, 5e-6)
    px %>% 
      filter(exposure == input_exposure) %>% 
      filter(outcome == input_outcome) %>% 
      filter(pt == input_pt) %>% 
      rename(EA = Effect_allele, NEA = Non_Effect_allele, 
             EA.proxy = Effect_allele.proxy, NEA.proxy = Non_Effect_allele.proxy) %>% 
      select(-exposure, -outcome, -pt, -r2)
  }))
  
  
  
  ##===============================================##  
  ## MR analysis
  ##===============================================## 
  
  output$mr_tabText = renderUI({
    HTML(paste0(tags$br(), "MR causaul estimates for ", exposure.name(), ' on ', outcome.name()))
  })
  
  output$mr_res <- DT::renderDataTable(DT::datatable({
    res() %>% 
      select(-id.exposure, -id.outcome, -exposure, -outcome) %>% 
      mutate(b = round(b, 3)) %>% 
      mutate(se = round(se, 3)) %>% 
      mutate(pval = ifelse(pval > 0.0001, round(pval, 4), format(pval, digits = 2, scientific = TRUE)))
  }, options = list(paging = FALSE, searching = FALSE)))
  
  output$mr_scatterText = renderUI({
    HTML(paste0(tags$br(), "Scatterplot of SNP effects for the association of ", exposure.name(), ' on ', outcome.name()))
  })
  
  output$mr_scatterPlot <- renderPlot({
    scatter_plot <- mr_scatter_plot(res(), mrdat())
    scatter_plot[[1]] + theme_bw() + theme(legend.position = "bottom", text = element_text(family="Times", size=12)) + 
        guides(col = guide_legend(nrow = 1)) + scale_colour_discrete() +
        labs(x = paste0('SNP effect on ', exposure.name()), 
             y = paste0('SNP effect on ', outcome.name()))  
  })
  
  ##===============================================##  
  ## Pleitropy
  ##===============================================##  
  output$mr_QText = renderUI({
    HTML(paste0(tags$br(), "Cochrans Q heterogeneity test for ", exposure.name(), ' on ', outcome.name()))
  })
  
  output$mr_Q <- DT::renderDataTable(DT::datatable({
    mr_heterogeneity(mrdat(), method_list=c("mr_egger_regression", "mr_ivw")) %>% 
      select(-id.exposure, -id.outcome, -exposure, -outcome) %>% 
      mutate(Q = round(Q, 2)) %>% 
      mutate(Q_pval = ifelse(Q_pval > 0.0001, round(Q_pval, 4), format(Q_pval, digits = 2, scientific = TRUE)))
  }, options = list(paging = FALSE, searching = FALSE)))
  
  output$mr_FunnelText = renderUI({
    HTML(paste0(tags$br(), "Funnel plot of the MR causal estimates against their precession"))
  })
  
  output$mr_FunnelPlot <- renderPlot({
    funnel_plot <- mr_funnel_plot(res_single())
    funnel_plot[[1]] + theme_bw() + scale_colour_discrete() + 
      theme(legend.position = "bottom", text = element_text(family="Times", size=12))
  })
  
  output$mr_RadialText = renderUI({
    HTML(paste0(tags$br(), "Radial Plot showing influential data points using Radial IVW"))
  })
  
  output$mr_RadialPlot <- renderPlot({
    radial.dat <- mrdat() %>% filter(mr_keep == TRUE) %>%  
      with(., format_radial(beta.exposure, beta.outcome, se.exposure, se.outcome, SNP))
    radial.ivw <- ivw_radial(radial.dat, alpha = 0.05/nrow(radial.dat), weights = 1)
    plot_radial(radial.ivw, radial_scale = F)
  })
  
  
  output$mr_EggerText = renderUI({
    HTML(paste0(tags$br(), "MR Egger test for directional pleitropy"))
  })
  
  output$mr_Egger <- DT::renderDataTable(DT::datatable({
    mr_pleiotropy_test(mrdat()) %>% 
      select(-id.exposure, -id.outcome, -exposure, -outcome) %>% 
      mutate(egger_intercept = round(egger_intercept, 4)) %>% 
      mutate(se = round(se, 4)) %>% 
      mutate(pval = ifelse(pval > 0.0001, round(pval, 4), format(pval, digits = 2, scientific = TRUE)))
  }, options = list(paging = FALSE, searching = FALSE)))
  
  output$mr_PressoGloablText = renderUI({
    HTML(paste0(tags$br(), "MR-PRESSO Global Test for pleitropy"))
  })
  
  output$mr_PressoGloabl <- DT::renderDataTable(DT::datatable({
    input_exposure <- input$exposure
    input_outcome <- input$outcome
    input_pt <- ifelse(input$pt == 1, 5e-8, 5e-6)
    mrpresso %>%   
      filter(exposure == input_exposure) %>% 
      filter(outcome == input_outcome) %>% 
      filter(pt == input_pt) %>% 
      mutate(RSSobs = round(RSSobs, 4)) %>% 
      select(-id.exposure, -id.outcome, -exposure, -outcome, -pt, -violated) 

  }, options = list(paging = FALSE, searching = FALSE)))
  
  ##===============================================##  
  ## Outlier Removal
  ##===============================================##  
  
  output$mr_PressoPlotText = renderUI({
    HTML(paste0(tags$br(), "MR causaul estimates for ", exposure.name(), ' on ', outcome.name(), " after outlier removal"))
  })
  
  output$mr_PressoPlot <- renderPlot({
    mrdat_mrpresso <- mrdat() %>% filter(mrpresso_keep == T) %>% as.data.frame()
    
    if(nrow(mrdat()) - sum(mrdat()$mrpresso_keep, na.rm=TRUE) >= 1){
      scatter_plot <- mr_scatter_plot(res_mrpresso(), mrdat_mrpresso)
      scatter_plot[[1]] + theme_bw() + theme(legend.position = "bottom", text = element_text(family="Times", size=12)) + 
        guides(col = guide_legend(nrow = 1)) + scale_colour_discrete() +
        labs(x = paste0('SNP effect on ', exposure.name()), 
             y = paste0('SNP effect on ', outcome.name()))  
    }else{
      scatter_plot <- mr_scatter_plot(res_mrpresso(), mrdat_mrpresso)
      scatter_plot[[1]] + theme_bw() + 
        theme(legend.position = "none", text = element_text(family="Times", size=12)) + geom_point(alpha = 0.5) + 
        guides(col = guide_legend(nrow = 1)) + scale_colour_discrete() +
        labs(x = paste0('SNP effect on ', exposure.name()), 
             y = paste0('SNP effect on ', outcome.name()))  +
        annotation_custom(grid::grid.text("No Outliers Detected", gp=grid::gpar(col="firebrick", fontsize=36, fontface="bold")), 
                          xmin = -Inf, xmax = Inf, ymin = -Inf, ymax = Inf)
    }
  })
  
  
  output$mr_PressoTabText = renderUI({
    HTML(paste0(tags$br(), "MR causaul estimates for ", exposure.name(), ' on ', outcome.name(), " after outlier removal"))
  })
  
  output$mr_PressoRes <- DT::renderDataTable(DT::datatable({
    res_mrpresso() %>% 
      select(-id.exposure, -id.outcome, -exposure, -outcome) %>% 
      mutate(b = round(b, 3)) %>% 
      mutate(se = round(se, 3)) %>% 
      mutate(pval = ifelse(pval > 0.0001, round(pval, 4), format(pval, digits = 2, scientific = TRUE)))
  }, options = list(paging = FALSE, searching = FALSE)))
  
  output$mrpresso_QText = renderUI({
    HTML(paste0(tags$br(), "Cochrans Q heterogeneity test for ", exposure.name(), ' on ', outcome.name(), ' after outlier removal'))
  })
  
  output$mrpresso_Q <- DT::renderDataTable(DT::datatable({
    mrdat_mrpresso <- mrdat() %>% filter(mrpresso_keep == T) %>% as.data.frame()
    mr_heterogeneity(mrdat_mrpresso, method_list=c("mr_egger_regression", "mr_ivw")) %>% 
      select(-id.exposure, -id.outcome, -exposure, -outcome) %>% 
      mutate(Q = round(Q, 2)) %>% 
      mutate(Q_pval = ifelse(Q_pval > 0.0001, round(Q_pval, 4), format(Q_pval, digits = 2, scientific = TRUE)))
  }, options = list(paging = FALSE, searching = FALSE)))
 
  output$mrpresso_EggerText = renderUI({
    HTML(paste0(tags$br(), "MR Egger test for directional pleitropy after outlier removal"))
  })
  
  output$mrpresso_Egger <- DT::renderDataTable(DT::datatable({
    mrdat_mrpresso <- mrdat() %>% filter(mrpresso_keep == T) %>% as.data.frame()
    mr_pleiotropy_test(mrdat_mrpresso) %>% 
      select(-id.exposure, -id.outcome, -exposure, -outcome) %>% 
      mutate(egger_intercept = round(egger_intercept, 4)) %>% 
      mutate(se = round(se, 4)) %>% 
      mutate(pval = ifelse(pval > 0.0001, round(pval, 4), format(pval, digits = 2, scientific = TRUE)))
  }, options = list(paging = FALSE, searching = FALSE)))
  
}

shinyApp(ui, server)