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


# 결과물인 medrxiv_list를 보고 싶으시면
# medrxiv_list.R을 다운받고
# medrxiv_list <- readRDS("?")를 하시고 ?에다가 본인 컴퓨터에서 medrxiv_list.R이
# 저장된 경로를 입력하시면 됩니다. 이때 \->/ 하셔야됩니다.



# medrxiv_list는 "열"들이 논문이고, "행"들이 논문정보들입니다. 예를 들어 2행 3열은 
# 3번째 논문의 2번째 정보인 peer_review라고 할 수 있습니다. 
# 열들의 이름은 논문의 DOI로 지정되어있습니다.

# 논문정보는(어차피 아래 코드와 함께 다시 하나씩 설명함)
# title, 
# peer_review(이후 peer_review되었는지 여부), 
# peer_review_doi(이후 peer_review 되었을 경우 peer_review된 것의 doi), 
# abstract(초록)
# medrxiv_doi(preprint의 doi), 
# date(등록날짜), 
# author_list(이는 리스트 형태의 자료로 저자들의 이름이 첫 번째 key이고 그 내에 또 리스트 형식으로 affiliation(소속),
# 교신 저자인지 여부(교신 저자이면 corresp라고 또 붙음)), 
# metrics(사람들이 해당 자료에 접속한 횟수로 preprint에서 제공해주는 dataframe 형식의 데이터), 
# citation_matrix(리스트 형태의 자료로 rcrossref 패키지에 preprint doi, peer_review_doi를 입력하여 인용횟수),
# attention_score(altmetric.com에서 제공해주는 자체 점수로 그냥 넣어봤습니다),
# twitter_geo(twitter 이용자들의 지역에 대해 altmetric.com에서 제공해주는 dataframe 데이터),
# twitter_demo(twitter 이용자들의 신분에 대해 altmetric.com에서 제공해주는 dataframe 데이터), 
# twitter_users_name(tweet한 사람들의 twitter 이름), 
# twitter_users_reaction(tweet 내용 전체) 
# 이 포함되어있는 리스트 형태의 자료입니다. 

# 각 정보들을 어디서 얻어왔는지는 예시로
# medrxiv.com -> https://www.medrxiv.org/content/10.1101/2020.02.03.20019497v2.article-metrics
# 여기서 metrics 누르고 원 부분을 누르면 아래의 altmetric.com으로 넘어갑니다.
# altmetric.com -> https://medrxiv.altmetric.com/details/94080191/twitter


# 코드 설명


# 이는 rcrossref 기능을 위한 코드이며 
# crossref_email=자기 이메일 넣어야 작동합니다
file.edit("~/.Renviron")


# 이는 이후 RSelenium 기능을 위한 코드이며
# 각자의 browser에 맞게 변경해야합니다
driver<-rsDriver(browser="firefox",port=7880L)
remDr <- driver[["client"]]


