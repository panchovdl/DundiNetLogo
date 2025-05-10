# Charger la bibliothèque ggplot2 pour la visualisation
library(ggplot2)
rm(list = ls())
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
source("petitParceur_openMole.R")

# Lire deux jeux de données CSV contenant les résultats de simulations ou de profils
data <- read.csv("../results/M1_results_Profile_FUt_080525.csv") ## data avec les "goodshepherd
data2 <- read.csv("../results/M1_results_Profile_0GoodShep_090525.csv") ## data sans goodShepherd

# Inverser les valeurs de "objective.MSTCattleNEC" dans les deux datasets (probablement pour changer le sens d'interprétation)
data$objective.MSTCattleNEC <- data$objective.MSTCattleNEC * -1
data2$objective.MSTCattleNEC <- data2$objective.MSTCattleNEC * -1

# ---------------------------------------
# PREMIER PLOT : proportionBigHerders vs objective.MSTCattleNEC avec density + points
# ---------------------------------------

ggplot(data, aes(x = proportionBigHerders, y = objective.MSTCattleNEC, color = FUtility)) +
  geom_density_2d_filled(alpha = 0.5) +                  # Ajouter la densité remplie avec transparence (pour voir la concentration des points)
  geom_smooth(colour = 'red')+
  geom_point() +                          # Ajouter les points, taille selon evolution.samples
  # geom_hline(yintercept = )+                           # (Optionnel / commenté) possibilité d'ajouter une ligne horizontale à une valeur donnée
  labs(x = "Proportion Big Herders", y = "MST Cattle NEC",              # Étiquettes des axes et titre
       title = "With goodShepherd") +
  theme_minimal()                                       # Thème graphique minimaliste (fond blanc/gris clair)

# ---------------------------------------
# DEUXIÈME PLOT : FUtility vs objective.MSTCattleNEC avec density + points (Dataset 1)
# ---------------------------------------

ggplot(data, aes(x = FUtility, y = objective.MSTCattleNEC)) +
  geom_density_2d_filled(alpha = 0.5, bins = 7) +                  # Ajouter la densité remplie
  geom_smooth(span = 0.5)+
  # geom_hline(yintercept = )+                           # (Optionnel) ajouter une ligne horizontale
  ylim(c(0.955, 0.965))+
  xlim(c(0.4, 0.7))+
  # geom_point() +                          # Ajouter les points
  labs(x = "Utility value", y = "MST Cattle NEC",        # Étiquettes des axes et titre
       title = "With goodShepherd") +
  theme_bw()+
  theme(legend.position="bottom")
  #guides(fill = guide_legend(label.position = "bottom"))

# Enregistrer le graphique précédent dans un fichier image PNG
ggsave("../img/M1_profil_withGShepherd.png")

# ---------------------------------------
# TROISIÈME PLOT : FUtility vs objective.MSTCattleNEC avec density + points (Dataset 2)
# ---------------------------------------

ggplot(data2, aes(x = FUtility, y = objective.MSTCattleNEC, size = evolution.samples)) +
  #geom_point(color = "blue") +                          # Ajouter les points
  geom_density_2d_filled(alpha = 0.5, bins = 7) +                  # Ajouter la densité remplie
  geom_smooth()+
  ylim(c(0.955, 0.965))+
  xlim(c(0.4, 0.75))+
  # geom_hline(yintercept = )+                           # (Optionnel) ajouter une ligne horizontale
  labs(x = "Utility value", y = "MST Cattle NEC",        # Étiquettes des axes et titre
       title = "Without goodShepherd") +
  theme_bw()+
  theme(legend.position="bottom")

# Enregistrer ce deuxième graphique dans un fichier image PNG
ggsave("../img/M1_profil_withoutGShepherd.png")


data$treesKilled_Med <- sapply(data$treesKilled, get.medians.from.vector)
data2$treesKilled_Med <- sapply(data2$treesKilled, get.medians.from.vector)





data$totalTrees_med <- sapply(data$totalTrees, get.medians.from.vector) 
max(data$totalTrees_med) # 9286420
min(data$totalTrees_med) # 8899228
data$shepherds <- TRUE
data2$totalTrees_med <- sapply(data2$totalTrees, get.medians.from.vector)
max(data2$totalTrees_med) # 9266987
min(data2$totalTrees_med) # 8627135
data2$shepherds <- FALSE

tree_med.df <- rbind(subset(data, select = c("FUtility", "totalTrees_med", "shepherds")),subset(data2, select = c("FUtility", "totalTrees_med", "shepherds")))

y_max <- max(data$totalTrees_med, na.rm = TRUE)

ggplot() +
  geom_point(data = tree_med.df, aes(x = FUtility, y = totalTrees_med, color = shepherds)) +                          # Ajouter les points                         # Ajouter les points
  labs(x = "Utility value", y = "total trees",        # Étiquettes des axes et titre
       title = "", colour = "Good\nShepherds") +
  theme_bw()+                                            # Thème graphique noir/blanc
  coord_cartesian(ylim = c(8666800, 9266987))

# Enregistrer ce deuxième graphique dans un fichier image PNG
ggsave("../img/M1_profil_totalTrees.png")



data$totalTreesOldes_med <- sapply(data$totalTreesOldes, get.medians.from.vector)
data2$totalTreesOldes_med <- sapply(data2$totalTreesOldes, get.medians.from.vector)
