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
library(js)

# 결과물인 DF2와 peer_review_twitter_reaction를 보고 싶으시면
# DF2.R, peer_review_twitter_reaction.R을 다운받고
# DF2 <- readRDS("?"),peer_review_twitter_reaction <- readRDS("?")를 하시고 
# ?에다가 본인 컴퓨터에서 DF2.R이 저장된 경로를 입력하시면 됩니다. 이때 \->/ 하셔야됩니다.



# Peer-Review 논문은 DF2라는 RDS 파일 내에 포함되어있습니다. DF2를 만들 때 사용한 코드는 
# 9.22 DF2_code.R에 있습니다. DF2는 데이터프레임으로 열에는 다음과 같은 정보들이 포함되어 있고
# 개별 논문들은 행으로 정리되어있습니다. 열로 표현된 논문 정보는 다음과 같습니다.(뭔지 모르겠는 것도 
# 있는데 이는 저희 연구에서 활용되지 않을 것이 거의 확실합니다.)

# "AU": 저자,
# "DE":저자들의 키워드, 
# "ID": SCOPUS의 키워드, 
# "C1": 저자의 주소,
# "CR": 참고문헌, 
# "JI": ISO Source 줄임말, 
# "AB": 초록, 
# "AR": Article Number,
# "chemicals_cas":? 주제어 같음,
# "coden": 뭔지 모르겠음, 
# "RP": Reprint Address
# "DT": 논문의 종류,
# "DI": DOI , 
# "FU": Funding Agency and Grant Number,
# "SN": ISSN, 
# "SO": Publication Name,
# "LA": 언어,
# "TC": 인용 횟수, 
# "PN": Part Number, 
# "PP": 어떤 종류의 번호 , 
# "PU": Publisher,
# "PM": PubMed ID, 
# "DB": Bibliographic Database,
# "TI": 제목,
# "url": SCOPUS url, 
# "VL": 몇 번째 Volume인지,
# "PY": Published 년도, 
# "FX": Funding Text,  
# "AU_UN", "AU1_UN", "AU_UN_NR", "SR_FULL", "SR": 이들은 뭔지 모르겠음...




# 코드

# 코드 자체는 간단합니다. 어떻게 한 것이냐면 선행 논문의 검색어를 SCOPUS에 입력하고
# 이를 월별로 BibTex 형식으로 저장한 것이 scopus (숫자).bib 들입니다.
# bibliometrix 패키지가 원래 이 BibTex 파일을 알아서 dataframe 으로 변환해줍니다. 
# 그냥 변환한 이후에 합한 것입니다.

# 여기서 DF와 DF2는 remove.duplicated=TRUE/FALSE의 차이만 있습니다. 
DF<-convert2df(file ="C:/Users/HOME/Downloads/scopus.bib", dbsource = "scopus", format = "bibtex")
DF2<-convert2df(file ="C:/Users/HOME/Downloads/scopus.bib", dbsource = "scopus", format = "bibtex")

for(i in 1:31){
  DF<-mergeDbSources(DF,convert2df(file =paste0("C:/Users/HOME/Downloads/scopus (",i,").bib"),
                                   dbsource = "scopus", format = "bibtex"),
                     remove.duplicated = TRUE)
}

for(i in 1:31){
  DF2<-mergeDbSources(DF2,convert2df(file =paste0("C:/Users/HOME/Downloads/scopus (",i,").bib"), 
                                     dbsource = "scopus", format = "bibtex"),
                      remove.duplicated = FALSE)
}

# 큰 문제는 아니지만 받아와보면 funding_text를 native encoding으로 번역할 수 없다는 에러가 뜸. 








# bibliometrix package로는 peer review 논문에 대한 twitter 반응을 얻을 수 없어
# 웹크롤링으로 얻어온 것입니다. 복잡한 것은 동적 웹크롤링이라 그런 것인지 
# 사실 코드 자체가 크게 중요하지는 않습니다. 자세한 설명은 생략하겠습니다.

driver <- rsDriver(browser ="chrome", chromever = "103.0.5060.134", port=1970L)
remDr <- driver[["client"]] 

altmetric_function<-'((function(){var a;a=function(){var a,b,c,d,e;b=document,e=b.createElement("script"),a=b.body,d=b.location;try{if(!a)throw 0;c="d1bxh8uas1mnw7.cloudfront.net";if(typeof runInject!="function")return e.setAttribute("src",""+d.protocol+"//"+c+"/assets/content.js?cb="+Date.now()),e.setAttribute("type","text/javascript"),e.setAttribute("onload","runInject()"),a.appendChild(e)}catch(f){return console.log(f),alert("Please wait until the page has loaded.")}},a(),void 0})).call(this);'

years<-c("2019","2020","2021","2022")

months<-c("January","February","March","April","May","June","July","August","September","October","November","December")

PUBDATE<-c()

for(year in years){
  PUBDATE<-append(PUBDATE,paste0(months,"+",year))
}


#아래 navigate 코드 시행한 다음에 자기 계정 입력해야함.

remDr$navigate("https://www.scopus.com/results/results.uri?sort=plf-f&src=s&sid=2e16374d91f146f3e981139c718c3878&sot=a&sdt=a&sl=264&s=TITLE-ABS%28%7bnovel+coronavirus%7d+OR+%7bnovel+corona+virus%7d+OR+%27coronavirus+disease+2019%27+OR+%27corona+virus+disease+2019%27+OR+%27coronavirus+2%27+OR+sars-cov-2+OR+covid-19+OR+2019-ncov+OR+covid+OR+covid19+OR+ncovid-19+OR+corona-19+OR+SARS-nCoV+OR+ncov-2019%29+AND+PUBYEAR+%3e+2018&origin=searchadvanced&editSaveSearch=&txGid=6b1c7a0417f1b7687096e900f28ca721")

