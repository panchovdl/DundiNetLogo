# Auteur : E. Delay
# date   : 05/06/2025
# Objetctif : L’objectif de ce travail est de générer des paysages neutres, 
# c’est-à-dire des structures spatiales artificielles mais contrôlées, permettant 
#de tester un modèle à base d'agents dans différentes configurations 
# environnementales. En particulier, cela permet d'évaluer la sensibilité du 
#modèle à la structure du paysage

# Qu'est-ce qui est fait ici ? 
# Concrètement, le script commence par le chargement d’un raster de biomasse 
# fourni par le CSE, puis le découpage de la zone d’intérêt à l’aide d’une boîte 
# englobante (BBox). Ce raster est ensuite reclassé en 7 classes par la méthode 
# de Jenks. Ensuite, une série de paysages neutres sont simulés à l’aide d’un 
# générateur basé sur le Midpoint Displacement (nlm_mpd), en forçant des 
# propriétés spatiales similaires à celles observées dans le raster réel. Chaque 
# simulation est évaluée selon plusieurs métriques paysagères (agrégation, nombre 
# de patchs, etc.),  et les meilleures sont retenues pour une utilisation 
# ultérieure dans le modèle SMA.

# TODO : définir le nombre optimal de paysages à simuler et automatiser la 
# sauvegarde des résultats dans un format compatible avec le modèle agent


# --- Chargement des bibliothèques ---
library(terra)
library(tidyverse)
library(landscapemetrics)
library(NLMR)
library(landscapetools)
library(purrr)
library(classInt)
library(snow)
library(parallel)
library(pbapply)

# --- Nettoyage de l’environnement ---
rm(list = ls())

# --- Chargement et traitement du raster de biomasse ---
biomass <- rast("data/Senegal/biomass_cse/biomtot_cse_2012_2022/biomtot_cse2012.tif")
biomass <- project(biomass, "EPSG:4326")
biomass <- crop(biomass, ext(-16.261139, -13.448639, 14.349548, 15.682543))
biomass <- project(biomass, "EPSG:32628")

# Reclassification en 7 classes (Jenks) pour le raster réel
vals <- values(biomass)[!is.na(values(biomass))]
breaks_real <- classIntervals(vals, n = 7, style = "fisher")$brks
breaks_real[1] <- min(vals)
rcl <- matrix(nrow = 7, ncol = 3)
for (i in 1:7) {
  rcl[i, 1] <- breaks_real[i]
  rcl[i, 2] <- ifelse(i < 7, breaks_real[i + 1], max(vals) + 1)
  rcl[i, 3] <- i
}
biomass_class <- classify(biomass, rcl, include.lowest = TRUE)

# --- Calcul des métriques réelles ---
metrics_names <- c("ai", "cohesion", "contag", "division", "np", "lsi", "split")
target <- calculate_lsm(biomass_class, level = "landscape", type = "aggregation metric") %>%
  filter(metric %in% metrics_names) %>%
  select(metric, value)

# --- Préparation des dimensions simples ---
ncol_biomass <- dim(biomass_class)[2]
nrow_biomass <- dim(biomass_class)[1]
res_x <- res(biomass_class)[1]
res_y <- res(biomass_class)[2]

ncol_adj <- ifelse(ncol_biomass %% 2 == 0, ncol_biomass + 1, ncol_biomass)
nrow_adj <- ifelse(nrow_biomass %% 2 == 0, nrow_biomass + 1, nrow_biomass)

# --- Fonctions utilitaires ---
classify_sim <- function(sim_raster) {
  vals_sim <- values(sim_raster)
  vals_sim <- vals_sim[!is.na(vals_sim)]
  
  if (length(unique(vals_sim)) < 7) {
    stop("Pas assez de classes uniques dans le raster simulé.")
  }
  
  breaks_sim <- classIntervals(vals_sim, n = 7, style = "fisher")$brks
  breaks_sim[1] <- min(vals_sim, na.rm = TRUE)
  
  rcl_sim <- matrix(nrow = 7, ncol = 3)
  for (i in 1:7) {
    rcl_sim[i, 1] <- breaks_sim[i]
    rcl_sim[i, 2] <- ifelse(i < 7, breaks_sim[i + 1], max(vals_sim, na.rm = TRUE) + 1)
    rcl_sim[i, 3] <- i
  }
  
  classify(sim_raster, rcl_sim, include.lowest = TRUE)
}

