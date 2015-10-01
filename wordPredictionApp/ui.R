library(shiny)

shinyUI(fluidPage(
    tags$head(tags$style(type = "text/css", "a{color: mistyrose;}")
    ),
    h2("Word Prediction App", 
       style = "font-family: 'Trebuchet MS', Helvetica, sans-serif;
       font-weight: 500; line-height: 1.1; 
       color: lightcoral;"),
    mainPanel(tags$style("body {background-color: steelblue; }"),
        tabsetPanel(type="tab",
            tabPanel("App", tags$style("body {color: mistyrose;}"), 
                     fluidRow(
                         column(width = 6,
                                textInput(inputId="userPhrase", label="Type a phrase to complete",
                                          value = "")
                         ),
                         column(width = 6, 
                                actionButton("predictAction", label = "Predict next word",
                                             style = "font-family: 'Trebuchet MS', Helvetica, sans-serif; font-size: 115%;
                                             font-weight: 500; line-height: 3.0; color: black;
                                             background-color: lightcoral;")
                         )
                     ),
                     fluidRow(
                         column(width = 4,
                                # selection box where user can put in option that is not in list
                                # choices is a named vector
                                selectInput(inputId="predWords", label="Possible words for completion:",
                                            choices=c("next word" = "%"))
                                # evaluate()
                         ),
                         column(width=8, plotOutput("wordcloud")  )
            )),
            
            tabPanel("Read Me", 
                     p("This app predicts the next word that comes after the phrase entered in the 
                       text box. The predicted words are displayed in the select box. Pick the item
                       with the word that you intended to complete the phrase.")
            )
        )
    )
))
