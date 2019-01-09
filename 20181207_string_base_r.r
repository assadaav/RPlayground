#https://jozefhajnala.gitlab.io/r/r007-string-manipulation/

# On String
# "" == ''
# character == string

d <- c("aaa","bbbb","cc")
# length of arrary
length(d)
# and length of (each) string/character
nchar(d)

# character version of NA
NA_character_

# convert
as.character(c(
  42,
  Sys.time(),
  factor("A",levels = LETTERS)
))

# Output
print(c("t1","t2"))
cat(c("t1","t2"))

# special char
  # line break
cat("1st\n2nd")
  # tab
cat("former\n\tlatter")

# paste
paste(1:3, month.name)
paste(1:3, month.name, sep=':')
# paste0: a short hand for sep='' 
paste0(1:3, month.name)
# output with format
sprintf("%s: %s", 1:3, month.name)
# collapse: merge all into one vector
paste(1:3, month.name, collapse = ',')
# Another solution:
toString(paste(1:3, month.name, sep=':'))

# string manipulation
# upper and lower
tolower(month.name)
toupper(month.name)
  # an alternate solution
casefold(month.name, upper=T)
# char substitution
chartr("ade","123","abcdefg")
# space trimming
trimws("   Hahaha.   ")
trimws("   Hahaha.   ", which = "left")
trimws("   Hahaha.   ", which = "right")
# Encoding conversion
iconv("šibrinkuje", "UTF-8","ASCII","?")
iconv("赵C", "UTF-8","ASCII","?")
# Quoting
sQuote(month.name) # embraced with ""
dQuote(month.name) # embraced with \"\"
# substr
substr(month.name, 1, 3)
substr(month.name, nchar(month.name)-2, nchar(month.name))
startsWith(month.name, "J")
endsWith(month.name, "ember")
# Auto abbr
abbreviate(month.name, minlength = 3)

# Substitution
myString <- paste(1:3, month.name, sep = '.')
chartr("a","4",myString)
gsub("a","4",myString)
sub("a","4",myString) # only first char substituted
gsub(".","0", myString)
gsub(".","0", myString, fixed = T) # fixed: regular expression (default) or string

# find
grepl("ember", myString) # array of T/F
grep("ember", myString) # which? (indices)
grep("ember", myString, value = T) # which? (value)
regexpr("a", myString) # where is the first?
gregexpr("a", myString) # where is everyone?

# Other
# Levenshtein distance
adist(c("lazy", "lasso", "lassie"), c("lazy", "lazier", "laser"))
# repeat
strrep(c('a','b','c'), 1:3)
# other packages:
  # 1. stringi
  # 2. stringr