get_metrics <- function(r) {
  m <- calculate_lsm(r, level = "landscape", type = "aggregation metric")
  m[m$metric %in% metrics_names, c("metric", "value")]
}

# --- Paramètres ---
n_sim <- 100
options(pbapply.type = "txt")

# --- Cluster parallèle ---
cl <- makeCluster(5, type = "PSOCK")

clusterExport(cl, varlist = c("ncol_adj", "nrow_adj", "ncol_biomass", "nrow_biomass",
                              "res_x", "res_y", "classify_sim", "get_metrics",
                              "metrics_names", "target"),
              envir = environment())

clusterEvalQ(cl, {
  library(terra)
  library(NLMR)
  library(landscapemetrics)
  library(classInt)
})

# --- Fonction de simulation ---
simulate_landscape <- function(i) {
  roughness_val <- runif(1, 0.3, 0.7)
  sim <- nlm_mpd(ncol = ncol_adj, nrow = nrow_adj, roughness = roughness_val)
  sim_rast <- rast(sim)
  
  sim_rast <- crop(sim_rast, ext(0, ncol_biomass * res_x,
                                 0, nrow_biomass * res_y))
  
  sim_class <- tryCatch({
    classify_sim(sim_rast)
  }, error = function(e) {
    return(NULL)
  })
  
  if (is.null(sim_class)) return(NULL)
  
  metrics <- get_metrics(sim_class)
  metrics$sim_id <- i
  metrics$roughness <- roughness_val
  return(metrics)
}

# --- Exécution parallèle avec barre de progression ---
results <- pblapply(1:n_sim, simulate_landscape, cl = cl)
stopCluster(cl)

# --- Nettoyage : retirer NULL (simulations ratées) ---
# Nettoyage : retirer les NULL
results_clean <- results[!sapply(results, is.null)]

# Pivoter les résultats
df_sim <- bind_rows(results_clean) %>%
  pivot_wider(names_from = metric, values_from = value)

# Identifier les simulations qui ont toutes les métriques demandées
df_sim_valid <- df_sim %>%
  filter(if_all(all_of(metrics_names), ~ !is.na(.)))

# Vérifier qu'on a au moins une simulation valide
if (nrow(df_sim_valid) == 0) {
  stop("Aucune simulation ne contient toutes les métriques nécessaires.")
}

# Extraire les valeurs cibles comme vecteur nommés
target_vec <- deframe(target)

# Calcul du score uniquement sur les colonnes des métriques
df_sim_valid <- df_sim_valid %>%
  mutate(score = pmap_dbl(select(., all_of(metrics_names)), function(...) {
    sim_vals <- c(...)
    target_vals <- target_vec[names(sim_vals)]
    sum(abs(sim_vals - target_vals), na.rm = TRUE)
  })) %>%
  arrange(score)


# --- Meilleur paysage simulé ---
# --- Extraire les 5 meilleures simulations
top5 <- df_sim_valid %>% slice(1:5)

# --- Affichage des 6 rasters côte à côte
par(mfrow = c(2, 3))  # Grille 2 lignes × 3 colonnes

# 1. Raster réel
plot(biomass_class, main = "Biomasse réelle")

# 2–6. Rasters simulés
for (i in 1:5) {
  sim_id <- top5$sim_id[i]
  rough <- round(top5$roughness[i], 2)
  
  # Regénérer la simulation
  sim <- nlm_mpd(ncol = ncol_adj, nrow = nrow_adj, roughness = rough)
  sim_rast <- rast(sim)
  sim_rast <- crop(sim_rast, ext(0, ncol_biomass * res_x,
                                 0, nrow_biomass * res_y))
  
  # Appliquer l'emprise et la projection du raster réel
  ext(sim_rast) <- ext(biomass_class)
  crs(sim_rast) <- crs(biomass_class)
  
  # Classifier
  sim_class <- classify_sim(sim_rast)
  ext(sim_class) <- ext(biomass_class)
  crs(sim_class) <- crs(biomass_class)
  
  # Affichage
  plot(sim_class, main = paste("Sim", sim_id, "\nRug =", rough))
}

# --- Export optionnel
# writeRaster(best_sim_class, "output/nlm_best_match_mpd.tif", overwrite = TRUE)
