# https://topepo.github.io/caret/pre-processing.html

# caret offers a set of function on modeling, inclluding
# preprocessing, data-splitting, model training, etc.

library(caret)
library(earth)

data("etitanic")


# Dummyvariables
# A dummy var for each level, while continuous remain continuous
dummies <- dummyVars(survived ~ ., data = etitanic)


# Near-Zero Variance Predictors
# Identified by both:
#   1. the frequency of the most prevalent value over
#      the second
#   2. the number of unique values divided by the 
#      the total number of samples
data(mdrr)
nzv <- nearZeroVar(mdrrDescr, saveMetrics = T)
nzv[nzv$nzv,][1:10,] # only for presentation. saveMetrics is F by default.

nzv <- nearZeroVar(mdrrDescr) # normal state
filteredDescr <- mdrrDescr[, -nzv]


# Correlated predictors
descrCor <- cor(filteredDescr)
highCorr <- sum(abs(descrCor[upper.tri(descrCor)]) > .999) # cor() generates a matrix, and the upper.tri() takes the upper part.

summary(descrCor[upper.tri(descrCor)])
highlyCorDescr <- findCorrelation(descrCor, cutoff = .75) # findCorrelation returns a list
filteredDescr <- filteredDescr[, -highlyCorDescr] # removed

descrCor2 <- cor(filteredDescr)
summary(descrCor2[upper.tri(descrCor2)])


#  Linear Dependencies
ltfrDesign <- matrix(0, nrow=6, ncol=6)
ltfrDesign[,1] <- c(1, 1, 1, 1, 1, 1)
ltfrDesign[,2] <- c(1, 1, 1, 0, 0, 0)
ltfrDesign[,3] <- c(0, 0, 0, 1, 1, 1)
ltfrDesign[,4] <- c(1, 0, 0, 1, 0, 0)
ltfrDesign[,5] <- c(0, 1, 0, 0, 1, 0)
ltfrDesign[,6] <- c(0, 0, 1, 0, 0, 1)

comboInfo <- findLinearCombos(ltfrDesign)
comboInfo
ltfrDesign <- ltfrDesign[, -comboInfo$remove]


# Centering and Scaling
set.seed(96)
inTrain <- sample(seq(along = mdrrClass), length(mdrrClass)/2)

training <- filteredDescr[inTrain,]
test <- filteredDescr[-inTrain,]
trainMDRR <- mdrrClass[inTrain]
testMDRR <- mdrrClass[-inTrain]


preProcValues <- preProcess(training, 
                            method = c("center", "scale")) # Key function: preProcess. Lots of para can be used.
trainTransformed <- predict(preProcValues, training) # preProcess() then predict()
testTransformed <- predict(preProcValues, test)


# Data Imputation
# Also in preProcess(), with methods of kNN or Bagged tree, etc.


# Transforming Predictors
library(AppliedPredictiveModeling)
transparentTheme(trans = .4)

plotSubset <- data.frame(scale(mdrrDescr[, c("nC", "X4v")])) 
xyplot(nC ~ X4v,
       data = plotSubset,
       groups = mdrrClass, 
       auto.key = list(columns = 2))

transformed <- spatialSign(plotSubset)
transformed <- as.data.frame(transformed)
xyplot(nC ~ X4v, 
       data = transformed, 
       groups = mdrrClass, 
       auto.key = list(columns = 2)) 


