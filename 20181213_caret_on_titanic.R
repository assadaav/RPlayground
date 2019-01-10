library(tidyverse)
library(caret)
library(recipes)
library(tidymodels)

## This is an implementation of package caret on the classic dataset titanic.
## Data retrieved from Kaggle.

df_input <- read_csv('titanic_train.csv')
df_task <- read_csv('titanic_test.csv')

###############################################################################
# Feature analysis and recode
df_task['Survived'] <- NA

input_index <- df_input$PassengerId
input_max <- max(df_input$PassengerId)
df_all <- rbind(df_input, df_task)

## Pclass
table(df_all$Pclass)

## Name
sample(df_all$Name, 10)
df_all <- mutate(df_all, 
                 Title = gsub('(.*, )|(\\..*)', '', Name), # Extract titles from Name
                 Surname = gsub(',.*', '', df_all$Name))   # Extract surnames from Name
sort(table(df_all$Title), decreasing = T)
### Extract title from name
rare_title <- c('Dona', 'Lady', 'the Countess','Capt', 'Col', 'Don', 
                'Dr', 'Major', 'Rev', 'Sir', 'Jonkheer')

df_all$Title[df_all$Title == 'Mlle']        <- 'Miss' 
df_all$Title[df_all$Title == 'Ms']          <- 'Miss'
df_all$Title[df_all$Title == 'Mme']         <- 'Mrs' 
df_all$Title[df_all$Title %in% rare_title]  <- 'Rare Title'

## Sex
table(df_all$Sex)
## 1 time more men than women

## Age
hist(df_all$Age)
sum(df_all$Age <= 16, na.rm = T)
### 134 children on titanic
sum(df_all$Age >= 60, na.rm = T)
### and 40 elders

## SibSp
hist(df_all$SibSp)
table(df_all$SibSp)
### mutual relation unknown, but Sibsp=5 should be in the same
### familiy, so is Sibsp==8
df_all[df_all$SibSp==8,]
## Sage family
df_all[df_all$SibSp==5,]
### ..and Goodwin family

## Parch
hist(df_all$Parch)
table(df_all$Parch)
df_all[df_all$Parch==9,]
### Again, tragical Sage Family
df_all[df_all$Parch==6,]
### ..and Goodwin family

df_all$family_Size <- df_all$SibSp + df_all$Parch + 1
df_all$is_Single <- ifelse(df_all$family_Size==1, TRUE, FALSE)
surname_Total <- df_all %>%
  group_by(Surname) %>%
  summarise(family_Total = n())
surname_In_Input <- df_all %>%
  group_by(Surname) %>%
  summarise(family_Known = sum(PassengerId <= input_max))
surname_Survived <- df_all %>%
  group_by(Surname) %>%
  summarise(family_Survived = sum(Survived))

df_all <- left_join(df_all, surname_Total, by = 'Surname')
df_all <- left_join(df_all, surname_In_Input, by = 'Surname')
df_all <- left_join(df_all, surname_Survived, by = 'Surname')

df_all$check <- df_all$family_Size - df_all$family_Total
filter(df_all, check == 0, is_Single == FALSE) %>%
  select(Name, Surname, family_Size, family_Total) # more than 300 people have matched family
filter(df_all, check != 0) %>%
  select(Name, Surname, family_Size, family_Total) # still, more than 300 people have mismatched family
filter(df_all, check != 0, is_Single == FALSE) %>%
  select(Name, Surname, family_Size, family_Total) # .. in which half is single. Thus, mathched vs mismatched = 348: 151
df_all$family_Survived[df_all$check != 0] <- NA
df_all$check <- NULL

df_all$family_SurvRate <- df_all$family_Survived / df_all$family_Known

## Ticket
sample(df_all$Ticket, 10)
table(gsub('[0-9]*','', df_all$Ticket))
### ... seems hard to understand

## Fare
hist(df_all$Fare)
## likely to highly colinear with Pclass

## Cabin
sample(df_all$Cabin, 10)
sum(is.na(df_all$Cabin))
### ... seems to be with too many missing values
table(gsub('[0-9]*','', df_all$Cabin))
## Seems that some people changed their cabin
### For convenience, only the first cabin letter was preserved.
df_all <- mutate(df_all, Cab_Lev = substr(gsub('[0-9]*','', Cabin), 1,1))
table(df_all$Cab_Lev)
rare_cab <- c('G', 'T')
df_all$Cab_Lev[df_all$Cab_Lev %in% rare_cab] <- 'R'

## Embarked
table(df_all$Embarked)
### Port of Embarkation. Doesn't sound quite predictive.

------------------------------------------------------------------------
# Preprocess
df_input <- df_all[input_index,]
df_task <- df_all[-input_index,]

set.seed(3721)
df_split <- initial_split(df_input, .75)
df_training <- training(df_split)
df_test <- testing(df_split)

## Imputation applied. Normally we should see the missing value patterns
## beforehand.
titanic_rec <- recipe(Survived ~ Pclass + Sex + Age + SibSp + Parch + Fare +
                      Embarked + Title + Cab_Lev + family_SurvRate, data = df_training) %>%
  step_dummy(Survived, Pclass, Sex, Embarked, Title, Cab_Lev) %>%
  step_knnimpute(all_predictors(), -family_SurvRate) %>%
  step_center(all_predictors()) %>%
  step_scale(all_predictors())
titanic_prep <- prep(titanic_rec, training = df_training)
training_data <- bake(titanic_prep, df_training)

head(training_data)

fitControl <- trainControl(method = "repeatedcv",
                           number = 10,
                           ## repeated ten times
                           repeats = 10)

# Let's try a lm first
set.seed(9213)
linreg_model <- train(Survived ~ ., 
                      data=training_data,
                      method = 'glm',
                      trControl = fitControl,
                      verbose = FALSE)
linreg_model
broom::augment(linreg_model, newdata = training_data) %>%
  rmse(Survived, .fitted) # RMSE = 0.240

# How about a gbm?
set.seed(1272)
gbmFit1 <- train()



ggplot(data = df_train)+
  geom_bar(mapping = aes(x = Pclass, fill = Survived), positioin = 'fill')
