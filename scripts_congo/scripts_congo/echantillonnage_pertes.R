options(stringsAsFactors=FALSE)

library(Hmisc)
library(sp)
library(rgdal)
library(raster)
library(plyr)
library(foreign)
#library(randomForest)


setwd("/media/xubuntu/fra2015/congo/output/")

################## Echantillonnage des points sur la carte par classe
getwd()
rast <-raster("arbre_route_pertes111213_filtre.tif",NAvalue=0)
tmp<-sampleRandom(rast,100000,xy=T)

#my_dbf<-read.dbf("/home/xubuntu/test2.dbf")
#table(my_dbf$arbre_rout)


smp<-data.frame(tmp)
#sapply(levels(as.factor(smp$arbre)),function(x){nrow(smp[smp$arbre==x,])})
table(smp$arbre)
write.table(file="../points_ce_soir.txt",smp,sep=" ",quote=FALSE, col.names=T,row.names=FALSE)
str(smp)

# ######### extraire les classes rares et convertir directement raster -> points
pts_31<-rasterToPoints(rast,fun=function(rast){rast==31})
pts_32<-rasterToPoints(rast,fun=function(rast){rast==32})
pts_33<-rasterToPoints(rast,fun=function(rast){rast==33})
pts_34<-rasterToPoints(rast,fun=function(rast){rast==34})
pts_04<-rasterToPoints(rast,fun=function(rast){rast==4})

df_pts_31<-as.data.frame(pts_31)
df_pts_31$id<-row(df_pts_31)[,1]

df_pts_32<-as.data.frame(pts_32)
df_pts_32$id<-row(df_pts_32)[,1]

df_pts_33<-as.data.frame(pts_33)
df_pts_33$id<-row(df_pts_33)[,1]

df_pts_34<-as.data.frame(pts_34)
df_pts_34$id<-row(df_pts_34)[,1]

df_pts_04<-as.data.frame(pts_04)
df_pts_04$id<-row(df_pts_04)[,1]
# ######### choisir xx=50 points aleatoires parmi les points ayant le code de classe rare
smp_31<-df_pts_31[df_pts_31$id %in% sample(df_pts_31[,4],50),]
write.table(file="../points_class31.txt",smp_31,sep=" ",quote=FALSE, col.names=T,row.names=FALSE)

smp_32<-df_pts_32[df_pts_32$id %in% sample(df_pts_32[,4],50),]
write.table(file="../points_class32.txt",smp_32,sep=" ",quote=FALSE, col.names=T,row.names=FALSE)

smp_33<-df_pts_33[df_pts_33$id %in% sample(df_pts_33[,4],50),]
write.table(file="../points_class33.txt",smp_33,sep=" ",quote=FALSE, col.names=T,row.names=FALSE)

smp_34<-df_pts_34[df_pts_34$id %in% sample(df_pts_34[,4],50),]
write.table(file="../points_class34.txt",smp_34,sep=" ",quote=FALSE, col.names=T,row.names=FALSE)

smp_04<-df_pts_04[df_pts_04$id %in% sample(df_pts_04[,4],50),]
write.table(file="../points_class04.txt",smp_04,sep=" ",quote=FALSE, col.names=T,row.names=FALSE)

# ######### accoller les listes ensemble
x<-rbind(smp[smp$arbre == 2 | smp$arbre == 11 | smp$arbre == 12 | smp$arbre == 13,],smp_31[,c(1:3)])
x<-rbind(x,smp_32[,c(1:3)])
x<-rbind(x,smp_33[,c(1:3)])
x<-rbind(x,smp_34[,c(1:3)])
all_points<-rbind(x,smp_04[,c(1:3)])

table(all_points$arbre)
all_points$id<-row(all_points)[,1]

df[,c(1,7)]

final<-all_points[all_points$id %in% 
                    sample(all_points[all_points$arbre==2,4],174)
                  |
                    all_points$id %in% 
                    sample(all_points[all_points$arbre==4,4],50)
                  
                  |
                    all_points$id %in% 
                    sample(all_points[all_points$arbre==11,4],198)
                  
                  |
                    all_points$id %in% 
                    sample(all_points[all_points$arbre==12,4],105)
                  
                  |
                    all_points$id %in% 
                    sample(all_points[all_points$arbre==13,4],181)
                  
                  |
                    all_points$id %in% 
                    sample(all_points[all_points$arbre==31,4],50)
                  
                  |
                    all_points$id %in% 
                    sample(all_points[all_points$arbre==32,4],50)
                  
                  |
                    all_points$id %in% 
                    sample(all_points[all_points$arbre==33,4],50)
                  |
                    all_points$id %in% 
                    sample(all_points[all_points$arbre==34,4],50)                  ,]

#final_bck<-final
#final<-final_bck


final<-read.csv("c:/Users/dannunzio/Documents/countries/congo_brazza/carto_arbre_decision/aa_congo/cep_files_congo/points_congo.ced")


final<-arrange(final,class)
final$group  <- rep(1:9,len=908) 
final<-arrange(final,group)

i<-1
name<-paste("group_",i,sep="")
tmp<-final[final$group == i,]
tmp$ordre<-sample(length(tmp$id))
final_arrange<-arrange(tmp,ordre)


for(i in 2:9){
  name<-paste("group_",i,sep="")
  tmp<-final[final$group == i,]
  tmp$ordre<-sample(length(tmp$id))
  tmp<-arrange(tmp,ordre)
  final_arrange<-rbind(final_arrange,tmp)
}

table(final_arrange$class,final_arrange$group)
tapply(final_arrange$id,final_arrange$group,function(x){c(min(x),max(x))})

names(final_arrange)
final_arrange$id<-row(final_arrange)[,1]
write.table(file="../sampling_908pts_shuffled.ced",final_arrange,sep=",",quote=FALSE, col.names=T,row.names=FALSE)
