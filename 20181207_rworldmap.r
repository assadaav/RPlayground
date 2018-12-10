# rworldmap
# http://blog.sina.com.cn/s/blog_4a238ec20102uwnz.html
# https://cran.r-project.org/web/packages/rworldmap/vignettes/rworldmap.pdf
# https://github.com/KehaoWu/PM25Plot

# code from Kehao Wu
if(version$os=="mingw32"){
  ChinaLocation = read.csv(file = "China.Cities.Location.Win.csv")
}else  ChinaLocation = read.csv(file = "China.Cities.Location.Linux.csv")

