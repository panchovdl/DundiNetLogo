library(ggplot2)
library(dplyr)
library(reshape2)

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
df <- read.csv("../results//M0_results_pse_muse.csv", header = T)

names(df)

ggplot(df, aes(x = objective.MSTCattleNEC, y = objective.MSTTrees, colour = goodShepherdPercentage, size = evolution.samples))+
  geom_point()+
  theme_bw()



library(plotly)

sel <- df$evolution.samples >= 1

# Création du graphique avec des info-bulles personnalisées
plot_ly(data = df[sel,],
        x = ~objective.MSTCattleNEC, 
        y = ~objective.MSTTrees, 
        type = 'scatter', 
        mode = 'markers', 
        color = ~interfaceNumberOfCampI,  # Coloration par nbBoats
        #size = ~evolution.samples,  # Taille par evolution.samples
        marker = list(sizemode = 'diameter'),
        text = ~paste("goodShepherdPercentage: ", goodShepherdPercentage, 
                      "<br>proportionBigHerders: ", proportionBigHerders, 
                      "<br>proportionMediumHerders: ", proportionMediumHerders,
                      "<br>interfaceNumberOfCampI: ", interfaceNumberOfCampI),
        hoverinfo = 'text') %>%
  layout(title = 'Scatter Plot with Custom Popups',
         xaxis = list(title = 'Objective MSTCattle'),
         yaxis = list(title = 'Objective MSTTrees'),
         plot_bgcolor = 'rgba(0,0,0,0)',  # Correspond à theme_bw()
         paper_bgcolor = 'rgba(0,0,0,0)')



# Création du graphique avec des info-bulles personnalisées
plot_ly(data = df[sel,],
        x = ~objective.MSTCattleNEC, 
        y = ~objective.MSTTrees, 
        z = ~goodShepherdPercentage,   # Axe Z (3ème dimension)
        type = 'scatter3d', 
        mode = 'markers', 
        color = ~interfaceNumberOfCampI,  # Coloration par nbBoats
        #size = ~evolution.samples,  # Taille par evolution.samples
        marker = list(sizemode = 'diameter'),
        text = ~paste("goodShepherdPercentage: ", goodShepherdPercentage, 
                      "<br>proportionBigHerders: ", proportionBigHerders, 
                      "<br>proportionMediumHerders: ", proportionMediumHerders,
                      "<br>interfaceNumberOfCampI: ", interfaceNumberOfCampI),
        hoverinfo = 'text') %>%
  layout(title = 'Scatter Plot with Custom Popups',
         xaxis = list(title = 'Objective MSTCattle'),
         yaxis = list(title = 'Objective MSTTrees'),
         zaxis = list(title = 'goodShepherdPercentage'),
         plot_bgcolor = 'rgba(0,0,0,0)',  # Correspond à theme_bw()
         paper_bgcolor = 'rgba(0,0,0,0)')






# Sauvegarder en fichier HTML interactif
library(htmlwidgets)
htmlwidgets::saveWidget(as_widget(a), "/tmp/graphique_interactif.html")


