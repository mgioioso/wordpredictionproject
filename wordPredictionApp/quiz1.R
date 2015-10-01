debugSource("predict2.R")
debugSource("utils.R")
library(dplyr)
library(data.table)
library(logging)
basicConfig()
setLevel(30)
grams <- loadGrams()

getFirstPrediction = function(phrase) {
    t2 <- proc.time()
    temp = predict2(phrase, grams)
    #P[i] = temp$word[1]
    #prob[i] = temp$prob[1]
    t3 <- proc.time()
    loginfo('Runtime: %.2f seconds', t3[3]-t2[3])
    #t2 <- t3
    temp[1,] %>% transmute(Pred=word)
}

quiz1 <- function() {
    ####### QUIZ 1
    Q = vector("character", 10)
    A = vector("character", 10)
    P = vector("character", 10)
    prob = vector("numeric", 10)
    freq = vector
    Q[1] = "The guy in front of me just bought a pound of bacon, a bouquet, and a case of"
    A[1] = "beer" # soda, pretzels, cheese
    Q[2] = "You're the reason why I smile everyday. Can you follow me please? It would mean the"
    A[2] = "world" # universe, most, best
    Q[3] = "Hey sunshine, can you follow me and make me the"
    A[3] = "happiest" # saddest, smelliest, bluest
    Q[4] = "Very early observations on the Bills game: Offense still struggling but the"
    A[4] = "defense" # players, crowd, referees
    Q[5] = "Go on a romantic date at the"
    A[5] = "grocery" # beach, movies, mall
    Q[6] = "Well I'm pretty sure my granny has some old bagpipes in her garage I'll dust them off and be on my"
    A[6] = "way" # phone, horse, motorcycle
    Q[7] = "Ohhhhh #PointBreak is on tomorrow. Love that film and haven't seen it in quite some"
    A[7] = "time" # thing, years, weeks
    Q[8] = "After the ice bucket challenge Louis will push his long wet hair out of his eyes with his little"
    A[8] = "fingers" # ears, eyes, toes
    Q[9] = "Be grateful for the good times and keep the faith during the"
    A[9] = "bad" # worse, sad, hard
    Q[10] = "If this isn't the cutest thing you've ever seen, then you must be"
    A[10] = "insane"  # insensitive, callous, asleep
    
    t1 <- proc.time()
    #t2 <- t1
    #for (i in 1:length(Q)) {
    #}
    compare = data.table(lapply(Q, getFirstPrediction) %>% bind_rows())
    compare$Ans = A
    tf <- proc.time()
    logwarn('Total runtime: %.2f seconds', tf[3]-t1[3])
    
    error = compare[Ans!=Pred, .N]/nrow(compare)
    logwarn("Error is %.3f", error)
    compare
}