# 이는 선행 논무에서 참고한 특정 단어들(Search Query)로 medrxiv에서 검색하여 얻은 논문들을 합하는 코드입니다.
# medrxiv의 search 제한 때문에 복잡해진 것입니다. 그닥 큰 의미를 갖는 코드는 아닙니다.
search_links<-c("https://www.medrxiv.org/search/abstract_title%3Anovel%2Bcoronavirus%20abstract_title_flags%3Amatch-phrase%20jcode%3Amedrxiv%20limit_from%3A2019-01-01%20limit_to%3A2022-07-31%20numresults%3A75%20sort%3Arelevance-rank%20format_result%3Astandard",
                "https://www.medrxiv.org/search/abstract_title%3Anovel%2Bcorona%2Bvirus%20abstract_title_flags%3Amatch-phrase%20jcode%3Amedrxiv%20limit_from%3A2019-01-01%20limit_to%3A2022-07-31%20numresults%3A75%20sort%3Arelevance-rank%20format_result%3Astandard",
                "https://www.medrxiv.org/search/abstract_title%3Acoronavirus%2Bdisease%2B2019%20abstract_title_flags%3Amatch-phrase%20jcode%3Amedrxiv%20limit_from%3A2019-01-01%20limit_to%3A2022-07-31%20numresults%3A75%20sort%3Arelevance-rank%20format_result%3Astandard",
                "https://www.medrxiv.org/search/abstract_title%3Acorona%2Bvirus%2Bdisease%2B2019%20abstract_title_flags%3Amatch-phrase%20jcode%3Amedrxiv%20limit_from%3A2019-01-01%20limit_to%3A2022-07-31%20numresults%3A75%20sort%3Arelevance-rank%20format_result%3Astandard",
                "https://www.medrxiv.org/search/abstract_title%3Acoronavirus%2B2%20abstract_title_flags%3Amatch-phrase%20jcode%3Amedrxiv%20limit_from%3A2019-01-01%20limit_to%3A2022-07-31%20numresults%3A75%20sort%3Arelevance-rank%20format_result%3Astandard",
                "https://www.medrxiv.org/search/abstract_title%3Asars%2Bcov%2B2%20abstract_title_flags%3Amatch-all%20jcode%3Amedrxiv%20limit_from%3A2019-01-01%20limit_to%3A2022-07-31%20numresults%3A75%20sort%3Arelevance-rank%20format_result%3Astandard",
                "https://www.medrxiv.org/search/abstract_title%3Acovid%2B19%20abstract_title_flags%3Amatch-all%20jcode%3Amedrxiv%20limit_from%3A2019-01-01%20limit_to%3A2022-07-31%20numresults%3A75%20sort%3Arelevance-rank%20format_result%3Astandard",
                "https://www.medrxiv.org/search/abstract_title%3A2019%2Bncov%20abstract_title_flags%3Amatch-all%20jcode%3Amedrxiv%20limit_from%3A2019-01-01%20limit_to%3A2022-07-31%20numresults%3A75%20sort%3Arelevance-rank%20format_result%3Astandard",
                "https://www.medrxiv.org/search/abstract_title%3Acovid%20abstract_title_flags%3Amatch-all%20jcode%3Amedrxiv%20limit_from%3A2019-01-01%20limit_to%3A2022-07-31%20numresults%3A75%20sort%3Arelevance-rank%20format_result%3Astandard",
                "https://www.medrxiv.org/search/abstract_title%3Acovid19%20abstract_title_flags%3Amatch-all%20jcode%3Amedrxiv%20limit_from%3A2019-01-01%20limit_to%3A2022-07-31%20numresults%3A75%20sort%3Arelevance-rank%20format_result%3Astandard",
                "https://www.medrxiv.org/search/abstract_title%3Ancovid%2B19%20abstract_title_flags%3Amatch-all%20jcode%3Amedrxiv%20limit_from%3A2019-01-01%20limit_to%3A2022-07-31%20numresults%3A75%20sort%3Arelevance-rank%20format_result%3Astandard",
                "https://www.medrxiv.org/search/abstract_title%3Acorona%2B19%20abstract_title_flags%3Amatch-all%20jcode%3Amedrxiv%20limit_from%3A2019-01-01%20limit_to%3A2022-07-31%20numresults%3A75%20sort%3Arelevance-rank%20format_result%3Astandard",
                "https://www.medrxiv.org/search/abstract_title%3ASARS%2BnCoV%20abstract_title_flags%3Amatch-all%20jcode%3Amedrxiv%20limit_from%3A2019-01-01%20limit_to%3A2022-07-31%20numresults%3A75%20sort%3Arelevance-rank%20format_result%3Astandard",
                "https://www.medrxiv.org/search/abstract_title%3Ancov%2B2019%20abstract_title_flags%3Amatch-all%20jcode%3Amedrxiv%20limit_from%3A2019-01-01%20limit_to%3A2022-07-31%20numresults%3A75%20sort%3Arelevance-rank%20format_result%3Astandard")

for(i in 1:length(search_links)){
  num_of_page<-GET(url=search_links[i])%>%
    read_html()%>%
    html_node(css="li.pager-last")%>%
    html_text(trim=TRUE)
  if(is.na(num_of_page)){
    num_of_page<-1
  }
  
  medrxiv_doi<-c()
  for(j in 1:num_of_page){
    medrxiv_doi<-append(medrxiv_doi,GET(url=paste0(search_links[i],"?page=",j-1))%>%
                          read_html()%>%
                          html_nodes(css="span.highwire-cite-metadata-doi.highwire-cite-metadata")%>%
                          html_text(trim=TRUE)%>%
                          str_extract(pattern="[[:digit:]].+"))
    
  }
  
  medrxiv_link<-c()
  for(k in 1:num_of_page){
    medrxiv_link<-append(medrxiv_link,paste0("https://www.medrxiv.org",GET(url=paste0(search_links[i],"?page=",as.numeric(k)-1))%>%
                                               read_html()%>%
                                               html_nodes(css="span.highwire-cite-title>a")%>%
                                               html_attr("href")))
  }
  
  Sys.sleep(0.1)
}

