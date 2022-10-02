library(tidyverse)
library(httr)
library(urltools)
library(RSelenium)
library(rvest)
library(jsonlite)
library(stringr)
library(dplyr)
library(writexl)
library(rcrossref)
library(usethis)
library(listviewer)
library(devtools)
library(rAltmetric)
library(js)
library(bibliometrix)

# 월별 그래프 그리기

# 우선 medrxiv_list의 자료를 월별로 정리하는 코드입니다. 보시면 2019년 것이 없습니다.
# 해당 코드를 돌린 것은 date_count_medrxiv.R 파일에 저장되어있습니다. 
# date_count_medrxiv<-readRDS("?")에서 ?에다가 위의 파일이 저장된 경로를 넣으면 됩니다.

date_count_medrxiv<-data.frame(matrix(ncol=2,nrow=0))

for(i in 1:length(medrxiv_list)){
  date_of_my <- gsub(pattern=" [[:digit:]]+, ", replacement=", ",x=medrxiv_list[[i]]$date)
  date_of_my <- gsub(pattern="\\.", replacement="",x=date_of_my)
  date_count_medrxiv <- rbind(date_count_medrxiv, c(date_of_my,1))
}

colnames(date_count_medrxiv)<-c("Date", "Count")

date_count_medrxiv$Count<-as.integer(date_count_medrxiv$Count)

date_count_medrxiv<-aggregate(Count~Date,date_count_medrxiv,sum)

date_count_medrxiv$Date <- factor(date_count_medrxiv$Date,
                                  levels = c("January, 2020",
                                             "February, 2020",
                                             "March, 2020",
                                             "April, 2020",
                                             "May, 2020",
                                             "June, 2020",
                                             "July, 2020",
                                             "August, 2020",
                                             "September, 2020",
                                             "October, 2020",
                                             "November, 2020",
                                             "December, 2020",
                                             "January, 2021",
                                             "February, 2021",
                                             "March, 2021",
                                             "April, 2021",
                                             "May, 2021",
                                             "June, 2021",
                                             "July, 2021",
                                             "August, 2021",
                                             "September, 2021",
                                             "October, 2021",
                                             "November, 2021",
                                             "December, 2021",
                                             "January, 2022",
                                             "February, 2022",
                                             "March, 2022",
                                             "April, 2022",
                                             "May, 2022",
                                             "June, 2022",
                                             "July, 2022"))

# 아래는 Peer-Review 논문들을 월별로 정리하기 위한 코드입니다. scopus(1).bib 와 같은
# 파일들은 월별로 BibTex 형태로 Export한 것입니다. SCOPUS가 년도까지만 알려주서 이렇게
# 비효율적인 방식으로 받아올 수 밖에 없었습니다. 이때 2019년에는 총 4개 밖에 없어서 
# 그래프에 추가하지 않았습니다.
# 해당 코드를 돌린 것은 date_count_SCOPUS.R 파일에 저장되어있습니다. 
# date_count_SCOPUS<-readRDS("?")에서 ?에다가 위의 파일이 저장된 경로를 넣으면 됩니다.

datelist<-c("January, 2020",
            "February, 2020",
            "March, 2020",
            "April, 2020",
            "May, 2020",
            "June, 2020",
            "July, 2020",
            "August, 2020",
            "September, 2020",
            "October, 2020",
            "November, 2020",
            "December, 2020",
            "January, 2021",
            "February, 2021",
            "March, 2021",
            "April, 2021",
            "May, 2021",
            "June, 2021",
            "July, 2021",
            "August, 2021",
            "September, 2021",
            "October, 2021",
            "November, 2021",
            "December, 2021",
            "January, 2022",
            "February, 2022",
            "March, 2022",
            "April, 2022",
            "May, 2022",
            "June, 2022",
            "July, 2022")

date_count_SCOPUS<-data.frame(matrix(ncol=2,nrow=0))

