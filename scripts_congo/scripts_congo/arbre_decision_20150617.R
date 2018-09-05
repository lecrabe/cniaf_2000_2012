options(stringsAsFactors=FALSE)

library(Hmisc)
library(sp)
library(rgdal)
library(raster)
library(plyr)
library(foreign)

CommArgs <- commandArgs(TRUE)

facet <- CommArgs[1]
gaf   <- CommArgs[2]
gfc   <- CommArgs[3]
gfcly <- CommArgs[4]
output<- CommArgs[5]

statout<-CommArgs[6]
statgaf<-CommArgs[7]
statfct<-CommArgs[8]
statgfc<-CommArgs[9]

treeout<-CommArgs[10]
stratout<-CommArgs[11]

# #
# # setwd("e://congo/output/histograms/")
# setwd("/media/xubuntu/fra2015/congo/output/histograms/")
# facet <- "hh19vv08h4v6_facet.txt"
# gaf   <- "hh19vv08h4v6_gaf.txt"
# gfc   <- "hh19vv08h4v6_gfc_tc.txt"
# gfcly <- "hh19vv08h4v6_gfc_ly.txt"
# output<- "../final/hh19vv08h4v6_out.txt"
# treeout<-"arbre.txt"
# stratout<-"stratout.txt"

##############################
### Lire les tables de donnees

df_fct<-    read.table(facet)
df_gaf<-    read.table(gaf)
df_gfc<-    read.table(gfc)
df_gfc_ly<- read.table(gfcly)

names(df_fct)<-c("id","total","ND","NF","ND","Eau","FP","FS","FM","P_P_0005","P_S_0005","P_M_0005","P_P_0510","P_S_0510","P_M_0510")
names(df_gaf)<-c("id","total","ND","F","NF","F_TC","F_ZH","F_S","F_If","F_Au","Gain","Nuage")
names(df_gfc)<-c("id","total","TC_Pc","TC_SD")
names(df_gfc_ly)<-c("id","total","NL",paste("An",seq(1:13),sep="_"))

summary(df_gaf$total-rowSums(df_gaf[,c(3:12)]))
summary(df_fct$total-rowSums(df_fct[,c(3:15)]))
summary(df_gfc_ly$total-rowSums(df_gfc_ly[,c(3:16)]))

# head(df_gaf)
# head(df_fct)
# head(df_gfc_ly)
# df_fct[df_fct$id==2,]

out <- df_gfc[,c(1,2)]

length(unique(out$id))
# head(out)
out$code<-0
out$branch<-0
head(df_gfc_ly)

###################  Branche 1 -> pertes
# /     FACET PERTES >= 30%
# /\    GFC PERTES   >= 30%
cat("Branche 1 \n")

tryCatch({
  liste_F1<- 
    out[
    out$id %in% df_fct[df_fct$P_P_0005 + df_fct$P_S_0005 + df_fct$P_M_0005+ df_fct$P_P_0510 + df_fct$P_S_0510 + df_fct$P_M_0510 >= df_fct$total*0.3,]$id
    &
    out$id %in% df_gfc_ly[rowSums(df_gfc_ly[,c(4:13)]) >= df_gfc_ly$total*0.3,]$id
    ,]$id

  out[out$id %in% liste_F1,]$code<-3
  out[out$id %in% liste_F1,]$branch <- 1
  
}, error=function(e){cat("Configuration impossible \n")}
)

###################  Branche 2 -> pertes
# /     FACET PERTES >= 30%
# //    GFC PERTES   <  30%
# //\   GAF PERTES   >= 30%

cat("Branche 2 \n")

tryCatch({
  liste_F2 <- 
  out[
    out$id %in% df_fct[df_fct$P_P_0005 + df_fct$P_S_0005 + df_fct$P_M_0005+ df_fct$P_P_0510 + df_fct$P_S_0510 + df_fct$P_M_0510 >= df_fct$total*0.3,]$id
    &
    out$id %in% df_gfc_ly[rowSums(df_gfc_ly[,c(4:13)]) < df_gfc_ly$total*0.3,]$id
    &
    out$id %in% df_gaf[rowSums(df_gaf[,c(6:10)]) >= df_gaf$total*0.3,]$id
    ,]$id
  
  out[out$id %in% liste_F2,]$code<-3
  out[out$id %in% liste_F2,]$branch <- 2
  
}, error=function(e){cat("Configuration impossible \n")}
)

