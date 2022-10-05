# DARE-COVID

DB 만들기

Preprint DB 만드는 방법.R
Peer Review DB 만드는 방법.R
를 읽으시면 될 것 같습니다!
제가 저번에 Twitter 본문을 웹스크래핑하면서 미처 고려하지 못한 점이 있어 첫 100개만 가져온 것 같습니다. 이후 다시 돌릴 때 수정하겠습니다. 또한 두 DB간의 형식도 통일해야합니다. 
나머지는 데이터가 들어있는 대용량 RDS 파일입니다. 





Preprint 장단점 평가하기

Preprint 장단점 평가하기.R
를 읽으시면 될 것 같습니다.
나머지는 데이터가 들어있는 대용량 RDS 파일입니다.

확인해야되는 것은

A 장점
1. Submission to Publication("Editorial Handling Time") 기간에 따른 논문 수

Submitted -> Accepted -> Published 를 Proquests.com 에서 웹스크래핑을 통해 수집하여 Editorial Handling Time을 구하고 이후 분석을 수행합니다.

(Proquest에서 " ~ "로 전체 검색하여 스크래핑)

https://pubmed.ncbi.nlm.nih.gov/33735591/ : Submission to Publication 에 대한 Systematic Review입니다

https://unlockingresearch-blog.lib.cam.ac.uk/?p=1872 : Submission to Publication과 여러 요인들의 상관관계를 조사한 논문으로, 여기서 논문의 Quality를 평가한 공식(Downloads 횟수, Citation Count 종합해서)을 활용할 수 있을 것 같습니다.

https://link.springer.com/article/10.1007/s11192-017-2309-y#Fn1 : 논문의 submitted, accepted, published version에 관한 내용입니다

2. 저저와 논문 이용자(Twitter user로 판단)의 Heterogeneity(Demographic, Geographic)

지역 편중(Regional Disproportion)을 평가하기 위한 지표를 찾기 위해 선행 연구를 검색하고 있었습니다. 대부분 경제 관련 논문들입니다. 거기서는 분산을 계산할 때 가중치(지역의 인구)를 설정하였는데 저희 연구에서 이런 가중치를 어떻게 설정할지 잘 모르겠습니다. 

 https://journals.vilniustech.lt/index.php/TEDE/article/download/5341/4621 : 다양한 Index들을 소개하고 있습니다.

아니면 

https://onlinelibrary.wiley.com/doi/full/10.1002/leap.1155 : 이것처럼 간단히 그래프로 상위 10개의 지역에 대한 논문수를 표현하거나 Table로, 지역에 따른 논문 수 비율을 표시하는 것도 괜찮을 것 같습니다.

https://www.nature.com/articles/d41586-022-00426-7 : Ethnic Diversity를 조사하는 기사입니다.

https://qz.com/2116375/covid-has-deepened-the-wests-monopoly-of-science-publishing/ : COVID-19가 서양 편중을 심하게 했다는 기사입니다

아래의 것들은 이와 관련된 경제 논문들입니다.

https://www.ncbi.nlm.nih.gov/pmc/articles/PMC7445182/

https://link.springer.com/article/10.1007/s11205-019-02208-7

 
3. Preprint와 Peer Reviewed에서 초기 연구자들의 비율

아직 선행연구를 많이 찾아보지는 못 했습니다. 제가 생각해본 것은, 우선 Author들을 모두 모은 다음 Early Stage researcher인지 이들의 Stage를 평가합니다. 저희 DB 속 논문 published 한 개수로 이를 평가할 수 있을 것 같습니다. 그 후 Preprint와 Peer-Review 논문을 비교하여, Heterogeneity와 비슷하게 분석하면 될 것 같습니다(e.g. 상위 10명의 저자의 비율 조사 )
이와 관련된 Bibliometrix package에 기능이 있으니 이를 활용하면 DF2(Peer-Review 논문)에 대한 것은 쉽게 할 수 있으며 이를 활용하면 Preprint에 대한 것도 수월하게 할 수 있을 것 같습니다.

아래는 Bibliometrix package의, Author들에 대한 분석 기능에 대한 것입니다.

https://www.bibliometrix.org/vignettes/Introduction_to_bibliometrix.html

https://warin.ca/shiny/bibliometrix/#section-bibliometrix



4. 일반 이용자들에게 더 친숙하게 와닿았는지(Twitter 반응에 대한 Sentimental Analysis를 통해서)

https://www.r-bloggers.com/2021/05/sentiment-analysis-in-r-3/


B 단점
1. 신뢰도 비교(rcrossref(Citation Network) 그리고 철회된 논문 속 Preprint와 Peer Reviewed의 비율 비교( https://retractionwatch.com/retracted-coronavirus-covid-19-papers/ ) )

교수님께서 이전에, 더 활발히 활동하는 저자들이 더 많은 Retracted 논문을 냈는지 분석하면 좋겠다고 말씀하셨습니다. Retraction Watch에서 철회된 논문의 Text는 얻을 수는 없지만, Jounral, Paper Type, Author에 대한 내용을 정리하면 이를 할 수 있을 것 같습니다.

2. 방법 도용 등에 대한 우려로 인한 이용률의 저조
3. 음모론에 취약(아래 것과 연관됨)
(교수님께서 이전에, 더 활발히 활동하는 저자들이 더 많은 음모론을 조장했는지, 어떤 저자들이 음모론을 더 조장했는지 분석하면 좋겠다고 말씀하셨습니다.)

음모론 분석하기
kaggle과 GitHub을 참고해서 작성한 코드가 있지만 따로 링크를 올리는 게 나은 것 같습니다.

https://github.com/KangDu-9/Fake-news-detection-NLP/blob/main/NLP%20code.R

https://www.kaggle.com/code/rtatman/nlp-in-r-topic-modelling

https://www.kaggle.com/datasets/arashnic/covid19-fake-news


제가 생각한 아이디어는

1. xgbosst나 BERT 등의 NLP 모델을 COVID-19 Fake/Real News Dataset 로 학습시킨다.

2.
2-1. Twitter 반응 속 음모론을 분석할 때는 DB 속 논문에 대한 Twitter 반응 Text를 대상으로 위의 NLP 모델을 적용합니다. 
     그러면 Preprint와 Peer-Reviewed 중 음모론 조장에 더 취약한 논문의 종류가 무엇인지 등을 알 수 있을 것입니다.
     
2-2. 논문 속 음모론을 분석할 때는 DB 속 논문의 Abstract를 대상으로 위의 NLP 모델을 적용합니다.
     그러면 Preprint와 Peer-Reviewed 중 음모론 조장에 더 취약한 논문의 종류가 무엇인지 등을 알 수 있을 것입니다.
     
     
   
