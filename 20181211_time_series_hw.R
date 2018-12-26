# https://otexts.org/fpp2/index.html

library(fpp2)

y <- ts(
  c(1,2,3,4,5,6,7,8,9,10),
  start = 2012,
  frequency = 4
)
y # Obj ts - frequency indicates how many data points in a year

head(melsyd)
# Frequency=52 indicates the data were collected weekly
summary(melsyd)

# autoplot() generates 'appropriate' plot for various types of data
autoplot(melsyd[, 'Economy.Class'])+
  ggtitle('Economy class passengers: Melbourne-Sydney')+
  xlab('Year')+
  ylab('Thousands')

# Three 'patterns': trend, seasonal, and cyclic

# Seasonal Plot
ggseasonplot(a10, year.labels=TRUE, year.labels.left=TRUE) +
  ylab("$ million") +
  ggtitle("Seasonal plot: antidiabetic drug sales")

ggseasonplot(a10, polar=TRUE) +
  ylab("$ million") +
  ggtitle("Polar seasonal plot: antidiabetic drug sales")

# Seasonal subseries plots
ggsubseriesplot(a10) +
  ylab("$ million") +
  ggtitle("Seasonal subseries plot: antidiabetic drug sales")

# To be continued...