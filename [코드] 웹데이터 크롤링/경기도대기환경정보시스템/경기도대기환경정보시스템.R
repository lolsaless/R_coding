if (!require(pacman)) {
    install.packages("pacman")
    library(pacman)
}

p_load(rvest, httr, jsonlite, readxl)


# 크롤링 url
url_air <- 'https://air.gg.go.kr/default/tms.do'
ref_air <- 'https://air.gg.go.kr/default/esData.do?mCode=A010010000'

# body에 들어갈 부분이며, 각 측정 지점의 고유 번호가 저장된 csv파일을 불러온다.
setwd("C:/Github/R_coding/[코드] 웹데이터 크롤링/경기도대기환경정보시스템")
setwd("D:/R_coding/[코드] 웹데이터 크롤링/경기도대기환경정보시스템")

locCd <- read_excel("locCd.xlsx")


# typeCd는 데이터의 타입으로 1 = 시간, 2 = 일, 3 = 월, 4 = 년 단위로 데이터 호출

# ----예시자료----
# user_agent 없으면 보안 정책에 의해서 차단
# data_air <- POST(url_air,
#                  body = list(op = 'getByLoc',
#                              fromDt = '2023-04-20',
#                              toDt = '2023-04-20',
#                              locCd = 131611,
#                              typeCd = '1'),
#                  add_headers(referer = ref_air))
# air_gg <- data_air %>% content(as='text') %>% fromJSON() %>% do.call(rbind,.)
# write.csv(air_gg, paste0(locCd$지역[count], '_', locCd$지점[count], '.csv'))


# 시간단위 측정결과 연간 자료 다운로드 가능
for (year in 2020:2021) {
    from_year <- paste0(year,"-01-01")
    to_year <- paste0(year, "-12-31")
    count = 0

    for (i in 1:nrow(locCd)) {
        count = count + 1
        data_air <- POST(url_air,
                         body = list(op = 'getByLoc',
                                     fromDt = from_year,
                                     toDt = to_year,
                                     locCd = as.numeric(locCd[i,1]),
                                     typeCd = '1'),
                         user_agent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Safari/537.36'),
                         add_headers(referer = ref_air))
        
        air_gg <- data_air %>% content(as='text') %>% fromJSON() %>% do.call(rbind,.)
        write.csv(air_gg, paste0(year, '_', locCd$지역[count], '_', locCd$지점[count], '.csv'))
        print(paste0(year, '_', locCd$지역[count], '_', locCd$지점[count], '.csv 파일 크롤링 완료'))
        Sys.sleep(10.0)
    }
}