###################  Branche 3 -> foret
# /     FACET PERTES >= 30%
# //    GFC PERTES   <  30%
# ///   GAF PERTES   <  30%
# ///\  FACET FORET  >= 30%

cat("Branche 3 \n")

tryCatch({
  liste_F3 <- 
    out[
    out$id %in% df_fct[df_fct$P_P_0005 + df_fct$P_S_0005 + df_fct$P_M_0005+ df_fct$P_P_0510 + df_fct$P_S_0510 + df_fct$P_M_0510 >= df_fct$total*0.3,]$id
    &
    out$id %in% df_gfc_ly[rowSums(df_gfc_ly[,c(4:13)]) < df_gfc_ly$total*0.3,]$id
    &
    out$id %in% df_gaf[rowSums(df_gaf[,c(6:10)]) < df_gaf$total*0.3,]$id
    &
    out$id %in% df_fct[df_fct$FP +  df_fct$FS + df_fct$FM >= df_fct$total*0.3,]$id
    ,]$id
  
  out[out$id %in% liste_F3,]$code<-1
  out[out$id %in% liste_F3,]$branch <- 3
  
}, error=function(e){cat("Configuration impossible \n")}
)

###################  Branche 4 -> non-foret
# /     FACET PERTES >= 30%
# //    GFC PERTES   <  30%
# ///   GAF PERTES   <  30%
# ////  FACET FORET  <  30%

cat("Branche 4 \n")

tryCatch({
  liste_F4 <- out[
    out$id %in% df_fct[df_fct$P_P_0005 + df_fct$P_S_0005 + df_fct$P_M_0005+ df_fct$P_P_0510 + df_fct$P_S_0510 + df_fct$P_M_0510 >= df_fct$total*0.3,]$id
    &
      out$id %in% df_gfc_ly[rowSums(df_gfc_ly[,c(4:13)]) < df_gfc_ly$total*0.3,]$id
    &
      out$id %in% df_gaf[rowSums(df_gaf[,c(6:10)]) < df_gaf$total*0.3,]$id
    &
      out$id %in% df_fct[df_fct$FP +  df_fct$FS + df_fct$FM < df_fct$total*0.3,]$id
    ,]$id
  
  out[out$id %in% liste_F4,]$code<-2
  out[out$id %in% liste_F4,]$branch <- 4
  
}, error=function(e){cat("Configuration impossible \n")}
)

###################  Branche 5 -> eau
# \     FACET PERTES <  30%
# \/    FACET FORET  <  30%
# \//   FACET EAU    >= 30%
# \///  GFC   FORET  <  30%

cat("Branche 5 \n")

tryCatch({
  liste_F5 <- out[
    out$id %in% df_fct[df_fct$P_P_0005 + df_fct$P_S_0005 + df_fct$P_M_0005+ df_fct$P_P_0510 + df_fct$P_S_0510 + df_fct$P_M_0510 < df_fct$total*0.3,]$id
    &
    out$id %in% df_fct[df_fct$FP + df_fct$FS + df_fct$FM < df_fct$total*0.3,]$id
    &
    out$id %in% df_fct[df_fct$Eau >= df_fct$total*0.3,]$id
    &
    out$id %in% df_gfc[df_gfc$TC_Pc < 30,]$id
    ,]$id
  
  out[out$id %in% liste_F5,]$code<-4
  out[out$id %in% liste_F5,]$branch <- 5
  
}, error=function(e){cat("Configuration impossible \n")}
)


###################  Branche 6 -> Non Foret
# \     FACET PERTES <  30%
# \/    FACET FORET  <  30%
# \//   FACET EAU    >= 30%
# \//\  GFC   FORET  >= 30%
# \//\/ GAF   FORET  <  30%

cat("Branche 6 \n")

