#clean slate...:
rm(list = ls())

#library(rstudioapi)
#setwd(dirname(rstudioapi::callFun("getActiveDocumentContext")$path))

#Standard summary of a topic model...

topjokes <- readRDS("topjokes.rds")

library(data.table)  #The following three lines of codes are not strictly necessary, but they will
#within each subplot arrange terms depending on  their loading.
# create dummy var 'ord' which reflects order when sorted alphabetically
topjokesDT <- setDT(topjokes) #make it a datatable.
topjokesDT[, ord := sprintf("%03i", frank(topjokesDT, topic, beta, ties.method = "first"))]
#we need three digits since nr>100 (818).
head(topjokesDT)

#and then plot
library(ggplot2)
# `ord` is plotted on x-axis instead of `topic`
ggplot(topjokesDT, aes(x = ord, y = beta, fill = factor(topic))) +
  # geom_col() is replacement for geom_bar(stat = "identity")
  geom_col() +
  # independent x-axis scale in each facet, 
  # drop absent factor levels
  facet_wrap(~ topic, nrow = 20, ncol = 5, scale = "free", drop = TRUE) +
  # use named character vector to replace x-axis labels
  scale_x_discrete(labels = topjokes[, setNames(as.character(term), ord)]) +
  # replace x-axis title
  xlab("terms") +
  coord_flip() +
  ggtitle("Top 5 words with loadings per topic 1-100") + 
  #add some colors...
  theme(plot.background = element_rect(fill = c("#FAF1D2")),
        panel.background = element_rect(fill = c("#CFE8DB"), colour = "lightblue", size = 0.5, linetype = "solid"),
        panel.grid.major = element_line(size = 0.5, linetype = 'solid', colour = "white"), 
        panel.grid.minor = element_line(size = 0.25, linetype = 'solid', colour = "white")) +
  theme(text = element_text(size=7)) +
  theme(legend.position = "none")

#Save as pdf in 8.27 (A4 width) * 24 inch to get something scrollable.

rm(list = ls()) #start over

options(warn=-1) #many warnings, little to worry about...

topicDocProbabilities <- readRDS("topicDocProbabilities.rds")

#library(dplyr)
#Total topic loadings
topicTotal <- readRDS("topicTotal.rds") 

topjokes <- readRDS("topjokes.rds")

#We are going to use Jensen Shannon Divergence (JSD)
#to determine the distances between the allocation of each topic over docs.
#We pass these results to a multidimensional scaling (MDS) to investigate
#the interrelatedness of topics. Finally, we cluster the MDS outcome,
#and use the cluster assignements to further our understanding of topics
#via various visualizations.

#JSD
jsd1 <- as.matrix(topicDocProbabilities[ ,2:101]) #Subset columns with topic loadings
library(textmineR)
jsd1 <- CalcJSDivergence(jsd1, y = NULL, by_rows = FALSE)

jsd1 <- as.matrix(jsd1) #to prepare for MDS

#MDS
#jsd1 is a (symmetrical 80*80) distance matrix, 
#so we can pass it down to a MDS...:
fit <- cmdscale(jsd1,eig=TRUE, k=2) # k is the number of dim
x <- fit$points[,1]
y <- fit$points[,2]
plot(x, y, xlab="Coordinate 1", ylab="Coordinate 2", 
     main="Multi dimensional scaling of topics",type="n")
text(x, y, labels = row.names(jsd1), cex=.7)

fitdf <- as.data.frame(fit$points)

#CLUSTERING
## Creating k-means clustering model, and assigning the result to
#the topjokes df
set.seed(427) #hoe about this number, then?
wss <- (nrow(fitdf)-1)*sum(apply(fitdf,2,var)) #within group sum of squares
for (i in 1:25) wss[i] <- sum(kmeans(fitdf,
                                     centers=i)$withinss)
par(mar=c(5.1,4.1,4.1,2.1)) #par sets or adjusts plotting parameters. Not allways necessary. "mar" = margin.
plot(1:25, wss, type="b", xlab="Number of Clusters", #match i
     ylab="Within groups sum of squares", main="Within cluster sum of squares (WCSS)")

