# source("http://bioconductor.org/biocLite.R")
# biocLite("rhdf5")
library(rhdf5)
# install.packages("topicmodels")
library(topicmodels)
library(stringr)

setwd("/Users/jiwenyou/Desktop")
common_id <- read.table("~/Desktop/Project4_data/common_id.txt", quote="\"", comment.char="")
common_id <- as.vector(common_id$V1)
load("Fall2016-proj4-yyuulan/data/music.RData")
load("Fall2016-proj4-yyuulan/data/music_new.RData")

# load the h5 files and save all information into a list variable
# save the list variable as  music.Rdata file
filenames <- vector()
for (a in c("A", "B")){
  for (b in LETTERS){
    for (c in LETTERS){
      names <- list.files(paste("Project4_data/data/", a, "/", b, "/", c, sep = ''), pattern="*.h5", full.names=TRUE)
      filenames <- append(filenames, names)
    }
  }
}
music <- lapply(filenames[1:length(filenames)], function(x) h5read(x,"/analysis"))
names(music) <- common_id$V1[1:length(filenames)]
save(music, file = "Fall2016-proj4-yyuulan/data/music.RData")


# set the legth cut off value for different music descriptive factors according to the histogram
bars_confidence_length <- unlist(lapply(music, function(x) length(x$bars_confidence)))
beats_confidence_length <- unlist(lapply(music, function(x) length(x$beats_confidence)))
sections_confidence <- unlist(lapply(music, function(x) length(x$sections_confidence)))
segments_confidence <- unlist(lapply(music, function(x) length(x$segments_confidence)))
segments_pitches <- unlist(lapply(music, function(x) length(x$segments_pitches)))
tatums_confidence <- unlist(lapply(music, function(x) length(x$tatums_confidence)))

hist(bars_confidence_length, breaks = 25)
n.bars <- 200
hist(beats_confidence_length, breaks = 25)
n.beats <- 500
hist(sections_confidence, breaks = 25)
n.section <- 10
hist(segments_confidence, breaks = 25)
n.segments <- 800
hist(segments_pitches, breaks = 25)
n.segments_pitch <- 10000
hist(tatums_confidence, breaks = 25)
n.tatums <- 1000


# Remove the songs with zero factor length
# The remaining song all have values in different kinds of musical descriptive factors
# List.nomissing.RData will be used in topic modeling
remove <- function(music){
  check <- sum(unlist(lapply(music, function(x) length(x) == 0)))
  if(check == 0){
    return(TRUE)
  } else{
    return(FALSE)
  }
}
list.nomissing <- lapply(music, function(x) remove(x))
save(list.nomissing, file = "Fall2016-proj4-yyuulan/data/list.nomissing.RData")
music_new <- music[unlist(list.nomissing)]
save(music_new, file = "Fall2016-proj4-yyuulan/data/music_new.RData")


####################################################################################
# feature extraction function
feature.extraction <- function(music_new, i){
  
  # extract same length of information from each song
  get_value <- function(x, factor, n){
    t <- x[[factor]]
    while(length(t) < n){
      t <- rep(t,2)
    }
    while(length(t) > n){
      t <- t[1:n]
    }
    return(t)
  }
  
  data.bars_confidence <- t(data.frame(lapply(music_new, function(x) get_value(x, i[1], n.bars))))
  data.bars_start <- t(data.frame(lapply(music_new, function(x) get_value(x, i[2], n.bars))))
  data.beats_confidence <- t(data.frame(lapply(music_new, function(x) get_value(x, i[3], n.beats))))
  data.beats_start <- t(data.frame(lapply(music_new, function(x) get_value(x, i[4], n.beats))))
  data.section_confidence <- t(data.frame(lapply(music_new, function(x) get_value(x, i[5], n.section))))
  data.section_start <- t(data.frame(lapply(music_new, function(x) get_value(x, i[6], n.section))))
  data.segments_confidence <- t(data.frame(lapply(music_new, function(x) get_value(x, i[7], n.segments))))
  data.segments_loudness_max <- t(data.frame(lapply(music_new, function(x) get_value(x, i[8], n.segments))))
  data.segments_loudness_max_time <- t(data.frame(lapply(music_new, function(x) get_value(x, i[9], n.segments))))
  data.segments_loudness_start <- t(data.frame(lapply(music_new, function(x) get_value(x, i[10], n.segments))))
  data.segments_start <- t(data.frame(lapply(music_new, function(x) get_value(x, i[12], n.segments))))
  data.segments_pitches <- t(data.frame(lapply(music_new, function(x) get_value(x, i[11], n.segments_pitch))))
  data.segments_timbre <- t(data.frame(lapply(music_new, function(x) get_value(x, i[13], n.segments_pitch))))
  data.tatums_confidence <- t(data.frame(lapply(music_new, function(x) get_value(x, i[14], n.tatums))))
  data.tatums_start <- t(data.frame(lapply(music_new, function(x) get_value(x, i[15], n.tatums))))
  
  # Try to combine all information of a song into one factor and apply PCA
  factor.all <- cbind(data.bars_confidence,data.bars_start,data.beats_confidence,data.beats_start,
                      data.section_confidence,data.section_start,data.segments_confidence,data.segments_loudness_max,
                      data.segments_loudness_max_time,data.segments_loudness_start,data.segments_start,
                      data.segments_pitches,data.segments_timbre,data.tatums_confidence,data.tatums_start)
  constant.list <- which(apply(factor.all,2,var) == 0)
  factor.all[,constant.list] <- factor.all[,constant.list] + matrix(rnorm(nrow(factor.all)*length(constant.list), 0, 0.001),ncol = length(constant.list))
  which(apply(factor.all,2,var) == 0)
  
  return(factor.all)
}

i = c(1:13,15,16)
factor.all <- feature.extraction(music_new, i)


# Apply PCA to reduce dimension
t1 <- Sys.time()
pca <- prcomp(factor.all, center=TRUE, scale=TRUE);
t2 <- Sys.time()
t2 - t1 # Time difference of 10.34193 mins

# Save the loading matrix for future prediciton
loading <- pca$rotation
save(loading, file = "Fall2016-proj4-yyuulan/data/loading.RData")
# Tranform the original data to the reduced dimensional data
music.data.transform <- factor.all %*% loading
save(music.data.transform, file = "Fall2016-proj4-yyuulan/data/music.data.transform.RData")


###################################################################################
# Apply random forest to construct the relationships beween features and predicted topics
# install.packages("randomForest")
library(randomForest)
load("Project4_data/topic.distribution.RData")
label <- as.matrix(topic.distribution, ncol = 1)

t1 <- Sys.time()
randomForest.fit <- randomForest(x = music.data.transform, y = as.factor(label))
t2 <- Sys.time()
t2 - t1 # Time difference of 6.045216 mins

