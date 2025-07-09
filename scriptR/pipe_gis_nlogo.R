# Packages
library(sf)
library(dplyr)
library(ggplot2)

# Nettoyage
rm(list = ls())

# Chemins
data_path <- "~/data/Senegal/apetence_pasto/vel_ocso.shp"
bbox_path <- "~/data/Senegal/ferloSine/velingara_DB/cadre.shp"
dico_path <- "~/data/Senegal/apetence_pasto/conversion_paysage_sol_puular.csv"
tree_dir <- "~/data/Senegal/ferloSine/trees_count/"

# Lire les données sol
data <- st_read(data_path) %>% st_set_crs(32628)
bbox <- st_read(bbox_path) %>% st_transform(32628)
dico <- read.csv(dico_path) %>% rename(CODE = 1)

# Jointure code -> Nom.puular
data_join <- left_join(data, dico, by = "CODE")

# Clip aux limites du bbox
clip_soil <- st_intersection(data_join, bbox)

# Carte rapide sol
ggplot() +
  geom_sf(data = clip_soil, aes(fill = Nom.puular)) +
  theme_minimal()

# Reprojection WGS84 et export
clip_soil <- st_transform(clip_soil, 4326)
st_write(clip_soil, "~/github/DundiNetLogo/DundiNetLogo/data/soils.shp", delete_dsn = TRUE)

# 🌳 ------------------------
# **TREES GRID**
# ------------------------

# ⃣ Lister et lire tous les shapefiles d’arbres
tree_files <- list.files(tree_dir, pattern = "\\.shp$", full.names = TRUE)
tree_list <- lapply(tree_files, st_read)

#⃣ Fusionner en un seul sf et reprojeter
trees <- do.call(rbind, tree_list) %>% st_transform(32628)

#⃣ Clip aux limites
clip_trees <- st_intersection(trees, bbox)

# Carte rapide arbres
ggplot() +
  geom_sf(data = clip_trees, aes(fill = cT)) +
  theme_minimal()

#  Créer la grille 22 x 22 sur l’étendue des arbres
grid <- st_make_grid(clip_trees, n = c(22,22), what = "polygons") %>% 
  st_sf(grid_id = 1:length(.))

# Vérifier CRS pour jointure
clip_trees <- st_transform(clip_trees, st_crs(grid))

# Intersections et somme des cT par cellule
joined <- st_join(grid, clip_trees)

aggregated <- joined %>%
  group_by(grid_id.x) %>%
  summarise(cT = sum(cT, na.rm = TRUE))

# Carte finale arbres agrégés
ggplot() +
  geom_sf(data = aggregated, aes(fill = cT)) +
  theme_minimal()

# Export en WGS84
aggregated <- st_transform(aggregated, 4326)
st_write(aggregated, "~/github/DundiNetLogo/DundiNetLogo/data/trees.shp", delete_dsn = TRUE)
