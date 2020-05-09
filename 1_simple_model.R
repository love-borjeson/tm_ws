#Start the workshop

#1. Save project for future use.
#Save temporary project by clicking "Save a Permanent Copy" on the top banner.
#If yopu do not do this, the project will be lost when you leave it (i.e. when you close your browser).

#2.Execute commands.
#To execute, place the cursor at the top and press ctrl+enter.
#You can now ctrl-enter your way through script 1-7.
#It is recommended to run the scripts in order,
#but every script can be run independently. Buckle-up and enjoy!

#clean slate...:
rm(list = ls())

#library(rstudioapi)
#setwd(dirname(rstudioapi::callFun("getActiveDocumentContext")$path)) #won't take '????' etcetera in your filepath.

text1 <- read.csv ("jokes.csv", stringsAsFactors=FALSE)
summary(text1)
head(text1)
# *Pungas, T. (2017). A dataset of English plaintext jokes. GitHub repository.
# Shared under the fair use doctrine.


str(text1)
#The data comes with a qualitative coding under the heading "category".
#Let's make it a factor, not a string..:
text1$Column1.category <- as.factor(text1$Column1.category)

set.seed(123)
text1 <- text1[sample(nrow(text1), 1000), ] #We'll sample for the purpose of this lab.

#Let's see how many levels there are of categories
nlevels(text1$Column1.category) #we'll reuse this information later.

#A key to being able to use the topic model is to maintain the 1:1:1 relation
#between the documents id in the original dataset, the corpus and in the so called document term matrix (dtm).
#In the later versions of 'tm' this is a bit easier, using the function 'DataFrameSource'
#A data frame source interprets each row of the data frame x as a document.
#The first column must be named "doc_id" and contain a unique string identifier for each document.
#The second column must be named "text" and contain the actual text.
#Below, we prepare our text file for this.

#Character encoding, like so...
#text1$Column1.body <- iconv(text1$Column1, "", "UTF-8", sub="")
#Here, system encoding ("") is replaced with UTF-8, and unknowns substituted (hence 'sub') with "".
#Character encoding is a joy to the world. Nonetheless, it can be kind of tricky. If you can avoid it, you probably should.

colnames(text1)
names(text1)[1] <- "text"
names(text1)[2] <- "category"
names(text1)[3] <- "doc_id"
names(text1)[4] <- "title"

text1 <- text1[c('doc_id', 'text', 'category', 'title')]
colnames(text1) #ok, now we're good to go.

saveRDS(text1, file = "smalltext1.rds") #for later use.

library(tm)
#If you get this: Error: package or namespace load failed for ‘tm’
#in loadNamespace(j <- i[[1L]], c(lib.loc, .libPaths()), versionCheck = vI[[j]]):
#there is no package called ‘Rcpp’
#...then install the Package "Rcpp".

corp1 <- VCorpus(DataframeSource(text1)) #create a corpus.
#a corpus is (for the purpose of this script/lab) a data class of tm that holds all of our texts
#and that we can manipulate in various ways. See below.

#clean up the copus
#Minimal cleaning:
corp1 <- tm_map(corp1, content_transformer(tolower))
corp1 <- tm_map(corp1, stripWhitespace)

dtm1 <- DocumentTermMatrix(corp1)
#The dtm is a way to transform words into numbers. The basic structure is:
#rows=docs, columns=terms, cells=fq (of terms in docs).

#There are about 20 empty docs in the full data set, if we're unlucky we'll have one of them in the subsample as well.
#Better get rid of them...
nrow(dtm1)
ui <- unique(dtm1$i) #i for rows...
dtm1 <- dtm1[ui,] #remove empty docs
nrow(dtm1) #So here we trim the dtm a little, but thanks to
#the 'DataFrameSource' described above, we maintain our linkage to the original corpus and text. 
#textminer
library(topicmodels) #This is the standard, go-to package, for topic modeling in R. 

k <- 24 #no of topics.
#24, as we've seen, happens to be the number of topics suggested by the qualitative coding of the texts to categories.
#We can actually see our exercise here (topic modeling) as competing with this coding. 

#minimal Gibbs controler
controlGibbs <- list(seed = 5683, #What's the significance of THIS particular seed?
                     iter = 500) #We'll cover the settings of a full-blown controler later on.

model1 <- LDA(dtm1, k, method = "Gibbs", control = controlGibbs) #Model...
terms(model1,10)#SUmmarize
#ok, it does not get much crappier than this.
#let's inspect its crappiness even more..:

library(slam) #to handle matrixes
library(LDAvis) #to visual LDA models
#function to wrap LDAvis  
topicmodels2LDAvis <- function(x, ...){
  post <- topicmodels::posterior(x)
  if (ncol(post[["topics"]]) < 3) stop("The model must contain > 2 topics")
  mat <- x@wordassignments
  LDAvis::createJSON(
    phi = post[["terms"]], 
    theta = post[["topics"]],
    vocab = colnames(post[["terms"]]),
    doc.length = slam::row_sums(mat, na.rm = TRUE),
    term.frequency = slam::col_sums(mat, na.rm = TRUE)
  )
}

#LDAvis will present you to a new acquaintance: 'lambda'.
#You can control lambda, so you should know what it does.
#We have it from...:
#Sievert, C., & Shirley, K. E. (2014). LDAvis: A method for visualizing and interpreting topics.
#Proceedings of the Workshop on Interactive Language Learning, Visualization, and Interfaces, 2014, 63-70.
#that...:
#'lift', defined as the ratio of a term's probability
#within a topic to its marginal probability across
#the corpus. This generally decreases the rankings
#of globally frequent terms.
#/.../
#Setting lambda = 1 results in the familiar ranking of terms in
#decreasing order of their topic-specific probability, and
#setting lambda = 0 ranks terms solely by their lift.

#ok, got it. Now, just put as argument your LDA model:
serVis(topicmodels2LDAvis(model1)) #call the function with the model (here, model1) as argument.
#Hiccup? You may need to install and load 'servr'.
#Also, you may need to try reload or to allow pop-up windows for rstudio.cloud. 

servr::daemon_stop(1) # to stop the server 

GMY <- "MYA"
GMY
    



