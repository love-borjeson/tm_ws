# tm_ws
Topic modeling workshop in R, data and scripts.

Instructions for preparations can be found here (currently only in Swedish):

https://docs.google.com/document/d/1OcbGpYs6L_KmWT6EYhjpi3MZJzX3CaNhHfDCrP5alDw/edit?usp=sharing

All material is unlicensed, i.e. donated to the public domain. Please feel free to give credit where credits due.

**FÖRBEREDELSER**

*Kontakt: Love Börjeson, [**love.borjeson@kb.se**](mailto:love.borjeson@kb.se)*

Oftast är det enkelt att genomföra de förberedande stegen nedan. Om du ändå stöter på problem, ta hjälp av din IT-avdelning på din institution. Man kan också försöka med att googla: får du ett felmeddelande, prova att klistra in det i din webläsare.

**Installera R och RStudio**

Installera R, härifrån: https://cran.r-project.org/

Installera RStudio, härifrån https://rstudio.com/products/rstudio/ Välj RStudio Desktop Open Scource Edition.

**Installera nödvändiga paket**

Öppna Rstudio. RStudios arbetsyta är uppdelad i olika fält. I den nedersta, högra fältet finns det en meny med alternativen Files, Plots, Packages, Help och Viewer. Välj Packages och sedan Install.

Du får nu upp en dialogruta. I den skriver du in paketets namn och trycker på install. Ändra inga inställningar i dialogrutan i övrigt. Installera, ett i taget, följande paket:

- tmtopicmodels
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

Det kommer ta ett tag att installera alla paket. I RStudio kommer det visas en liten röd stoppknapp så länge R arbetar med en installation. Så länge den är röd ska man inte avbryta, stänga av eller ge programmet nya instruktioner.

**Ladda ned workshopmaterial och tala om för R var du lagt materialet**

Här hittar du allt material du behöver till workshopen: https://github.com/love-borjeson/tm_ws Använd den gröna knappen Clone or download och välj download ZIP.

Skapa en mapp för workshopen på din dator och spara zipfilen där. Extrahera zipfilen.

Öppna RStudio. I RStudios menyrad högst upp hittar du menyn Session. Öppna den och navigera till Set Working Directory/Choose Directory. Du får då upp ett vanligt navigeringsfönster där du navigerar dig fram till den mapp där du lagt labbmaterialet.