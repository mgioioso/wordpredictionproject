suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(dplyr))
library(logging)
basicConfig()
setLevel(30)
library(stringr)



predict2 = function(phrase, grams) {
    loginfo("user phrase = \n%s", phrase)

    phrase <- str_to_lower(phrase)
    
    uPhrases <- simplify2array(str_split(phrase, pattern="[.,;:?!]"))
    uPhrase <- uPhrases[length(uPhrases)]
    uWords <- simplify2array(str_split(str_trim(uPhrase), pattern="[ .,;:?!]"))

    # Find matches in 5-grams .. 2-grams
    alpha = 1
    all_matches = data.table()
    for (i in 5:2) {
        if (length(uWords) >= (i-1)) {
            tokens = tail(uWords, n=(i-1))
            matches <- grams[[i]][preword==paste(tokens[1:(i-1)], collapse=" "),]
            if (nrow(matches)>0) {
                matches[,prob:=prob*alpha]
                loginfo('Matched %d-grams', i)
                all_matches <- rbind(all_matches, matches)
            }
        }
        alpha = alpha*.4
    }
    

    # unigrams
    if (nrow(all_matches)==0) {
        all_matches <- head(grams[[1]][order(-prob,-freq)], n=4)
        loginfo('Matched unigrams')
    }
    
    # There are repeats from the different ngram tables, so take
    # unique entries using the highest value of 'prob'
    all_matches = all_matches[,.SD[prob == max(prob)], by=pword]
    all_matches <- all_matches[order(-prob,-freq)]
    t1 <- proc.time()

    
    ### Finally, grab final 4 best matches and return them in data frame like below
    matches <- head(all_matches, n=8)
    
    # Complete stems for natural sounding English
    #completeMatches <- mutate(matches, pword=stemCompletion(pword, corpus))
    loginfo("matches: ")
    loginfo(select(matches, pword, prob))
    data.frame(word = matches$pword, prob = matches$prob*100, 
               freq=matches$freq, stringsAsFactors = FALSE)
}