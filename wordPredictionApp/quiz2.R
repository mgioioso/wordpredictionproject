debugSource("predict2.R")
debugSource("utils.R")
library(dplyr)
library(data.table)
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

quiz2 <- function() {
  ####### QUIZ 1
  Q = vector("character", 10)
  A = vector("character", 10)
  P = vector("character", 10)
  prob = vector("numeric", 10)
  
  Q[1] = "When you breathe, I want to be the air for you. I'll be there for you, I'd live and I'd"
  A[1] = "die" # die, eat, give, sleep
  Q[2] = "Guy at my table's wife got up to go to the bathroom and I asked about dessert and he started telling me about his"
  A[2] = "marital" # horticultural, spiritual, marital, financial
  Q[3] = "I'd give anything to see arctic monkeys this"
  A[3] = "weekend" # month, weekend, morning, decade
  Q[4] = "Talking to your mom has the same effect as a hug and helps reduce your"
  A[4] = "stress" # hunger, happiness, sleepiness, stress
  Q[5] = "When you were in Holland you were like 1 inch away from me but you hadn't time to take a"
  A[5] = "walk" #? not look, minute, picture, walk
  Q[6] = "I'd just like all of these questions answered, a presentation of evidence, and a jury to settle the"
  A[6] = "" # not case, account, incident, matter
  Q[7] = "I can't deal with unsymetrical things. I can't even hold an uneven number of bags of groceries in each"
  A[7] = "hand" # arm, finger, toe, hand
  Q[8] = "Every inch of you is perfect from the bottom to the"
  A[8] = "top" # side, top, middle, center
  Q[9] = "I'm thankful my childhood was filled with imagination and bruises from playing"
  A[9] = "outside" # outside, weekly, daily, inside
  Q[10] = "I like how the same people are in almost all of Adam Sandler's"
  A[10] = "movies"  # novels, stories, pictures, movies
  
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


