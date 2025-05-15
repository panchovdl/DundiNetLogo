# Nettoyer l'environnement de travail en supprimant tous les objets
rm(list = ls())

# Charger les bibliothèques nécessaires
library(ggplot2)  # Pour les visualisations
library(dplyr)    # Pour la manipulation des données
library(ggpubr)
library(tidyverse)


# Définir le répertoire de travail comme étant celui où se trouve ce script
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Charger une fonction personnalisée depuis un fichier R externe
source("petitParceur_openMole.R")

# Charger les résultats d'une simulation sous forme de tableau
df <- read.csv("../results/M1_results_nsga2_transhumance_130525.csv", header = TRUE)

# Prendre la valeur absolue de certaines colonnes d'objectifs
# Cela inverse leur direction car l'algorithme génétique cherche à maximiser
df$objective.MSTCattleNEC <- abs(df$objective.MSTCattleNEC)
df$objective.totalTrees <- abs(df$objective.totalTrees)

# Afficher les noms des colonnes pour référence
names(df)




# === PREMIÈRE FIGURE : Cattle NEC vs Nombre de camps ===
ggplot(df, aes(x = objective.MSTCattleNEC, y = numberofCamps)) +
  geom_smooth() +  # Ajouter une courbe de tendance
  geom_point(alpha = 0.5) +  # Points colorés selon pourcentage de bons bergers
  geom_hline(yintercept = 105, linetype = "dotdash") +  # Ligne de référence horizontale
  labs(x = "Mean sojourn time for Cattle NEC", y = "Number of camps") +
  theme_bw() +  # Thème graphique sobre
  ylim(c(60, 120)) +  # Limites de l'axe y
  theme(legend.position = "bottom")  # Légende en bas

# Sauvegarder la figure en PNG
ggsave("../img/M1_nsga2_camps_NEC.png")

# === DEUXIÈME FIGURE : Total arbres vs Nombre de camps ===
ggplot(df, aes(x = objective.totalTrees, y = numberofCamps)) +
  geom_smooth() +
  geom_point( alpha = 0.5) +
  geom_hline(yintercept = 105, linetype = "dotdash") +
  labs(x = "objective.totalTrees", y = "Number of camps") +
  theme_bw() +
  ylim(c(60, 120)) +
  theme(legend.position = "bottom")

ggsave("../img/M1_nsga2_camps_trees.png")

# === TROISIÈME FIGURE : Total arbres vs Cattle NEC ===
ggplot(df, aes(x = objective.totalTrees, y = objective.MSTCattleNEC)) +
  geom_smooth() +
  geom_point(aes(colour = numberofCamps), alpha = 0.5) +
  theme_bw() +
  theme(legend.position = "bottom")
ggsave("../img/M1_nsga2_both_objectfs.png")



df$med_MSTCattleLeft  <- sapply(df$MSTCattleLeft, get.medians.from.vector)
df$med_MSTSeepLeft  <- sapply(df$MSTSheepLeft, get.medians.from.vector)
df$med_MSTTempsPasse  <- sapply(df$MSTTempsPasse, get.medians.from.vector)

ggplot(data = df )+
  geom_boxplot(aes(y = df$med_MSTTempsPasse, x = as.factor(1)), outliers = F)+
  ylim(c(0.8, 1))+
  labs(x = "", y = "Mean Sojourn Time (MST) time spend") 


a <- data.frame()
b <- data.frame()
med_sumCattlesPression  <- sapply(df$sumCattlesPretionPastoLocal, get.medians.from.vector)
type <- rep("local", length = length(med_sumCattlesPression))
a <- as.data.frame(cbind(type, med_sumCattlesPression))

med_sumCattlesPression  <- sapply(df$sumCattlesPetionPastoTranshuman, get.medians.from.vector)
type <- rep("transhumant", length = length(med_sumCattlesPression))
b <- as.data.frame(cbind(type, med_sumCattlesPression))

data <- remove_rownames(rbind(a, b))
data$type <- as.factor(data$type)
data$med_sumCattlesPression <- as.numeric(data$med_sumCattlesPression)


ggplot(data = data, aes(x = as.factor(type), y = med_sumCattlesPression))+
  geom_boxplot()+
  labs(x = "Type", y = "Pression Pastorale (UBT/Km²/tours)")+
  theme_bw()

