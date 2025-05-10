## Petit parceur OpenMole 

pp_mean <- function(s) {
  numbers_numeric <- convert.data.frame(s)
  # Calculer la moyenne
  mean_value <- mean(numbers_numeric)
  return(mean_value)
}

convert.data.frame <- function(s){
  # Retirer les crochets
  s_clean <- gsub("\\[|\\]", "", s)
  # Diviser la chaîne par les virgules
  numbers <- strsplit(s_clean, ",")[[1]]
  # Convertir en nombres
  numbers_numeric <- as.numeric(numbers)
  return(numbers_numeric)
}

get.medians.from.vector <- function(s) {
  # Retirer les crochets
  s_clean <- gsub("\\[|\\]", "", s)
  # Diviser la chaîne par les virgules
  numbers <- strsplit(s_clean, ",")[[1]]
  # Convertir en nombres
  numbers_numeric <- as.numeric(numbers)
  med <- median(numbers_numeric)
  return(med)
}
