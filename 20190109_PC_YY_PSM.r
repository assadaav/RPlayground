library(tidyverse)
library(rms)
library(MatchIt)
library(survminer)

date_transform <- function(date){
  return(
    as.Date(ifelse(grepl("-", date), 
                   as.Date(date, format = c("%Y-%m-%d")), 
                   ifelse( grepl("/", date), 
                           as.Date(date, format = c("%Y/%m/%d")),
                           as.Date(date, format = c("%Y%m%d"))
                   )
    ), origin = "1970-01-01"
    )
  )
}


df <- read_csv("../data/20190110_PC_YY_PSM.csv")

df <- rename(df, ID = "住院号", ED = "生存状态", DoS = "手术日期", DoD = "死亡日期",
             AGE_SURG = "手术时年龄", SEX = "性别", GRADE = "病理分级", NEUINV = "X40",
             OS = "days_to_last_followup (年)" )

###################################################
ndf <- select(df, ID, ED, DoS, DoD, AGE_SURG, SEX, GRADE, T, N, M, NEUINV, OS)

ndf$ED <- factor(ndf$ED, levels = c("存活", "死亡"), labels = c(0, 1))
ndf$OS <- ndf$OS * 12
# ndf$OS <- ifelse(ndf$OS <=24, ndf$OS, 24)

#ndf$DoS <- date_transform(ndf$DoS)
# ndf$DoD <- date_transform(ndf$DoD) # wrong line...
#ndf$OS <- ndf$DoD - ndf$DoS

ndf$SEX <- factor(ndf$SEX, levels = c("男", "女"),
                  labels = c(0, 1))
ndf$GRADE <- factor(ndf$GRADE, levels = c("I级", "I-II级", "II级", "II-III级", 
                                          "II-III级，伴粘液性癌成分", "III级"),
                    labels = c(1, 2, 3, 4, 4, 5), ordered = TRUE)
ndf$T <- factor(ndf$T, levels = c("T1", "T2", "T3", "T4"),
                labels = c(1, 2, 3, 4))
ndf$N <- factor(ndf$N, levels = c("N0", "NO", "N1", "N2"),
                labels = c(0, 0, 1, 2))
ndf$M <- factor(ndf$M, levels = c("Mx", "M1"), labels = c(0, 1))
ndf$NEUINV[is.na(ndf$NEUINV)] <- 0
ndf$NEUINV <- factor(ndf$NEUINV, levels = c("0", "侵犯神经"),
                     labels = c(0,1))

###################################################

S <- Surv(ndf$OS, ndf$ED==1)

ggsurvplot(survfit(S ~ 1, data = ndf))
ggsurvplot(survfit(S ~ NEUINV,  data = ndf))

cph(S ~ T + N + NEUINV, data = ndf)



