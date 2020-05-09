
#"Someone must have slandered K, for one morning, without having done anything wrong, he was arrested."

#clean slate...:
rm(list = ls())

#library(rstudioapi)
#setwd(dirname(rstudioapi::callFun("getActiveDocumentContext")$path))

#The only thing we need really, for both lda tuning and perplexity calculations is our dtm, "dtmKW".
dtmKW <- readRDS("dtmKW.rds")

#The single most important parameter of the Gibbs sampler is K, the number of topics.
#Previously, we've used K=24, informed by the no of predefined categories in the samples.

#Another straight forward approach is to rely on our knowledge interest:
#A quick overview of a corpus requires perhaps 10 topics, something more refined 25,
#and a really detailed topical inspection perhaps 100 topics.
#Though robust, these approaches are still somewhat unsatisfying.

#Let's try to be a bit data driven.
#The general approach is to fixate the sampler params EXCEPT K,
#(alpha, beta, etc.) and then manipulate K to get the best model.
#We'll look into 3 methods to do it, and since doing this is computationally expensive,
#we'll do it in parallel.

#Still: once you've started the iterations on a fairly large dataset (>50')
#to find K for a good model, it's a good time have a cup of coffee.
#If that coffee is served in a harbor café in
#Murmansk, and you take your rowing boat to get there.

###############################################################################
###############################################################################

#Method 1. Density-based method
#From:
#Cao Juan, Xia Tian, Li Jintao, Zhang Yongdong, and Tang Sheng. 2009. A density-based method for adaptive lDA model selection.
#Neurocomputing - 16th European Symposium on Artificial Neural Networks 2008 72, 7-9: 1775-1781.

#"Cluster-like approach: ..."that the similarity will be as large as possible in the intra-
#cluster, but as small as possible between inter-clusters."

#Transfer this idea to topics, maximizing (density-based) similarity intra-topics
#and maximizing difference inter-topics.

###############################################################################

#Metod 2. Harmonic-mean of the log likelihood
#From (among others):
#Thomas L. Griffiths and Mark Steyvers. 2004. Finding scientific topics.
#Proceedings of the National Academy of Sciences 101, suppl 1: 5228-5235.

#Maximizing the likelihood of the observed data by changing the number of topics.
#(I.e. maximizing the probability that the model gives to the observed data,
#i.e. the likelihood P(words|no. of topics))
#This (log-)likelihood is estimated with harmonic means, using the Gibbs sampler.

###############################################################################

#From the package 'ldatuning', we get the result of method 1 and 2 normalized to a 0-1 scale,
#where we will just pick the model with a minimum from method 1, and maximum from method 2. 

###############################################################################
###############################################################################


candidate_k <- c(2, 3, 2:60 * 2, 7:10 * 20) # a proper sampling of models with different no of K.
candidate_k
candidate_k <- c(2, 24, 60, 120) #for the purpose of this lab. Higher numbers add A LOT OF TIME.
controlGibbs <- list(seed = 5683, #hrm?
                     burnin = 200,
                     iter = 500,
                     delta = 0.15) #with a more dense dtm (resulting from our linguistic pre-processing),
# topics will be very specific,
# almost document-specific (especially for a small corpus).
# We can counter this effect by increasing alpha and/or delta (i.e. beta) slightly.
# Are we then rigging the below tests? In some sense, yes.
# i.e. what we "objectively" find as the appropriate K (no of topics)
# is partly the result of how we tweak delta. 

library(parallel) #If you run this locally, un-comment this and make the suggetsted changes below at "mc.cores"
detectCores()-1
library(ldatuning)
result <- FindTopicsNumber(
  dtmKW,
  topics = candidate_k,
  metrics = c("Griffiths2004", "CaoJuan2009"),
  method = "Gibbs",
  control = controlGibbs,
  mc.cores = detectCores()-1,
  verbose = TRUE
)
FindTopicsNumber_plot(result)

#If you use to many cores on large models (say, many models and >300 topics) you can run out of RAM and then R/RStudio
#will abort your session. Solution: use fewer cores but more time. Or get more RAM.



#"But I'm not guilty," said K. "there's been a mistake.
#How is it even possible for someone to be guilty?
#We're all human beings here, one like the other."
#"That is true" said the priest "but that is how the guilty speak." 


###############################################################################
###############################################################################
#Metod 3. Perplexity
#From (among others):
#Martin Ponweiser. 2012. Latent dirichlet allocation in r.

#Divide the corpus, build models with different number of topics on a training-set,
#see how well the models predict the held-out set. If the models does not predict well,
#it gets "perplexed" (who wouldn't be?) in terms of high entropy/low redundancy:
#the held-out dataset contains information we can't predict well with our model.
#Hence, high perplexity -> poor model. Low perplexity -> good model.
#The levels of perplexity are essentially
#corpus- but not model-specific.
#Find the model with the number of topics
#that have the lowest perplexity.

