suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(dplyr))
library(logging)
basicConfig()
library(stringr)
setLevel(30)


predict = function(phrase, grams) {
    loginfo("user phrase = \n%s", phrase)

    phrase <- str_to_lower(phrase)
    
    uPhrases <- simplify2array(str_split(phrase, pattern="[.,;:?!]"))
    uPhrase <- uPhrases[length(uPhrases)]
    uWords <- simplify2array(str_split(str_trim(uPhrase), pattern="[ .,;:?!]"))
    matches <- data.table()
    
    # Find matches in 5-grams .. 2-grams
    for (i in 5:2) {
        if ((length(uWords) >= (i-1)) & (nrow(matches)==0)) {
            tokens = tail(uWords, n=(i-1))
            matches <- grams[[i]][preword==paste(tokens[1:(i-1)], collapse=" "),]
            if (nrow(matches)>0) {
                loginfo('Matched %d-grams', i)
            }
        }
    }
    

    # unigrams
    if (nrow(matches)==0) {
        matches <- head(grams[[1]][order(-prob,-freq)], n=4)
        if (nrow(matches)>0) {
            loginfo('Matched unigrams')
        }
    }
    
    matches <- matches[order(-prob,-freq)]
    
    t1 <- proc.time()
    ### When there is a match, how to determine best match. Instead of freq, need
    ### prob = freq/total???
    ### Finally, grab final 4 best matches and return them in data frame like below
    matches <- head(matches, n=8)
    #loginfo("Matches: ")
    #loginfo(matches)
    
    # Complete stems for natural sounding English
    #completeMatches <- mutate(matches, pword=stemCompletion(pword, corpus))
    loginfo("matches: ")
    loginfo(select(matches, pword, prob))
    data.frame(word = matches$pword, prob = matches$prob*100, 
               freq=matches$freq, stringsAsFactors = FALSE)
    #matches$pword[1:min(length(matches),3)]
}