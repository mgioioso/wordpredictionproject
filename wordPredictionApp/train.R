library(quanteda)
library(stringr)
suppressPackageStartupMessages(library(data.table))
suppressPackageStartupMessages(library(dplyr))
library(logging)
basicConfig()

swearWords = as.vector(t(read.csv("../data/swearWords.csv", header=FALSE)))

files <- c('../data/sample/en_US.twitter.sample5.txt',
           '../data/sample/en_US.blogs.sample5.txt',
           '../data/sample/en_US.news.sample5.txt')

getLines <- function(f) {
    out = system(paste0("bash -c 'wc -l ",f,"'\n"), intern=TRUE)
    as.numeric(str_split(out, " ", n=2)[[1]][1])
}

lowProb = 1E-3

genTrainTest <- function() {
    
    lines = sapply(files, getLines)
    
    # divide up set into 5 parts randomly
    set.seed(1212)
    fiveparts <- lapply(lines, function(line) sample(1:5, line, replace=T))
    dataInds <- list()
    for (i in 1:length(files)) {
        trainSet = which(fiveparts[[i]]<=3)
        xvSet = which(fiveparts[[i]]==4)
        testSet = which(fiveparts[[i]]==5)
        dataInds[[length(dataInds)+1]] = list(train=trainSet, xv=xvSet, test=testSet)
    }
    saveRDS(dataInds, file="../data/dataInds.rds")
    return(dataInds)
}

gnames <- c("unigrams", "bigrams", "trigrams", "quadrigrams",
            "quintigrams")

extractngrams <- function(test=FALSE) {
    loginfo("____START training___")
    kwd = ""
    if (test) {
        dataInds = genTrainTest()
        kwd = ".60pct"
    }
    
    for (j in 1:length(gnames)) {
        ### CREATE NGRAMS________
        grams <- data.table(ngram=character(), freq=numeric())
        
        for (i in 1:length(files)) {
            txt = readLines(files[i],skipNul = TRUE)
            if (test)
                txt = txt[dataInds[[i]]$train]
            loginfo("Read %s", files[i])
            t1 <- proc.time()
            dt=data.table(ngram=unlist(tokenize(txt, what="fastestword", n=j, 
                                                concatenator = " ")))
            rm(txt)
            t2 <- proc.time()
            loginfo('Created list of %d %d-grams in %.2f minutes', 
                    dim(dt)[1], j, (t2[3]-t1[3])/60)
            setkeyv(dt,"ngram")
            dt = dt[,.(freq=.N), by=ngram]
            dt <- dt[freq>1]
            grams <- rbindlist(list(grams, dt))
            t3 <- proc.time()
            loginfo('Added %d %d-grams for a total of %d in %.2f seconds', 
                    dim(dt)[1], j, dim(grams)[1], t3[3]-t2[3])
        }
        grams = grams[,.(freq=sum(freq)), by=ngram]
        saveRDS(grams, file=paste0("../data/",gnames[j],"1",kwd,".rds"))
        rm(dt, grams)
    }
}

## Given an ngram table and the (n-1)gram table, generate probabilities
# for the ngram table. prob = count(ngram[1:n])/count(ngram[1:n-1])
genGramProbs <- function(thesegrams, lastgrams) {
    # remove ~ and ' b/c never going to predict it
    thesegrams <- thesegrams[!(pword %in% c("'","~","~~","''"))]
    thesegrams <- thesegrams[!(pword %in% swearWords)]
    
    # prob = P(w2 | w1) = count(w1, w2)/count(w1)
    setkeyv( thesegrams , "preword" )
    setkeyv( lastgrams , "ngram" )
    # https://rstudio-pubs-static.s3.amazonaws.com/52230_5ae0d25125b544caab32f75f0360e775.html
    count1 <- lastgrams[ thesegrams, freq ] # left join
    thesegrams[, prob := freq / count1 ]
    thesegrams = thesegrams[complete.cases(thesegrams)] # get rid of NAs
    thesegrams = thesegrams[prob > lowProb]
    thesegrams <- thesegrams[order(-prob)]
    return(thesegrams)
}