for(i in 1:31){
  date_count_SCOPUS<-rbind(date_count_SCOPUS,c(datelist[i],nrow(convert2df(file =paste0("C:/Users/HOME/Downloads/scopus (",i,").bib"), dbsource = "scopus", format = "bibtex"))))
}

colnames(date_count_SCOPUS)<-c("Date", "Count")

date_count_SCOPUS$Count<-as.integer(date_count_SCOPUS$Count)

date_count_SCOPUS$Date <- factor(date_count_SCOPUS$Date, 
                                 levels = c("January, 2020",
                                            "February, 2020",
                                            "March, 2020",
                                            "April, 2020",
                                            "May, 2020",
                                            "June, 2020",
                                            "July, 2020",
                                            "August, 2020",
                                            "September, 2020",
                                            "October, 2020",
                                            "November, 2020",
                                            "December, 2020",
                                            "January, 2021",
                                            "February, 2021",
                                            "March, 2021",
                                            "April, 2021",
                                            "May, 2021",
                                            "June, 2021",
                                            "July, 2021",
                                            "August, 2021",
                                            "September, 2021",
                                            "October, 2021",
                                            "November, 2021",
                                            "December, 2021",
                                            "January, 2022",
                                            "February, 2022",
                                            "March, 2022",
                                            "April, 2022",
                                            "May, 2022",
                                            "June, 2022",
                                            "July, 2022"))


# 이것은 앞에서 말씀드렸듯이 2019년에 수집된 것들인데 Preprint가 2019년 것이 없기에 
# 그냥 하지 않았습니다. 
# date_count_SCOPUS<-rbind(date_count_SCOPUS,c("August, 2019", 1))
# date_count_SCOPUS<-rbind(date_count_SCOPUS,c("October, 2019", 1 ))
# date_count_SCOPUS<-rbind(date_count_SCOPUS,c("December, 2019", 2 )) 

# 아래는 하나의 그래프로 합치는 과정입니다. 
date_count_medrxiv$Type<-"Preprints"
date_count_SCOPUS$Type<-"Peer-Reviewed Papers"

date_count_together<-rbind(date_count_medrxiv,date_count_SCOPUS)

ggplot(date_count_together) +
  geom_bar(
    aes(x = Date, y = Count, fill = Type, group = Type), 
    stat='identity', position = 'dodge'
  ) +
  ylim(0,1500) +
  theme(axis.title = element_blank()) +
  theme(axis.text.x = element_text(size=10, face="bold", angle = 90)) + 
  theme(axis.text.y = element_text(face="bold", size=20)) +
  labs(title='No of preprints and peer-reviewed papers by month') +
  theme(plot.title=element_text(hjust=0.5, size=20, face="bold.italic"))+
  theme(legend.position = c(0.9,0.6)) +
  annotate(fontface =2, "text", hjust=0, x=18, y=1400, label= "Total of 8227 Peer-Reviewed Papers", size=6, col="black")+
  annotate(fontface =2, "text", hjust=0, x=18, y=1200, label= "Total of 18680 Preprints", size=6, col="black")+
  geom_text(aes(x = Date, y = Count, label = Count, group = Type),
            position = position_dodge(width = 1),
            vjust = -0.5, size = 2.6, fontface=2)



# 인용횟수에 따른 그래프 그리기


# 우선 medrxiv_list의 자료를 citation count에 따라 정리하는 코드입니다.
# 해당 코드를 돌린 것은 rcrossref_count_medrxiv 파일에 저장되어있습니다. 
# rcrossref_count_medrxiv<-readRDS("?")에서 ?에다가 위의 파일이 저장된 경로를 넣으면 됩니다.

rcrossref_count_medrxiv<-data.frame(matrix(ncol=2,nrow=0))
for(i in 1:length(medrxiv_list)){
  if(is.na(medrxiv_list[[i]]$citation_matrix$medrxiv)){
    a<-0
  } else a<-medrxiv_list[[i]]$citation_matrix$medrxiv
  
  if(is.na(medrxiv_list[[i]]$citation_matrix$journal)){
    b<-0
  } else b<-medrxiv_list[[i]]$citation_matrix$journal
  
  timescited<- a+b
  
  rcrossref_count_medrxiv <- rbind(rcrossref_count_medrxiv, c(timescited,1))
}
colnames(rcrossref_count_medrxiv)<-c("TimesCited", "Count")

