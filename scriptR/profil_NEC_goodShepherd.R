# Charger la bibliothèque ggplot2 pour la visualisation
library(ggplot2)
rm(list = ls())
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
source("petitParceur_openMole.R")

# Lire deux jeux de données CSV contenant les résultats de simulations ou de profils
data <- read.csv("../results/M1_results_Profile_FUt_080525.csv") ## data avec les "goodshepherd
data2 <- read.csv("../results/M1_results_Profile_FUt_050525.csv") ## data sans goodShepherd

# Inverser les valeurs de "objective.MSTCattleNEC" dans les deux datasets (probablement pour changer le sens d'interprétation)
data$objective.MSTCattleNEC <- data$objective.MSTCattleNEC * -1
data2$objective.MSTCattleNEC <- data2$objective.MSTCattleNEC * -1

# ---------------------------------------
# PREMIER PLOT : proportionBigHerders vs objective.MSTCattleNEC avec density + points
# ---------------------------------------

ggplot(data, aes(x = proportionBigHerders, y = objective.MSTCattleNEC, color = FUtility, size = evolution.samples)) +
  geom_density_2d_filled(alpha = 0.5) +                  # Ajouter la densité remplie avec transparence (pour voir la concentration des points)
  geom_smooth(colour = 'red')+
  geom_point() +                          # Ajouter les points, taille selon evolution.samples
  # geom_hline(yintercept = )+                           # (Optionnel / commenté) possibilité d'ajouter une ligne horizontale à une valeur donnée
  labs(x = "Prop BH", y = "MST Cattle NEC",              # Étiquettes des axes et titre
       title = "With goodShepherd") +
  theme_minimal()                                       # Thème graphique minimaliste (fond blanc/gris clair)

# ---------------------------------------
# DEUXIÈME PLOT : FUtility vs objective.MSTCattleNEC avec density + points (Dataset 1)
# ---------------------------------------

ggplot(data, aes(x = FUtility, y = objective.MSTCattleNEC)) +
  geom_density_2d_filled(alpha = 0.5) +                  # Ajouter la densité remplie
  geom_smooth(span = 0.5)+
  # geom_hline(yintercept = )+                           # (Optionnel) ajouter une ligne horizontale
  ylim(c(0.96, 0.965))+
  xlim(c(0.4, 0.75))+
  geom_point() +                          # Ajouter les points
  labs(x = "Utility value", y = "MST Cattle NEC",        # Étiquettes des axes et titre
       title = "With goodShepherd") +
  theme_bw()                                            # Thème graphique fond blanc/noir (plus contrasté)

# Enregistrer le graphique précédent dans un fichier image PNG
ggsave("../img/M1_profil_withGShepherd.png")

# ---------------------------------------
# TROISIÈME PLOT : FUtility vs objective.MSTCattleNEC avec density + points (Dataset 2)
# ---------------------------------------

ggplot(data2, aes(x = FUtility, y = objective.MSTCattleNEC, size = evolution.samples)) +
  geom_point(color = "blue") +                          # Ajouter les points
  geom_density_2d_filled(alpha = 0.5) +                  # Ajouter la densité remplie
  geom_smooth()+
  # geom_hline(yintercept = )+                           # (Optionnel) ajouter une ligne horizontale
  labs(x = "Utility value", y = "MST Cattle NEC",        # Étiquettes des axes et titre
       title = "Without goodShepherd") +
  theme_bw()                                            # Thème graphique noir/blanc

# Enregistrer ce deuxième graphique dans un fichier image PNG
ggsave("../img/M1_profil_withoutGShepherd.png")


data$treesKilled_Med <- sapply(data$treesKilled, get.medians.from.vector)
data2$treesKilled_Med <- sapply(data2$treesKilled, get.medians.from.vector)





data$totalTrees_med <- sapply(data$totalTrees, get.medians.from.vector) 
max(data$totalTrees_med) # 21879806
min(data$totalTrees_med) # 18862636
data2$totalTrees_med <- sapply(data2$totalTrees, get.medians.from.vector)
max(data2$totalTrees_med) # 8687665
min(data2$totalTrees_med) # 8666800

y_max <- max(data$totalTrees_med, na.rm = TRUE)

ggplot() +
  geom_point(data = data2, aes(x = FUtility, y = totalTrees_med), color = "blue") +                          # Ajouter les points
  geom_point(data = data, aes(x = FUtility, y = totalTrees_med), color = "red") +                          # Ajouter les points
  labs(x = "Utility value", y = "total trees",        # Étiquettes des axes et titre
       title = "") +
  theme_bw()+                                            # Thème graphique noir/blanc
  coord_cartesian(ylim = c(8666800, 21879806))+
  annotate("text", 
           x = mean(data$FUtility, na.rm = TRUE),   # Position X (ici au milieu, tu peux changer)
           y = y_max + 5,                          # Juste au-dessus du max de Y
           label = "With good Shepherds", 
           color = "black", size = 5)

# Enregistrer ce deuxième graphique dans un fichier image PNG
ggsave("../img/M1_profil_totalTrees.png")



data$totalTreesOldes_med <- sapply(data$totalTreesOldes, get.medians.from.vector)
data2$totalTreesOldes_med <- sapply(data2$totalTreesOldes, get.medians.from.vector)
