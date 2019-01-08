library(RISmed)

# Main function: EUtilsSummary
## query = 'gallbladder[ti]' # what you type in the search box
## type = 'esearch' ## and einfo, esearch, epost, esummary, elink, egquery, espell
### info on exx: https://www.ncbi.nlm.nih.gov/books/NBK25499/
## db = 'pubmed': any database in NCBI
## url: a way to bypass query
## encoding
## possible ...s: 
### About date: 
#### reldate = x: articles within x days (from now)
#### mindate = x1, maxdate = x2: as name indicate
#### datetype = 'edat'# online date or 'ppdt'# publication date

# EUtilsSummary(query,type="esearch",db="pubmed",url=NULL,encoding="unknown", ...)

data("myeloma")

res <- list()

i <- 1
for (time in seq(2014, 2018)){
  Sys.sleep(1)
  res[[i]] <- EUtilsSummary("Karolinska[Affiliation] AND biostatistics[Affiliation]",
                          type="esearch",db="pubmed",
                          mindate = time, maxdate = time)
  i <- i+1
}

rst <- list()

for (i in 1:5){
  Sys.sleep(1)
  rst[[i]] <- EUtilsGet(res[[i]])
}


res <- EUtilsSummary("Karolinska[Affiliation] AND biostatistics[Affiliation]",type="esearch",db="pubmed",
                     mindate = '2014', maxdate = '2018')
fetch <- EUtilsGet(res)
