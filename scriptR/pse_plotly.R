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

## creation d'un graph interactif en 3D
a <- plot_ly(data = df[sel,],
             x = ~objective.MSTCattleNEC, 
             y = ~objective.MSTTrees, 
             z = ~mTotalcattles,   # Axe Z (3ème dimension)
             type = 'scatter3d', 
             mode = 'markers', 
             color = ~mCattlesLiveWeight,  # Coloration par nbBoats
             marker = list(sizemode = 'diameter'),
             text = ~paste(
               "<span style='font-size:18px;'>",  # Début du style
               "🔪goodShepherdPercentage: ", signif(goodShepherdPercentage, digits = 2), 
               "<br>🐮🧑 proportionBigHerders: ", signif(proportionBigHerders, digits = 2), 
               "<br>🐮🧑proportionMediumHerders: ", signif(proportionMediumHerders, digits = 2),
               "<br>🛖 interfaceNumberOfCampI: ", signif(interfaceNumberOfCampI, digits = 2),
               "<br> &#127795; TotalOldTree: ", signif(mTotalTreesOld, digits = 2),
               "<br> &#128003; TotalCattles: ", signif(mTotalcattles, digits = 2),
               "<br> 🍖 mCattlesLiveWeight: ", signif(mCattlesLiveWeight, digits = 2),
               "</span>"  # Fin du style
             ),
             hoverinfo = 'text') %>%
  layout(title = 'Scatter Plot with Custom Popups',
         scene = list(
           xaxis = list(title = 'Objective MSTCattle'),
           yaxis = list(title = 'Objective MSTTrees'),
           zaxis = list(title = 'mTotalcattles')),
         plot_bgcolor = 'rgba(0,0,0,0)',  # Correspond à theme_bw()
         paper_bgcolor = 'rgba(0,0,0,0)')

a



# Sauvegarder en fichier HTML interactif
library(htmlwidgets)
htmlwidgets::saveWidget(as_widget(a), "/tmp/graphique_interactif.html")