set.seed(427)
fit_kmeans <- kmeans(fitdf, 5) # perhaps 7 is better...
clusters <- as.data.frame(as.factor(fit_kmeans$cluster))
clusters <- cbind(rownames(clusters),
                  data.frame(clusters,
                             row.names=NULL))
clusters
names(clusters) <- c("topic","cluster")
head(clusters) #SO we have arrived at some clusters of topics. We want them together with our topwords
#clusters$cluster <- sprintf("%03i", clusters$cluster) 

library(dplyr)
clusters$temp <- factor("Cluster_")
clusters$cluster <- paste(clusters$temp,clusters$cluster)
clusters$cluster <- gsub("[[:space:]]", "", clusters$cluster)
clusters <- select(clusters, -temp)
clusters <- clusters[,c(2,1)]
clusters$topic <- topicTotal$topic
#Lets glue the cluster to our topjokes summary...: 

#If warnings still on:
#warning messages will appear because the joining columns have different level orders. No worries.
joinedjokes <- topjokes %>% #add our clusters
  left_join(y=clusters, by=c("topic")) 
head(joinedjokes)

joinedjokes <- joinedjokes %>% #Add the total topic loading
  left_join(y=topicTotal, by=c("topic"))

TotalLoadingCluster <- joinedjokes %>% #Calculate loadings per cluster based on total topic loading.
  group_by(cluster) %>% 
  summarise(totalclusterloading = sum(totaltopicloading))

joinedjokes <- joinedjokes %>%
  left_join(y=TotalLoadingCluster, by=c("cluster")) #Add the total cluster loading

head(joinedjokes)

#joinedjokes, as we have wrangled it now, is in the form of one row per word,
#with all the hierarchy (above the word, i.e. cluster/topic/word) reported on the same row

#Make use of the wonderful joinedjokes
library(collapsibleTree)
collapsibleTree( joinedjokes, c("cluster", "topic", "term"))

#Supercalifragilisticexpialidocious!

#or
library(data.tree)
#define the hierarchy (cluster/topic/term)
joinedjokes$pathString <- paste("jokes", joinedjokes$cluster, joinedjokes$topic, joinedjokes$term, sep=".")
#convert to Node
jokesRtree <- as.Node(joinedjokes, pathDelimiter = ".")
#something more unusual could be more suitable, eg. "|".

jokesRtree

library(networkD3) #plot with networkD3
jokesRtreeList <- ToListExplicit(jokesRtree, unname = TRUE)
radialNetwork(jokesRtreeList) #pretty. Useless.

#Show the radialNetwork in a browser window...

#PACKED CIRCLE
# Load the library
install.packages("devtools") #This to be able to install packages from github

devtools::install_github("jeromefroe/circlepackeR")
library(circlepackeR)

# Make the plot. You can custom the minimum and maximum value of the color range.
circlepackeR(jokesRtree, size = "beta", color_min = "hsl(188, 34%, 67%)", color_max = "hsl(188, 94%, 14%)")
#This is more useful than pretty. We get a lot of information, presented in a neat way.

#TREEMAPS
library(treemap)
devtools::install_github("d3treeR/d3treeR")
library(d3treeR)
library(RColorBrewer)

kindofpretty2 <- c("#F0F0F0", "#D8E6DB", "#82807F", "#FCECE2", "#C5E5F0")
kindofpretty3 <- c("#FFFFFF", "#FFFFFF", "#FFFFFF", "#FFFFFF", "#FFFFFF",
                   "#FFF5F5", "#F7D8D7", "#634275", "#0E5066")

pscale <- treemap(joinedjokes,
                  index=c("cluster","topic", "term"),
                  vSize= "beta",
                  vColor= "beta",
                  palette = kindofpretty3,
                  type= "value")
pscale
pcategory <- treemap(joinedjokes,
                     index=c("cluster","topic", "term"),
                     vSize="beta",
                     vColor="cluster",
                     palette = kindofpretty2, #You can also use standards.
                     type="index") #colored by cluster, then beta.

pcategory



GMY <- "MYA"
GMY

