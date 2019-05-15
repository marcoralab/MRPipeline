library(shiny)
library(shiny)
library(shinyauthr)
library(shinyjs)
library(sodium)

user_base <- data.frame(
  user = c("user1"),
  password = sapply(c("pass1"), sodium::password_store), 
  permissions = c("admin"),
  name = c("User One"),
  stringsAsFactors = FALSE,
  row.names = NULL
)


# Define UI for random distribution app ----
ui <- fluidPage(
  # must turn shinyjs on
  shinyjs::useShinyjs(),
  # add logout button UI 
  div(class = "pull-right", shinyauthr::logoutUI(id = "logout")),
  # add login panel UI function
  shinyauthr::loginUI(id = "login"),
  # setup table output to show user info after login
  uiOutput("testUI")
)

# Define server logic for random distribution app ----
server <- function(input, output) {
  # call the logout module with reactive trigger to hide/show
  logout_init <- callModule(shinyauthr::logout, 
                            id = "logout", 
                            active = reactive(credentials()$user_auth))
  
  # call login module supplying data frame, user and password cols
  # and reactive trigger
  credentials <- callModule(shinyauthr::login, 
                            id = "login", 
                            data = user_base,
                            user_col = user,
                            pwd_col = password,
                            log_out = reactive(logout_init()))
  
  # Reactive expression to generate the requested distribution ----
  # This is called whenever the inputs change. The output functions
  # defined below then use the value computed from this expression
  d <- reactive({
    dist <- switch(input$dist,
                   norm = rnorm,
                   unif = runif,
                   lnorm = rlnorm,
                   exp = rexp,
                   rnorm)
    
    dist(input$n)
  })
  
  # Generate a plot of the data ----
  # Also uses the inputs to build the plot label. Note that the
  # dependencies on the inputs and the data reactive expression are
  # both tracked, and all expressions are called in the sequence
  # implied by the dependency graph.
  output$plot <- renderPlot({
    dist <- input$dist
    n <- input$n
    
    hist(d(),
         main = paste("r", dist, "(", n, ")", sep = ""),
         col = "#75AADB", border = "white")
  })
  
  # Generate a summary of the data ----
  output$summary <- renderPrint({
    summary(d())
  })
  
  # Generate an HTML table view of the data ----
  output$table <- renderTable({
    d()
  })
  
  output$testUI <- renderUI({
    req(credentials()$user_auth)
    fluidPage(
    
    # App title ----
    titlePanel("Tabsets"),
    
    # Sidebar layout with input and output definitions ----
    sidebarLayout(
      
      # Sidebar panel for inputs ----
      sidebarPanel(
        
        # Input: Select the random distribution type ----
        radioButtons("dist", "Distribution type:",
                     c("Normal" = "norm",
                       "Uniform" = "unif",
                       "Log-normal" = "lnorm",
                       "Exponential" = "exp")),
        
        # br() element to introduce extra vertical spacing ----
        br(),
        
        # Input: Slider for the number of observations to generate ----
        sliderInput("n",
                    "Number of observations:",
                    value = 500,
                    min = 1,
                    max = 1000)
        
      ),
      
      # Main panel for displaying outputs ----
      mainPanel(
        
        # Output: Tabset w/ plot, summary, and table ----
        tabsetPanel(type = "tabs",
                    tabPanel("Plot", plotOutput("plot")),
                    tabPanel("Summary", verbatimTextOutput("summary")),
                    tabPanel("Table", tableOutput("table"))
        )
        
      )
    )
  )
  })
  
}

# Create Shiny app ----
shinyApp(ui, server)