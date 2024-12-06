rm(list = ls())

library(ggplot2)
library(dplyr)
library(reshape2)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
source("petitParceur_openMole.R")
df <- read.csv("../results//M0_results_pse_muse.csv", header = T)

names(df)

df$mTotalTreesOld <- sapply(df$totalTreesOldes, pp_mean)
df$mTotalcattles <- sapply(df$totalCattles, pp_mean)
df$mTotalsheeps <- sapply(df$totalSheeps, pp_mean)
df$mCattlesLiveWeight <- sapply(df$meanCattlesLiveWeight, pp_mean)


ggplot(df, aes(x = objective.MSTCattleNEC, y = objective.MSTTrees, colour = goodShepherdPercentage, size = evolution.samples))+
  geom_point()+
  theme_bw()



library(plotly)

sel <- df$evolution.samples >= 1

# Création du graphique avec des info-bulles personnalisées
a <- plot_ly(data = df[sel,],
        x = ~objective.MSTCattleNEC, 
        y = ~objective.MSTTrees, 
        z = ~mTotalcattles,   # Axe Z (3ème dimension)
        type = 'scatter3d', 
        mode = 'markers', 
        color = ~mCattlesLiveWeight,  # Coloration par nbBoats
        #size = ~evolution.samples,  # Taille par evolution.samples
        marker = list(sizemode = 'diameter'),
        text = ~paste("goodShepherdPercentage: ", goodShepherdPercentage, 
                      "<br>proportionBigHerders: ", proportionBigHerders, 
                      "<br>proportionMediumHerders: ", proportionMediumHerders,
                      "<br>interfaceNumberOfCampI: ", interfaceNumberOfCampI,
                      "<br>TotalOldTree: ", mTotalTreesOld,
                      "<br>TotalCattles: ", mTotalcattles,
                      "<br>TotalSheeps: ", mTotalsheeps,
                      "<br>mCattlesLiveWeight: ", mCattlesLiveWeight
                      ),
        hoverinfo = 'text') %>%
  layout(title = 'Scatter Plot with Custom Popups',
         xaxis = list(title = 'Objective MSTCattle'),
         yaxis = list(title = 'Objective MSTTrees'),
         zaxis = list(title = 'mTotalcattles'),
         plot_bgcolor = 'rgba(0,0,0,0)',  # Correspond à theme_bw()
         paper_bgcolor = 'rgba(0,0,0,0)')


a



# Sauvegarder en fichier HTML interactif
library(htmlwidgets)
htmlwidgets::saveWidget(as_widget(a), "/tmp/graphique_interactif.html")


