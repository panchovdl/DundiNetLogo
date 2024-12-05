## Petit parceur OpenMole 

pp_mean <- function(s) {
  # Retirer les crochets
  s_clean <- gsub("\\[|\\]", "", s)
  # Diviser la chaîne par les virgules
  numbers <- strsplit(s_clean, ",")[[1]]
  # Convertir en nombres
  numbers_numeric <- as.numeric(numbers)
  # Calculer la moyenne
  mean_value <- mean(numbers_numeric)
  return(mean_value)
}

# Exemple d'utilisation
s <- "[5.0,1.0,3.0,3.0,5.0,7]"
moyenne <- calculate_mean(s)
print(moyenne)