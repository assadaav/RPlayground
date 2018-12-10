# https://www.tidyverse.org/articles/2018/11/parsnip-0-0-1/

# parsnip is a regularized model-fitting framework

library(parsnip)
library(tidymodels)

set.seed(4831)
split <- initial_split(mtcars, prop = .9)
car_train <- training(split)
car_test <- testing(split)

car_rec <-
  recipe(mpg ~ ., data = car_train) %>%
  step_center(all_predictors()) %>%
  step_scale(all_predictors()) %>%
  prep(training = car_train, retain = T)

# juice() for training data, while bake() for other data
# with the same recipe procedure.
# ..Of course, prep() first.
train_data <- juice(car_rec)
test_data <- bake(car_rec, car_test)

# Start with model specification
car_model <- linear_reg()
car_model

# Then engine specification
# penalized least squares are computated with differnet 'engine'
lm_car_model <- 
  car_model %>%
  set_engine('lm')
lm_car_model

# Model fit
lm_fit <-
  lm_car_model %>%
  fit(mpg ~ ., data = car_train)
lm_fit

# stan engine for Bayesian estimation
stan_car_model <-
  car_model %>%
  set_engine('stan', iter = 5000, prior_intercept = rstanarm::cauchy(0, 10), 
             seed = 2347)
stan_car_model

ctrl <- fit_control(verbosity = 0)
stan_fit <- 
  stan_car_model %>%
  fit(mpg ~ ., data = car_train, control = ctrl)
stan_fit

# predict
predict(lm_fit, car_test)
predict(stan_fit, car_test)
predict(lm_fit, car_test, type = 'conf_int')
