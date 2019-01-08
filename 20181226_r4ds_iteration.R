# https://r4ds.had.co.nz/iteration.html

library(tidyverse)

data("mtcars")

# seq_along():
y <- vector("double", 0)
seq_along(y)
#> integer(0)
1:length(y)
#> [1] 1 0

# when delaing with zero-length vector,
# seq_along() does the right thing while 
# length() does wrong

# map()
## map() applies the function to every colomn of the dataframe, then 
## makes a list, while map_*() creates a vector of some specific data form

map(mtcars, mean)
map_dbl(mtcars, mean)
map(mtcars, quantile)
# map_dbl(mtcars, quantile) # error: not a single value
map_dbl(mtcars, quantile, probs = .25) # parameters can be transferred

# model-fitting for every subgroup (cyc)
models <- mtcars %>% 
  split(.$cyl) %>% # . indicates the previous parameter, can only be used after %>%
  map(function(df) lm(mpg ~ wt, data = df))

# a more convenient version
models <- mtcars %>% 
  split(.$cyl) %>% 
  map(~lm(mpg ~ wt, data = .))

# use map to extract R2
models %>% 
  map(summary) %>% 
  map_dbl(~.$r.squared)