for(month_and_year in PUBDATE[1:length(PUBDATE)]){
  
  remDr$navigate(paste0("https://www.scopus.com/results/results.uri?cc=10&sort=plf-f&src=s&nlo=&nlr=&nls=&sid=629984eaf93ce6d09b27803a14a3f4ed&sot=a&sdt=a&sl=290&s=TITLE-ABS%28%7bnovel+coronavirus%7d+OR+%7bnovel+corona+virus%7d+OR+%27coronavirus+disease+2019%27+OR+%27corona+virus+disease+2019%27+OR+%27coronavirus+2%27+OR+sars-cov-2+OR+covid-19+OR+2019-ncov+OR+covid+OR+covid19+OR+ncovid-19+OR+corona-19+OR+SARS-nCoV+OR+ncov-2019%29+AND+PUBYEAR+%3e+2018+AND+PUBDATETXT%28",month_and_year,"%29&ss=plf-f&ps=r-f&editSaveSearch=&origin=resultslist&zone=resultslist"))
  
  if(!remDr$getPageSource()[[1]]%>%  
     read_html()%>%
     str_detect("resultsCount")) next
  
  while(TRUE){
    
    bef_length<-length(scopus_links)
    
    scopus_links<-append(scopus_links,remDr$getPageSource()[[1]]%>%  
                           read_html()%>%
                           html_nodes(css="tr.searchArea>td[data-type='docTitle']> a")%>%
                           html_attr("href"))
    
    aft_length<-length(scopus_links)
    
    if(aft_length==0){
      break
    }
    
    for(i in bef_length+1:aft_length){
      remDr$navigate(scopus_links[i])
      Sys.sleep(0.1)
      
      remDr$executeScript(altmetric_function)
      Sys.sleep(0.1)
      
      title<-remDr$getPageSource()[[1]]%>%
        read_html()%>%
        html_node(css="#doc-details-page-container > article > div:nth-child(2) > section > div.row.margin-size-8-t > div > els-typography > span")%>%
        html_text(trim=TRUE)
      
      link<-remDr$getPageSource()[[1]]%>%
        read_html()%>%
        html_node(css="div#altmetric-wrapper>div>div.donut>a")%>%
        html_attr("href")
      
      altmetric_links_for_peer_review[[title]]<-link
      
      doi<-remDr$getPageSource()[[1]]%>%
        read_html()%>%
        html_node(css="#source-info-aside > div > div > div > dl:nth-child(4) > dd")%>%
        html_text(trim=TRUE)
      
      if(!is.na(link)){
        
        print(paste0(i," has altmetrics data"))
        
        #이후부터는 기존에 하던 분석임. attention score는 지원하지 않음
        
        html_altmetrics<- GET(url=link) %>% read_html()
        
        twitter_geo<-html_altmetrics%>%
          html_node(css="div.table-wrapper.geo")%>%
          html_table(fill=TRUE) %>% as.data.frame()
        
        twitter_demo<-html_altmetrics%>%
          html_node(css="div.table-wrapper.users")%>%
          html_table(fill=TRUE) %>% as.data.frame()
        
        html_altmetrics_twitter<- GET(url=paste0("https://medrxiv.altmetric.com/details/",str_extract(link,pattern="[[:digit:]]+"),"/twitter")) %>% read_html()
        
        twitter_users_name<-html_altmetrics_twitter%>%
          html_nodes(css="div.handle")%>%
          html_text(trim=TRUE)
        
        twitter_users_reaction<-html_altmetrics_twitter%>%
          html_nodes(css="p.summary")%>%
          html_text(trim=TRUE)
        
        peer_review_twitter_reaction[[doi]]<-list(twitter_geo=twitter_geo,
                                                  twitter_demo=twitter_demo,
                                                  twitter_users_name=twitter_users_name,
                                                  twitter_users_reaction=twitter_users_reaction)
      }
      
      if(i==aft_length){
        break
      }
    }
    
    remDr$findElements("css selector", "#refNavLinksId > ul > li.backToResults.noPaddingLeft > a")[[1]]$clickElement()
    Sys.sleep(0.1)
    
    if(is.na(remDr$getPageSource()[[1]]%>%  
             read_html()%>%
             html_node(css="#resultsFooter > div.col-md-6.center-block.text-center > ul > li"))){
      break
    }
    
    current_page<-remDr$getPageSource()[[1]]%>%  
      read_html()%>%
      html_node(css="#resultsFooter > div.col-md-6.center-block.text-center > ul > li > a.selectedPage")%>%
      html_text(trim=TRUE)%>%
      as.numeric()
    
    if(is.na(remDr$getPageSource()[[1]]%>%  
             read_html()%>%
             html_node(css=paste0("#resultsFooter > div.col-md-6.center-block.text-center > ul > li > a[data-value='",current_page+1,"']")))){
      break
    }
    
    remDr$findElements("css selector", paste0("#resultsFooter > div.col-md-6.center-block.text-center > ul > li > a[data-value='",current_page+1,"']"))[[1]]$clickElement()
    Sys.sleep(0.1)
  }}






