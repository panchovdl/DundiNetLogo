library(tidyverse)
library(gridExtra)
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

data.df <- read.csv("../results/M2_results_pse_humanlever_160925.csv", header = T)

data.df$proportionSmallHerders <- 100 - (data.df$proportionBigHerders+data.df$proportionMediumHerders)
# Découpage en 5 classes de largeur égale
data.df$classesgoodShepherd <- cut(data.df$goodShepherdPercentage, breaks = 5)


data.df$popTreeAdulte <- ((data.df$objective.totalTrees / 22^2) / 100)*0.3 * 0.3



a <- ggplot(data = data.df)+
  geom_point(aes(x = objective.MSTCattleNEC, y=popTreeAdulte, size = evolution.samples, 
                 colour = proportionSmallHerders, shape = classesgoodShepherd))+
  labs(
    x = "objective MST Cattle NEC",
    y = "Prop. Arbres Adultes",
    size = "Sim. sample",
    colour = "Prop. de petits éleveurs",
    shape = "Classe de bon berger")+  
  ylim(0,150)+
  geom_hline(aes(yintercept = 9), linetype="dotted") +  #9  #resultat 74
  geom_hline(aes(yintercept = 65), linetype="dotted") +  #moyen
  geom_hline(aes(yintercept = 148), linetype="dotted") + #148 # resultat 110
  theme_light()

b <- ggplot(data = data.df)+
  geom_point(aes(x = objective.MSTCattleNEC, y=popTreeAdulte, size = evolution.samples, 
                 colour = proportionMediumHerders, shape = classesgoodShepherd))+
  labs(
    x = "objective MST Cattle NEC",
    y = "Prop. Arbres Adultes",
    size = "Sim. sample",
    colour = "Prop. de moyens éleveurs",
    shape = "Classe de bon berger")+  
  scale_colour_gradient(low = "white", high = "black")+
  ylim(0,150)+
  geom_hline(aes(yintercept = 9), linetype="dotted") +  #9  #resultat 74
  geom_hline(aes(yintercept = 65), linetype="dotted") +  #moyen
  geom_hline(aes(yintercept = 148), linetype="dotted") + #148 # resultat 110
  theme_light()


g <- grid.arrange(a, b, ncol = 2)  # côte à côte

# Sauvegarder en PNG
ggsave("../img/pse_humainlever.png", g, width = 10, height = 5, dpi = 300)

