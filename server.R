
server <- function(input, output, session) {
  
  type <- dropdown_type_Server(id = "type")
  name <- dropdown_name_Server(id = "name", type = type)
  
  # reactive observation
  observation <- reactive(
    x = {
      ships[ship_name == name()]
    }
  )
  
  output$port <- renderText(
    expr = {
      observation()$port
    }
  )
  
  output$destination <- renderText(
    expr = {
      observation()$destination
    }
  )
  
  output$flag <- renderUI(
    expr = {
      flag <- tolower(observation()$flag)
      tags$i(class = paste(flag, "flag"))
    }
  )
  
  output$map <- renderLeaflet(
    expr = {
      
      icon_start <- makeAwesomeIcon(
        icon= 'flag', 
        markerColor = 'green',
        library= 'fa',
        iconColor = 'white'
      )
      
      icon_finish <- makeAwesomeIcon(
        icon = 'flag',
        markerColor = 'red',
        library= 'fa',
        iconColor = 'white'
      )
      
      obs <- observation()
      
      midpoint <- tryCatch(
        expr = {
          with(obs, midPoint(c(lon_lag, lat_lag), c(lon, lat)))
        },
        error = function (e) NULL
      )
      
      content <- paste(
        "<b> Distance travelled:",
        format(round(obs$distance), big.mark = ".", decimal.mark = ","), 
        "m",
        "</b>"
      )
      
      map_plot <- leaflet() %>%
        addTiles() %>%
        addAwesomeMarkers(
          lng = obs$lon_lag, 
          lat = obs$lat_lag, 
          label = "Start",
          icon = icon_start
        ) %>%
        addAwesomeMarkers(
          lng = obs$lon, 
          lat = obs$lat, 
          label = "Finish",
          icon = icon_finish
        )
      
      if (!is.null(midpoint)) {
        map_plot <- map_plot %>%
          addPopups(
            lng = midpoint[[1]], 
            lat = midpoint[[2]], 
            popup = content,
            popupOptions(closeOnClick = TRUE)
          ) 
      }
      
      return(map_plot)
      
    }
  )
  
}