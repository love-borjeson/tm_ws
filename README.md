# Topic modeling in R
Topic modeling workshop in R, data and scripts. The workshop goes through *topic modeling*; (tweaking) the *Gibbs sampler*; using and editing a *stoplist*; linguistically inform the model using *Part-of-Speech*, *Lemmatization* and *key-words*; finding the appropriate *number of topics* (hello K!); and, finally, *exporting model results* to the extra-R world (if there is such a world). Bonus scripts (6-7) include code to build and app that will let you *interact with the model and the original data* at the same time and some *eye-candy* if you have the need to impress someone with your results.

A very brief introduction to topic modeling can be found [here](https://docs.google.com/presentation/d/1UPmCKOCR35Bv7atY15pSILNm_HxR_t62IHMkmU-fKa8/edit?usp=sharing).

**Learning and modeling philosophy**

In this workshop we adopt the learning philosophy of [Fast AI](https://www.fast.ai/2016/10/08/teaching-philosophy/). Rather than starting off with the typical “Hello World” and building from ground up (which would take years of training), we start in the other end with state-of-the-art modeling, using very practical, (re-)usable examples. Many of the finer details of both the scripts and the underlying statistical “machinery” will, with this approach, be hard to get immediately, *but that is ok*: scripts and data are written and organized in such a way that each participant can return to whatever section of the workshop that has been unclear to gain a better understanding by themselves. The scripts are plentifully commented and the only command ever needed is ctrl+enter.

This is a *friendly, inclusive*, workshop. We believe that *trying* is the right thing to do, *even when you fail*. We thus *encourage everyone* who is interested to participate, regardless of prior knowledge. Should you feel that you need more preparations (theoretical, technical, or otherwise), that will not be the end of the world.

All material is unlicensed, i.e. donated to the public domain. For R, Rstudio and packages, additional licenses may apply. Please feel free to give credit where credits due.

Responsible for this workshop: [Love Börjeson](love.borjeson@kb.se), Director of KBLab at the National Library of Sweden.

You can take part in the workshop in two ways, in the cloud or locally. Running the workshop in the cloud is recommended for inexperienced R-users, but you loose some functionality. Should you wish to run the workshop in the cloud, switch to this repo: https://github.com/love-borjeson/tm_ws_cloud. Otherwise, continue with the preparations below.

**Preparations** 

It is usually pretty straight forward to complete the preparatory steps below. If you still encounter problems, consult your IT-support at your department. You can also try googling: if you get an error message, try pasting it into your browser.

**Install R and RStudio**

Install R, from here: https://cran.r-project.org/

Install RStudio, from here https://rstudio.com/products/rstudio/ Select *RStudio Desktop Open Scource Edition*.

**Get data and scripts, install necessary packages**

Clone or download this repo.

Under the "Session" menu in RStudio, choose "Set Working Directory" and tell R where you have put your workshop files.

Run the preparation script in R/RStudio named "0_preparations.R"

**Now, get cracking!**

Start the workshop by executing from "1_simple_model.R"

