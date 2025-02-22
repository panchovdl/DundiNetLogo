rm(list = ls())
library(tidyverse)

# Un script pour évaluer l'avancement de l'exploration du plan complet. 

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

myPath <- '../results/'
files.l <- list.files(path = myPath, pattern = "M0_directSampling_muse",)

###############################################################################
# Lecture du fichier CSV
###############################################################################
# Les fichiers "M0_directSampling_muse_*" sont lu dans une boucle qui itère les noms 
# avec la première ligne considérée comme en-têtes de colonnes (header = TRUE).
data <- data.frame()
for(i in 1:length(files.l)){
  tmp <- read.csv(paste0(myPath,files.l[i]), header = TRUE)
  data <- rbind(data, tmp)
}

###############################################################################
# Sélection d'un sous-ensemble de colonnes
###############################################################################
# Nous choisissons les colonnes qui nous intéressent : goodShepherdPercentage,
# proportionBigHerders, proportionMediumHerders, numberofCamps, avgUBTpercamp,
# decreasingFactor. Cet ensemble est stocké dans sub.data.
sub.data <- subset(
  data, 
  select = c(
    goodShepherdPercentage, 
    proportionBigHerders,
    proportionMediumHerders, 
    numberofCamps, 
    avgUBTpercamp, 
    decreasingFactor, 
    totalCattles,
    totalFoyers,
    MSTBaldiol,
    MSTCaangol,
    MSTSangre,
    MSTSeeno,
    MSTSheepNEC,
    MSTCattleNEC
  )
)

###############################################################################
# Tables de fréquences
###############################################################################

# 1) lapply(sub.data, table) : Applique la fonction table à chacune des 
#    colonnes séparément, retournant une liste de tables de fréquences 
#    (une par colonne).
lapply(sub.data, table)



sel <- data$proportionBigHerders == 50 & data$proportionMediumHerders == 50 &
  data$numberofCamps == 130 & data$avgUBTpercamp == 90 & data$decreasingFactor == 6.1


ggplot( data = data[sel,])+
  geom_point(aes(x = as.factor(goodShepherdPercentage), y = sheepsTempCamp))+
  # ylim(c(0,1))+
  theme_bw()
