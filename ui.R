
library("shiny")

shinyUI(pageWithSidebar(
  
  ## Application title
  headerPanel("Gas Mileage"),
  
  ## Choose driving type(s)
  sidebarPanel(
    checkboxGroupInput("drivetype", label = h3("Driving type"),
                       choices = list("City" = "City",
                                      "Highway" = "Highway", 
                                      "Mix" = "Mix"))
  ),
  
  ## Show plot and table summarizing gas mileage
  mainPanel(
    tabsetPanel(type = "tabs", 
      tabPanel("Plot", plotOutput("mpgplot")), 
      tabPanel("Summary", tableOutput("mpgsummary"))
    )
  )
))
