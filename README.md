# Topic modeling in R
Topic modeling workshop in R, data and scripts. The workshop goes through *topic modeling*; (tweaking) the *Gibbs sampler*; using and editing a *stoplist*; linguistically inform the model using *Part-of-Speech*, *Lemmatization* and *key-words*; finding the appropriate *number of topics* (hello K!); and, finally, *exporting model results* to the extra-R world (if there is such a world). Bonus scripts (6-7) include code to build and app that will let you *interact with the model and the original data* at the same time and some *eye-candy* if you have the need to impress someone with your results.

Below follows instructions on how to prepare for the workshop.

Identical instructions in Swedish can be found here:

https://docs.google.com/document/d/1OcbGpYs6L_KmWT6EYhjpi3MZJzX3CaNhHfDCrP5alDw/edit?usp=sharing

All material is unlicensed, i.e. donated to the public domain. Please feel free to give credit where credits due.

Responsible for this workshop: *[Love Börjeson](love.borjeson@kb.se) ,*Director of KBLab at the National Library of Sweden

**PREPARATIONS**

Usually, it is usually pretty straight forward to complete the preparatory steps below. If you still encounter problems, consult your IT-support at your department. You can also try googling: if you get an error message, try pasting it into your browser.

**Install R and RStudio**
Install R, from here: https://cran.r-project.org/

Install RStudio, from here https://rstudio.com/products/rstudio/ Select *RStudio Desktop Open Scource Edition*.

**Install the necessary packages**
Open Rstudio. RStudio's workspace is divided into different fields. In the lower right field, there are menus for *Files*, *Plots*, *Packages*, *Help* and *Viewer* options.

Select *Packages* and then *Install*. You will now see a dialog box. In it, enter the name of the package and press install. Do not change any other settings in the dialog box. Install the following packages one at a time:

- tm
- topicmodels
- slam
- LDAvis
- servr
- textclean
- chinese.misc
- slam
- udpipe
- dplyr
- parallel
- ldatuning
- doParallel
- ggplot2
- scales
- plotly

It will take a while to install all packages. In RStudio, a small red stop button will be displayed as long as R is working on an installation. As long as it is red, do not interrupt, close, or give the program new instructions.

**Download workshop material and tell R where you put the material**
Download all material in this repository using the green drop-menu button *Clone or download* and select *download ZIP*.

Create a folder for the workshop on your computer and save the zip file there. Unzip.

Open RStudio. In the RStudio's menu bar at the top, you will find the *Session* menu. Open it and navigate to *Set Working Directory* / *Choose Directory*. You will then get a regular navigation window where you navigate to the folder where you put the lab material.