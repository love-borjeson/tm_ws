#clean slate...:
rm(list = ls())

#library(rstudioapi)
#setwd(dirname(rstudioapi::callFun("getActiveDocumentContext")$path)) #won't take '????' etcetera in your filepath.

#Preparations
#You can install packages we need for the workshop via the RStudio menue, or run the below code:

install.packages("tm")
install.packages("topicmodels")
install.packages("slam")
install.packages("LDAvis")
install.packages("servr")
install.packages("textclean")
install.packages("chinese.misc")
install.packages("udpipe")
install.packages("dplyr")
install.packages("ldatuning")
install.packages("ggplot2")
install.packages("scales")
install.packages("plotly")

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
library(ldatuning)
library(ggplot2)
library(scales)
library(plotly)



GMY <- "MYA"
GMY
    