tryCatch({
  liste_F6 <-  out[
    out$id %in% df_fct[df_fct$P_P_0005 + df_fct$P_S_0005 + df_fct$P_M_0005+ df_fct$P_P_0510 + df_fct$P_S_0510 + df_fct$P_M_0510 < df_fct$total*0.3,]$id
    &
      out$id %in% df_fct[df_fct$FP + df_fct$FS + df_fct$FM < df_fct$total*0.3,]$id
    &
      out$id %in% df_fct[df_fct$Eau >= df_fct$total*0.3,]$id
    &
      out$id %in% df_gfc[df_gfc$TC_Pc >= 30,]$id
    &
      out$id %in% df_gaf[df_gaf$F < df_gaf$total*0.3,]$id
    ,]$id
  
  out[out$id %in% liste_F6,]$code <- 2
  out[out$id %in% liste_F6,]$branch <- 6
  
}, error=function(e){cat("Configuration impossible \n")}
)

###################  Branche 7 -> foret
# \     FACET PERTES <  30%
# \/    FACET FORET  <  30%
# \//   FACET EAU    >= 30%
# \//\  GFC   FORET  >= 30%
# \//\\ GAF   FORET  >= 30%

cat("Branche 7 \n")

tryCatch({
  liste_F7 <-  out[
    out$id %in% df_fct[df_fct$P_P_0005 + df_fct$P_S_0005 + df_fct$P_M_0005+ df_fct$P_P_0510 + df_fct$P_S_0510 + df_fct$P_M_0510 < df_fct$total*0.3,]$id
    &
      out$id %in% df_fct[df_fct$FP + df_fct$FS + df_fct$FM < df_fct$total*0.3,]$id
    &
      out$id %in% df_fct[df_fct$Eau >= df_fct$total*0.3,]$id
    &
      out$id %in% df_gfc[df_gfc$TC_Pc >= 30,]$id
    &
      out$id %in% df_gaf[df_gaf$F >= df_gaf$total*0.3,]$id
    
    ,]$id
  
  out[out$id %in% liste_F7,]$code<-1
  out[out$id %in% liste_F7,]$branch<-7
  
}, error=function(e){cat("Configuration impossible \n")}
)

###################  Branche 8 -> non-foret
# \     FACET PERTES <  30%
# \/    FACET FORET  <  30%
# \/\   FACET EAU    <  30%
# \/\\  GFC FORET    <  30%

cat("Branche 8 \n")

tryCatch({
 liste_F8 <- out[
    out$id %in% df_fct[df_fct$P_P_0005 + df_fct$P_S_0005 + df_fct$P_M_0005+ df_fct$P_P_0510 + df_fct$P_S_0510 + df_fct$P_M_0510 < df_fct$total*0.3,]$id
    &
      out$id %in% df_fct[df_fct$FP + df_fct$FS + df_fct$FM < df_fct$total*0.3,]$id
    &
      out$id %in% df_fct[df_fct$Eau < df_fct$total*0.3,]$id
    &
      out$id %in% df_gfc[df_gfc$TC_Pc < 30,]$id

    ,]$id
 
 out[out$id %in% liste_F8,]$code <- 2
 out[out$id %in% liste_F8,]$branch <- 8
 
}, error=function(e){cat("Configuration impossible \n")}
)

###################  Branche 9 -> non-foret
# \     FACET PERTES <  30%
# \/    FACET FORET  <  30%
# \/\   FACET EAU    <  30%
# \/\/  GFC FORET    >= 30%
# \/\/\ GAF FORET    <  30%

cat("Branche 9 \n")

tryCatch({
  liste_F9 <- out[
    out$id %in% df_fct[df_fct$P_P_0005 + df_fct$P_S_0005 + df_fct$P_M_0005+ df_fct$P_P_0510 + df_fct$P_S_0510 + df_fct$P_M_0510 < df_fct$total*0.3,]$id
    &
      out$id %in% df_fct[df_fct$FP + df_fct$FS + df_fct$FM < df_fct$total*0.3,]$id
    &
      out$id %in% df_fct[df_fct$Eau < df_fct$total*0.3,]$id
    &
      out$id %in% df_gfc[df_gfc$TC_Pc >= 30,]$id
    &
      out$id %in% df_gaf[df_gaf$F < df_gaf$total*0.3,]$id
    &
      out$id %in% df_fct[df_fct$ND < df_fct$total*0.05,]$id 
    ,]$id
  
  out[out$id %in% liste_F9,]$code<-2
  out[out$id %in% liste_F9,]$branch <- 9
  
}, error=function(e){cat("Configuration impossible \n")}
)

