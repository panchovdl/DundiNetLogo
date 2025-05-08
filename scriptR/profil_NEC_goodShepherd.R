# Charger la bibliothèque ggplot2 pour la visualisation
library(ggplot2)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Lire deux jeux de données CSV contenant les résultats de simulations ou de profils
data <- read.csv("../results/M1_results_Profile_FUt_060525.csv") ## data avec les "goodshepherd
data2 <- read.csv("../results/M1_results_Profile_FUt_050525.csv") ## data sans goodShepherd

# Inverser les valeurs de "objective.MSTCattleNEC" dans les deux datasets (probablement pour changer le sens d'interprétation)
data$objective.MSTCattleNEC <- data$objective.MSTCattleNEC * -1
data2$objective.MSTCattleNEC <- data2$objective.MSTCattleNEC * -1

# ---------------------------------------
# PREMIER PLOT : proportionBigHerders vs objective.MSTCattleNEC avec density + points
# ---------------------------------------

ggplot(data, aes(x = proportionBigHerders, y = objective.MSTCattleNEC, size = evolution.samples)) +
  geom_point(color = "blue") +                          # Ajouter les points, taille selon evolution.samples
  geom_density_2d_filled(alpha = 0.5) +                  # Ajouter la densité remplie avec transparence (pour voir la concentration des points)
  # geom_hline(yintercept = )+                           # (Optionnel / commenté) possibilité d'ajouter une ligne horizontale à une valeur donnée
  labs(x = "Prop BH", y = "MST Cattle NEC",              # Étiquettes des axes et titre
       title = "With goodShepherd") +
  theme_minimal()                                       # Thème graphique minimaliste (fond blanc/gris clair)

# ---------------------------------------
# DEUXIÈME PLOT : FUtility vs objective.MSTCattleNEC avec density + points (Dataset 1)
# ---------------------------------------

ggplot(data, aes(x = FUtility, y = objective.MSTCattleNEC, size = evolution.samples)) +
  geom_point(color = "blue") +                          # Ajouter les points
  geom_density_2d_filled(alpha = 0.5) +                  # Ajouter la densité remplie
  # geom_hline(yintercept = )+                           # (Optionnel) ajouter une ligne horizontale
  labs(x = "Utility value", y = "MST Cattle NEC",        # Étiquettes des axes et titre
       title = "With goodShepherd") +
  theme_bw()                                            # Thème graphique fond blanc/noir (plus contrasté)

# Enregistrer le graphique précédent dans un fichier image PNG
ggsave("github/DundiNetLogo/img/M1_profil_withGShepherd.png")

# ---------------------------------------
# TROISIÈME PLOT : FUtility vs objective.MSTCattleNEC avec density + points (Dataset 2)
# ---------------------------------------

ggplot(data2, aes(x = FUtility, y = objective.MSTCattleNEC, size = evolution.samples)) +
  geom_point(color = "blue") +                          # Ajouter les points
  geom_density_2d_filled(alpha = 0.5) +                  # Ajouter la densité remplie
  # geom_hline(yintercept = )+                           # (Optionnel) ajouter une ligne horizontale
  labs(x = "Utility value", y = "MST Cattle NEC",        # Étiquettes des axes et titre
       title = "Without goodShepherd") +
  theme_bw()                                            # Thème graphique noir/blanc

# Enregistrer ce deuxième graphique dans un fichier image PNG
ggsave("github/DundiNetLogo/img/M1_profil_withoutGShepherd.png")