rcrossref_count_medrxiv<- aggregate(Count ~ TimesCited,rcrossref_count_medrxiv, sum) 


# 아래는 Peer-Review 논문들을 citation count에 따라 정리하기 위한 코드입니다. 
# 해당 코드를 돌린 것은 rcrossref_count_SCOPUS 파일에 저장되어있습니다. 
# rcrossref_count_SCOPUS<-readRDS("?")에서 ?에다가 위의 파일이 저장된 경로를 넣으면 됩니다.

rcrossref_count_SCOPUS<-data.frame(matrix(ncol=2,nrow=0))
for(i in 1:length(DF2$DI)){
  rcrossref_count_SCOPUS <- rbind(rcrossref_count_SCOPUS, c(cr_citation_count(doi=DF2$DI[i])[["count"]],1))
}
colnames(rcrossref_count_SCOPUS)<-c("TimesCited", "Count")
rcrossref_count_SCOPUS<- aggregate(One ~ TimesCited, Count, sum)

# 아래는 하나의 그래프로 합치는 과정입니다. 
rcrossref_count_medrxiv$Type<-"Preprints"
rcrossref_count_SCOPUS$Type<-"Peer-Reviewed Papers"

rcrossref_together<-rbind(rcrossref_count_medrxiv,rcrossref_count_SCOPUS)

ggplot(rcrossref_together)+
  geom_bar(
    aes(x = TimesCited, y = Count, fill=Type, group=Type),
    stat="identity", position = "dodge"
  ) +
  xlim(0,25)+ 
  ylim(0,3500) +
  theme(axis.title = element_blank()) +
  theme(axis.text.x = element_text(size=20, face="bold")) + 
  theme(axis.text.y = element_text(face="bold", size=20)) +
  labs(title='No of preprints and peer-reviewed papers by citation number') +
  theme(plot.title=element_text(hjust=0.5, size=20, face="bold.italic"))+
  theme(legend.position = c(0.78,0.7)) + 
  geom_text(aes(x = TimesCited, y = Count, label = Count, group = Type),
            position = position_dodge(width = 1),
            vjust = -0.5, size = 2.6, fontface=2)



# twitter 반응수에 따른 그래프 그리기

# 아래는 medrxiv_list 논문들을 twitter 반응 수 에 따라 정리하기 위한 코드입니다. 
# 해당 코드를 돌린 것은 twitter_count_medrxiv,  twitter_count_SCOPUS 파일에 저장되어있습니다. 
# twitter_count_medrxiv<-readRDS("?"), twitter_count_SCOPUS<-readRDS("?")에서 ?에다가 
# 위의 파일이 저장된 경로를 넣으면 됩니다.


twitter_count_medrxiv<-data.frame(matrix(ncol=2,nrow=0))
for(i in 1:length(medrxiv_list)){
  twitter_count_medrxiv <- rbind(twitter_count_medrxiv, c(length(medrxiv_list[[i]]$twitter_users_reaction),1))
}
colnames(twitter_count_medrxiv)<-c("TimesTwitted", "Count")
twitter_count_medrxiv<- aggregate(Count ~ TimesTwitted,twitter_count_medrxiv, sum) 


ggplot(data = twitter_count_medrxiv, aes(x = TimesTwitted, y = Count)) +
  geom_col(stat = "identity", fill = 1, color = "lightblue", lwd = 0.5)+ xlim(0,50) + ylim(0,1000)
annotate("text",x=40, y=500, label= paste0("Mean is ", mean_tw_medrxiv), size=10, col="red")


