#clean slate...:``
rm(list = ls())

#library(rstudioapi)
#setwd(dirname(rstudioapi::callFun("getActiveDocumentContext")$path))

text1_small <- readRDS("smalltext1.rds")

#Clean the text
library(textclean)
text1_small$text <- strip(text1_small$text, char.keep = c(), digit.remove = TRUE,
                    apostrophe.remove = TRUE, lower.case = FALSE)
#Most nonsense is done away with allready by the strip function above.
#By char.keep, exceptions can be made.
#'textclean' has some quite powerful and yet precise tools that are handy if you are dealing with
#hashtags, webpages, dates, emails, emojis, money, titles, etcetera.
#Text clean can strip them, or, spell them out.
#You could also check out the package 'qdap'.
#If everything else fails, use gsub, e.g.:

#gsub('[[:digit:]]+', '', x)
#gsub('[[:punct:]]', '', x)
#Pretty flexible and powerful as well.

library(tm)
corp2 <- VCorpus(DataframeSource(text1_small)) #create a corpus.
#Some of the more powerful cleaning/manipulating tools do this directly on the text(see above).
#That has the advantage of giving us more options downstream
#(i.e. passing the text to some other package, e.g. 'udpipe'),
#without getting stuck in the rather rigid "corpus".

#clean up the corpus, extended
corp2 <- tm_map(corp2, removePunctuation) #Potentially redundant because of the textclean/strip above.
corp2 <- tm_map(corp2, removeNumbers) #Potentially redundant because of the textclean/strip above.
#should there still be  nuisance characters left we can use a dedicated function to get rid of it:
toSpace <- content_transformer(function (x , pattern ) gsub(pattern, " ", x)) #the function uses the R base gsub.
corp2 <- tm_map(corp2, toSpace, "@") #pretty convinient.
corp2 <- tm_map(corp2, toSpace, "$") #pretty convinient.
#But hey! $ (and alike) could carry meaning, so be careful!
#Using textclean or qdap can transform symbols to words.
corp2 <- tm_map(corp2, content_transformer(tolower))
corp2 <- tm_map(corp2, removeWords, stopwords("english")) #See:
#http://www.ai.mit.edu/projects/jmlr/papers/volume5/lewis04a/a11-smart-stop-list/english.stop
corp2 <- tm_map(corp2, stripWhitespace)

#'Pneumonoultramicroscopicsilicovolcanoconiosis' is the longest word I (don't really) know in the English language.
#It is 45 chr long. We can exclude it and longer words when creating the document term matrix.
#Short words tend to clog up our model as well. Let's stay in the interval  of 3-45.
dtm2 <- DocumentTermMatrix(corp2, control=list(wordLengths=c(3,45)))

#Now, to complicate things a bit, we want to inspect the dtm but only after converting it
#to a sparse matrix (zeros not stored). We need slam (to deal with matrixes) and 
#chinese miscellaneous to convert between different dtm-forms:
library(chinese.misc)
library(slam)
dtm2Sparse <- m3m(dtm2, "dgCMatrix")

library(udpipe) #udpipe is a very impressive NLP package in R. We'll look in to it more presently.
#Here we use it only to get word fq in a convenient way:
dtmfq <- as.data.frame(dtm_colsums(dtm2Sparse))
names(dtmfq)[1] <- "word_fq"
dtmfq <- cbind(rownames(dtmfq),
               data.frame(dtmfq,
                          row.names=NULL))
names(dtmfq)[1] <- "words"
library(dplyr) #dplyr for some basic data wrangling
dtmfq <- dtmfq %>%
  arrange(desc(word_fq))

dtmfq$rank <- 1:nrow(dtmfq)

View(dtmfq) #This is what we wanted to accomplish. 
#Typically, words that are very frequent don't provide much insight,
#since they are spread across many topics and documents.
#When included in a model, topics tend to get hard to distinguish from one and other.
#Words that are very infrequent on the other hand, are only deadweight.
#Trimming away the infrequent words is fairly easy and it's hard to get it completely wrong.
#in the other end of the scale, one has to proceed with caution: frequent words,
#especially **** after applying a standardized stoplist ****, are important, at least to the corpus.
#Don't take away to much and iterate. That is why we want to carefully inspect the word fq.
#In line with this argument, let's use the top words as a
#curated extra stoplist for maximum control.

#In my world, the top 10 words in 'dtmfq' are disposable. Put them in a vector:
topw <- top_n(dtmfq, 10, word_fq) #a wrapper from dplyr that uses
#filter and min_rank to select the top n.
topw$words <- as.character(topw$words)
str(topw)
topw <- c(topw$words)
topw #our curated stoplist:

#Now strip the corpus from the word in our stoplist
corp2 <- tm_map(corp2, removeWords, topw) #remove it from the corpus.
#recreate the dtm, get rid of the infq (less than 6) words as well, using the bounds argument..:
dtm2 <- DocumentTermMatrix(corp2, control=list(bounds = list(global = c(5,Inf)), wordLengths=c(3,45)))


#An alternative is to use a more dynamic approach:
# ignore overly sparse terms (appearing in less than 1% of the documents)
# ignore overly common terms (appearing in more than 80% of the documents)
#like so:
#ndocs <- length(corp2) #length of corpus
#percentages of ndocs..:
#minDocFreq <- ndocs * 0.01 #or simply a fq here, for more control
#maxDocFreq <- ndocs * 0.8 #and then
#dtm2_d <- DocumentTermMatrix(corp2,
#                             control = list(bounds = list(global = c(minDocFreq, maxDocFreq)),
#                                            wordLengths=c(3,45)))
#hats off to trungnv@stackoverflow.
#With this approach, however, we do not know exactly what we are taking away.

