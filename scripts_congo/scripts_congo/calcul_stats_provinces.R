options(stringsAsFactors=FALSE)

library(Hmisc)
library(sp)
library(rgdal)
library(raster)
library(plyr)
library(foreign)
#library(randomForest)


setwd("/media/dannunzio/fra2015/congo/output/stats_provinces/")
setwd("D:/congo/output/stats_provinces/")


list_rd <-list.files(pattern="stat_out_dt_rd.txt")
list_ly <-list.files(pattern="stat_out_dt_road_ly1112_strat.txt")
list_gfc<-list.files(pattern="stat_gfc.txt")
list_gaf<-list.files(pattern="stat_gaf.txt")
list_fct<-list.files(pattern="stat_fct.txt")

############## Calcul et aggregation par boite des stats de sortie + route
file<-list_rd[1]
table_rd<-read.table(file)
summary(table_rd[,2]-rowSums(table_rd[,c(3:37)]))

for(file in list_rd[c(2:length(list_rd))]){
  temp<-read.table(file)
  table_rd<-rbind(table_rd,temp)
}

names(table_rd)<-c("prov","total","class0",paste("class",seq(1:34),sep="_"))
head(table_rd)
out_rd<-table_rd[,c(1,2,3,5,7,14,15,16,34,35,36,37)]
names(out_rd)<-c("prov","total","no_data","autre","eau","FP","FS","FM","PP","PS","PM","rout_gaf")

############## Calcul et aggregation par boite des stats de sortie + route + perte 2011-2013
file<-list_ly[1]
table_ly<-read.table(file)
summary(table_ly[,2]-rowSums(table_ly[,c(3:40)]))

for(file in list_ly[c(2:length(list_ly))]){
  temp<-read.table(file)
  table_ly<-rbind(table_ly,temp)
}

names(table_ly)<-c("prov","total","class0",paste("class",seq(1:37),sep="_"))
head(table_ly)

out_ly<-table_ly[,c(1,2,3,5,7,14,15,16,34,35,36,37,38,39,40)]
names(out_ly)<-c("prov","total","no_data","autre","eau","FP","FS","FM","PP","PS","PM","routes_gaf","P2011","P2012","P2013")

############## Calcul et aggregation par boite des stats de GFC
file<-list_gfc[1]
table_gfc<-read.table(file)
summary(table_gfc[,2]-rowSums(table_gfc[,c(3:16)]))

for(file in list_gfc[c(2:length(list_gfc))]){
  temp<-read.table(file)
  table_gfc<-rbind(table_gfc,temp)
}

names(table_gfc)<-c("prov","total","NL",paste("An",seq(1:13),sep="_"))

############## Calcul et aggregation par boite des stats de fct
file<-list_fct[1]
table_fct<-read.table(file)
summary(table_fct[,2]-rowSums(table_fct[,c(3:15)]))

for(file in list_fct[c(2:length(list_fct))]){
  temp<-read.table(file)
  table_fct<-rbind(table_fct,temp)
}

names(table_fct)<-c("prov","total","NoData","NF","ND","Eau","FP","FS","FM","P_P_0005","P_S_0005","P_M_0005","P_P_0510","P_S_0510","P_M_0510")
#head(table_fct)

############## Calcul et aggregation par boite des stats de gaf
file<-list_gaf[1]
table_gaf<-read.table(file)
summary(table_gaf[,2]-rowSums(table_gaf[,c(3:12)]))

for(file in list_gaf[c(2:length(list_gaf))]){
  temp<-read.table(file)
  table_gaf<-rbind(table_gaf,temp)
}

names(table_gaf)<-c("prov","total","ND","F","NF","F_TC","F_ZH","F_S","F_If","F_Au","Gain","Nuage")


############## Somme des colonnes par province
gfc_tmp<-as.data.frame(sapply(names(table_gfc),function(x){tapply(table_gfc[,x],table_gfc$prov,sum)}))
gaf_tmp<-as.data.frame(sapply(names(table_gaf),function(x){tapply(table_gaf[,x],table_gaf$prov,sum)}))
fct_tmp<-as.data.frame(sapply(names(table_fct),function(x){tapply(table_fct[,x],table_fct$prov,sum)}))
ly_tmp<-as.data.frame(sapply(names(out_ly),function(x){tapply(out_ly[,x],out_ly$prov,sum)}))
rd_tmp<-as.data.frame(sapply(names(out_rd),function(x){tapply(out_rd[,x],out_rd$prov,sum)}))

gfc<-rbind(gfc_tmp,colSums(gfc_tmp))*900/10000
gaf<-rbind(gaf_tmp,colSums(gaf_tmp))*900/10000
fct<-rbind(fct_tmp,colSums(fct_tmp))*900/10000
ly<-rbind(ly_tmp,colSums(ly_tmp))*900/10000
rd<-rbind(rd_tmp,colSums(rd_tmp))*900/10000

summary(fct_tmp[,2]-rowSums(fct_tmp[,c(3:15)]))
summary(gaf_tmp[,2]-rowSums(gaf_tmp[,c(3:12)]))
summary(gfc_tmp[,2]-rowSums(gfc_tmp[,c(3:16)]))
summary(ly_tmp[,2]-rowSums(ly_tmp[,c(3:15)]))
summary(rd_tmp[,2]-rowSums(rd_tmp[,c(3:12)]))

head(ly_tmp)

provinces<-c("KOUILOU","NIARI","BOUENZA","LEKOUMOU","POOL","PLATEAUX","CUVETTE","CUVETTE OUEST","SANGHA","LIKOUALA","TOTAL")

gfc$prv<-provinces
fct$prv<-provinces
gaf$prv<-provinces
ly$prv<-provinces
rd$prv<-provinces
ly
write.table(file="../stats_gfc.csv",gfc,sep=",",quote=FALSE, col.names=T,row.names=FALSE)
write.table(file="../stats_gaf.csv",gaf,sep=",",quote=FALSE, col.names=T,row.names=FALSE)
write.table(file="../stats_fct.csv",fct,sep=",",quote=FALSE, col.names=T,row.names=FALSE)
write.table(file="../stats_ly12_strat.csv",ly,sep=",",quote=FALSE, col.names=T,row.names=FALSE)
write.table(file="../stats_rd.csv",rd,sep=",",quote=FALSE, col.names=T,row.names=FALSE)
