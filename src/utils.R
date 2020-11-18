
dropdown_UI <- function(id, label, choices) {
  ns <- NS(id)
  tagList(
    dropdown_input(
      default_text = label,
      input_id = ns("ship"),
      choices = choices
    )
  )
}

dropdown_type_Server <- function (id) {
  moduleServer(
    id = id,
    module = function (input, output, session) {
      return(reactive(input$ship))
    }
  )
}

dropdown_name_Server <- function(id, type) {
  moduleServer(
    id = id,
    module = function(input, output, session) {
      
      observeEvent(
        eventExpr = type(),
        handlerExpr = {
          
          updated_ships <- ships[ship_type == type()]
          updated_ships <- updated_ships[order(-distance), ship_name] 
          
          update_dropdown_input(
            session = session,
            input_id = "ship",
            choices = updated_ships
          )
          
        }
        
      )
      
      return(reactive(input$ship))
      
    }
  )
}