###################  Branche 10 -> foret
# \     FACET PERTES <  30%
# \/    FACET FORET  <  30%
# \/\   FACET EAU    <  30%
# \/\/  GFC FORET    >= 30%
# \/\// GAF FORET    >= 30%

cat("Branche 10 \n")

tryCatch({
  liste_F10 <- out[
    out$id %in% df_fct[df_fct$P_P_0005 + df_fct$P_S_0005 + df_fct$P_M_0005+ df_fct$P_P_0510 + df_fct$P_S_0510 + df_fct$P_M_0510 < df_fct$total*0.3,]$id
    &
      out$id %in% df_fct[df_fct$FP + df_fct$FS + df_fct$FM < df_fct$total*0.3,]$id
    &
      out$id %in% df_fct[df_fct$Eau < df_fct$total*0.3,]$id
    &
      out$id %in% df_gfc[df_gfc$TC_Pc >= 30,]$id
    &
      out$id %in% df_gaf[df_gaf$F >= df_gaf$total*0.3,]$id
    ,]$id
  
  out[out$id %in% liste_F10,]$code<-1
  out[out$id %in% liste_F10,]$branch <- 10
  
}, error=function(e){cat("Configuration impossible \n")}
)


###################  Branche 11 -> pertes
# \     FACET PERTES <  30%
# \\    FACET FORET  >= 30%
# \\/   GFC PERTES   >= 30%
# \\//  GAF PERTES   >= 30%

cat("Branche 11 \n")

tryCatch({
  liste_F11 <- out[
    out$id %in% df_fct[df_fct$P_P_0005 + df_fct$P_S_0005 + df_fct$P_M_0005+ df_fct$P_P_0510 + df_fct$P_S_0510 + df_fct$P_M_0510 < df_fct$total*0.3,]$id
    &
      out$id %in% df_fct[df_fct$FP + df_fct$FS + df_fct$FM >= df_fct$total*0.3,]$id
    &
      out$id %in% df_gfc_ly[rowSums(df_gfc_ly[,c(4:13)]) >= df_gfc_ly$total*0.3,]$id
    &
      out$id %in% df_gaf[rowSums(df_gaf[,c(6:10)]) >= df_gaf$total*0.3,]$id    
    ,]$id
  
  out[out$id %in% liste_F11,]$code<-3
  out[out$id %in% liste_F11,]$branch <- 11
  
}, error=function(e){cat("Configuration impossible \n")}
)

###################  Branche 12 -> foret
# \     FACET PERTES <  30%
# \\    FACET FORET  >= 30%
# \\/   GFC PERTES   >= 30%
# \\/\  GAF PERTES   <  30%

cat("Branche 12 \n")

tryCatch({
  liste_F12 <- out[
    out$id %in% df_fct[df_fct$P_P_0005 + df_fct$P_S_0005 + df_fct$P_M_0005+ df_fct$P_P_0510 + df_fct$P_S_0510 + df_fct$P_M_0510 < df_fct$total*0.3,]$id
    &
      out$id %in% df_fct[df_fct$FP + df_fct$FS + df_fct$FM >= df_fct$total*0.3,]$id
    &
      out$id %in% df_gfc_ly[rowSums(df_gfc_ly[,c(4:13)]) >= df_gfc_ly$total*0.3,]$id
    &
      out$id %in% df_gaf[rowSums(df_gaf[,c(6:10)]) < df_gaf$total*0.3,]$id 
    ,]$id
  
  out[out$id %in% liste_F12,]$code<-1
  out[out$id %in% liste_F12,]$branch <- 12
  
}, error=function(e){cat("Configuration impossible \n")}
)

###################  Branche 13 -> foret
# \     FACET PERTES <  30%
# \\    FACET FORET  >= 30%
# \\\   GFC PERTES   <  30%
# \\\/  GFC FORET    >= 30%

cat("Branche 13 \n")

