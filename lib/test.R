# Load the h5 files and save all information into a list variable
# Save the list variable as a Rdata file
library(rhdf5)
# install.packages("topicmodels")
library(topicmodels)
library(stringr)
names <- list.files("Project4_data/TestSongFile100", pattern="*.h5", full.names=TRUE)
music.test <- lapply(names[1:length(names)], function(x) h5read(x,"/analysis"))
test.name <- paste(rep("testsong",100), c(1:100), sep = '')
names(music.test) <- test.name
save(music.test, file = "Project4_data/music.test.RData")


load("Project4_data/music.test.RData")
i = c(1:15)
test.feature.all <- feature.extraction(music.test, i)
save(test.feature.all, file = "Project4_data/test.feature.all.RData")
load("Project4_data/loading.RData")
test.music.data.transform <- test.feature.all %*% loading
save(test.music.data.transform, file = "Project4_data/test.music.data.transform.RData")


load("Project4_data/randomForest.fit.RData")
prob <- predict(randomForest.fit, test.music.data.transform, type = "prob")
prob.test <- matrix(0, ncol = 10, nrow = 100)
colnames(prob.test) <- as.character(c(1:20))
prob.test[,colnames(prob.test) %in% colnames(prob)] = prob
pred = prob.test %*% word.topic.distribution 

rank <- apply(pred, 1, function(x) rank(x, ties.method = 'random'))

