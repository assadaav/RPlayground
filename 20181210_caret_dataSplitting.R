library(caret)
set.seed(3456)

# Simple splitting based on the outcome
trainIndex <- createDataPartition(
  iris$Species, 
  p = .8,
  list = FALSE,
  times = 1
)

irisTrain <- iris[trainIndex,]
irisTest <- iris[-trainIndex,]

# Splitting based on the predictors
# The tutorial introduced a method to
# maximize the 'diversity' of a variable.

# Splitting the time-series data
# which should be treated separately
# by createTimeSlices()

# groupKFold .. not so understand