ggsave("../img/pression_pastorale.png", dpi = 300, width = 5, height = 8)

ggplot(data = df )+
  geom_boxplot(aes(y = df$med_MSTCattleLeft, x = as.factor(1)), outliers = F)+
  ylim(c(0.8, 1))

ggplot(data = df )+
  geom_boxplot(aes(y = df$med_MSTSeepLeft, x = as.factor(1)), outliers = F)+
  ylim(c(0.8, 1))
  


ggplot(df, aes(x = objective.totalTrees, y = objective.MSTCattleNEC)) +
  geom_smooth() +
  geom_point(aes(colour = med_MSTCattleLeft, size = numberofCamps) , alpha = 0.5) +
  theme_bw() +
  theme(legend.position = "bottom")
ggsave("../img/M1_nsga2_both_objectfs.png", dpi = 300, width = 7)  


ggplot(df, aes(x = objective.totalTrees, y = objective.MSTCattleNEC)) +
  geom_smooth() +
  geom_point(aes(colour = med_MSTTempsPasse, size = numberofCamps) , alpha = 0.5) +
  theme_bw() +
  theme(legend.position = "bottom")
ggsave("../img/M1_nsga2_both_objectfs.png", dpi = 300, width = 7)  


df$med_totalCattles  <- sapply(df$totalCattles, get.medians.from.vector )
df$med_totalTransCattles <- sapply(df$totalTransCattles, get.medians.from.vector)
df$med_sumCattlesPretionPastoLocal <- sapply(df$sumCattlesPretionPastoLocal, get.medians.from.vector) / 3650
df$med_sumCattlesPetionPastoTranshuman <- sapply(df$sumCattlesPetionPastoTranshuman, get.medians.from.vector) / 3650



both_Pression <- ggplot(df, aes(x = objective.totalTrees, y = objective.MSTCattleNEC)) +
  geom_smooth() +
  geom_point(aes(colour = med_sumCattlesPretionPastoLocal), alpha = 0.5) +
  labs(colour = "Cattles by Km² by ticks")+
  scale_color_gradient(low = "#f7f4f9", high = "#e7298a")+
  theme_bw() +
  theme(legend.position = "bottom")
both_Pression


both_left <- ggplot(df, aes(x = objective.totalTrees, y = objective.MSTCattleNEC)) +
  geom_smooth() +
  geom_point(aes(colour = med_MSTCattleLeft)) +
  labs(colour = "Cattles Mean Sojourn Time Out")+
  scale_color_gradient(low = "#fff7ec", high = "#7f0000")+
  theme_bw() +
  theme(legend.position = "bottom")
both_left


figure <- ggarrange(both_Pression, both_left,
                    labels = c("A", "B"),
                    ncol = 2, nrow = 1)
figure

ggsave("../img/M1_nsga2_both_objectfs.png", dpi = 300, width = 9)  




ggplot(df, aes(x = objective.totalTrees, y = objective.MSTCattleNEC)) +
  geom_smooth() +
  geom_point(aes(colour = med_MSTCattleLeft, size = med_sumCattlesPretionPastoLocal)) +
  labs(colour = "Cattles Mean Sojourn Time Out", size = "Cattles by Km² by ticks")+
  scale_color_gradient(low = "#fff7ec", high = "#e7298a")+
  theme_bw() +
  theme(legend.position = "bottom")



## TEST 

df <- read.csv("../results/M1_results_nsga2_delayReturn140525.csv", header = TRUE)

# Prendre la valeur absolue de certaines colonnes d'objectifs
# Cela inverse leur direction car l'algorithme génétique cherche à maximiser
df$objective.MSTCattleNEC <- abs(df$objective.MSTCattleNEC)
df$objective.totalTrees <- abs(df$objective.totalTrees)


ggplot(df, aes(x = objective.totalTrees, y = objective.MSTCattleNEC)) +
  geom_smooth() +
  geom_point(aes(colour = retardJours, size = goodShepherdPercentage)) +
  labs(colour = "Delay (in days)", size = "Good Shephered (%)")+
  scale_color_gradient(low = "#fff7ec", high = "#e7298a")+
  theme_bw() +
  theme(legend.position = "bottom")



df$med_MSTCattleLeft <- sapply(df$MSTCattleLeft, get.medians.from.vector)


ggplot(df)+
  geom_boxplot(aes(y = med_MSTCattleLeft), outliers = F)
