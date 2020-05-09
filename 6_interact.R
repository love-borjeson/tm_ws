rm(list = ls())

#library(rstudioapi)
#setwd(dirname(rstudioapi::callFun("getActiveDocumentContext")$path))

#We will create an app to interact with out topic model via two outputs,
#topicDocProbabilities (gamma) and topic summary. We will enrich the latter a bit.

topicDocProbabilities <- readRDS("topicDocProbabilities.rds")
head(topicDocProbabilities)
topicDocProbabilities[, 2:101] <- round(topicDocProbabilities[, 2:101], 4) #We don't need the full format...

library(topicmodels)
modelBig100 <- readRDS("model_k100.rds") #we'll use a full-sized model

library(dplyr)
library(tidytext) #tidy text communicates with our model objects
jokesterms <- tidy(modelBig100, matrix = "beta")
head(jokesterms)

topjokes <- jokesterms %>%
  group_by(topic) %>%
  top_n(10, beta) %>% #only top 10 terms (by beta) and their beta
  mutate(rank = order(order(beta, decreasing=TRUE))) %>% #rank them 'within' each topic
  ungroup() %>%
  arrange(topic, -beta) %>%
  mutate(term = reorder(term, beta)) #have them sorted...

#Let's improve the labels..:
head(topjokes)
str(topjokes)
topjokes$topic <- sprintf("%03i", topjokes$topic) #to get the order of plots right
topjokes$topic <- as.factor(topjokes$topic) #Make topic no a factor
topjokes$temp <- factor("Topic_") #create a new column/var filled with the word Topic_
topjokes$topic <- paste(topjokes$temp,topjokes$topic) #Paste together
topjokes$topic <- gsub("[[:space:]]", "", topjokes$topic) #Take away white space
topjokes <- select(topjokes, -temp) #Remove temp column.
#All this just to get the word "Topic" into the topics column. Phew!
saveRDS(topjokes, file = "topjokes.rds") #We'll need this later
head(topjokes)

topjokes <- as.data.frame(topjokes) #Make topjokes a dataframe (and not just a tibble)
topjokes$beta <- round(topjokes$beta, 4) #round to four digits...

#Reshape topjokes to wideformat and transpose, i.e. topics are columns after this:
topjokes_w <- t(reshape(topjokes, idvar = "topic", timevar = "rank", direction = "wide"))
head(topjokes_w)

colnames(topjokes_w) <- as.character(unlist(topjokes_w[1,])) #make top row columnnames
topjokes_w = topjokes_w[-1, ]

#Get total topic loadings
topicTotal <- as.data.frame(colSums(topicDocProbabilities[, c(2:101)]))
topicTotal$topic <- seq.int(nrow(topicTotal))
topicTotal$topic <- sprintf("%03i", topicTotal$topic) #to be able to match this to previous results further down the line
topicTotal$topic <- as.factor(topicTotal$topic) #Make topic no a factor
topicTotal$temp<- factor("Topic_") #create a new column/var filled with the word Topic_
topicTotal$topic <- paste(topicTotal$temp,topicTotal$topic) #Paste together
topicTotal$topic <- gsub("[[:space:]]", "", topicTotal$topic) #Take away white space
topicTotal <- select(topicTotal, -temp) #Remove temp column.
names(topicTotal)[1] <- "totaltopicloading"
head(topicTotal)

saveRDS(topicTotal, file = "topicTotal.rds") #for later use

topicTotal$totaltopicloading <- round(topicTotal$totaltopicloading, 4) #round to four digits

topicTotal_t <- as.data.frame(t(topicTotal[ ,2:2])) #make data.frame, transpose
colnames(topicTotal_t) <- colnames(topjokes_w) #resuse names from topjokes
head(topicTotal_t)

topjokes_w <- rbind(topicTotal_t, topjokes_w) #bind togehter
rownames(topjokes_w)[rownames(topjokes_w) == "1"] <- "Total loading" 
head(topjokes_w)

#Now we'll create the app...:
library(shiny)
library(DT)

#The user interface
ui <- fluidPage(
  title = "Examples of DataTables",
  sidebarLayout(
    sidebarPanel(
      conditionalPanel(
        'input.dataset === "topicDocProbabilities"'
      ),
      
      conditionalPanel(
        'input.dataset === "topjokes_w"'
      ),
      width = 4,
      helpText("Here you can interact with the model and the data at the sametime"),
    ),
    mainPanel(
      tabsetPanel(
        id = 'dataset',
        tabPanel("Documents and topics", DT::dataTableOutput("tbl")),
        tabPanel("Top words per topic", DT::dataTableOutput("tbl2"))
      ),
      width = 30
    )
  )
)

