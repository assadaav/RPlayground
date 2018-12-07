# https://www.brodrigues.co/blog/2018-11-25-tidy_cv/
# Key word: Random Forest; Optimization
# Package to learn: 
#   recipe-prep-bake for preprocessing
#   mc_cv for cross-validationg
#   rand_forest
#   mlrMBO (???)

library(tidyverse)
library(tidymodels)
library(parsnip)
library(brotools)
library(mlbench)

data("BostonHousing2")

boston <- BostonHousing2 %>%
  select(-medv, -town, -lon, -lat) %>%
  rename(price=cmedv)

train_test_split <- initial_split(boston, prop=0.9) # generate two set
housing_train <- training(train_test_split)
housing_test <- testing(train_test_split)

# in random forest, some parameters are needed to be set a priori
# here, the author estimate these para by splitting the training data again

validation_data <- mc_cv(housing_train, prop = 0.9, times=30) # Monte Carlo Cross-Validation; further investigation needed
# the dataset was splietted into "analysis" and "assesment" set

# package recipe for preprocessing
simple_recipe  <- function(dataset){
  recipe(price ~ ., data=dataset) %>%
    step_center(all_numeric()) %>%
    step_scale(all_numeric()) %>%
    step_dummy(all_nominal())
}

# prep() estimates the procedure, then bake() applies it
testing_rec <- prep(simple_recipe(housing_test), testing=housing_test)
# thus, test_data are the processed data
test_data <- bake(testing_rec, new_data = housing_test)
# the MCCV part will be processed in the same way later, but
# as it's not a dataframe now (a 30-fold... thing), the function will be.. "large"

# try a lm, as a.. baseline?
trainlm_rec <- prep(simple_recipe(housing_train), testing = housing_train)
trainlm_data <- bake(trainlm_rec, new_data = housing_train)
linreg_model <- lm(price ~ ., data=trainlm_data)
broom::augment(linreg_model, newdata = test_data) %>%
  rmse(price, .fitted) # get RMSE as a standard of judging

my_rf <- function(mtry, trees, split, id){
  analysis_set <- analysis(split)
  analysis_prep <- prep(simple_recipe(analysis_set), training=analysis_set)
  analysis_processed <- bake(analysis_prep, newdata = analysis_set)
  
  # rand_forest() form {parsnip}
  model <- rand_forest(mtry = mtry, trees = trees) %>%
    set_engine("ranger", importance = 'impurity') %>%
    fit(price ~ ., data = analysis_processed)
  
  assessment_set <- assessment(split)
  assessment_prep <- prep(simple_recipe(assessment_set), training=assessment_set)
  assessment_processed <- bake(assessment_prep, newdata = assessment_set)
  
  tibble::tibble("id" = id,
                 "truth" = assessment_processed$price,
                 "prediction" = unlist(predict(model, new_data = assessment_processed)))
}

results_example <- map2_df(.x = validation_data$splits,
                           .y = validation_data$id,
                           ~my_rf(mtry = 3, trees = 200, split = .x, id = .y))
head(results_example)
results_example %>%
  group_by(id) %>%
  rmse(truth, prediction) %>%
  summarise(mean_rmse = mean(.estimate)) %>%
  pull

# get RMSE from specific data (like above)
tuning <- function(param, validation_data){
  mtry <- param[1]
  trees <- param[2]
  
  results <- purrr::map2_df(.x = validation_data$splits,
                            .y = validation_data$id,
                            ~my_rf(mtry, trees, split = .x, id = .y))
  results %>%
    group_by(id) %>%
    rmse(truth, prediction) %>%
    summarise(mean_rmse = mean(.estimate)) %>%
    pull
  
}

tuning(c(3,200), validation_data)

plot_points <- crossing("mtry" = 3, "trees" = seq(200,300))

plot_data <- plot_points %>%
  mutate(value = map_dbl(seq(200, 300), ~tuning(c(3, .), validation_data)))

plot_data %>%
  ggplot(aes(x = trees, y = value)) +
  geom_line() +
  theme_minimal() +
  labs(title = "RMSE for mtry = 3")

# not so understood part

library(mlrMBO)
library(lhs)
library(ParamHelpers)
library(mlr)

fn <- makeSingleObjectiveFunction(
  name = 'tuning',
  fn = tuning,
  par.set = makeParamSet(
    makeIntegerParam('x1', lower = 3, upper = 8),
    makeIntegerParam("x2", lower = 50, upper = 500)
  )
)

des <- generateDesign(n = 5L * 2L, getParamSet(fn), fun = randomLHS)
surrogate <- makeLearner("regr.ranger", predict.type = 'se', keep.inbag=T)
ctrl <- makeMBOControl()
ctrl <- setMBOControlTermination(ctrl, iters = 10L)
ctrl <- setMBOControlInfill(ctrl, crit = makeMBOInfillCritEI())

result <- mbo(fn, des, surrogate, ctrl, more.args = list("validation_data" = validation_data))
result

# According to the result, we got the optimal value of mtry and trees

training_rec <- prep(simple_recipe(housing_train), testing = housing_train)
train_data <- bake(training_rec, newdata= housing_train)

final_modal <- rand_forest(mtry = 6, trees = 475) %>%
  set_engine("ranger", importance = 'impurity') %>%
  fit(price ~ ., data = train_data)

price_predict <- predict(final_modal, new_data = select(test_data, -price))

cbind(price_predict * sd(housing_train$price)+mean(housing_train$price),
      housing_test$price)

tibble::tibble("truth" = test_data$price,
               "prediction" = unlist(price_predict)) %>% 
  rmse(truth, prediction)
