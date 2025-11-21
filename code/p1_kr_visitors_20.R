# === 2020년 국적별 해외 입국자 통계 분석 ===
# 데이터 출처: 한국문화관광연구원 관광지식정보시스템 (투어고, http://know.tour.go.kr)
# 목적: 코로나19 확산 초기 해외 입국자 변화를 확인
# 참고문헌: 혼자 공부하는 R 데이터 분석 (강전희, 엄동란 지음 / 한빛미디어)


install.packages("reshape2")
library(readxl)
entrance_xls <- read_excel("C:/Rstudy/p1_data.xlsX")

str(entrance_xls)
head(entrance_xls)


# === 데이터 전처리 ===
# 전처리 완료: 13개 컬럼, 67개 관측치
# 컬럼명을 단순화를 위해 영문으로 수정(colnames 함수: 칼럼명(열이름)변경)
# 관측치 공백 제거(gsub 함수: 특정 문자를 원하는 문자열로 대체)

colnames(entrance_xls) <- c("country", "JAN", "FEB", "MAR", "APR", "MAY",
                            "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC")

entrance_xls$country <- gsub(" ", "", entrance_xls$country)
entrance_xls


# === 1월 입국자 기준 상위 5개국 추출 ===
# order() 기본값은 오름차순, 내림차순은 decreasing = TRUE 또는 변수 앞에 - 사용
# R 4.1.0 이상: 패키지 없이 네이티브 파이프(|>) 사용 가능
#   → 왼쪽 객체를 오른쪽 함수의 첫 번째 인자로 전달, 연속 처리에 유용
#   → 기존 magrittr/dplyr의 %>%와 동일한 의미

entrance_xls |> nrow()
top5_country <- entrance_xls[order(-entrance_xls$JAN),] |> head(n = 5)
top5_country


# === 시각화를 위한 데이터 재구조화 ===
# melt() 함수: wide format 데이터를 long format으로 변환 (데이터 열을 행으로 변환)
#   → 컬럼별 월 데이터를 하나의 열(mon)로 통합 
#   → 그래프 그리기 및 그룹별 통계 분석에 편리

library(reshape2)
top5_melt <- melt(top5_country, id.vars = 'country', variable.name = 'mon')
head(top5_melt)


# === 선 그래프 ===
# x축: 월(mon), y축: 입국 수(value)
# group = country: 국가별 선 연결
# color = country: 국가별 색상 구분

library(ggplot2)

ggplot(top5_melt, aes(x = mon, y = value, group = country)) +
  geom_line(aes(color = country))


# === 그래프 제목 지정 및 y축 범위 조정 ===
# geom_line(): 국가별 다른 색상으로 선 그래프 표시
# group = country: 국가별로 선 연결
# scale_y_continuous(): Y축 범위 및 눈금 조정
# seq(): 차이가 일정한 연속값 생성 (예시: breaks = seq(0, 500000, 50000): Y축 0~500,000 범위를 50,000 단위로 표시)

ggplot(top5_melt, aes(x = mon, y = value, group = country)) +
  geom_line(aes(color = country)) +
  ggtitle("2020년 국적별 입국 수 변화 추이") +
  scale_y_continuous(breaks = seq(0, 500000, 50000))


# === 막대 그래프 그리기 ===
# geom_bar() 주요 옵션
# - stat = "identity": y값 그대로 막대 높이로 사용 (예: value = 100이면 막대 높이 = 100)
# - stat = "count": x값 빈도를 계산하여 막대 높이로 사용
# - position = "dodge": 옆으로 나란히
# - position = "stack": 위로 쌓기 (누적 막대)

ggplot(top5_melt, aes(x = mon, y = value, fill = country)) +
  geom_bar(stat = "identity", position = "dodge")


# === 누적 막대 그래프 그리기 ===

ggplot(top5_melt, aes(x = mon, y = value, fill = country)) +
  geom_bar(stat = "identity", position = "stack")

