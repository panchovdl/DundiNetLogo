rm(list = ls())

library(ggplot2)
library(dplyr)
library(reshape2)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
source("petitParceur_openMole.R")
data <- read.csv("../results//M0_directSampling_muse.csv", header = T)

names(data)

# On va réflechir a la satisfaction sur le nombre d'arbre et on pensera la satisfaction sur la NEC plus tard

# Define the ∆t value (you can set this as needed)
delta_t <- 0.6 # seuil de durabilité
satisfactionb <- 111358
delta_r <- 0.5


#####################
# Classify states based on the given conditions
data <- data %>%
  mutate(
    state_b = case_when(
      totalTreesOldes >= satisfactionb & MSTCaangol < delta_t & MSTCaangol > delta_r ~ "Resilient Satisfactory and Non-Durable",
      totalTreesOldes >= satisfactionb & MSTCaangol <= delta_t ~ "Satisfactory and Durable",
      totalTreesOldes >= satisfactionb & MSTCaangol > delta_t ~ "Satisfactory and Non-Durable",
      
      totalTreesOldes < satisfactionb & MSTCaangol <= delta_t & MSTCaangol > delta_r ~ "Resilient Non-Satisfactory and Non-Durable",
      
      totalTreesOldes < satisfactionb & MSTCaangol <= delta_t ~ "Non-Satisfactory and Non-Durable",
      totalTreesOldes < satisfactionb & MSTCaangol > delta_t ~ "Non-Satisfactory and Durable",
      
    )
  )


##########


data$state_b <- factor(data$state_b, levels = c("Satisfactory and Durable", "Satisfactory and Non-Durable","Resilient Satisfactory and Non-Durable",
                                                "Non-Satisfactory and Non-Durable","Resilient Non-Satisfactory and Non-Durable","Non-Satisfactory and Durable"
))

biomS <- ggplot(data = data)+
  geom_tile(aes(x = interfaceNumberOfCampI, y = goodShepherdPercentage, fill = state_b))+
  scale_fill_manual(values = c('#1a9850','#ffc0cb','#ffffff','#90ee90','#ffffff','#d73027'))+
  theme_light()+
  theme(axis.text.x = element_text(angle = 45, hjust = 1), 
        legend.position = "bottom")+
  facet_grid(proportionMediumHerders~proportionBigHerders, labeller = label_both)+
  labs(title = "From biomass perspective", subtitle = "regarding the system",
       x = "Camps", y = "good shepherd", fill = "State")
biomS

