#clean slate...:
rm(list = ls())

#library(rstudioapi)
#setwd(dirname(rstudioapi::callFun("getActiveDocumentContext")$path)) #won't take '????' etcetera in your filepath.

#Preparations
#You can install packages we need for the workshop via the RStudio menue, or run the below code:

#Need to have
install.packages("tm")
install.packages("topicmodels")
install.packages("slam")
install.packages("LDAvis")
install.packages("servr")
install.packages("textclean")
install.packages("chinese.misc")
install.packages("udpipe")
install.packages("dplyr")
install.packages("tidytext")
install.packages("ldatuning")
install.packages("doParallel")
install.packages("ggplot2")
install.packages("scales")
install.packages("plotly")

#Nice to have
install.packages("data.table")
install.packages("textmineR")
install.packages("collapsibleTree")
install.packages("data.tree")
install.packages("treemap")
install.packages("RColorBrewer")
install.packages("networkD3")

#A couple of the "nice to have packages" are not yet availiable on cran, so we need to get them directly from github
install.packages("devtools") #first install devtools
#then call devtools, point to the repository and get the package from github
devtools::install_github("jeromefroe/circlepackeR") 
devtools::install_github("d3treeR/d3treeR")

#Testload the packages
library(tm)
#If you get this: Error: package or namespace load failed for ‘tm’
#in loadNamespace(j <- i[[1L]], c(lib.loc, .libPaths()), versionCheck = vI[[j]]):
#there is no package called ‘Rcpp’
#...then install the Package "Rcpp".

library(topicmodels)
library(slam)
library(LDAvis)
library(servr)
library(textclean)
library(chinese.misc)
library(udpipe)
library(dplyr)
library(tidytext)
library(ldatuning)
library(doParallel)
library(ggplot2)
library(scales)
library(plotly)
library(data.table)
library(textmineR)
library(collapsibleTree)
library(data.tree)
library(treemap)
library(RColorBrewer)
library(networkD3)

library(circlepackeR)
library(d3treeR)

#I think that's all.

GMY <- "MYA"
GMY
    