tryCatch({
  liste_F13 <- out[
      out$id %in% df_fct[df_fct$P_P_0005 + df_fct$P_S_0005 + df_fct$P_M_0005+ df_fct$P_P_0510 + df_fct$P_S_0510 + df_fct$P_M_0510 < df_fct$total*0.3,]$id
    &
      out$id %in% df_fct[df_fct$FP + df_fct$FS + df_fct$FM >= df_fct$total*0.3,]$id
    &
      out$id %in% df_gfc_ly[rowSums(df_gfc_ly[,c(4:13)]) < df_gfc_ly$total*0.3,]$id
    &
      out$id %in% df_gfc[df_gfc$TC_Pc >= 30,]$id
    ,]$id
  
  out[out$id %in% liste_F13,]$code<-1
  out[out$id %in% liste_F13,]$branch <- 13  
}, error=function(e){cat("Configuration impossible \n")}
)

###################  Branche 14 -> foret
# \      FACET PERTES <  30%
# \\     FACET FORET  >= 30%
# \\\    GFC PERTES   <  30%
# \\\\   GFC FORET    <  30%
# \\\\/  GAF FORET    >= 30%

cat("Branche 14 \n")

tryCatch({
  liste_F14 <- out[
      out$id %in% df_fct[df_fct$P_P_0005 + df_fct$P_S_0005 + df_fct$P_M_0005+ df_fct$P_P_0510 + df_fct$P_S_0510 + df_fct$P_M_0510 < df_fct$total*0.3,]$id
    &
      out$id %in% df_fct[df_fct$FP + df_fct$FS + df_fct$FM >= df_fct$total*0.3,]$id
    &
      out$id %in% df_gfc_ly[rowSums(df_gfc_ly[,c(4:13)]) < df_gfc_ly$total*0.3,]$id
    &
      out$id %in% df_gfc[df_gfc$TC_Pc < 30,]$id
    &
      out$id %in% df_gaf[df_gaf$F >= df_gaf$total*0.3,]$id
    ,]$id
  
  out[out$id %in% liste_F14,]$code<-1
  out[out$id %in% liste_F14,]$branch <- 14
  
}, error=function(e){cat("Configuration impossible \n")}
)

###################  Branche 15 -> Non-Foret
# \       FACET PERTES <  30%
# \\      FACET FORET  >= 30%
# \\\     GFC PERTES   <  30%
# \\\\    GFC FORET    <  30%
# \\\\\   GAF FORET    <  30%
# \\\\\/  FACET EAU    <  30%

cat("Branche 15 \n")

tryCatch({
  liste_F15 <- out[
      out$id %in% df_fct[df_fct$P_P_0005 + df_fct$P_S_0005 + df_fct$P_M_0005+ df_fct$P_P_0510 + df_fct$P_S_0510 + df_fct$P_M_0510 < df_fct$total*0.3,]$id
    &
      out$id %in% df_fct[df_fct$FP + df_fct$FS + df_fct$FM >= df_fct$total*0.3,]$id
    &
      out$id %in% df_gfc_ly[rowSums(df_gfc_ly[,c(4:13)]) < df_gfc_ly$total*0.3,]$id
    &
      out$id %in% df_gfc[df_gfc$TC_Pc < 30,]$id
    &
      out$id %in% df_gaf[df_gaf$F < df_gaf$total*0.3,]$id
    &
      out$id %in% df_fct[df_fct$Eau < df_fct$total*0.3,]$id
    ,]$id
  
  out[out$id %in% liste_F15,]$code <- 2
  out[out$id %in% liste_F15,]$branch <- 15
  
}, error=function(e){cat("Configuration impossible \n")}
)

###################  Branche 16 -> Eau
# \       FACET PERTES <  30%
# \\      FACET FORET  >= 30%
# \\\     GFC PERTES   <  30%
# \\\\    GFC FORET    <  30%
# \\\\\   GAF FORET    <  30%
# \\\\\\  FACET EAU    >= 30%

cat("Branche 16 \n")

