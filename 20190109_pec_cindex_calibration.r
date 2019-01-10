# Original article written by Ziwei Wang, from a Wechat article.
library(pec)
library(tidyverse)
library(rms)

# seer gbc data, processed
df <- read_csv("../data/GBC_SEER_processed.csv")

# data splitting (convenient way)
df_train <- filter(df, YEAR_DX <= 2010)
df_test <- filter(df, YEAR_DX > 2010)

# cox fitting.
## pec is friendly with package rms.
cox1 <- cph(Surv(SRV_TIME_MON, VSRTSADX==1) ~ DAJCCT + DAJCCN,
            data = df_train, surv = TRUE)
cox2 <- cph(Surv(SRV_TIME_MON, VSRTSADX==1) ~ DAJCCT + DAJCCN + AGE_DX + GRADE,
            data = df_train, surv = TRUE)

t <- c(12, 36, 60) # time point to estimate
## predict the survival in newdata, caution that
## tibble is not supported.
survprob <- predictSurvProb(cox1, newdata = as.data.frame(df_test), times = t)

## c-index calculation
c_ind <- cindex(list("Cox2V" = cox1, "Cox5V" = cox2),
                formula = Surv(SRV_TIME_MON, VSRTSADX==1) ~ DAJCCT + DAJCCN + AGE_DX + GRADE,
                data = as.data.frame(df_test), eval.times = seq(3, 60, .1), na.action = na.omit)
plot(c_ind)

### with bootstrap. B=100 only for demostration
c_ind2 <- cindex(list("Cox2V" = cox1, "Cox5V" = cox2),
                 formula = Surv(SRV_TIME_MON, VSRTSADX==1) ~ DAJCCT + DAJCCN + AGE_DX + GRADE,
                 data = as.data.frame(df), eval.times = seq(3, 60, .1), na.action = na.omit,
                 splitMethod = "bootcv", B = 100)
plot(c_ind2)

## Calibration Plot
calPlot(list("Cox2V" = cox1, "Cox5V" = cox2),
        time = 36, data = as.data.frame(df_test), na.action = na.omit)
calPlot(list("Cox2V" = cox1, "Cox5V" = cox2),
        time = 50, data = as.data.frame(df_test), na.action = na.omit)
calPlot(list("Cox2V" = cox1, "Cox5V" = cox2),
        time = 36, data = as.data.frame(df), na.action = na.omit,
        splitMethod = "bootcv", B = 100)