###############################################################################
###############################################################################

#Below script is ever so slightly adjusted from..:
#https://www.r-bloggers.com/cross-validation-of-topic-modelling/.
#Hats of to the r-blogger "Peter's stats stuff - R".
library(chinese.misc)
dtmKW <- m3m(dtmKW, "dtm") #The below function needs a 2d dtm...
#Ignore the warnings

library(doParallel)
#ForEach is a different way to parallelize, since it does not split the data, but the processes.

burnin = 200
iter = 500
keep = 50 
delta = 0.15 #We need these stated individually, to call them inside the below function...

n <- nrow(dtmKW) #We need this for splitting the sample

cluster <- makeCluster(detectCores(logical = TRUE) - 1)

registerDoParallel(cluster)

clusterEvalQ(cluster, {
  library(topicmodels)
})

folds <- 3 #For the overachievers: =>5.
splitfolds <- sample(1:5, n, replace = TRUE) #1:5 will result in (roughly) a 80/20 split.

#to inspect train and validation data-set
#for(i in 1:folds){
#  train_set <- dtmKW[splitfolds != i , ]
#  valid_set <- dtmKW[splitfolds == i, ]} #i.e., you do not really need these two objects.

clusterExport(cluster, c("dtmKW", "burnin", "iter", "keep", "delta", "splitfolds", "folds", "candidate_k"))
#These are 'uploaded' to the clusters to be included in the calculations

#Below, parallelization below by the different number of topics: a processor is allocated a value
#of k, and does the cross-validation serially. Why (and why not over folds)?
#Because it is assumed there are more candidate values of k than there are cross-validation folds (k>folds),
system.time({
  results <- foreach(j = 1:length(candidate_k), .combine = rbind) %dopar%{
    k <- candidate_k[j]
    results_1k <- matrix(0, nrow = folds, ncol = 2)
    colnames(results_1k) <- c("k", "perplexity")
    for(i in 1:folds){
      train_set <- dtmKW[splitfolds != i , ]
      valid_set <- dtmKW[splitfolds == i, ]
      fitted <- LDA(train_set, k = k, method = "Gibbs",
                    control = list(burnin = burnin, iter = iter, keep = keep, delta = delta) )
      results_1k[i,] <- c(k, perplexity(fitted, newdata = valid_set))
    }
    return(results_1k)
  }
})
stopCluster(cluster)

results_perplexity <- as.data.frame(results)

library(ggplot2)
library(scales)
p <- ggplot(results_perplexity, aes(x = k, y = perplexity)) +
  geom_point(pch = 21, size = 2, fill = I("orange")) +
  geom_line(color=c("#753633"),size=0.5) +
  ggtitle("3-fold cross-validation of LDA-model with Gobbs sampler on the 'jokes' dataset",
          "Perplexity when fitting the trained model to the hold-out set.") +
  labs(x = "Candidate number of topics", y = "Perplexity when fitting the trained model to the hold-out set")

p

library(plotly)
ggplotly(p) #The perplexity measure thus indicates a higher no of appropriate topics.

###############################################################################
###############################################################################

#The above methods are global (valid for the model as a whole).
#You could/should also have a look at coherence measures that are both global
#and local (valid for single topics), 
#readily applicable using 'textminer'.

###############################################################################
###############################################################################

#"No," said the priest, "you don't need to accept everything as true, you only have to accept it as necessary."
#"Depressing view," said K. "The lie made into the rule of the world." 


#Let's find K for the whole 10K data set of jokes, and for many more models..
results_KBIGldaT <- readRDS("results_KBIGldaT.rds") #pre-tested...
results_KBIGperpl <- readRDS("results_KBIGperpl.rds") #to save time

FindTopicsNumber_plot(results_KBIGldaT)

p <- ggplot(results_KBIGperpl, aes(x = k, y = perplexity)) +
  geom_point(pch = 21, size = 2, fill = I("orange")) +
  geom_smooth(color=c("#753633"),size=0.5) +
  ggtitle("3-fold cross-validation of LDA-model with Gibbs sampler on the 'jokes' dataset",
          "Perplexity when fitting the trained model to the hold-out set.") +
  labs(x = "Candidate number of topics", y = "Perplexity when fitting the trained model to the hold-out set")
p

ggplotly(p)
#So here too, perplexity measures disagrees with the rest of the pack...
#Nonetheless: Should we keep looking for K, it is between 8 and 120 we should look.

GMY <- "MYA"
GMY 