tryCatch({
  liste_F16 <- out[
    out$id %in% df_fct[df_fct$P_P_0005 + df_fct$P_S_0005 + df_fct$P_M_0005+ df_fct$P_P_0510 + df_fct$P_S_0510 + df_fct$P_M_0510 < df_fct$total*0.3,]$id
    &
      out$id %in% df_fct[df_fct$FP + df_fct$FS + df_fct$FM >= df_fct$total*0.3,]$id
    &
      out$id %in% df_gfc_ly[rowSums(df_gfc_ly[,c(4:13)]) < df_gfc_ly$total*0.3,]$id
    &
      out$id %in% df_gfc[df_gfc$TC_Pc < 30,]$id
    &
      out$id %in% df_gaf[df_gaf$F < df_gaf$total*0.3,]$id
    &
      out$id %in% df_fct[df_fct$Eau >= df_fct$total*0.3,]$id
    ,]$id
  
  out[out$id %in% liste_F16,]$code <- 4
  out[out$id %in% liste_F16,]$branch <- 16
  
}, error=function(e){cat("Configuration impossible \n")}
)


################## RESUME LES OCCURENCES DES BRANCHES DE L'ARBRE, extrait un exemple de chaque
l1<-list()
for(i in 1:16){
  tryCatch({
    l1[i]<-list(get(paste("liste_F",i,sep="")))
    }, error=function(e){l1[i]=NULL}
  )
}

poids_branches <-sapply(l1,length)

#example_id_branches<-sapply(l1,function(x){sample(x,1)})
#apply(example_id_branches,function(x){paste('DN = ',x,' OR',sep='')})

################## EXPORTER RESULTATS NON STRATIFIES
# write.table(file="../final/hh19vv08h4v6_out_nonstratifie.txt",out,sep=" ",quote=FALSE, col.names=FALSE,row.names=FALSE)

################## STRATIFICATION DES FORETS 
################## Strate 17 -> Foret Primaire
#       CODE = FORET
#       Foret Primaire  majoritaire

cat("Stratification F Primaire \n")

tryCatch({
  liste_F17 <- out[
  out$id %in% df_fct[df_fct$FP > df_fct$FS & df_fct$FP >= df_fct$FM,]$id 
  &
  out$code==1
  ,]$id
  
  out[out$id %in% liste_F17,]$code <- 11
  out[out$id %in% liste_F17,]$branch <- 17
  
}, error=function(e){cat("Configuration impossible \n")}
)

################## Strate 18 -> Foret Marecageuse
#       CODE = FORET
#       Foret Marecageuse majoritaire

cat("Stratification F Marecageuse \n")

tryCatch({
  liste_F18 <- out[
    out$id %in% df_fct[df_fct$FM > df_fct$FS & df_fct$FM > df_fct$FP,]$id 
    &
    out$code==1
    ,]$id
  
  out[out$id %in% liste_F18,]$code <- 13
  out[out$id %in% liste_F18,]$branch <- 18
  
}, error=function(e){cat("Configuration impossible \n")}
)

################## Strate 19 -> Foret Secondaire
#       CODE = FORET
#       Foret Secondaire majoritaire

cat("Stratification F Secondaire \n")

tryCatch({
  liste_F19 <- out[
    out$id %in% df_fct[df_fct$FS >= df_fct$FM & df_fct$FS >= df_fct$FP,]$id 
    &
    out$code==1
    ,]$id
  
  out[out$id %in% liste_F19,]$code <- 12
  out[out$id %in% liste_F19,]$branch <- 19
  
}, error=function(e){cat("Configuration impossible \n")}
)

################## STRATIFICATION  DES PERTES
################## Strate 20 -> Pertes  Primaire
#       CODE = Perte
#       Perte Primaire  majoritaire

cat("Stratification P Primaire \n")

tryCatch({
  liste_F20 <- out[
    out$id %in% df_fct[(df_fct$P_P_0510+df_fct$P_P_0005) > (df_fct$P_S_0510+df_fct$P_S_0005) & (df_fct$P_P_0510+df_fct$P_P_0005) >= (df_fct$P_M_0510+df_fct$P_M_0005),]$id 
    &
      out$code==3
    ,]$id
  
  out[out$id %in% liste_F20,]$code <- 31
  out[out$id %in% liste_F20,]$branch <- 20
  
}, error=function(e){cat("Configuration impossible \n")}
)

################## Strate 21 -> Perte Marecageuse
#       CODE = Perte
#       Perte  Marecageuse majoritaire

cat("Stratification P Marecageuse \n")

