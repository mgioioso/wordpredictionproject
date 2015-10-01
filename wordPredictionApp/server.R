library(shiny)
library(wordcloud)
library(logging)
basicConfig()
source("predict2.R")
source("utils.R")

t1 <- proc.time()
grams <- loadGrams()
t2 <- proc.time()
loginfo("loaded data in %.2f seconds", t2[3]-t1[3])

# so that it's really loaded instead of lazy...
tmp = grams[[5]][preword=="who let the dogs",]
tmp = grams[[4]][preword=="have a nice",]
tmp = grams[[3]][preword=="have a",]
tmp = grams[[2]][preword=="have",]
t3 <- proc.time()
loginfo("Touched data in %.2f seconds", t3[3]-t2[3])


shinyServer(
    function(input, output, clientData, session) {
        
        observe({
            s_options <- ''
            completeWords <- data.frame(word=c("predict","the","next","word"), prob=c(20,10,5,2))
            
            if(input$predictAction>0) {
                loginfo("button clicked")
                isolate({
                    # Get phrase from user and generate next word predictions
                    # set of answers, top likelihood
                    t4 <- proc.time()
                    phrase <- input$userPhrase
                    completeWords <- predict2(phrase, grams)
                    t5 <- proc.time()
                    loginfo("Predicted word in %.2f seconds", t5[3]-t4[3])
                    
                    # Select input ===================
                    # Create a list of word/likelihood entries
                    s_options <- apply( completeWords , 1 , 
                                        function(x) {sprintf("%s - %0.2f%%", 
                                                             x[1], as.numeric(x[2]))})
                    t6 <- proc.time()
                    loginfo("Created word list in %.2f seconds", t6[3]-t5[3])
                })
            }
            t7 <- proc.time()
            # Change values for input$inSelect
            updateSelectInput(session, "predWords", choices = s_options)
            
            t8 <- proc.time()
            loginfo("Update dropdown in %.2f seconds", t3[3]-t2[3])
            
            output$wordcloud <- renderPlot({
                wordcloud(completeWords$word, completeWords$prob, scale=c(5,0.5),
                              min.freq = 0, colors=brewer.pal(8, "Dark2"))
            })
            
            t9 <- proc.time()
            loginfo("Created wordcloud in %.2f seconds", t3[3]-t2[3])
        })
        
    }
)