#The server function
#####################################################################
#HOW TO CREATE A VECTOR WITH TOPIC SUMMARY TO DISPLAY ON MOUSE-OVER:
vec <- as.data.frame(terms(modelBig100 ,10)) #Summarize.
vect <- as.data.frame(t(vec)) #Transpose
library(tidyr)
vect2 <- vect %>% unite("z", sep=',', V1:V10, remove = T) #Conflate words within each topic
vect2$z <- paste0(" '", vect2$z) #Insert ' in beginning
vect2$z <- paste0(vect2$z, "'") #... and in the end
vect2 <- as.data.frame(t(vect2)) #Transpose
vect2 <- vect2 %>% unite("z", sep=',', c(1:100), remove = T) #Conflate between topics
print(vect2) #Copy the print output from the console and paste it into the Javascript below after "callback = JS("var tips = ['Row Names', 'doc',"
#This is already done below (at your service, allways...)
#####################################################################

server <- function(input, output) {
  
  # sorted columns are colored now because CSS are attached to them
  output$tbl <- DT::renderDataTable({
    DT::datatable(topicDocProbabilities[, 1:103],
                  extensions = c('FixedColumns'),
                  callback = JS("var tips = ['Row Names', 'doc', 
    'back,wall,time,oil,king,place,true,matter,great,jack', 'car,driver,window,truck,road,side,wheel,front,highway,gas', 'manager,night,momma,dumb,poor,grandma,dude,telephone_store,tomato,mamma', 'sex,lady,condom,drug,sexual,cigarette,pharmacist,worm,safe,smoke', 'new,line,time,next,idea,much,deal,sale,several,market', 'fart,group,one,way,time,common,good,whole,most,gas', 'baby,fire,pregnant,department,best,plant,right,fact,month,hard', 'farmer,pig,field,farm,duck,bucket,tourist,sheep,well,sweet', 'number,phone,machine,call,hello,name,message,telephone,please,line', 'computer,mouse,help,key,power,email,button,customer,desk,address', 'letter,name,word,more,only,average,first,language,time,moon', 'american,chinese,french,pope,german,mexican,japanese,italian,russian,jewish', 'young_man,beautiful,one,nice,perfect,cowboy,couple,young,smart,handsome', 'box,chocolate,time,rock,one,cookie,full,dark,camel,chip', 'police,gun,death,accident,record,crime,head,knife,state,story', 'well,yes,sir,sorry,reply,okay,right,nice,upset,receptionist', 'water,fish,cold,hot,parrot,boat,air,wood,ice,winter', 'priest,point,nun,rabbi,reply,candy,catholic,good_morning,bishop,true',
    'free,law,government,bridge,time,bad_news,good_news,tax,right,tha', 'tree,few,top,short,bike,right,nut,ugly,dirty,last', 'black,redneck,white,red,shoe,shirt,suit,blue,pair,color', 'head,leg,right,arm,side,left,wooden,artist,next,tattoo', 'plane,seat,pilot,flight,agent,air,passenger,airplane,engine,airport', 'judge,case,truth,court,way,witness,time,charge,defendant,guilty', 'life,age,heaven,indian,good,other,great,chief,rest,big', 'minute,hour,time,clock,bell,degree,day,lie,shoulder,afternoon', 'man,first_man,second_man,penis,third_man,few_minute,rest,brick,embarrassed,special', 'woman,man,breast,women,wrong,need,item,equal,several,dress', 'more,mile,half,pound,time,hour,weight,other,high,low', 'hand,bill,time,else,security,back,other,sound,server,drip', 'bar,beer,bartender,drink,drunk,glass,can,shot,sit,whiskey', 'eye,finger,ear,hair,long,other,blind,nose,lesbian,tongue', 'people,person,same,different,only,one,last,air,art,cake', 'child,parent,family,gay,home,school,marriage,great,kid,half', 'order,large,pizza,other,conversation,voice,time,last,food,one', 'brain,engineer,life,prime,mistake,other,idiot,experience,cell,day', 'difference,common,one,guard,prison,favorite,more,good,period,better',
    'word,cow,milk,bull,other,costello,sentence,more,office,trouble', 'guy,same,next_day,buddy,2nd,first_guy,sure,1st,amazing,cake', 'old,old_man,year,young,gentleman,older,elderly,well,time,age', 'money,dollar,bank,much,cent,check,account,change,business,rich', 'problem,wrong,way,morning,sure,while,usage,master,solution,tomorrow', 'question,answer,exam,test,one,correct,sure,final,last,many', 'please,hotel,yesterday,today,room,own,dear,shop,soap,best', 'blonde,brunette,blond,redhead,hair,red,head,turn,dumb,blanket', 'human,toy,cat,good,game,door,food,other,time,bed', 'room,bed,night,roommate,sleep,hour,window,floor,time,ghost', 'bag,bottle,warning,plastic,product,box,food,mouth,use,direction', 'officer,cop,bird,ticket,policeman,donkey,sorry,police_officer,police,license', 'joke,site,page,user,information,other,type,list,such,web_site', 'thing,way,lot,important,stuff,time,whole,only,rat,better', 'fat,mama,stupid,momma,tooth,ugly,yellow,scale,mouth,side', 'year,month,time,last,island,next,ready,better,many_year,last_year', 'people,one,car,water,bottom,hell,day,fire,possible,word', 'shit,ass,hell,chair,day,mountain,monk,bitch,pot,damn', 'world,country,great,place,land,history,famous,city,largest,peace',
    'doctor,patient,hospital,nurse,office,pain,psychiatrist,pill,care,surgery', 'kid,voice,small,frog,time,little,shout,own,fast,movie', 'store,customer,clerk,owner,shop,counter,sale,salesman,pet,price', 'house,home,neighbor,street,holiday,one,grass,night,more,study', 'brother,sister,year_old,happy,birthday,uncle,family,grandmother,grandfather,cousin', 'shotgun,rule,passenger,car,seat,driver,amendment,other,call,person', 'ball,hole,golf,club,shot,green,course,golfer,round,dick', 'window,computer,system,virus,file,program,error,version,software,bug', 'door,floor,next,open,elevator,stair,dentist,trick,doorbell,front_door', 'knock,fan,enough,baseball,small,ceiling,double,paint,lot,same', 'front,top,pool,watch,blah,bottom,board,stranger,stuff,bean', 'way,story,general,ship,soldier,enemy,private,army,tank,moron', 'bathroom,toilet,shower,kind,mirror,towel,sure,butt,roll,stall', 'elephant,animal,bear,lion,rabbit,monkey,snake,cage,zoo,hat', 'day,end,run,lake,rug,monkey,hallway,forest,last,trapdoor', 'work,job,boss,office,lunch,time,worker,good,meeting,coworker', 'face,heart,look,roundhouse_kick,turkey,blood,head,deer,single,world', 'pants,bus,train,date,station,other,banana,track,step,turn',
    'dog,name,tail,tiger,chain,walk,butcher,radio,pet,basket', 'book,dear,other,next,god,hard,whole,funny,mind,people', 'many,lightbulb,light_bulb,wish,genies,apple,none,beach,lamp,pile', 'little,big,better,kiss,one,prof,wolf,hey,voice,river', 'wife,husband,couple,marriage,honey,married,love,night,divorce,happy', 'teacher,class,student,school,professor,grade,principal,college,senior,homework', 'boy,father,son,dad,little_boy,well,young,yellow_golf_ball,proud,family', 'hey,well,sure,yeah,fine,okay,cool,wow,like,buck', 'week,day,today,card,next_day,time,flower,tomorrow,report,weekend', 'girl,other,love,girlfriend,boyfriend,date,fun,okay,relationship,movie', 'foot,ground,building,inch,piece,rope,roof,tall,height,short', 'illegal,law,street,city,state,person,public,place,man,more', 'friend,game,team,player,football,real,coach,time,sport,other', 'horse,dead,commandment,local,cliff,great,same,edge,rancher,example', 'lawyer,other,attorney,good,funeral,grave,client,department,old_woman,defense', 'chicken,road,sign,town,other_side,way,local,side,middle,own', 'church,service,preacher,pastor,minister,congregation,morning,crowd,member,back', 'table,restaurant,food,dinner,egg,bread,waiter,meal,kitchen,waitress',
    'good,bad,better,lot,reason,angel,luck,big,same,mind', 'party,part,wedding,dress,dinner,best,bride,direction,front,guest', 'company,female,male,employee,new,interviewer,plan,management,candidate,interview', 'cat,coffee,cup,mouth,vet,tea,pill,close,open,table', 'mother,mom,daughter,dad,little_girl,mommy,daddy,last_night,little,room', 'body,light,naked,temperature,kind,part,moment,soul,earth,degree', 'paper,note,picture,piece,video,tape,camera,way,scream,large', 'first,second,third,last,base,fourth,first_one,full,time,pause'
    ],
    header = table.columns().header();
for (var i = 0; i < tips.length; i++) {
  $(header[i]).attr('title', tips[i]);
}"), # The pasted topic-summary-vector above has to be diveded into seperate lines, 3-5... Or R won't read them.
                  options = list(
                    pageLength = 10,
                    lengthMenu = c(5, 10, 15, 20),
                    scrollX = TRUE,
                    fixedColumns = list(leftColumns = 2, rightColumns = 2),
                    fixedHeader = TRUE,
                    autoWidth = TRUE,
                    columnDefs = list(list(width = '600px', targets = c(103))
                    )))%>% formatStyle(names(topicDocProbabilities[, 2:101]),
                                       background = styleColorBar(range(topicDocProbabilities[, 2:101]), 'lightblue'),
                                       backgroundSize = '98% 88%',
                                       backgroundRepeat = 'no-repeat',
                                       backgroundPosition = 'center')
    
  })
  
  output$tbl2 <- DT::renderDataTable({
    DT::datatable(topjokes_w,
                  extensions = c('FixedColumns', "Buttons"),
                  options = list(
                    pageLength = 25,
                    dom = 'Bfrtip',
                    buttons = c('csv', 'excel', 'pdf', 'print'),
                    scrollX = TRUE,
                    fixedColumns = list(leftColumns = 1),
                    fixedHeader = TRUE,
                    autoWidth = TRUE
                  ))
  })
  
}

#Combine user interface and server function into an app:
shinyApp(ui, server)

#check out, e.g., topic no 5.

GMY <- "MYA"
GMY
