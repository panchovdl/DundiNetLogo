# --- Packages nécessaires ---
# Installe-les une fois si besoin :
# install.packages(c("readxl", "ggplot2", "dplyr"))

library(readxl)
library(ggplot2)
library(dplyr)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# --- 1) Charger les données ---
# Ajuste le chemin si besoin
dfCampTree <- read.csv("../results/Profile_Camps_Trees_Dundi.csv")
dfCampCattle <- read.csv("../results/Profile_Camps_MSTCattle_Dundi.csv")
dfDecreaseTree <- read.csv("../results/Profile_DecreaseFactor_Trees_Dundi.csv")
dfDecreaseCattle <- read.csv("../results/Profile_DecreaseFactor_MSTCattle_Dundi.csv")



  print(names(dfCampTree))
  
  
  # Inverser les valeurs de "objective.MSTCattleNEC" 
  dfCampCattle$objective.MSTCattleNEC <- dfCampCattle$objective.MSTCattleNEC * -1
  dfDecreaseCattle$objective.MSTCattleNEC <- dfDecreaseCattle$objective.MSTCattleNEC * -1
  # Inverser les valeurs de "objective.TotalTrees" et les convertir en moyenne par hectare (division par le nombre de cellules du modèle (22x22) et conversion en population mature (3 ans et +, à raison d'un taux de survie moyen de 30% (wade et al., 2018) les deux premières années) à l'hectare)
  dfCampTree$objective.totalTrees <- ((dfCampTree$objective.totalTrees / 22^2) / 100)*0.3 * -0.3
  dfDecreaseTree$objective.totalTrees <- ((dfDecreaseTree$objective.totalTrees / 22^2) / 100)*0.3 * -0.3
  
  # ---------------------------------------
  # PREMIER PLOT : Nombre de campements vs objective.MSTCattleNEC avec density + points
  # ---------------------------------------
  
 a <- ggplot(dfCampCattle, aes(x = numberofCamps, y = objective.MSTCattleNEC)) +
    geom_density_2d_filled(alpha = 0.5) +                  # Ajouter la densité remplie avec transparence (pour voir la concentration des points)
    geom_point() +                          # Ajouter les points, taille selon evolution.samples
    ylim(c(0.0, 0.8))+    
    geom_smooth(colour = 'red', se = FALSE)+
    # geom_hline(yintercept = )+                           # (Optionnel / commenté) possibilité d'ajouter une ligne horizontale à une valeur donnée
    labs(x = "Nombre de campements", y = "MST Cattle NEC",              # Étiquettes des axes et titre
         title = "MST Cattle NEC selon le nombre de campements dans la simulation") +
    theme_minimal()                                       # Thème graphique minimaliste (fond blanc/gris clair)
  
  # ---------------------------------------
  # DEUXIEME PLOT : Nombre de campements vs objective.TotalTrees avec density + points
  # ---------------------------------------
  
  b <- ggplot(dfCampTree, aes(x = numberofCamps, y = objective.totalTrees)) +
    geom_density_2d_filled(alpha = 0.5) +                  # Ajouter la densité remplie avec transparence (pour voir la concentration des points)
    geom_point() +                          # Ajouter les points, taille selon evolution.samples
    geom_smooth(colour = 'red', se = FALSE)+
    # geom_hline(yintercept = )+                           # (Optionnel / commenté) possibilité d'ajouter une ligne horizontale à une valeur donnée
    labs(x = "Nombre de campements", y = "Nombre moyen d'arbres à l'hectare",              # Étiquettes des axes et titre
         title = "Nombre moyen d'arbres à l'hectare selon le nombre de campements dans la simulation") +
    theme_minimal()                                       # Thème graphique minimaliste (fond blanc/gris clair)
  # ---------------------------------------
  # TROISIEME PLOT : Facteur de décroissance de stock herbacé vs objective.MSTCattleNEC avec density + points
  # ---------------------------------------
  
  c <- ggplot(dfDecreaseCattle, aes(x = decreasingFactor, y = objective.MSTCattleNEC)) +
    geom_density_2d_filled(alpha = 0.5) +                  # Ajouter la densité remplie avec transparence (pour voir la concentration des points)
    geom_point() +                          # Ajouter les points, taille selon evolution.samples
    ylim(c(0.0, 0.8))+    
    geom_smooth(colour = 'red', se = FALSE)+
    # geom_hline(yintercept = )+                           # (Optionnel / commenté) possibilité d'ajouter une ligne horizontale à une valeur donnée
    labs(x = "Facteur de décroissance", y = "MST Cattle NEC",              # Étiquettes des axes et titre
         title = "MST Cattle NEC selon la vitesse de décroissance herbacée dans la simulation") +
    theme_minimal()                                       # Thème graphique minimaliste (fond blanc/gris clair)
  
  # ---------------------------------------
  # QUATRIEME PLOT : Facteur de décroissance de stock herbacé vs objective.TotalTrees avec density + points
  # ---------------------------------------
  
  d <- ggplot(dfDecreaseTree, aes(x = decreasingFactor, y = objective.totalTrees)) +
    geom_density_2d_filled(alpha = 0.5) +                  # Ajouter la densité remplie avec transparence (pour voir la concentration des points)
    geom_point() +                          # Ajouter les points, taille selon evolution.samples
    #ylim(c(0.0, 0.8))+    
    geom_smooth(colour = 'red', se = FALSE)+
    # geom_hline(yintercept = )+                           # (Optionnel / commenté) possibilité d'ajouter une ligne horizontale à une valeur donnée
    labs(x = "Facteur de décroissance", y = "Nombre moyen d'arbres à l'hectare",              # Étiquettes des axes et titre
         title = "Nombre moyen d'arbres à l'hectare selon la vitesse de décroissance herbacée dans la simulation") +
    theme_minimal()                                       # Thème graphique minimaliste (fond blanc/gris clair)
  
  
  
  g <- grid.arrange(a, b, c, d, ncol = 2) # côte à côte
  
  # Sauvegarder en PNG
  ggsave("../img/profile_externalforces.png", g, width = 10, height = 5, dpi = 300)
  print(a)
  print(b)
  print(c)
  print(d)
# --- 5) (Optionnel) Export en PNG ---
# ggsave("scatter_mst_trees.png", p, width = 8, height = 6, dpi = 300)
