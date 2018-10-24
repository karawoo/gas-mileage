
library("shiny")
library("tidyverse")
library("wesanderson")
library("googlesheets")

shinyServer(function(input, output) {

  ## Download data
  sheet <- gs_url("https://docs.google.com/spreadsheets/d/1WH65aJjlmhOWYMFkhDuKPcRa5mloOtsTCKxrF7erHgI/pub?output=csv") %>%
    gs_read()

  full_dat <- sheet %>%
    filter(remove != "y" | is.na(remove)) %>%
    mutate(mpg = miles / gallons)

  ## Set ggplot2 theme
  theme_set(
    theme_minimal() +
      theme(
        axis.text = element_text(size = 14),
        axis.title = element_text(size = 16),
        legend.text = element_text(size = 14),
        legend.title = element_text(size = 16),
        plot.title = element_text(size = 18)
      )
  )
  
  ## Service dates -- not currently used
  service <- as.Date(
    c(
      "2014-06-14",
      "2014-09-20",
      "2015-01-20",
      "2015-05-06",
      "2015-07-21",
      "2016-01-15"
    )
  )
  
  ## Reactive data for plot
  dat_reac <- reactive({
    filter(full_dat, driving_type %in% input$drivetype)
  })

  ## Plot
  output$mpgplot <- renderPlot({
    ggplot(dat_reac(), aes(x = gallons, y = miles, color = driving_type)) + 
      geom_point(size = 5) + 
      scale_color_manual(
        values = wes_palette("Darjeeling", 3),
        guide_legend(title = "Driving type")
      ) +
      ggtitle("Miles per gallon") +
      ylab("Miles driven") +
      xlab("Gallons") +
      ylim(190, 420) + 
      xlim(7, 13) +
      coord_fixed(ratio = 0.015) +
      theme(legend.position = "bottom")
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
    ggplot(dat_reac(), aes(x = date, y = mpg, color = driving_type)) +
      geom_point(size = 5) +
      scale_color_manual(
        values = wes_palette("Darjeeling", 3),
        guide_legend(title = "Driving type")
      ) +
      ## geom_vline(xintercept = as.numeric(service)) +
      ggtitle("Gas mileage over time") + 
      ylab("Miles per gallon") +
      xlab("Date") +
      ylim(0, 40) +
      theme(legend.position = "bottom")
  })
})