tryCatch({
  liste_F21 <- out[
    out$id %in% df_fct[(df_fct$P_M_0510+df_fct$P_M_0005) > (df_fct$P_S_0510+df_fct$P_S_0005) & (df_fct$P_M_0510+df_fct$P_M_0005) > (df_fct$P_P_0510+df_fct$P_P_0005),]$id  
    &
    out$code==3
    ,]$id
  
  out[out$id %in% liste_F21,]$code <- 33
  out[out$id %in% liste_F21,]$branch <- 21
  
}, error=function(e){cat("Configuration impossible \n")}
)

################## Strate 22 -> Perte Secondaire
#       CODE = Perte
#       Perte Secondaire majoritaire

cat("Stratification P Secondaire \n")

tryCatch({
  liste_F22 <- out[
    out$id %in% df_fct[(df_fct$P_S_0510+df_fct$P_S_0005) >= (df_fct$P_M_0510+df_fct$P_M_0005) & (df_fct$P_S_0510+df_fct$P_S_0005) >= (df_fct$P_P_0510+df_fct$P_P_0005),]$id  
    &
      out$code==3
    ,]$id
  
  out[out$id %in% liste_F22,]$code <- 32
  out[out$id %in% liste_F22,]$branch <- 22
  
}, error=function(e){cat("Configuration impossible \n")}
)


###################  Branche 23 -> foret primaire
#       FACET NO DATA > 30%
#       GFC FORET     >= 30%

cat("Branche Foret Frontiere \n")

tryCatch({
  liste_F23 <- out[
      out$id %in% df_gfc[df_gfc$TC_Pc >= 30,]$id
      &
      out$id %in% df_fct[df_fct$ND >= df_fct$total*0.05,]$id
    ,]$id
  
  out[out$id %in% liste_F23,]$code<-11
  out[out$id %in% liste_F23,]$branch <- 23
  
}, error=function(e){cat("Configuration impossible \n")}
)


###################  masque donnees FACET -> no data
#     FACET NO DATA = 95%


cat("No data \n")

tryCatch({
  liste_ND <- out[
      out$id %in% df_fct[df_fct$ND >= df_fct$total*0.95,]$id 
    ,]$id
  
  out[out$id %in% liste_ND,]$code <- 0
  out[out$id %in% liste_ND,]$branch <- 0
  
}, error=function(e){cat("Configuration impossible \n")}
)


################## RESUME LES OCCURENCES DES STRATIFICATIONS, extrait un exemple de chaque
l2<-list()
for(i in 1:7){
  tryCatch({

    l2[i]<-list(get(paste("liste_F",i+16,sep="")))
}, error=function(e){l2[i]=NULL})
}

poids_strates <-sapply(l2,length)
# example_id_strates<-sapply(l2,function(x){sample(x,1)})
# sapply(example_id_strates,function(x){paste('DN = ',x,' OR',sep='')})


################## Exporter les resultats comme fichier TXT
write.table(file=output,out,sep=" ",quote=FALSE, col.names=FALSE,row.names=FALSE)

################## Exporter les stats comme fichier TXT
out_stats<- c(sum(out[out$code==0,2]),sum(out[out$code==1,2]),sum(out[out$code==2,2]),sum(out[out$code==3,2]),sum(out[out$code==4,2]),sum(out[out$code==11,2]),sum(out[out$code==12,2]),sum(out[out$code==13,2]),sum(out[out$code==31,2]),sum(out[out$code==32,2]),sum(out[out$code==33,2]))
fct_stats<- colSums(df_fct)
gfc_stats<- colSums(df_gfc_ly)
gaf_stats<- colSums(df_gaf)

write.table(file=statout,out_stats,sep=" ",quote=FALSE, col.names=FALSE,row.names=FALSE)
write.table(file=statgfc,gfc_stats,sep=" ",quote=FALSE, col.names=FALSE,row.names=FALSE)
write.table(file=statgaf,gaf_stats,sep=" ",quote=FALSE, col.names=FALSE,row.names=FALSE)
write.table(file=statfct,fct_stats,sep=" ",quote=FALSE, col.names=FALSE,row.names=FALSE)

write.table(file=treeout,poids_branches,sep=" ",quote=FALSE, col.names=FALSE,row.names=FALSE)
write.table(file=stratout,poids_strates,sep=" ",quote=FALSE, col.names=FALSE,row.names=FALSE)

sum(out_stats)
