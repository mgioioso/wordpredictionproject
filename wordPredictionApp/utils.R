library(stringr)

files <<- c('../data/sample/en_US.twitter.sample5.txt',
           '../data/sample/en_US.blogs.sample5.txt',
           '../data/sample/en_US.news.sample5.txt')

getLines <- function(f) {
    out = system(paste0("bash -c 'wc -l ",f,"'\n"), intern=TRUE)
    as.numeric(str_split(out, " ", n=2)[[1]][1])
}


loadGrams <- function(test=FALSE, bench=FALSE) {
    if (!("grams" %in% ls(globalenv()))) {
        grams <- vector("list", 5)
        kwd = ""
        dir = ""
        if (bench)
            dir = "../wordpredictionproject/wordPredictionApp/"
        if (test) {
            kwd = ".60pct"
            dir = "../data/"
        }
        
        grams[[1]] <- readRDS(paste0(dir,"unigrams",kwd,".rds"))
        grams[[2]] <- readRDS(paste0(dir,"bigrams",kwd,".rds"))
        grams[[3]] <- readRDS(paste0(dir,"trigrams",kwd,".rds"))
        grams[[4]] <- readRDS(paste0(dir,"quadrigrams",kwd,".rds"))
        grams[[5]] <- readRDS(paste0(dir,"quintigrams",kwd,".rds"))
    }
    grams
}

