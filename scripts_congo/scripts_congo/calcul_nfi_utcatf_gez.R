options(stringsAsFactors=FALSE)

library(Hmisc)
library(sp)
library(rgdal)
library(raster)
library(plyr)
library(foreign)
#library(randomForest)


setwd("/media/dannunzio/data_ofgt/stratification/")
df<-read.dbf("CUT_principale/placette_utcatf_gez.dbf")
head(df)
table(df$CUT_Name,df$arbre_rout)
list_gez <-list.files(pattern="utcatf.txt")

############## Calcul et aggregation par boite des stats de sortie + route
file<-list_gez[1]
table_gez<-read.table(file)
summary(table_gez[,2]-rowSums(table_gez[,c(3:37)]))

for(file in list_gez[c(2:length(list_gez))]){
  temp<-read.table(file)
  table_gez<-rbind(table_gez,temp)
}

names(table_gez)<-c("gez","total","class0",paste("class",seq(1:34),sep="_"))
head(table_gez)
out_gez<-table_gez[,c(1,2,3,5,7,14,15,16,34,35,36,37)]
names(out_gez)<-c("gez","total","no_data","autre","eau","FP","FS","FM","PP","PS","PM","rout_gaf")

############## Somme des colonnes par gez
gez_tmp<-as.data.frame(sapply(names(out_gez),function(x){tapply(out_gez[,x],out_gez$gez,sum)}))
gez <- gez_tmp*900/10000
gez_total <-colSums(gez_tmp)*900/10000

gez_total["total"] - gez_total["no_data"]

summary(gez[,2]-rowSums(gez[,c(3:12)]))

gez$gez_codes <- as.numeric(rownames(gez))

df<-merge(gez,gez_table,by.x="gez_codes",by.y="Value")
summary(df)
length(unique(df$gez_codes))
length(unique(df$Code))
length(unique(df$ELU))
length(unique(df$EF_Bio_Des))
unique(df$EF_LF_Desc)
unique(df$EF_Bio_Des)
unique(df$EF_Lit_Des)

(x1 <- unique(df$EF_GLC_Des))
(x2 <- c("NF","OpenF","NF","OpenF","ClosedF","OpenF","NF","NF","OpenF","NF","NF","NF","MediumF","OpenSwampF","NF","ClosedSwampF","NF","OpenF","Water","Nodata"))


sapply(names(df),function(x){length(unique(df[,x]))})
table(df$EF_GLC_Des)
head(df)

recode <-as.data.frame(cbind(x1,x2))
names(recode)=c("EF_GLC_Des","strata")
recode

df1<-merge(df,recode,by="EF_GLC_Des")
unique(df1$strata)
strata_code<-as.data.frame(cbind(c(2,11,13,15,14,12,9,4),unique(df1$strata)))
names(strata_code)<-c("strata_code","strata")
strata_code

head(df1)
df2<-df1[,c(25,4:14)]
names(df2)

strata<-as.data.frame(sapply(names(df2)[-1],function(x){tapply(df2[,x],df2$strata,sum)}))
strata
colSums(strata)["total"]-colSums(strata)["no_data"]
df3<-merge(df1,strata_code,by="strata")
head(df3)
reclass <- df3[,c("gez_codes","strata_code")]
write.table(file="../../reclass_strata.txt",reclass,sep=" ",quote=FALSE, col.names=F,row.names=FALSE)
summary(reclass)
df3[df3$gez_codes==45448,]
