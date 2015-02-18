
library("shiny")
library("RCurl")
library("dplyr")
library("ggplot2")
library("wesanderson")

shinyServer(function(input, output) {

  ## Download data
  full_dat <- getURL("https://docs.google.com/spreadsheets/d/1WH65aJjlmhOWYMFkhDuKPcRa5mloOtsTCKxrF7erHgI/export?gid=0&format=csv") %>% 
    textConnection() %>%
    read.csv(header = TRUE) %>%
    filter(remove != "y") %>%  # remove problematic data
    mutate(date = as.Date(date, "%m/%d/%Y"), 
           mpg = miles / gallons)

  ## Reactive data for plot
  dat_reac <- reactive({
    filter(full_dat, driving_type %in% input$drivetype)
  })

  ## Plot
  output$mpgplot <- renderPlot({
    ggplot(dat_reac(), aes(x = gallons, y = miles, color = driving_type)) + 
      geom_point(size = 5) + 
      scale_color_manual(values = wes_palette("Darjeeling", 3), 
                         guide_legend(title = "Driving type")) +
      ggtitle("Miles per gallon") +
      ylab("miles driven") +
      ylim(190, 420) + 
      xlim(7, 13) +
      coord_fixed(ratio = 0.015)
  })

  ## Summary of gas mileage by driving type
  output$mpgsummary <- renderTable({
    full_dat %>%
      group_by(driving_type) %>%
      summarize(mean_mpg = mean(miles / gallons)) %>%
      arrange(desc(mean_mpg))
  })
  
  ## Gas mileage over time
  output$mpgtime <- renderPlot({
    ggplot(full_dat, aes(x = date, y = mpg, color = driving_type)) +
      geom_point(size = 5) +
      scale_color_manual(values = wes_palette("Darjeeling", 3), 
                         guide_legend(title = "Driving type")) + 
      ggtitle("Gas mileage over time") + 
      ylab("miles per gallon") +
      ylim(0, 40)
  })
})