medrxiv_doi<-unique(medrxiv_doi)
medrxiv_link<-unique(medrxiv_link)

link_vector<-medrxiv_link




# 위에서 얻은 논문들의 url는 link_vector에 포함되어있습니다. 이제 하나씩 얻어가는 과정입니다.
for(paper_link in link_vector[1:18890]){
  
  res_html<-GET(url=paper_link) %>% read_html()
  
  # title(제목)
  title<-res_html%>%
    html_node(css="h1.highwire-cite-title#page-title")%>%
    html_text(trim=TRUE)
  
  # peer_review(이후 peer_review되었는지 여부)
  peer_review<-res_html%>%
    html_node(css="div.highwire-cite-metadata>div>i")%>%
    html_text(trim=TRUE)
  
  # peer_review_doi(이후 peer_review 되었을 경우 peer_review된 것의 doi)
  peer_review_doi<-
    if(is.na(peer_review)){NA}else{
      res_html%>%
        html_node(css="div.highwire-cite-metadata>div>a")%>%
        html_text(trim=TRUE)
    }
  
  # abstract(초록)
  abstract<-res_html%>%
    html_node(css="div.article.abstract-view")%>%
    html_text(trim=TRUE)
  
  res_html_info<- GET(url=paste0(paper_link,".article-info")) %>% read_html()
  
  # medrxiv_doi(preprint의 doi)
  medrxiv_doi<-res_html_info%>%
    html_node(css="div.field-items > div > a")%>%
    html_text(trim=TRUE)%>%
    str_extract(pattern="[[:digit:]].+")
  
  # citation_matrix(리스트 형태의 자료로 rcrossref 패키지에 
  # preprint doi, peer_review_doi를 입력하여 얻은 인용횟수)
  citation_matrix<-list()
  citation_matrix[["medrxiv"]]<-cr_citation_count(doi=medrxiv_doi)[["count"]]
  citation_matrix[["journal"]]<-cr_citation_count(doi=peer_review_doi)[["count"]]
  
  # date(등록날짜)
  date<-res_html_info%>%
    html_node(css="div>div>ul>li.published")%>%
    html_text(trim=TRUE)
  
  # author_list(리스트 형태의 자료로 저자들의 이름이 첫 번째 key이고 그 내에 또 리스트 형식으로 affiliation(소속),
  # 교신 저자인지 여부(교신 저자이면 corresp라고 또 붙음))
  author<-res_html_info%>%
    html_nodes(css="ol.contributor-list>li>span.name")%>%
    html_text(trim=TRUE)
  full_aff<-res_html_info%>%
    html_nodes(css="li.aff>address")%>%
    html_text(trim=TRUE)
  aff<-res_html_info%>%
    html_nodes(css="li.aff>address>span")%>%
    html_text(trim=TRUE)
  label<-res_html_info%>%
    html_nodes(css="li.aff>address>sup")%>%
    html_text(trim=TRUE)
  correspond_label<-res_html_info%>%
    html_nodes(css="ol.corresp-list>li>span:nth-of-type(1)")%>%
    html_text(trim=TRUE)
  kind_of_corr<-res_html_info%>%
    html_nodes(css="ol.corresp-list>li")%>%
    html_attr('class')
  afflist<-list()
  if(length(label)>0){for(i in 1:length(label)){
    afflist[[label[i]]]<-paste0(aff[i]," NEXTISADDRESS ",str_sub(full_aff[i],start=(4+nchar(aff[i]))))
  }}
  if(length(correspond_label)>0){for(j in 1:length(correspond_label)){
    afflist[[correspond_label[j]]]<-kind_of_corr[j]
  }}
  
  author_list<-list()
  for(i in 1:length(author)){
    author_label<-res_html_info%>%
      html_nodes(css=paste0("li#contrib-",i,">a"))%>%
      html_text(trim=TRUE)
    a<-c()
    for(j in author_label){
      a<-append(a,afflist[[j]])
    }
    author_list[[author[i]]]<-a
  }
  
  
  remDr$navigate(paste0(paper_link,".article-metrics"))
  res_html_metrics<- remDr$getPageSource()[[1]] %>% read_html()
  
  # metrics(사람들이 해당 자료에 접속한 횟수로 preprint에서 제공해주는 dataframe 형식의 데이터)
  cite_kinds<-res_html_metrics%>%
    html_nodes(css="table.highwire-stats.sticky-enabled.tableheader-processed.sticky-table>thead>tr>th") %>%
    html_text(trim=TRUE)
  cite_kinds<-cite_kinds[-1]
  cite_num<-res_html_metrics%>%
    html_nodes(css="tr.cshl_total>td") %>%
    html_text(trim=TRUE)
  cite_num<-cite_num[-1]
  metrics<-data.frame("kinds"=cite_kinds,"num"=cite_num) %>% t()
  
  # attention_score(altmetric.com에서 제공해주는 자체 점수로 그냥 넣어봤습니다)
  attention_score<-res_html_metrics %>%
    html_node(css="div>a[target='_blank']>img")%>%
    html_attr('alt') %>%
    str_extract(pattern="[[:digit:]]+")
  
  link_<-res_html_metrics %>%
    html_node(css="div[style='overflow:hidden;']>div>a")%>%
    html_attr("href")
  
  if(is.na(link_)){
    
    twitter_geo<-NA
    twitter_demo<-NA
    twitter_users_name<-NA
    twitter_users_reaction<-NA
    
    c <- list(title = title,
              peer_review = peer_review,
              peer_review_doi = peer_review_doi,
              abstract = abstract,
              medrxiv_doi = medrxiv_doi,
              date = date,
              author_list = author_list,
              metrics = metrics,
              citation_matrix = citation_matrix,
              attention_score = attention_score,
              twitter_geo = twitter_geo,
              twitter_demo = twitter_demo,
              twitter_users_name = twitter_users_name,
              twitter_users_reaction = twitter_users_reaction)
    
    medrxiv_list[[medrxiv_doi]] <- c
    
    repeat_times=repeat_times+1
    if(repeat_times%%100==0) Sys.sleep(0.1)
    
    next
  }
  
  res_html_altmetrics<- GET(url=link_) %>% read_html()
  
  
  # twitter_geo(twitter 이용자들의 지역에 대해 altmetric.com에서 제공해주는 dataframe 데이터)
  twitter_geo<-res_html_altmetrics%>%
    html_node(css="div.table-wrapper.geo")%>%
    html_table(fill=TRUE) %>% as.data.frame()
  
  # twitter_demo(twitter 이용자들의 신분에 대해 altmetric.com에서 제공해주는 dataframe 데이터) 
  twitter_demo<-res_html_altmetrics%>%
    html_node(css="div.table-wrapper.users")%>%
    html_table(fill=TRUE) %>% as.data.frame()
  
  res_html_altmetrics_twitter<- GET(url=paste0("https://medrxiv.altmetric.com/details/",str_extract(link_,pattern="[[:digit:]]+$"),"/twitter")) %>% read_html()
  
  # twitter_users_name(tweet한 사람들의 twitter 이름)
  twitter_users_name<-res_html_altmetrics_twitter%>%
    html_nodes(css="div.handle")%>%
    html_text(trim=TRUE)
  
  # twitter_users_reaction(tweet 내용 전체) 
  twitter_users_reaction<-res_html_altmetrics_twitter%>%
    html_nodes(css="p.summary")%>%
    html_text(trim=TRUE)
  
  c <- list(title = title,
            peer_review = peer_review,
            peer_review_doi = peer_review_doi,
            abstract = abstract,
            medrxiv_doi = medrxiv_doi,
            date = date,
            author_list = author_list,
            metrics = metrics,
            citation_matrix = citation_matrix,
            attention_score = attention_score,
            twitter_geo = twitter_geo,
            twitter_demo = twitter_demo,
            twitter_users_name = twitter_users_name,
            twitter_users_reaction = twitter_users_reaction)
  
  medrxiv_list[[medrxiv_doi]] <- c
  
  repeat_times=repeat_times+1
  if(repeat_times%%100==0) Sys.sleep(0.1)
}
