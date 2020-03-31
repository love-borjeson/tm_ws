rm(list = ls())

#library(rstudioapi)
#setwd(dirname(rstudioapi::callFun("getActiveDocumentContext")$path))

library(topicmodels)
modelBig100<- readRDS("model_k100.rds") #This one we'll use'. 
#It is the model on the full jokes dataset, with K=80 based on the result we just inspected.

terms(modelBig100 ,7) #Have a quick look
#pretty ok, by a quick inspection. Albeit far from perfect.

#Get stuff out of the model, three tables:
#1. Model summary
topicModelSummary <- as.data.frame(terms(modelBig100 ,15)) #Col = topics, cells = topterms(15)/topic
#2. Topic loadings per doc (gamma), i.e. the strength of the relations between respectiv topics and documents
topicDocProbabilities <- as.data.frame(topicmodels::posterior(modelBig100)$topics) #Col = topics, rows = doc_id
#3. Topic loadings per term (beta), i.e. the strength of the relations between respective topics and terms
topicTermProbabilities <- as.data.frame(t(topicmodels::posterior(modelBig100)$terms))#Col = terms, rows = topics
#These can be saved as csv and further analysed outside R. It is allowed.

#Let's just enrich the gamma output table slightly first:
colnames(topicDocProbabilities) <- paste("Topic", colnames(topicDocProbabilities), sep = "_") #Add "Topic" to the columnames

#Make rownames the first column:
topicDocProbabilities <- cbind(rownames(topicDocProbabilities),
                               data.frame(topicDocProbabilities,
                                          row.names=NULL)) 

top.topics <- as.data.frame(topics(modelBig100)) #top topics per doc

#marry gamma with toptopics
head(top.topics)
names(top.topics)[1] <- "TopTopic"
topicDocProbabilities$TopTopic <- top.topics$TopTopic
head(topicDocProbabilities)
names(topicDocProbabilities)[1] <- "doc_id" #rename the first column wich holds the doc_id.
#This column is important because it maps to the corresponding column in the file that holds the cleaned texts.

text1 <- readRDS("Text1Full.rds") #Load the the texts/jokes. Pre-cleaned. Thank you. You're wellcome.
str(text1) 
str(topicDocProbabilities) #This is to see type of data in the different columns...
text1$doc_id <- as.factor(text1$doc_id) #to enable joining, i.e. we want doc_id to be a factor not a number.
library(dplyr) #datawrangling package.
topicDocProbabilities <- topicDocProbabilities %>% left_join(text1, by = "doc_id") #Don't worry about the warning.
head(topicDocProbabilities)
saveRDS(topicDocProbabilities, file = "topicDocProbabilities.rds") #Save this.  

#Export to csv:
k <- 100 #For naming
write.csv(topicModelSummary, file = paste("LDAGibbs",k,"Summary.csv"))
write.csv(topicDocProbabilities, file = paste("LDAGibbs",k,"Gamma.csv"))
write.csv(topicTermProbabilities, file = paste("LDAGibbs",k,"Beta.csv"))

GMY <- "MYA"
GMY

