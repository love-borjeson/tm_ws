#clean slate...:
rm(list = ls())

#library(rstudioapi)
#setwd(dirname(rstudioapi::callFun("getActiveDocumentContext")$path))

library(udpipe)

Eng_model <- udpipe_download_model(language = "english") #Just specify the language of your data here.
#UDpipe have more than 60 languages available. Awesome.

Eng_model <- udpipe_load_model(Eng_model$file_model) #and load to be used in this session

testtext <- read.csv("SmallTest.csv", stringsAsFactors=FALSE)
testtext

z <- udpipe_annotate(Eng_model, x = testtext$text, doc_id = testtext$doc_id)
z <- as.data.frame(z)
View(z)
#Handles twitter better than Shakespeare, apparently.
rm(z)


###############################For reference!
#parallelize!!
#Annotation - unlike topic modeling - can be readily parallelized.
#library(parallel) #This package speaks with udpipe.
#cores <- detectCores(logical = TRUE) - 1 #leave one-two for stability
#And then run the annotation...:
#x <- udpipe(Text1Full, Eng_model, parallel.cores = cores)
###############################

x <- readRDS("annotated_jokes.rds") #pre-annotated our joke sub-sample to save time...

x$topic_level_id <- unique_identifier(x, fields = c("doc_id", "paragraph_id", "sentence_id"))

#clean
library(textclean)
x$lemma <- strip(x$lemma, char.keep = c(), digit.remove = F,
                 apostrophe.remove = T, lower.case = T) #Clean conservatively at first.
#create keywords
keyw_rake2 <- keywords_rake(x, 
                            term = "lemma", group = c("sentence_id"),
                            relevant = x$upos %in% c("NOUN", "ADJ"),
                            ngram_max = 3, n_min = 5) #Relevant: nouns and adjectives. Optioanlly, include all open classes
                            #n_min may have to be increased when modelling on a larger corpus

keyw_rake2 <- subset(keyw_rake2, ngram > 1) #only keep keywords if they are > 1 word.

# Recode terms to keywords
x$term <- x$lemma #Let's model on lemmas if not kw.
x$term <- txt_recode_ngram(x$term, 
                           compound = keyw_rake2$keyword, ngram = keyw_rake2$ngram)

## Keep keyword or just plain nouns, adj or adv
#REF http://hackage.haskell.org/package/rake:
#Rapid Automatic Keyword Extraction (RAKE) is an algorithm (well-known and widely used) to automatically extract keywords from documents.
#Keywords are sequences of one or more words that, together, provide a compact representation of content.
#But hey! Isn't that what topic modeling is supposed to do? True.
#We do it to reduce the dimensionality a bit by representing common bigrams as one word.
x$term <- ifelse(x$upos %in% c("NOUN", "ADJ"), x$term,
                 ifelse(x$term %in% c(keyw_rake2$keyword), x$term, NA)) #Include lemmas of NOUN and ADJ and kw. Otherwise NA.
                 #Cf https://universaldependencies.org/u/pos/index.html

# Build document/term/matrix
dtf <- document_term_frequencies(x, document = "doc_id", term = "term") #model on docs.
dtf$term <- gsub(" ", "_", dtf$term, fixed = TRUE) #Whitestrips to underscore
dtf$term <- gsub('\\b\\w{1,2}\\b','',dtf$term) #wordlengts
dtf$term <- gsub('\\b\\w{150,}\\b','',dtf$term) #wordlengts, longer since we have keywords
dtf$term <- gsub(" ", "", dtf$term, fixed = TRUE) #Whitestrips removal
dtf <- dtf[!(is.na(dtf$term) | dtf$term==""), ] #remove empty rows
dtmKW <- document_term_matrix(x = dtf) #Save as dtm
dtmKW <- dtm_remove_lowfreq(dtmKW, minfreq = 3) #This is the direct method to trim the dtm.
saveRDS(dtmKW, file = "dtmKW.rds")

#A more dynamic approach is to use tf-idf, see below.
#TF-IDF =
#term frequency- (log scaled) inverse document frequency,
#can be used to filter away very infrequent words AND words frequent in many docs
#https://en.wikipedia.org/wiki/Tf%E2%80%93idf#Inverse_document_frequency
dgCM_dtm <- document_term_matrix(x = dtf) #make a non-zero dtm
dtm_tfidfVector <- as.data.frame(dtm_tfidf(dgCM_dtm)) #check out the vector
View(dtm_tfidfVector)
dgCM_dtm <- dtm_remove_tfidf(dgCM_dtm, cutoff=2) #Decide cut-off after studying the tfidf-vector.

#But let's for now, use the dtmKW
rm(dgCM_dtm)
rm(dtm_tfidfVector) #Cleaning up a bit-

#remodel
library(topicmodels)
k = 24

#the sampler, as before
controlGibbs <- list(seed = 5683, #what does this mean?
                     burnin = 200,
                     iter = 500)

model4 <- LDA(dtmKW, k, method = "Gibbs", control = controlGibbs) #Model...
terms(model4,10) #Looks ok.
#To fine-tune and add a (short) stoplist, use LDAvis as before.
dtmKW <- dtm_remove_terms(dtmKW, terms = c("wtfe")) #This is what we need to develop.
#remodel.....
# and then visualize. If you do, you will notice that the LDA is symmetric with this approach as well.

#But what about K?

GMY <- "MYA"
GMY
    



