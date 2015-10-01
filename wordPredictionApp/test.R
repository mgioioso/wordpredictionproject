debugSource("predict.R")
source("utils.R")
library(dplyr)
grams <- loadGrams(test=TRUE)
library(logging)
basicConfig()
setLevel(30)

getFirstPrediction = function(phrase) {
    t2 <- proc.time()
    temp = predict(phrase, grams)
    t3 <- proc.time()
    loginfo('Runtime: %.2f seconds', t3[3]-t2[3])
    temp[1,] %>% transmute(Pred=word)
}

parsePhrases = function(phrases) {
    locs = str_locate(phrases, "(\\w+)$")
    part1 = str_sub(phrases, start=1,end=locs[,1]-2)
    part2 = str_sub(phrases, start=locs[,1], end=locs[,2])
    return(list(phraseSeg=part1, pword=part2))
}

test <- function() {
    ####### Get validation data from dataInds.rds
    dataInds = readRDS("../data/dataInds.rds")
    
    compare = list()
    
    for (i in 1:length(files)) {
        txt = readLines(files[i],skipNul = TRUE)
        valPhrases = txt[dataInds[[i]]$xv]
        valPhrases = valPhrases[1:1000] # otherwise, too many!
        
        ### Remove last word from each line, and try to predict it
        splitPhrases <- parsePhrases(valPhrases)
        
        
        t1 <- proc.time()
        compare[[i]] = data.table(lapply(splitPhrases$phraseSeg, getFirstPrediction) %>% bind_rows())
        compare[[i]]$Ans = splitPhrases$pword
        tf <- proc.time()
        logwarn('Total runtime: %.2f seconds', tf[3]-t1[3])
        
        error = compare[[i]][Ans!=Pred, .N]/nrow(compare[[i]])
        logwarn("Error is %.3f", error)
        saveRDS(compare[[i]], paste0("compare", as.character(i),".rds"))
        logwarn("saved stats to compare%d.rds", i)
    }
    compare
}


