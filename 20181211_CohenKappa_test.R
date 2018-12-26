# https://www.wikiwand.com/en/Cohen%27s_kappa

# Cohen's kappa is a measure of classifier.
# Cohen's kappa describes such a degree:
# To what degree do two raters agree,
# in case the agreement is not by chance?

generateMatrix <- function(a, b, c, d){
  return(matrix(c(a, b, c, d), ncol = 2,
                nrow = 2, byrow = T))
}

cohensKappa <- function(m){
  a <- m[1,1]
  b <- m[1,2]
  c <- m[2,1]
  d <- m[2,2]
  N <- sum(a,b,c,d)
  
  ## p_0: the observed agreement
  p_0 <- (a+d)/N
  ## based on the observed distribution of the choices,
  ## we estimate his 'preference', presuming that
  ## the distribution of the random choice is the same.
  p_e_a_yes <- (a+b)/N
  p_e_b_yes <- (a+c)/N
  p_e_a_no <- 1 - p_e_a_yes
  p_e_b_no <- 1 - p_e_b_yes
  p_e_yes <- p_e_a_yes * p_e_b_yes
  p_e_no <- p_e_a_no * p_e_b_no
  p_e <- p_e_yes + p_e_no
  
  kappa <- (p_0 - p_e)/(1 - p_e)
  
  return(list(kappa=kappa, p_0=p_0, p_e=p_e))
}