calculateProbs <- function(test=FALSE) {
    output <- system(paste("bash -c 'if [ -e unigrams.rds ] ; then echo \"Moving RDS files to rds.old\";",
                 "mv -f unigrams.rds unigrams.rds.old;",
                 "mv -f bigrams.rds bigrams.rds.old;", 
                 "mv -f trigrams.rds trigrams.rds.old;",
                 "mv -f quadrigrams.rds quadrigrams.rds.old;",
                 "mv -f quintigrams.rds quintigrams.rds.old;",
                 "fi'\n", sep=" "))
    print(output)
    
    kwd = ""
    dir = ""
    if (test) {
        kwd = ".60pct"
        dir = "../data/"
    }
    
    #_________________________________
    ## Set up probability for UNIGRAMS
    t4 <- proc.time()
    unigrams <- readRDS(paste0("../data/unigrams1",kwd,".rds"))
    
    # FURTHER CULLING: remove all unigrams of frequency 2
    #unigrams <- unigrams[freq>2]
    unigrams <- unigrams[(ngram!="'") & (ngram!="~") & (ngram!="~~") & (ngram!="''")]
    unigrams[, prob := freq/sum(freq)]
    unigrams <- unigrams[order(-prob)]
    #temp <- saveSQLite(unigrams, "unigrams")
    
    t5 <- proc.time()
    loginfo('Created %d 1-grams in %.2f seconds', dim(unigrams)[1], 
            t5[3]-t4[3])
    
    ## Set up probability for BIGRAMS
    bigrams <- readRDS(paste0("../data/bigrams1",kwd,".rds"))
    bigrams[, c("preword", "pword") := tstrsplit(ngram, " ", fixed=TRUE)]
    bigrams <- bigrams[pword != preword] # remove stuttering
    
    bigrams = genGramProbs(bigrams, unigrams)
    #biCoca = fread("../data/COCA/w2_.txt")
    #setnames(biCoca, c("freq","preword","pword"))
    
    setnames(unigrams,"ngram","pword")
    saveRDS(unigrams, file=paste0(dir,"unigrams",kwd,".rds"))
    rm(unigrams)
    t6 <- proc.time()
    loginfo('Created %d 2-grams in %.2f seconds', dim(bigrams)[1], 
            t6[3]-t5[3])
    
    ## Set up probability for TRIGRAMS
    trigrams <- readRDS(paste0("../data/trigrams1",kwd,".rds"))
    
    trigrams[, c("word1", "word2", "pword") := tstrsplit(ngram, " ", fixed=TRUE)]
    trigrams <- trigrams[(pword != word2) & (word1!=word2)] # remove stuttering
    
    trigrams[,preword:=paste(word1,word2)]
    trigrams[,c("word1", "word2"):=NULL]
    
    trigrams = genGramProbs(trigrams, bigrams)
    bigrams[,ngram:=NULL]
    saveRDS(bigrams, file=paste0(dir,"bigrams",kwd,".rds"))
    #temp <- saveSQLite(bigrams, "bigrams")
    t7 <- proc.time()
    loginfo('Created %d 3-grams in %.2f seconds', dim(trigrams)[1], 
            t7[3]-t6[3])
    rm(bigrams)
    
    ## Set up probability for QUADRIGRAMS
    quadrigrams <- readRDS(paste0("../data/quadrigrams1",kwd,".rds"))
    
    quadrigrams[, c("word1", "word2", "word3", "pword") := tstrsplit(ngram, " ", fixed=TRUE)]
    quadrigrams <- quadrigrams[(word3 != word2) & (word1!=word2) & (pword!=word3)] # remove stuttering
    
    quadrigrams[,preword:=paste(word1,word2,word3)]
    quadrigrams[,c("word1","word2","word3"):=NULL]
    
    quadrigrams = genGramProbs(quadrigrams, trigrams)
    trigrams[,ngram:=NULL]
    saveRDS(trigrams, file="trigrams.rds")
    #temp <- saveSQLite(trigrams, "trigrams")
    
    saveRDS(trigrams, file=paste0(dir,"trigrams",kwd,".rds"))
    t8 <- proc.time()
    loginfo('Created %d 4-grams in %.2f seconds', dim(quadrigrams)[1], 
            t8[3]-t7[3])
    rm(trigrams)
    
    ## Set up probability for QUINTIGRAMS
    quintigrams <- readRDS(paste0("../data/quintigrams1",kwd,".rds"))
    
    quintigrams[, c("word1", "word2", "word3", "word4", "pword") := tstrsplit(ngram, " ", fixed=TRUE)]
    quintigrams <- quintigrams[(word3 != word2) & (word1!=word2) & (word4!=word3) & (pword!=word4)] # remove stuttering
    
    quintigrams[,preword:=paste(word1,word2,word3,word4)]
    quintigrams[,c("word1","word2","word3","word4"):=NULL]
    
    
    quintigrams = genGramProbs(quintigrams, quadrigrams)
    quintigrams[,ngram:=NULL]
    quadrigrams[,ngram:=NULL]
    saveRDS(quadrigrams, file=paste0(dir,"quadrigrams",kwd,".rds"))
    #temp <- saveSQLite(quadrigrams, "quadrigrams")
    saveRDS(quintigrams, file=paste0(dir,"quintigrams",kwd,".rds"))
    #temp <- saveSQLite(quintigrams, "quintigrams")
    t9 <- proc.time()
    loginfo('Created %d 5-grams in %.2f seconds', dim(quintigrams)[1], 
            t9[3]-t8[3])
    
    
    loginfo("____END training___")
    
}



train <- function(test=FALSE) {
    
    #extractngrams(test)
    
    calculateProbs(test)
}
