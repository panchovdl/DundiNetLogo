rm(list = ls())

library(ggplot2)
library(dplyr)
library(reshape2)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
source("petitParceur_openMole.R")
df <- read.csv("../results/MO_results_nsga2_muse.csv", header = T)
df$objective.MSTCattleNEC <- abs(df$objective.MSTCattleNEC) # on prend l'absolut parce que l'objectf est de maximiser ces valeurs dans l'AG
df$objective.MSTTrees <- abs(df$objective.MSTTrees)         # on prend l'absolut parce que l'objectf est de maximiser ces valeurs dans l'AG

names(df)

# Sélectionner les colonnes de 11 à la dernière
cols_to_process <- names(df)[11:ncol(df)]

# Appliquer pp_mean à chaque colonne sélectionnée
df[cols_to_process] <- lapply(df[cols_to_process], function(col) sapply(col, pp_mean))


ggplot(df, aes(x = objective.MSTCattleNEC, y = objective.MSTTrees, colour = goodShepherdPercentage))+
  geom_point()+
  theme_bw()
