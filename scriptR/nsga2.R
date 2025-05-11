rm(list = ls())

library(ggplot2)
library(dplyr)
library(reshape2)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
source("petitParceur_openMole.R")
df <- read.csv("../results/M1_results_nsga2_110525.csv", header = T)
df$objective.MSTCattleNEC <- abs(df$objective.MSTCattleNEC) # on prend l'absolut parce que l'objectf est de maximiser ces valeurs dans l'AG
df$objective.totalTrees <- abs(df$objective.totalTrees)         # on prend l'absolut parce que l'objectf est de maximiser ces valeurs dans l'AG

names(df)

# Sélectionner les colonnes de 11 à la dernière
cols_to_process <- names(df)[11:ncol(df)]

# Appliquer pp_mean à chaque colonne sélectionnée
df[cols_to_process] <- lapply(df[cols_to_process], function(col) sapply(col, pp_mean))


ggplot(df, aes(x = objective.MSTCattleNEC, y = numberofCamps))+
  geom_smooth()+
  geom_point(aes(colour = goodShepherdPercentage),alpha = 0.5)+
  geom_hline(yintercept = 105, linetype = "dotdash")+
  labs(x = "Mean sojourn time for Cattle NEC", y = "Number of camps") +
  theme_bw()+
  ylim(c(60,120))+
  theme(legend.position="bottom")

ggsave("../img/M1_nsga2_camps_NEC.png")

ggplot(df, aes(x = objective.totalTrees, y = numberofCamps))+
  geom_smooth()+
  geom_point(aes(colour = goodShepherdPercentage),alpha = 0.5)+
  geom_hline(yintercept = 105, linetype = "dotdash")+
  labs(x = "Total trees at the end", y = "Number of camps") +
  theme_bw()+
  ylim(c(60,120))+
  theme(legend.position="bottom")
ggsave("../img/M1_nsga2_camps_trees.png")

ggplot(df, aes(x = objective.totalTrees, y = goodShepherdPercentage))+
  geom_smooth()+
  geom_point(aes(colour = goodShepherdPercentage),alpha = 0.5)+
  theme_bw()

ggplot(df, aes(x = objective.MSTCattleNEC, y = goodShepherdPercentage))+
  geom_smooth()+
  geom_point(aes(colour = goodShepherdPercentage),alpha = 0.5)+
  theme_bw()


ggplot(df, aes(x = objective.MSTCattleNEC, y = proportionMediumHerders))+
  geom_smooth()+
  geom_point(aes(colour = proportionMediumHerders),alpha = 0.5)+
  theme_bw()

ggplot(df, aes(x = objective.totalTrees, y = proportionMediumHerders))+
  geom_smooth()+
  geom_point(aes(colour = proportionMediumHerders),alpha = 0.5)+
  theme_bw()

