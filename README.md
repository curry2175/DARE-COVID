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
1. Submission to Publication 기간에 따른 논문 수
https://pubmed.ncbi.nlm.nih.gov/33735591/
2. 저저와 논문 이용자(Twitter user로 판단)의 Heterogeneity(Demographic, Geographic)
3. Preprint와 Peer Reviewed에서 초기 연구자들의 비율
4. 일반 이용자들에게 더 친숙하게 와닿았는지(Twitter 반응에 대한 Sentimental Analysis를 통해서)

B 단점
1. 신뢰도 비교(rcrossref 그리고 철회된 논문 속 Preprint와 Peer Reviewed의 비율 비교( https://retractionwatch.com/retracted-coronavirus-covid-19-papers/ ) )
2. 방법 도용 등에 대한 우려로 인한 이용률의 저조
3. 음모론에 취약(아래 것과 연관됨)





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
   
