# Put the lyr into the format required by the lda package:
load("Project4_data/lyr.RData")
rownames(lyr) <- lyr$`dat2$track_id`
lyr <- data.matrix(lyr)

# In the feature extraction section, there are some songs have missing value inside certain features
# list.nomissing.RData is the list of songs have missing features
# list.nomissing.RData is under the data file
# We remove those songs from lyr.RData
load("Fall2016-proj4-yyuulan/data/list.nomissing.RData")
lyr <- lyr[unlist(list.nomissing),]

# Remove the first ID column
lyr <- lyr[,-c(1)]
voc <- colnames(lyr)

# Transform the data into the required format of lda
lyr.list <- split(lyr, seq(nrow(lyr)))
lyr.list <- setNames(split(lyr, seq(nrow(lyr))), rownames(lyr))

get.terms <- function(x) {
  index <- which(x != 0) - 1
  rbind(index = as.integer(index),counts = as.integer(x[which(x != 0)]))
}
documents <- lapply(lyr.list, get.terms)
documents[1]
save(documents, file = "Fall2016-proj4-yyuulan/data/documents.RData")

# Compute some statistics related to the data set:
D <- length(documents)  # number of songs (2,350)
W <- length(voc)  # number of terms in the vocab (5,000)
doc.length <- sapply(documents, function(x) sum(x[2, ]))  # number of words per song
N <- sum(doc.length)  # total number of words in the data

# MCMC and model tuning parameters:
K <- 10
G <- 5000
alpha <- 0.02
eta <- 0.02

# Fit the model:
library(lda)
set.seed(1)
t1 <- Sys.time()
fit.song <- lda.collapsed.gibbs.sampler(documents = documents, K = K, vocab = voc, 
                                   num.iterations = G, alpha = alpha, 
                                   eta = eta, initial = NULL, burnin = 0,
                                   compute.log.likelihood = TRUE)
t2 <- Sys.time()
t2 - t1
save(fit.song, file = "Fall2016-proj4-yyuulan/data/topicmodelling.RData")

# The distribution matrix of each words with respect to different topics
word.topic.distribution <- t(apply(t(fit.song$topics) + eta, 2, function(x) x/sum(x)))
save(word.topic.distribution, file = "Fall2016-proj4-yyuulan/data/word.topic.distribution.RData")

# The list of topics for different songs predicted by topic modeling
topic.distribution <- apply(fit.song$document_sums + alpha, 2, function(x) which.max(x))
save(topic.distribution, file = "Fall2016-proj4-yyuulan/data/topic.distribution.RData")
