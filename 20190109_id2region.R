library(tidyverse)

df_prep <- read_csv("../data/id2region.csv", 
                    col_types = cols(.default = "c"))

df_prep$REGION <- gsub("[[]]","", myString)

df_prep$prov_num <- substr(df_prep$PREFIX, 1, 2)
df_prep$city_num <- substr(df_prep$PREFIX, 3, 4)
df_prep$distr_num <- substr(df_prep$PREFIX, 5, 6)

temp_num <- ""
temp_text <- ""
df_prep$PROVINCE <- NA
for (i in 1:dim(df_prep)[1]){
  if (df_prep$prov_num[i] != temp_num){
    temp_num <- df_prep$prov_num[i]
    temp_text <- df_prep$REGION[i]
  }
  df_prep$PROVINCE[i] <- temp_text
}

temp_num <- ""
temp_text <- ""
df_prep$CITY <- NA
for (i in 1:dim(df_prep)[1]){
  if (df_prep$city_num[i] != temp_num){
    temp_num <- df_prep$city_num[i]
    temp_text <- df_prep$REGION[i]
  }
  df_prep$CITY[i] <- temp_text
}

df_prep$DISTRICT <- df_prep$REGION

df_prep <- select(df_prep, PREFIX, PROVINCE, CITY, DISTRICT)

#########################################################

df <- read_csv('../data/20190109_AH_ID_region.csv', 
               col_types = cols(.default = "c"), na = "NA")
df$PREFIX <- substr(df$ID, 1, 6)
df <- left_join(df, df_prep, by = "PREFIX")

df <- select(df, -PREFIX)

df <- rename(df, "序号" = NO, "身份证号" = ID, "一级" = PROVINCE, "二级" = CITY,
             "三级" = DISTRICT)
df$"是否死亡" <- ""
df$"死亡日期" <- ""
df$"备注（健在？查无此人？）" <- ""

df_output <- df
df_output$身份证号 <- paste0("'", df_output$身份证号)

temp_cities <- unique(df_output$"二级")
for (i in 1:length(temp_cities)) {
  temp_df <- filter(df_output, df_output$"二级" == temp_cities[i])
  write_excel_csv(temp_df,
            path = paste0("output/",i, temp_cities[i], dim(temp_df)[1], ".csv"))
}

