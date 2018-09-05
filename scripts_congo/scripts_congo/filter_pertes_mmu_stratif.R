options(stringsAsFactors=FALSE)

library(Hmisc)
library(sp)
library(rgdal)
library(raster)
library(plyr)
library(foreign)

CommArgs <- commandArgs(TRUE)

hist <- CommArgs[1]
fact <- CommArgs[2]
output   <- CommArgs[3]


# #
# # setwd("e://congo/output/histograms/")
#setwd("/media/xubuntu/fra2015/congo/output/sortie_arbre_route_pertes_11_12/")
#
#df<-"/media/xubuntu/fra2015/congo/output/sortie_arbre_route_pertes_11_12/

##############################
### Lire les tables de donnees

df<-read.table(hist)
df<-df[,c(1,2,3,14,15,16)]
names(df)<-c("id","total","ND","p11","p12","p13")
df$class<-0

head(df)

df_fct<-read.table(fact)
names(df_fct)<-c("id","total","ND","NF","ND","Eau","FP","FS","FM","P_P_0005","P_S_0005","P_M_0005","P_P_0510","P_S_0510","P_M_0510")


################## STRATIFICATION  
################## Pertes  Primaire
#       CODE = Perte
#       FORET Primaire  majoritaire

cat("Stratification P Primaire \n")

tryCatch({
  df[
    df$id %in% df_fct[df_fct$FP > df_fct$FS & df_fct$FP >= df_fct$FM,]$id
    &
    df$p11 + df$p12 >= 5
    ,]$class<-31
  
  
}, error=function(e){cat("Configuration impossible \n")}
)

##################  Perte Marecageuse
#       CODE = Perte
#       Foret  Marecageuse majoritaire

cat("Stratification P Marecageuse \n")

tryCatch({
  df[
    df$id %in% df_fct[df_fct$FM > df_fct$FS & df_fct$FM > df_fct$FP,]$id
    &
    df$p11 + df$p12 >= 5
    ,]$class<-33
  
}, error=function(e){cat("Configuration impossible \n")}
)

################## Perte Secondaire
#       CODE = Perte
#       Foret Secondaire majoritaire

cat("Stratification P Secondaire \n")

tryCatch({
  df[
    df$id %in% df_fct[df_fct$FS >= df_fct$FM & df_fct$FS >= df_fct$FP,]$id
    &
    df$p11 + df$p12 >= 5
    ,]$class<-32

  
}, error=function(e){cat("Configuration impossible \n")}
)


################## Exporter les resultats comme fichier TXT
write.table(file=output,df,sep=" ",quote=FALSE, col.names=FALSE,row.names=FALSE)