#In the same vein:
#Create function:
#removeCommonTerms <- function (x, pct) 
#{
  #stopifnot(inherits(x, c("DocumentTermMatrix", "TermDocumentMatrix")), 
            #is.numeric(pct), pct > 0, pct < 1)
  #m <- if (inherits(x, "DocumentTermMatrix")) 
    #t(x)
 #else x
  #t <- table(m$i) < m$ncol * (pct)
  #termIndex <- as.numeric(names(t[t]))
  #if (inherits(x, "DocumentTermMatrix")) 
    #x[, termIndex]
  #else x[termIndex, ]
#}

#And then aplly function directly on th dtm
#dtm2 <- removeCommonTerms(dtm, .8)

#Let's get back on track
#clean the dtm from NA:s
nrow(dtm2)
ui <- unique(dtm2$i)
dtm2 <- dtm2[ui,]
nrow(dtm2)

#Lets continue with dtm2 and remodel
#Typically, we would now try to identify K (no of topics),
#model with K, inspect and tweak the stoplists (and possibly other params),
#find K again and then remodel.
#Theoretically, this loop could go on forever.
#It takes time to fit a model and it takes even longer time to find K.
#After about 5-10 loops/iterations,
#we should be about done or at least see some noticeable progression.
#if not, consider some drastic measures to move forward.
#First we tweak the sampler and use..:
k <- 24 #no of topics

#Suggested default settings of the sampler for a full-blown proper model
controlGibbs <- list(#alpha is the numeric prior for document-topic multinomial distribution,
                     #i.e. smaller alpha means fewer topics per document.
                     #Starting value for alpha is 50/k as suggested by Griffiths and Steyvers (2004).
                     alpha = 50/k,                   
                     estimate.beta = TRUE, #Save logarithmized parameters of the term distribution over topics.
                     #Not a prior in 'topicmodels'! See 'delta' below.
                     verbose = 0, #no information is printed during the algorithm
                     save = 0, #no intermediate results are saved
                     keep = 0, #the log-likelihood values are stored every 'keep' iteration. For diagnostic purposes.
                     seed = list(5683, 123, 8972, 7, 9999), #seed needs to have the length nstart.
                     nstart = 5, #no of independent runs
                     best = TRUE, #only the best model over all runs with respect to the log-likelihood is returned.
                     #Default is true. But read first:
                     #http://cs.colorado.edu/~jbg/docs/2014_emnlp_howto_gibbs.pdf
                     delta = 0.1, #numeric prior for topic-word multinomial distribution. 
                     #The default 0.1 is suggested in Griffiths and Steyvers (2004).
                     #Also, 'delta', ususally referred to as 'beta'. Yes. Confusing.
                     #Decreasing 'Delta' ('beta'), e.g. from 0.1 to 0.001 will increase the granularity of the model.
                     #If topics appear to be to general and hard to distinguish, manipulating 'delta' (lowering its value) 
                     #could be a strategy. If topcs are too particular, go the opposite way.
                     iter = 2000, #>1000
                     burnin = 5, #>200, to throwaway the first inaccurate samples. Default set to 0.
                     thin = 2000) #Default = iter, that is to say we only need the stationary state of the last iteration.
                     # setting iter=thin is sometimes disputed, optionally thin to have >10 samples.
                     #Following Griffiths and Steyvers (2004).

#The priors above, especially alpha and delta (beta), are our guesses on properties of data.
#We typically inherit these guesses from someone  else, i.e. we use standard values suggeted in a paper somewhere.
#Priors are nonetheless slippery since they can have large effect on what we "find": finding is ths more "shaping".
#TM in other words, relies heavily on the integrity of the researcher. The quality of your TM thus relies on YOU!
#Transparency vis-a-vis your methodological choices are crucial.

#simplified sampler for the purpose of this lab
controlGibbs <- list(seed = 5683, #what does this mean?
                     burnin = 200,
                     iter = 500)

library(topicmodels)
model2 <- LDA(dtm2, k, method = "Gibbs", control = controlGibbs) #Model...
terms(model2,10)#Summarize.
#Better... 
#The stoplist nonetheless may need to be extended. 

#Visualize
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

library(LDAvis)
serVis(topicmodels2LDAvis(model2))
#Notice how the size (and spread) of topics (in the MDS) is much more even than before.
#We can now say that the model i symmetric, which is a good thing,
#since there's not any implementation for an asymmetric LDA in R (know to me, at least)
#The symmetry is the result of dropping all to frequent words).
#See if we can come up with 5-15 more words to remove, using LDAvis.

LabStop <- c("wtfe") #..and put them in here. EACH PARTICIPANT OWE ME ONE WORD!!!!!
#remove them
corp2 <- tm_map(corp2, removeWords, LabStop)
#recreate the dtm..
dtm2 <- DocumentTermMatrix(corp2, control=list(bounds = list(global = c(5,Inf)), wordLengths=c(3,45)))
#clean the dtm from NA:s
ui <- unique(dtm2$i)
dtm2 <- dtm2[ui,]
nrow(dtm2)
#remodel
model2 <- LDA(dtm2, k, method = "Gibbs", control = controlGibbs) #Model...
terms(model2,10)#Summarize.

#Visualize
serVis(topicmodels2LDAvis(model2))
servr::daemon_stop(1) # to stop the server 

#But what about K?

GMY <- "MYA"
GMY
