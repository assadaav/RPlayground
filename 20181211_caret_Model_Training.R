# https://topepo.github.io/caret/model-training-and-tuning.html#basic-parameter-tuning
library(caret)
library(mlbench)
data(Sonar)

set.seed(998)
inTraining <- createDataPartition(Sonar$Class, p = .75, list = FALSE) # list=FALSE to generate a set of indices
training <- Sonar[ inTraining,]
testing  <- Sonar[-inTraining,]

## traincontrol() generates every details of 
## train()
fitControl <- trainControl(## 10-fold CV
  method = "repeatedcv",
  number = 10,
  ## repeated ten times
  repeats = 10)

## Accuracy: overall agreement rate averaged over cross-validation iterations.
## Kappa: Cohen's kappa.
## preProcess() is automatically used with train().
## By default, train() generates 3 values for each 
## tuning variables. This can be customized as following:
set.seed(825)
gbmFit1 <- train(Class ~ ., data = training, 
                 ## gradient boosting machine
                 method = "gbm", 
                 trControl = fitControl,
                 ## This last option is actually one
                 ## for gbm() that passes through
                 verbose = FALSE)
gbmFit1

## A grid composed of 4 tuning variables for
## gbm.
gbmGrid <-  expand.grid(interaction.depth = c(1, 5, 9), 
                        n.trees = (1:30)*50, 
                        shrinkage = 0.1,
                        n.minobsinnode = 20)

nrow(gbmGrid)

set.seed(825)
gbmFit2 <- train(Class ~ ., data = training, 
                 method = "gbm", 
                 trControl = fitControl, 
                 verbose = FALSE, 
                 ## Now specify the exact models 
                 ## to evaluate:
                 tuneGrid = gbmGrid)
gbmFit2

trellis.par.set(caretTheme())
## By default, plot() gives accuracy.
plot(gbmFit2)
trellis.par.set(caretTheme())
## Other measures could be shown with metric
plot(gbmFit2, metric = "Kappa")
trellis.par.set(caretTheme())
## For other types of plot, see ?plot.train
plot(gbmFit2, metric = "Kappa", plotType = "level",
     scales = list(x = list(rot = 90)))
## ggplot
ggplot(gbmFit2)

## more features of trainControl(),
fitControl <- trainControl(method = "repeatedcv",
                           number = 10,
                           repeats = 10,
                           ## Estimate class probabilities
                           classProbs = TRUE,
                           ## Evaluate performance using 
                           ## the following function
                           summaryFunction = twoClassSummary)

set.seed(825)
gbmFit3 <- train(Class ~ ., data = training, 
                 method = "gbm", 
                 trControl = fitControl, 
                 verbose = FALSE, 
                 tuneGrid = gbmGrid,
                 ## Specify which metric to optimize
                 metric = "ROC")
gbmFit3

## As indicated by the result, depth=9 is the 
## optimized option. However, a tolerance of 
## small loss of performance would allow a
## much simpler model.
whichTwoPct <- tolerance(gbmFit3$results, metric = "ROC", 
                         tol = 2, # within 2 pct of best
                         maximize = TRUE)  
gbmFit3$results[whichTwoPct,1:6]

## Of course, predict() can be used.
predict(gbmFit3, newdata = head(testing))
predict(gbmFit3, newdata = head(testing), type = "prob")

## resampling results, within models
trellis.par.set(caretTheme())
densityplot(gbmFit3, pch = "|")

## Between models. Here, SVM is used.
## same seed as before, ensuring the same
## se is used.
set.seed(825)
svmFit <- train(Class ~ ., data = training, 
                method = "svmRadial", # SVM
                trControl = fitControl, 
                preProc = c("center", "scale"),
                tuneLength = 8,
                metric = "ROC")
svmFit   

## and.. an RDA fit
set.seed(825)
rdaFit <- train(Class ~ ., data = training, 
                method = "rda", 
                trControl = fitControl, 
                tuneLength = 4,
                metric = "ROC")
rdaFit

## Begin our comparison
resamps <- resamples(list(GBM = gbmFit3,
                          SVM = svmFit,
                          RDA = rdaFit))
resamps
summary(resamps)

theme1 <- trellis.par.get()
theme1$plot.symbol$col = rgb(.2, .2, .2, .4)
theme1$plot.symbol$pch = 16
theme1$plot.line$col = rgb(1, 0, 0, .7)
theme1$plot.line$lwd <- 2
trellis.par.set(theme1)
bwplot(resamps, layout = c(3, 1))

trellis.par.set(caretTheme())
dotplot(resamps, metric = "ROC")

trellis.par.set(theme1)
xyplot(resamps, what = "BlandAltman")

splom(resamps)

difValues <- diff(resamps)
difValues
summary(difValues)

trellis.par.set(theme1)
bwplot(difValues, layout = c(3, 1))

trellis.par.set(caretTheme())
dotplot(difValues)

## When we don't need tuning..
fitControl <- trainControl(method = "none", classProbs = TRUE)

set.seed(825)
gbmFit4 <- train(Class ~ ., data = training, 
                 method = "gbm", 
                 trControl = fitControl, 
                 verbose = FALSE, 
                 ## Only a single model can be passed to the
                 ## function when no resampling is used:
                 tuneGrid = data.frame(interaction.depth = 4,
                                       n.trees = 100,
                                       shrinkage = .1,
                                       n.minobsinnode = 20),
                 metric = "ROC")
gbmFit4