
server <- function(input, output, session) {
  
  # ships type
  type <- dropdown_type_Server(id = "type")
  
  # checking that the type is reactive before passing to name
  testthat::expect_true(is.reactive(type))
  
  # grabbing the name of the ship and updating by the ship's type
  name <- dropdown_name_Server(id = "name", type = type)
  
  # reactive observation
  observation <- reactive(
    x = {
      ships[ship_name == name()]
    }
  )
  
  # testing that the observation is reactive
  testthat::expect_true(is.reactive(observation))
  
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
      
      # check that the distance is numeric
      testthat::expect_is(obs$distance, "numeric")
      
      midpoint <- tryCatch(
        expr = {
          with(obs, midPoint(c(lon_lag, lat_lag), c(lon, lat)))
        },
        error = function (e) NULL
      )
      
      content <- paste(
        "<b> Distance travelled:", f_meter(obs$distance), "</b>"
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
  
  output$accordion <- renderUI(
    expr = {
      
      if (type() == "") return(NULL)
      
      description <- desc[Type == type(), Description]
      src <- desc[Type == type(), Source]
      nu_ships <- ships[ship_type == type(), uniqueN(ship_id)]
      nu_flags <- ships[ship_type == type(), uniqueN(flag)]
      min_dist <- ships[ship_type == type(), f_meter(min(distance))]
      max_dist <- ships[ship_type == type(), f_meter(max(distance))]
      
      info_content <- list(
        list(title = type(),
             content = div(p(description), a(href = src, "Source", target = "_blank"))),
        list(title = "More information",
             content = p(
               paste0(
                 "There are ", nu_ships, " ships of the ", type(), " type in this dataset. ",
                 "They come from ", nu_flags, " distinct countries. ",
                 "The lowest distance travelled by these ships is ", min_dist,
                 " while the greatest distance is ", max_dist, "."
               )
             )
        )
      )
      
      accordion(
        accordion_list = info_content, 
        fluid = F,
        active_title = type(),
        custom_style = "background: #fffddb;"
      )
      
    }
  )
  
}