twitter_count_SCOPUS<-data.frame(matrix(ncol=2,nrow=0))
for(i in 1:length(peer_review_twitter_reaction)){
  twitter_count_SCOPUS <- rbind(twitter_count_SCOPUS, c(length(peer_review_twitter_reaction[[i]]$twitter_users_reaction),1))
}
colnames(twitter_count_SCOPUS)<-c("TimesTwitted", "Count")
twitter_count_SCOPUS<- aggregate(Count ~ TimesTwitted,twitter_count_SCOPUS, sum) 


ggplot(data = twitter_count_SCOPUS, aes(x = TimesTwitted, y = Count)) +
  geom_col(stat = "identity", fill = 1, color = "lightblue", lwd = 0.5)+
  annotate("text", x=40, y=500, label= paste0("Mean is ", mean_tw_SCOPUS), size=10, col="red")







# Twitter Demographic, Geographic 그래프 그리기

# Geographic 그래프 그리기
# Twitter_geo_medrxiv<-readRDS("?")에서 ?에다가 저장된 경로를 넣으면 됨. peer도 마찬가지.

Twitter_geo_medrxiv<-data.frame(matrix(ncol=2,nrow=0))
for(i in 1:length(medrxiv_list)){
  if(is.na(medrxiv_list[[i]]$twitter_geo)){
    next
  }
  Twitter_geo_medrxiv <- rbind(Twitter_geo_medrxiv, medrxiv_list[[i]]$twitter_geo[,1:2])
}
Twitter_geo_medrxiv<- aggregate(Count ~ Country,Twitter_geo_medrxiv, sum)    


Twitter_geo_peer<-data.frame(matrix(ncol=2,nrow=0))
for(i in 1:length(peer_review_twitter_reaction)){
  if(is.na(peer_review_twitter_reaction[[i]]$twitter_geo)){
    next
  }
  Twitter_geo_peer <- rbind(Twitter_geo_peer, peer_review_twitter_reaction[[i]]$twitter_geo[,1:2])
}
Twitter_geo_peer<- aggregate(Count ~ Country,Twitter_geo_peer, sum)   


Twitter_demo_medrxiv<-data.frame(matrix(ncol=2,nrow=0))
for(i in 1:length(medrxiv_list)){
  if(is.na(medrxiv_list[[i]]$twitter_demo)){
    next
  }
  Twitter_demo_medrxiv <- rbind(Twitter_demo_medrxiv, medrxiv_list[[i]]$twitter_demo[,1:2])
}
Twitter_demo_medrxiv<- aggregate(Count ~ Type,Twitter_demo_medrxiv, sum) 


Twitter_demo_peer<-data.frame(matrix(ncol=2,nrow=0))
for(i in 1:length(peer_review_twitter_reaction)){
  if(is.na(peer_review_twitter_reaction[[i]]$twitter_demo)){
    next
  }
  Twitter_demo_peer <- rbind(Twitter_demo_peer, peer_review_twitter_reaction[[i]]$twitter_demo[,1:2])
}
Twitter_demo_peer<- aggregate(Count ~ Type,Twitter_demo_peer, sum)



# 지도를 보면 medrxiv가 비율적으로 서양에 덜 집중됨
joinData <- joinCountryData2Map( Twitter_geo_medrxiv,
                                 joinCode = "NAME",
                                 nameJoinColumn = "Country")
theMap <- mapCountryData( joinData, nameColumnToPlot="Count", addLegend=FALSE )
do.call( addMapLegend, c(theMap, legendWidth=1, legendMar = 2))

joinData <- joinCountryData2Map( Twitter_geo_peer,
                                 joinCode = "NAME",
                                 nameJoinColumn = "Country")
theMap <- mapCountryData( joinData, nameColumnToPlot="Count", addLegend=FALSE )
do.call( addMapLegend, c(theMap, legendWidth=1, legendMar = 2))

# Demo에서 Members of the public이 차지하는 비율이 생각보다 큰 차이가 나지 않음.
Twitter_demo_medrxiv$Count[1]/sum(Twitter_demo_medrxiv$Count)
Twitter_demo_peer$Count[1]/sum(Twitter_demo_peer$Count)

