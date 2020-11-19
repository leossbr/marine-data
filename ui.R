
ui <- shinyUI(
  semanticPage(
    title = "Appsilon - Marine Data",
    theme = "cerulean",
    header(
      title = "Marine Data",
      description = "Greatest distance travelled by each ship"
    ),
    sidebar_layout(
      sidebar_panel = sidebar_panel(
        p("Select the ship's type"),
        dropdown_UI(
          id = "type",
          label = "Ship type",
          choices = sort(unique(ships$ship_type))
        ),
        br(),
        p("Select the ship"),
        dropdown_UI(
          id = "name",
          label = "Ship name",
          choices = ships$ship_name
        ),
        br(),
        uiOutput("accordion")
      ),
      main_panel = main_panel(
        cards(
          class = "three",
          card(
            div(class="content",
                div(class="header", "Port"),
                div(class="description", textOutput("port"))
            )
          ),
          card(
            div(class="content",
                div(class="header", "Destination"),
                div(class="description", textOutput("destination"))
            )
          ),
          card(
            div(class="content",
                div(class="header", "Ship's Flag"),
                htmlOutput("flag")
            )
          )
        ),
        div(class = "ui divider"),
        fluidRow(
          leafletOutput("map")
        )
      )
    )
  )
)
