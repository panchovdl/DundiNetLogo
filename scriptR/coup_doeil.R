library(GGally)
library(ggplot2)

data <- read.csv("~/Téléchargements/M1_directSampling_muse_20250504.csv")

# val myDirectSampling = DirectSampling(
#   evaluation = replications hook (workDirectory / "M1_directSampling_muse_20250505"),
#   sampling = 
#     (goodShepherdPercentage in (0.0 to 90.0 by 30.0)) x // 4
#   (proportionBigHerders in (0.0 to 45.0 by 10.0))x    // 5
#   (proportionMediumHerders in (0.0 to 45.0 by 10.0))x // 5
#   (numberofCamps in (10.0 to 140.0 by 30.0))x         // 5
#   (reforestationPlots in (0.0 to 10.0 by 2.0))
# )

v.goodShep <- unique(data$goodShepherdPercentage)
v.propBig <- unique(data$proportionBigHerders)
v.propMed <- unique(data$proportionMediumHerders)
v.nbCamp <- unique(data$numberofCamps)

sel <-  data$proportionBigHerders == v.propBig[1] & data$proportionMediumHerders == v.propMed[1] #& data$goodShepherdPercentage == v.goodShep[1] & data$numberofCamps == v.nbCamp[1]

a <- data[sel,]

ggplot(data = a)+
  geom_point(aes( x = as.factor(reforestationPlots), y = MSTCattleNEC))+
  facet_grid(goodShepherdPercentage~numberofCamps, labeller = label_both)




a <- subset(data, select = c("numberofCamps", "proportionBigHerders", "proportionMediumHerders","reforestationPlots","goodShepherdPercentage",
                  "MSTTrees", "MSTBaldiol", "MSTCaangol", "MSTSangre", "MSTSeeno", "MSTCattleNEC", "MSTSheepNEC", 
                  "meanFruitsConsumedCattle","meanLeavesConsumedCattle", "meanCattlesGrassEaten",
                  "meanFruitsConsumedSheep","meanLeavesConsumedSheep", "meanSheepsGrassEaten",
                  "totalCattles","totalSheeps"
                  ))

sel <-  a$proportionBigHerders == v.propBig[1] & a$proportionMediumHerders == v.propMed[1] & a$goodShepherdPercentage == v.goodShep[1] & a$numberofCamps == v.nbCamp[1]
ggpairs(a[sel,])
