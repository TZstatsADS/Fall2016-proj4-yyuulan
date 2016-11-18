# load the h5 files and save all information into a list variable
# save the list variable as a Rdata file
names <- list.files("Project4_data/TestSongFile100", pattern="*.h5", full.names=TRUE)
music.test <- lapply(names[1:length(names)], function(x) h5read(x,"/analysis"))
test.name <- paste(rep("testsong",100), c(1:100), sep = '')
names(music.test) <- test.name

i = c(1:15)
test.feature.all <- feature.extraction(music.test, i)
load("Project4_data/loading.RData")
test.music.data.transform <- factor.all %*% loading


prob <- predict(randomForest.fit, test.music.data.transform, type = "prob")
prob.test <- matrix(0, ncol = 20, nrow = 100)
colnames(prob.test) <- as.character(c(1:20))
prob.test[,colnames(prob.test) %in% colnames(prob)] = prob
pred = prob.test %*% word.topic.distribution 

rank <- apply(pred, 1, function(x) rank(x, ties.method = 'random'))
