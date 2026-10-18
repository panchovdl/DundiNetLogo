# DundiModel — DundiNetLogo

Modèle multi-agents d'une Unité Pastorale (UP) au Ferlo (Sénégal), co-construit entre 2023 et 2025 dans une démarche de modélisation d'accompagnement (ComMod) avec responsables communautaires, élus, services des Eaux et Forêts, chercheurs et ONG (projet Dundi Ferlo). Il simule les interactions entre troupeaux bovins et ovins, foyers locaux et transhumants, tapis herbacé, populations ligneuses et parcelles de reforestation clôturées, au pas de temps journalier, sur des périodes simulées de dix ans.

Question portée par le modèle : **« Comment concilier renouvellement ligneux et usage partagé des ressources pastorales ? »**

La description suit le protocole ODD+D (Müller et al., 2013). Elle décrit le code tel qu'il est dans ce dépôt (`DundiNetLogo/DundiModelODD.nlogo` et fichiers `.nls` inclus).
---

## Sommaire

1. [Utiliser le modèle](#1-utiliser-le-modèle)
2. [ODD+D — Overview](#2-odd-d--overview)
3. [ODD+D — Design concepts](#3-odd-d--design-concepts)
4. [ODD+D — Details](#4-odd-d--details)
5. [Points de vigilance dans le code](#5-points-de-vigilance-dans-le-code)
6. [Références](#6-références)

---

## 1. Utiliser le modèle

### 1.1 Prérequis

- **NetLogo 6.4.0** pour `DundiModelODD.nlogo`, ou **NetLogo 7.0.4** pour `DundiModelODD.nlogox` (même code, format NetLogo 7).
- Extensions `csv`, `table` et `gis`, livrées avec NetLogo. (attention, les extensions entre NetLogo 6.4.0 et 7.0.4 ne sont pas compatibles et peuvent générer des bugs lors de la simulation)
- Le dossier `DundiNetLogo/` doit rester complet : le modèle lit ses fichiers d'entrée par chemin relatif.

### 1.2 Contenu du dépôt

```
DundiNetLogo/
├── DundiModelODD.nlogo / .nlogox   Modèle principal (globals, breeds, setup, go, visualisation, indicateurs annuels)
├── landUnits.nls                    Patchs : type de paysage, herbe, qualité, parcelles de reforestation
├── camps.nls                        Campements permanents, rattachement des campements aux parcelles (COGES)
├── households.nls                   Foyers locaux et transhumants, stratégies du chef de ménage
├── herds.nls                        Troupeaux : déplacement, alimentation, état corporel, piétinement
├── tree-populations.nls             Populations ligneuses : initialisation, vieillissement, régénération, croissance
├── crop-lands.nls                   Champs et résidus de culture
├── seasons.nls                      Saisons, durées, arrivées et départs des transhumants
├── reporters.nls                    Fonctions de calcul (croissance logistique, choix du pâturage, besoins, piétinement…)
├── calculStat.nls                   Indicateurs de sortie (déclarés ici comme globals)
├── loading-files.nls                Lecture des fichiers d'entrée
├── landscape.nls                    Repartition des données attribuées aux patches
├── environment_vel.txt              Grille 23×23 : couvert ligneux, zones basses, type de sol
├── year-type.txt                    Succession des types d'années
├── tree_info.csv                    Stocks ligneux par sol, type et âge
├── tree_nutrition.csv               Phénologie et valeurs nutritives des ligneux par type, sol et saison
├── germination_rate.csv             Paramètres de reproduction par sol et type
└── data/soils.* , data/trees.*      Shapefiles (WGS84) des types de sol et du comptage d'arbres
scriptOpenMole/                      Plans d'exploration OpenMOLE
scriptR/                             Traitements R (SIG, analyses des sorties)
results/                             Sorties d'exploration (CSV, RDS)
img/                                 Figures d'analyse
DundiNetLogo.xml                     Diagramme de classes (draw.io)
```

### 1.3 Lancer une simulation

1. Ouvrir `DundiNetLogo/DundiModelODD.nlogo` dans NetLogo.
2. Régler les paramètres (§ 1.4). Les valeurs indiquées sont celles enregistrées dans l'interface.
3. Optionnel : éditer `year-type.txt` pour fixer la succession des années (§ 1.5) - pas d'effet sur la simulation.
4. Cliquer **setup**. Le monde est redimensionné à 23 × 23 patchs, les fichiers sont chargés et les agents créés.
5. Cliquer **go** (une fois = un jour ; bouton « toujours » = continu) ou **GO 10** (simulation de 10 ans, soit `ticks < 3650`).
6. Pendant la simulation, on peut modifier `influx-*`, `retard-jours`, `decreasing-factor`, `FUtility`, les seuils de satisfaction et `visualization-mode` ; les autres paramètres ne servent qu'au `setup`.

### 1.4 Paramètres de l'interface

| Paramètre | Plage | Défaut | Rôle |
|---|---|---|---|
| `number-of-camps` | 1–150 | 92 | Nombre de campements permanents demandés au setup |
| `avg-UBT-per-camp` | 10–100 (pas 5) | 60 | UBT moyennes par campement ; fixe le cheptel local total `sum-UBT = number-of-camps × avg-UBT-per-camp` |
| `proportion-big-herders` | 0–100 % | 48 | Part de grands éleveurs |
| `proportion-medium-herders` | 0–100 % | 0 | Part d'éleveurs moyens ; les petits éleveurs complètent à 100 % |
| `good-shepherd-percentage` | 0–100 % | 100 | Part de « bons » bergers chez les foyers locaux |
| `good-shepherd-trans-percentage` | 0–100 % | 100 | Part de « bons » bergers chez les transhumants |
| `influx-Nduungu` | 0–100 | 0 | Foyers transhumants arrivant au début de la saison des pluies (bande sud) |
| `influx-Ceedu` | 0–100 | 0 | Foyers transhumants arrivant au début de la saison sèche chaude (bande nord) |
| `influx-Ceetcelde` | 0–100 | 0 | Foyers transhumants arrivant au début de la soudure (bande nord) |
| `retard-jours` | 0–100 | 0 | Jour de l'année (depuis le début du Nduungu) où les troupeaux locaux partis hors zone reviennent |
| `decreasing-factor` | 0–100 | 20 | Multiplicateur de la décroissance de l'herbe en saison sèche |
| `FUtility` | 0–1 (pas 0,1) | 0,4 | Poids α de la qualité dans la fonction d'utilité des bons bergers |
| `reforestation-plots-number` | 0–20 | 5 | Nombre de parcelles de reforestation clôturées |
| `COGES-camps` | 2–10 | 2 | Nombre maximal de campements rattachés à une parcelle (comité de gestion) |
| `max-ponds-4-months` / `-5-months` / `-6-months` | 0–10 | 4 / 7 / 6 | Nombre de mares par durée d'eau (stock 1000 / 2000 / 3000) |
| `CattleNECSatifactionIndex` | 0–5 | 3 | NEC jugée satisfaisante pour les bovins (seuil d'exploration et indicateur MST) |
| `SheepNECSatifactionIndex` | 0–5 | 3 | Idem pour les ovins |
| `SatisfactionMeanTreesInCaangol` | 50–150 | 101 | Densité d'arbres de plus de 4 ans (arbres/ha) jugée satisfaisante en Caangol |
| `SatisfactionMeanTreesInSeeno` | 12–50 | 20 | Idem Seeno |
| `SatisfactionMeanTreesInBaldiol` | 0–100 | 40 | Idem Baldiol |
| `SatisfactionMeanTreesInSangre` | 0–100 | 50 | Idem Sangre |
| `treshold-tree-satisfaction` | 0,1–1 | 0,6 | Part minimale de patchs satisfaisants pour qu'un type de sol soit jugé restauré |
| `min-time-ratio` | 0–100 % | 30 | Part du séjour prévu qu'un transhumant doit atteindre pour être satisfait |
| `visualization-mode` | liste | grass-cover | `soil-type`, `tree-cover`, `grass-cover`, `grass-quality`, `known-space` |

Boutons : **setup** ; **go** (un pas) ; **go** (continu) ; **GO 10** (10 ans) ; **Changer Visu** (applique `visualization-mode`) ; **Cacher arbres** (bouton patch, masque les populations ligneuses du patch cliqué).

Moniteurs : `totalFoyers`, `totalCattles`, `totalSheeps` (têtes locales), `waterStock`, `sum-UBT`, saison (`current-season`), type d'année (`current-year-type`), année (`year-index`).

Graphiques : gain de poids vif par tête ; troupeaux en petite transhumance ; troupeaux partis hors zone ; poids vif par tête (moyen, max, min) bovins et ovins ; espace connu lointain moyen ; histogramme des types d'éleveurs ; biomasse herbacée moyenne (kg MS/ha) ; consommation de feuilles et fruits par tête ; ressources ligneuses moyennes ; NEC moyenne (locaux, transhumants) ; MST NEC (locaux, transhumants) ; nombre moyen d'arbres/ha par type de sol ; MST arbres par type de sol ; arbres tués ; recrues d'un an ; populations par classe d'âge ; biomasse herbacée consommée par tête ; MST temps passé des transhumants (annuel et moyenne simulation) ; MST de présence des troupeaux locaux (`plot 1`).

Lecture de la vue : couleur des patchs selon `visualization-mode` ; parcelles clôturées en orange ; vaches en gris, moutons en noir (taille proportionnelle à l'effectif) ; campements permanents en maisons brunes (vert clair s'ils sont rattachés à une parcelle) ; foyers transhumants en rouge ; une icône d'arbre par type pour les populations de 8 ans et plus, de taille proportionnelle à l'effectif (0,1 à 1,5 pour 0 à 8000 arbres).

### 1.5 Fichiers d'entrée

| Fichier | Format | Contenu |
|---|---|---|
| `environment_vel.txt` | 529 lignes `[v px py arbres X Y zone sol]` | Coordonnées du patch (−11 à 11), nombre d'arbres, coordonnées projetées, zone basse (1 ou 2), type de sol. La colonne `v` et les coordonnées projetées ne sont pas lues |
| `data/soils.shp` | polygones, champ `NOM_PUULAR` | Type de sol appliqué aux patchs après le fichier précédent |
| `data/trees.shp` | polygones, champ `CT` | Comptage d'arbres par km² (d'après Brandt et al., 2020) appliqué au couvert ligneux |
| `year-type.txt` | une ligne par année : `bonne`, `moyenne` ou `mauvaise` | 20 lignes. La lecture commence à la **deuxième ligne** et boucle sur les lignes 2 à 20 (§ 5). Fichier fourni : 20 × `moyenne` |
| `tree_info.csv` | `sol,type,âge,feuilles_max,fruits_max,bois_max,accessibilité,nb_fruits_max` | Stocks maximaux par arbre (kg MS) pour 4 sols × 3 types × 8 âges |
| `tree_nutrition.csv` | `type,sol,saison,statut_feuilles,UF_feuilles,MAD_feuilles,statut_fruits,UF_fruits,MAD_fruits` | Statuts phénologiques (`dispo`, `croissance`, `chute`, `sol`) et valeurs nutritives par saison |
| `germination_rate.csv` | `sol,type,germination_%,survie_jeunes_%,dormance(yes/no),poids_fruit,graines_par_fruit,poids_graine,part_consommable` | Paramètres de reproduction |

### 1.6 Exploration et analyse

- `scriptOpenMole/` : `DundiModel.oms` et `DundiModel_PSE.oms` (squelettes de couplage, 10 ans par réplication), `M0_PlanComplet.oms` (plan complet, `DirectSampling` répliqué), `M0_sensibilite.oms` (indices de Saltelli), `M0_PSE_muse.oms` (PSE), `M0_NSGA2.oms` et `M1_NSGA2_island.oms` (optimisation multi-objectifs NSGA-II), `M1_Profile_FUt.oms` et `M1_profil_0GoodShep.oms` (profils de calibration sur `MSTCattle-NEC`). Chaque tâche lance `setup` puis `while [ticks <= 3650] [go]` avec une graine `mySeed`.
- `scriptR/` : préparation SIG (`pipe_gis_nlogo.R`), lecture des sorties OpenMOLE (`petitParceur_openMole.R`), analyses de plan complet, sensibilité, PSE, NSGA-II, profils et satisfaction.
- `results/` et `img/` : sorties et figures correspondantes. Les analyses sont présentées au chapitre 5 de la thèse.
- L'expérience BehaviorSpace `oat_pierre` incluse dans le `.nlogo` appelle des indicateurs supprimés depuis (§ 5) ; utiliser les scripts OpenMOLE.

---

## 2. ODD+D — Overview

### 2.1 Objectif et public

Le modèle explore comment des mesures de gestion collective (accès aux communs pastoraux, parcelles clôturées, régulation de la transhumance) et des décisions individuelles (foyers, bergers) influencent, sur dix ans, l'**état corporel des troupeaux** (Note d'État Corporel, NEC) et la **densité d'arbres adultes** par type de sol.

Hypothèses testées par scénarios :

| Hypothèse | Levier |
|---|---|
| Les bons bergers entretiennent mieux les troupeaux et préservent mieux les ligneux | `good-shepherd-percentage`, `good-shepherd-trans-percentage` |
| Les transhumants prélèvent l'herbe de la zone, ne permettent pas aux troupeaux locaux de s'alimenter suffisamment et restent trop longtemps | `influx-*` |
| Moins de troupeaux améliore la santé des troupeaux et la régénération | `number-of-camps`, `avg-UBT-per-camp` |
| Plus le retour des troupeaux partis au sud est tardif, plus ils tiennent l'année suivante | `retard-jours` |
| Sensibilité aux critères de selection des pâturages et à la vitesse de décroissance de l'herbe | `FUtility`, `decreasing-factor` |

Public : communautés pastorales et agro-pastorales, services des Eaux et Forêts, collectivités et services déconcentrés, ONG, chercheurs en écologie, pastoralisme, foresterie et modélisation socio-écologique.

### 2.2 Entités, variables d'état et échelles

Les variables marquées *(non utilisée)* sont déclarées ou initialisées sans intervenir dans les processus.

#### Patchs (1 km²)

| Variable | Description |
|---|---|
| `soil-type` | Unité de paysage en dénomination pulaar : `Baldiol`, `Caangol` (bas-fonds inondables), `Sangre`, `Seeno` ; chaîne vide hors zone |
| `init-camp-pref` | Aptitude à l'installation d'un campement (0, 1, 2) |
| `has-camps` | Présence d'un campement permanent |
| `current-grass` | Stock d'herbe total (kg MS) |
| `K` | Capacité de charge herbacée (kg MS), réduite par les champs |
| `K-max` | Capacité de charge du type de sol avant réduction |
| `p` | Proportion de monocotylédones dans le stock |
| `current-monocot-grass`, `current-dicot-grass` | Stocks de monocotylédones (graminées) et dicotylédones (légumineuses) |
| `monocot-UF-per-kg-MS`, `monocot-MAD-per-kg-MS`, `dicot-UF-per-kg-MS`, `dicot-MAD-per-kg-MS` | Valeurs nutritives saisonnières : Unités Fourragères et g de Matière Azotée Digestible par kg MS |
| `grass-quality` | `good`, `average` ou `poor` |
| `q` | Valeur numérique de la qualité (1 ; 0,7 ; 0,5) |
| `tree-cover` | Nombre d'arbres sur le km² à l'initialisation |
| `max-tree-cover` | Copie de `tree-cover` pour la visualisation |
| `max-tree-number` | Plafond annuel de recrues par population |
| `num-nutritious`, `num-less-nutritious`, `num-fruity` | Effectifs initiaux par type ligneux |
| `intermediate-patch-*`, `init-patch-*` | Variables de transfert patch → population au setup |
| `is-fenced`, `plot-id` | Parcelle de reforestation clôturée et son identifiant |
| `has-pond`, `water-stock` | Mare et stock d'eau (1000, 2000 ou 3000), constants au cours de la simulation |
| `patch-sensitivity` | Sensibilité à la dégradation (1 à 3) *(non utilisée)* |
| `water-point` | Forage *(non utilisée)* |

#### Variables communes à toutes les tortues (`turtles-own`)

| Variable | Description |
|---|---|
| `head` | Nombre de têtes |
| `UBT-size` | Poids d'une tête en Unité de Bétail Tropical (bovin 1, ovin 0,16) |
| `initial-live-weight`, `live-weight`, `max-live-weight`, `min-live-weight` | Poids vif du troupeau (kg) : initial, courant, plafond, plancher |
| `weight-gain` | Gain ou perte journalière par tête (kg) |
| `corporal-condition` | NEC du troupeau (1 à 5) |
| `ticks-left-year` | Jours passés hors zone dans l'année |
| `max-daily-DM-ingestible-per-head` | Ingestion maximale par tête (7,2 kg MS × UBT) |
| `daily-needs-DM`, `daily-needs-UF`, `daily-needs-MAD` | Besoins journaliers du troupeau |
| `daily-min-UF-needed-head`, `daily-min-MAD-needed-head` | Besoins d'entretien par tête |
| `desired-DM-intake` | Ingestion visée selon la valeur du fourrage |
| `DM-ingested`, `UF-ingested`, `MAD-ingested` | Ingéré total du jour |
| `total-DM-ingested-from-trees`, `total-UF-ingested-from-trees`, `total-MAD-ingested-from-trees` | Part ligneuse de l'ingéré |
| `preference-mono` | Part visée de monocotylédones dans la ration herbacée |
| `daily-water-consumption` | 22 L/UBT/jour × effectif *(non utilisée)* |
| `known-space` | Patchs connus |
| `close-known-space`, `distant-known-space` | Patchs connus à 6 km ou moins (`radius-close`) et au-delà |
| `daily-trip` | Distance parcourue dans la journée (patchs) |
| `is-transhumant` | Statut transhumant |
| `original-home-camp`, `original-home-patch` | Campement permanent et son patch |
| `current-home-camp`, `current-home-patch` | Campement actuel et son patch |
| `prev-home-patch` | Patch du campement de la veille |
| `is-in-temporary-camp` | Installation en campement temporaire |
| `reforestation-plot` | Patchs de la parcelle associée |

#### Campements (`camps`)

| Variable | Description |
|---|---|
| `available-space` | Capacité d'accueil en foyers |
| `is-temporary` | Campement temporaire (transhumants) |
| `foyers-hosted` | Foyers rattachés |
| `wood-needs` (100), `wood-quantity` (0) | Besoins et stock de bois *(non utilisées)* |

#### Foyers (`foyers`)

| Variable | Description |
|---|---|
| `herder-type` | Type d'éleveur : `grand`, `moyen`, `petit` |
| `shepherd-type` | Berger `bon` ou `mauvais` |
| `cattle-herd`, `sheep-herd` | Troupeaux possédés |
| `cattle-herd-size`, `sheep-herd-size` | Classe de taille de chaque troupeau |
| `cattle-herd-count`, `sheep-herd-count` | Effectifs tirés dans la classe |
| `cattle-low-threshold-cc`, `sheep-low-threshold-cc` | Seuil critique de NEC (1) |
| `cattle-high-threshold-cc`, `sheep-high-threshold-cc` | Seuil de satisfaction de NEC (sliders) |
| `cattle-low-threshold-pc`, `cattle-high-threshold-pc`, `sheep-low-threshold-pc`, `sheep-high-threshold-pc` | Seuils MAD *(non utilisées)* |
| `far-exploration-count` | Explorations lointaines faites dans l'année |
| `close-exploration-count` | Exploration proche faite dans l'année |
| `planned-days`, `days-present`, `presence-satisfaction`, `counted-satisfied?` | Séjour prévu, jours présents, ratio (%) et indicateur de satisfaction des transhumants |
| `cattleNEC-satisfaction`, `sheepNEC-satisfaction` | Jours où la NEC des troupeaux locaux atteint le seuil |
| `transCattleNEC-satisfaction`, `transSheepNEC-satisfaction` | Idem pour les transhumants |
| `surface-agriculture` | Surface cultivée (0,01 km² = 1 ha) |
| `stock-residu` | Stock de résidus de culture |
| `owned-trees-pop` | *(non utilisée)* |

#### Troupeaux (`cattles`, `sheeps`)

| Variable | Description |
|---|---|
| `foyer-owner` | Foyer propriétaire |
| `shepherd-type` | Hérité du foyer |
| `have-left` | Troupeau parti hors de l'UP |
| `best-patches` | Meilleurs pâturages du jour (jusqu'à 5) |
| `original-camp-known-space` | Patchs connus à 6 km ou moins du campement permanent |
| `leaves-eaten`, `fruits-eaten` | Feuilles et fruits consommés (kg MS) |
| `mean-DM-ingested` | Herbe ingérée par tête |

#### Populations ligneuses (`tree-populations`)

Une population regroupe sur un patch les arbres d'un même type et d'une même classe d'âge (3 types × 8 âges, soit jusqu'à 24 populations par patch, plus les cohortes de recrues).

| Variable | Description |
|---|---|
| `tree-type` | `nutritive`, `lessNutritive`, `fruity` |
| `tree-pop-age` | Classe d'âge 1 à 8 (8 = adultes) |
| `population-size` | Nombre d'arbres |
| `current-wood-stock`, `max-wood-stock` | Bois courant et maximal (kg) |
| `wood-ratio` | `current-wood-stock / max-wood-stock` |
| `current-leaf-stock`, `max-leaf-stock` | Feuilles sur l'arbre (kg MS) |
| `current-fruit-stock`, `max-fruit-stock` | Fruits sur l'arbre (kg MS) |
| `soil-current-fruit-stock` | Fruits tombés au sol |
| `fruit-nb`, `max-fruit-nb`, `seed-nb`, `max-seed-nb` | Nombres de fruits et de graines (`max-seed-nb` non utilisée) |
| `germinated-seed-nb` | Graines passées par le tube digestif du bétail |
| `leaves-percent-accessible`, `fruits-percent-accessible` | Accessibilité au bétail selon l'âge |
| `leaves-status`, `fruits-status` | Stade phénologique de la saison |
| `leaves-UF-per-kg-MS`, `leaves-MAD-per-kg-MS`, `fruits-UF-per-kg-MS`, `fruits-MAD-per-kg-MS` | Valeurs nutritives |
| `germination-rate`, `young-regen-rate` | Taux de germination et de survie annuelle des âges 1 à 4 (%) |
| `dormance-needed` | Levée de dormance par endozoochorie (`yes`/`no`) |
| `one-fruit-weight`, `one-seed-weight`, `seed-nb-per-fruit`, `ratio-consumable` | Caractéristiques des fruits |

Agents de visualisation : `mature-tree-nutritive-pops`, `mature-tree-less-nutritive-pops`, `mature-tree-fruity-pops`. Champs (`champs`) : `foyer-owner`, `surface`.

#### Variables globales

| Groupe | Variables |
|---|---|
| Temps | `current-season`, `last-season`, `season-counter`, `year-counter`, `year-index`, `year-types`, `current-year-type`, `total-ticks-per-year`, `nduungu-duration`, `dabbuunde-duration`, `ceedu-duration`, `ceetcelde-duration` |
| Tables ligneuses | `tree-age-table`, `tree-nutrition-table`, `tree-germination-table` |
| Herbe | `K-Baldiol` (120 000), `K-Caangol` (270 000), `K-Sangre` (56 000), `K-Seeno` (180 000) kg MS/km² ; `seuil-bon-UF` (0,6), `seuil-moyen-UF` (0,45), `seuil-bon-MAD` (53), `seuil-moyen-MAD` (25) |
| Population | `pB`, `pM`, `pS` (proportions d'éleveurs), `sum-UBT`, `total-UBT-created`, `initial-number-of-camps`, `space-camp-min` (1), `space-camp-max` (100), `space-camp-mean` (50,5), `space-camp-standard-deviation` (20) |
| Espace | `radius-close` (6), `reforestation-plots-nb`, `current-plot-id`, `caangol-surface`, `seeno-surface`, `sangre-surface`, `baldiol-surface` |
| Agriculture | `production-residu-hectare-agriculture` (1) |
| Visualisation | `max-grass`, `max-trees`, `listValueHerdeType` |
| Non utilisées | `soilGrid`, `treeGrid` (stockage SIG), `size-x`, `size-y`, `UBT_grand`, `UBT_moyen`, `UBT_petit` |

Les indicateurs de sortie sont décrits en § 3.10.

#### Échelles

- **Espace** : grille de 23 × 23 patchs (−11 à 11), monde non torique, 1 patch = 1 km², soit 529 km² représentant une Unité Pastorale. Les distances sont exprimées en patchs (= km).
- **Temps** : 1 tick = 1 jour. Année de 365 jours en quatre saisons pulaar : *Nduungu* (saison des pluies), *Dabbuunde* (saison sèche froide), *Ceedu* (saison sèche chaude), *Ceetcelde* (soudure). Horizon de 10 ans (3650 ticks).

| Type d'année | Nduungu | Dabbuunde | Ceedu | Ceetcelde |
|---|---|---|---|---|
| `bonne` | 120 | 60 | 175 | 10 |
| `moyenne` | 90 | 60 | 175 | 40 |
| `mauvaise` | 60 | 60 | 175 | 70 |

Variables exogènes : paramètres d'interface, fichiers d'entrée, type d'année. Variables endogènes : stocks d'herbe et de ligneux, qualité, poids vif et NEC, espace connu, positions et campements, effectifs ligneux, indicateurs.

### 2.3 Processus et ordonnancement

**Setup** : chargement de `environment_vel.txt` → saison initiale `Nduungu` → application des shapefiles → lecture de `year-type.txt` et des trois CSV ligneux → type d'année et durées des saisons → constantes (`set-initial-values`) → paysage → mares → campements → foyers → troupeaux → populations ligneuses → champs → suppression des campements sans foyer → parcelles de reforestation → rattachement des campements aux parcelles → valeurs nutritives et qualité de l'herbe → indicateurs → visualisation.

**Go** (un tick) :

| Ordre | Processus | Procédures |
|---|---|---|
| 1 | Avancer les compteurs ; changer de saison si sa durée est atteinte ; stocker les résidus au début du Dabbuunde | `update-season`, `stock-residu-cultures` |
| 2 | Si la saison change : départs et arrivées de transhumants, valeurs nutritives de l'herbe et des ligneux, icônes d'arbres | `generate-transhumance`, `update-UF-and-MAD`, `update-tree-nutritional-values`, `update-tree-visualisation` |
| 3 | Si l'année est révolue : réensemencement des patchs à moins de 100 kg, nouveau type d'année et durées, vieillissement et recrutement ligneux, nouvelles proportions herbacées, indicateurs annuels | `update-year-type`, `set-season-durations`, `update-tree-age`, `renew-tree-population`, `assign-grass-proportions`, `evaluate-MST-Time`, `evaluate-MST-have-left` |
| 4 | Le jour `retard-jours` : retour des troupeaux partis | `call-back-herds` |
| 5 | Dynamique des ressources | `grow-grass`, `update-grass-quality`, `grow-tree-resources` |
| 6 | Bovins présents, puis ovins présents : déplacement, alimentation, état corporel, piétinement ; troupeaux absents : compteur d'absence | `move`, `eat`, `update-corporal-conditions`, `trample-trees` |
| 7 | Foyers : rejoindre le troupeau (transhumants) puis choisir une stratégie par troupeau présent | `join-herd`, `choose-strategy-for-cattles`, `choose-strategy-for-sheeps` |
| 8 | Partage de l'espace connu foyer ↔ troupeaux (réinitialisation en début d'année) | `update-known-space`, `renew-known-space` |
| 9 | Satisfaction de présence des transhumants | `evaluate-presence-satisfaction-for-transhumants` |
| 10 | Indicateurs, visualisation, tick | `calculStat`, `update-visualization`, `update-plot` |

Les agents d'un même ensemble sont activés dans un ordre aléatoire (`ask`), les mises à jour sont asynchrones.

---

## 3. ODD+D — Design concepts

### 3.1 Cadre théorique et empirique

- **Communs pastoraux** et « faire-commun » (CTFD, 2017 ; Aubert & Dutilly, 2024, Aubert & Botta, 2022) : question de recherche et indicateurs par groupe d'acteurs.
- **Modélisation d'accompagnement** (Etienne 2010, Gurung 2006): hypothèses de décision, catégories (bon/mauvais berger, types d'éleveurs, saisons, unités de paysage) et indicateurs validés en ateliers. Le chapitre 4 de la thèse retrace pour 80 variables leur émergence, validation, formalisation et validation de la formalisation.
- **Choix du pâturage** : théorie du choix rationnel (Boudon, 2004) en information partielle, l'agent révisant sa carte de l'espace en l'explorant ; arbitrage qualité/quantité par une fonction d'utilité linéaire (von Neumann & Morgenstern).
- **Zootechnie sahélienne** : ingestion, besoins UF/MAD et valeurs fourragères (Boudet & Rivière, 1968 ; Boudet, 1975 ; Guérin, 1987) ; conversion poids vif → NEC du zébu Gobra (Amougou Messi, 1998) et des ovins sahéliens (CIRDES, 2007) ; piétinement de l'herbe (Diawara, 2018).
- **Écologie** : croissance logistique discrète de Verhulst (Bommel, 2009) ; unités de paysage vernaculaires (Barral, 1982 ; Bah, 2003 ; Touré, 2003 ; PAPEL) ; comptage satellitaire des arbres (Brandt et al., 2020) ; allométrie, germination et phénologie des ligneux (Le Houérou, 1980 ; Poupon, 1980 ; Ngom et al., 2013 ; Fécherolle, 2016 ; Hiernaux, 1994).

### 3.2 Décision individuelle

Toutes les décisions sont individuelles, sans concertation entre agents.

- **Berger-troupeau** (entité agrégée) : choisit chaque jour un pâturage parmi les patchs connus, décide de s'y rendre en aller-retour ou d'y installer un campement temporaire, ajuste son ingestion à la valeur du fourrage et choisit les ligneux à émonder selon son type.
- **Foyer** (chef de ménage, seul à observer l'état du troupeau) : compare la NEC de chaque troupeau à deux seuils. Sous le seuil de satisfaction, il explore ; au seuil critique, il retire le troupeau de la zone (local) ou quitte la zone avec tout son cheptel (transhumant).
- Les **bons bergers** maximisent `U = FUtility × q + (1 − FUtility) × current-grass` ; les **mauvais bergers** ne considèrent que `current-grass`. Parmi les 5 meilleurs patchs, tous deux retiennent le plus proche.

### 3.3 Adaptation

- Ingestion ajustée à la valeur énergétique du fourrage ; préférence herbacée ajustée à la saison et au rapport MAD/UF.
- Besoins énergétiques et azotés relevés selon la distance parcourue.
- Mobilité adaptée au type de campement : un troupeau en campement temporaire déplace son campement dès 2 km, un troupeau au campement permanent seulement à partir de 6 km.
- Caangol exclu du pâturage en Nduungu (bas-fonds inondés).
- Sans pâturage viable, le troupeau divague autour de son campement.

### 3.4 Normes sociales

Les transhumants pâturent et s'installent hors des patchs portant un campement permanent, et à moins de deux campements par patch, conformément au plan de gestion de l'UP. Les parcelles clôturées sont inaccessibles à tous.

### 3.5 Espace et temps dans les décisions

- L'espace connu est découpé en proche (≤ 6 km de la position de référence) et lointain. Les pâturages sont cherchés à moins de 12 km du campement actuel.
- Le calendrier fixe les valeurs nutritives, la phénologie, l'exclusion du Caangol, les arrivées de transhumants, le retour des troupeaux et la réinitialisation annuelle de l'espace connu.

### 3.6 Incertitude

Les agents ne connaissent qu'une partie du paysage ; les patchs inconnus sont invisibles jusqu'à leur exploration, dont la destination est tirée au hasard. Les égalités de distance entre meilleurs patchs sont départagées au hasard.

### 3.7 Apprentissage

Apprentissage individuel par exploration et par installation de campements temporaires (ajout d'un rayon de 2 patchs) ; apprentissage collectif par partage quotidien de l'espace connu entre un foyer et ses troupeaux. La connaissance est remise à zéro chaque année.

### 3.8 Perception et prédiction

Les agents perçoivent, sur leurs patchs connus, les stocks d'herbe, la qualité, la présence de campements et de clôtures, ainsi que leurs positions réciproques ; le foyer perçoit la NEC de ses troupeaux. Aucun agent ne fait de prédiction.

### 3.9 Interactions et collectifs

- **Directes** : prélèvement d'herbe, de feuilles et de fruits ; piétinement de l'herbe et des jeunes arbres ; mortalité d'arbres par sur-émondage ; compétition pour la place (2 campements maximum par patch).
- **Indirectes** (stigmergie) : l'état des patchs laissé par un troupeau conditionne les choix des suivants.
- **Collectifs explicites** : campement permanent (foyers rattachés) ; comité de gestion (COGES) liant jusqu'à `COGES-camps` campements à une parcelle, sans règle de gestion associée.
- **Collectifs implicites** : troupeau (effectif agrégé), patch (stocks du km²), population ligneuse (arbres d'un même type et âge).

### 3.10 Hétérogénéité

Taille des campements ; type d'éleveur, type de berger et effectifs des foyers ; statut local ou transhumant ; espèce (coefficients d'ingestion, de NEC et de part ligneuse propres aux bovins et ovins) ; sol, type et âge des populations ligneuses (stocks, accessibilité, germination, survie, phénologie).

### 3.11 Stochasticité

Initialisation : proportions herbacées, emplacement et capacité des campements, mares, types d'éleveur et de berger (listes mélangées), classes et effectifs des troupeaux, parcelles de reforestation et campements rattachés, position des icônes. Simulation : proportions herbacées annuelles, emplacement d'arrivée des transhumants, destinations d'exploration, choix entre patchs ex æquo, positions dans le patch, piétinement fractionnaire, population ligneuse victime de piétinement ou de sur-émondage. Les analyses utilisent des réplications à graine contrôlée.

### 3.12 Observation

Indicateurs calculés à chaque tick par `calculStat` et, pour certains, en fin d'année :

| Groupe | Indicateurs |
|---|---|
| Effectifs | `totalFoyers`, `totalLocalFoyers`, `totalTransFoyers`, `totalCattles`, `totalSheeps`, `totalTransCattles`, `totalTransSheeps`, `sumSmallHerder`, `sumMediumHerder`, `sumLargeHerder` |
| Mobilité | `cattlesTempCamp`, `sheepsTempCamp` (locaux en campement temporaire), `cattlesHaveLeft`, `sheepsHaveLeft`, `meanDistantKnownSpaceCattles`, `meanDistantKnownSpaceSheeps` (% du territoire connu au-delà de 6 km, locaux) |
| Alimentation | `meanCattlesGrassEaten`, `meanSheepsGrassEaten` (kg MS/tête), `meanLeavesConsumedCattle`, `meanFruitsConsumedCattle`, `meanLeavesConsumedSheep`, `meanFruitsConsumedSheep` |
| État corporel (locaux présents) | `cattlesWeightGain`, `sheepsWeightGain`, `meanCattlesLiveWeight`, `maxCattlesLiveWeight`, `minCattlesLiveWeight`, `meanSheepsLiveWeight`, `maxSheepsLiveWeight`, `minSheepsLiveWeight` (kg/tête), `meanCattlesNEC`, `meanSheepsNEC` |
| État corporel (transhumants) | `transCattlesWeightGain`, `transSheepsWeightGain`, `meanTransCattlesLiveWeight`, `maxTransCattlesLiveWeight`, `minTransCattlesLiveWeight`, `meanTransSheepsLiveWeight`, `maxTransSheepsLiveWeight`, `minTransSheepsLiveWeight`, `meanTransCattlesNEC`, `meanTransSheepsNEC` |
| MST NEC | `MSTCattle-NEC`, `MSTSheep-NEC` : moyenne sur les foyers locaux de la part des jours où la NEC atteint l'indice de satisfaction ; `MSTTransCattle-NEC`, `MSTTransSheep-NEC` : idem pour les transhumants, rapportée à `ticks-with-transhumants` |
| MST présence | `percent-satisfied-year`, `serie-mst-temps-passe`, `mean-mst-temps-passe`, `mst-temps-passe-simu` (transhumants satisfaits / foyers attendus, puis moyenne annuelle) ; `mst-cattle-left`, `mst-sheep-left`, `serie-mst-*-left`, `mean-mst-*-left`, `mst-cattle-left-simu`, `mst-sheep-left-simu` (1 − part de l'année passée hors zone, puis moyenne annuelle) |
| Herbe et eau | `totalGrass`, `meanGrass` (kg MS/km²), `waterStock` |
| Ligneux | `totalTrees`, `meanTrees1yearsByPatch` … `meanTrees8yearsByPatch`, `meanTreesYoungsByPatch` (≤ 4 ans), `meanTreesOldesByPatch` (> 4 ans), `meanTreesInCaangol`, `meanTreesInSeeno`, `meanTreesInBaldiol`, `meanTreesInSangre` (arbres/ha), `trees-killed` (cumul piétinement, émondage, dépérissement) |
| MST arbres | `good-patches-*` et `totalGP*` (patchs dont la densité d'arbres de plus de 4 ans dépasse le seuil du sol), `traj-satisfaction-*` (jours où la part de bons patchs atteint `treshold-tree-satisfaction`), `MST-Seeno`, `MST-Baldiol`, `MST-Sangre`, `MST-Caangol` (`traj-satisfaction-*` / ticks) |
| Pression pastorale | `pretionPastoLocal`, `pretionPastoTranshuman` (têtes bovines par km²), `sumPretionPastoLocal`, `sumpPetionPastoTranshuman` (cumuls) |
| Déclarés sans calcul | `ticks-wih-transhumants`, `mst-temps-passe`, `mst-temps-passe-annee`, `traj-trees`, `MST-trees`, `totalTreesOldes`, `totalTreesYoung` |

Les MST (*Mean Sojourn Time*, Mathias et al., 2024) mesurent la durée relative passée dans l'état jugé satisfaisant par chaque groupe d'acteurs : NEC pour les agro-pasteurs, temps de présence pour les transhumants, densité ligneuse pour les forestiers. Ce sont ces indicateurs qui sont importants a observer en simulation.

---

## 4. ODD+D — Details

### 4.1 Initialisation

**Paysage.** `soil-type` et `tree-cover` sont lus dans `environment_vel.txt`, puis remplacés par les champs `NOM_PUULAR` et `CT` des shapefiles (enveloppe du monde = emprise de `soils.shp`). Pour chaque sol :

| Sol | `K` | Part nutritive / peu nutritive / fruitière | `max-tree-number` | `patch-sensitivity` | `p` initial |
|---|---|---|---|---|---|
| Baldiol | 120 000 | 0,4 / 0,3 / 0,3 | 8 000 | 2 | U[0,6 ; 0,7] |
| Caangol | 270 000 | 0,5 / 0,25 / 0,25 | 20 000 | 2 | U[0,7 ; 0,8] |
| Sangre | 56 000 | 0,3 / 0,1 / 0,2 | 15 000 | 3 | U[0,5 ; 0,6] |
| Seeno | 180 000 | 0,4 / 0,2 / 0,4 | 5 000 | 1 | U[0,55 ; 0,65] |

`current-grass` = 100 kg sur tous les patchs typés (1 kg et `K` = 1 hors zone), réparti en monocotylédones et dicotylédones selon `p` (plancher 0,2).

**Mares.** Parmi les patchs de zone basse 2 du fichier d'environnement, `max-ponds-4-months` patchs reçoivent 1000 unités d'eau, puis `max-ponds-5-months` 2000 et `max-ponds-6-months` 3000.

**Campements.** `init-camp-pref` est recalculé : 1 pour un patch hors Caangol voisin d'un Caangol ou d'une mare, 2 à deux patchs de distance, 0 sinon. Les `number-of-camps` campements sont placés aléatoirement sur les patchs de préférence 1 (préférence 2 seulement s'il n'existe aucun patch de préférence 1), deux au plus par patch. `available-space` suit N(50,5 ; 20) tronquée à [1 ; 100].

**Foyers locaux.** Une liste de types de berger (`bon`/`mauvais`, selon `good-shepherd-percentage`) est mélangée pour la somme des `available-space`. Les campements sont parcourus dans l'ordre ; chacun reçoit au plus `round(0,8 × available-space)` foyers, jusqu'à ce que ses UBT atteignent `avg-UBT-per-camp` ou que le total atteigne `sum-UBT`. `herder-type` est tiré selon `pB`, `pM`, `pS`, puis les classes de troupeaux :

| `herder-type` | Bovins / ovins |
|---|---|
| grand | 29 % moyen/grand ; 71 % grand/grand |
| moyen | 27 % moyen/petit ; 73 % petit/moyen |
| petit | petit/petit |

| Classe | Bovins (têtes) | Ovins (têtes) |
|---|---|---|
| grand | 30–49 | 30–69 |
| moyen | 10–24 | 10–29 |
| petit | 1–9 | 1–9 |

Le dernier foyer est réduit (bovins puis ovins) pour ne pas dépasser `sum-UBT` ; un foyer sans animal disparaît. Chaque foyer connaît les patchs dans un rayon de 3 autour de son campement. Les campements restés vides sont supprimés.

**Troupeaux.** Chaque foyer crée un troupeau bovin et un troupeau ovin (supprimé si l'effectif est nul), placés sur le campement :

| | Bovins | Ovins |
|---|---|---|
| `UBT-size` | 1 | 0,16 |
| `initial-live-weight` | 250 kg × tête | 40 kg × tête |
| `max-live-weight` | 391 kg × tête (NEC 5) | 50 kg × tête (NEC 5) |
| `min-live-weight` | 149 kg × tête (NEC 0) | 21 kg × tête (NEC 0) |
| `max-daily-DM-ingestible-per-head` | 7,2 kg MS | 1,15 kg MS |
| `corporal-condition` | calculée à partir du poids : 2,08 | calculée à partir du poids : 3,27 |

**Populations ligneuses.** Pour chaque type, l'effectif du patch est réparti en 80 % d'arbres d'âge 8 et 20 % répartis uniformément sur les âges 1 à 7. Chaque population reçoit les stocks maximaux de `tree_info.csv` multipliés par son effectif, les paramètres de `germination_rate.csv` et la phénologie de `tree_nutrition.csv` pour la saison en cours. Feuilles et fruits démarrent à 50 % du maximum, le bois à 100 %.

**Champs.** Chaque foyer local cultive 1 ha sur le patch de son campement (ou un voisin) ; `K` du patch est réduit de `surface × K-max`.

**Parcelles de reforestation.** Les patchs sans campement sont parcourus aléatoirement ; une parcelle est créée sur un patch comptant au moins 2 campements à 2 km ou moins et sans voisin clôturé, et s'étend avec une probabilité de 0,9 à un voisin direct libre. On crée `reforestation-plots-number` parcelles au plus. Jusqu'à `COGES-camps` campements non encore rattachés, situés à 4 km ou moins, sont rattachés à chaque parcelle.

### 4.2 Données d'entrée

Fichiers décrits en § 1.5. Le climat n'entre que par la succession des types d'années, qui fixe la durée des saisons.

### 4.3 Sous-modèles

#### Saisons et années (`update-season`, `set-season-durations`, `update-year-type`)

`season-counter` et `year-counter` augmentent de 1 par tick. La saison passe à la suivante (Nduungu → Dabbuunde → Ceedu → Ceetcelde → Nduungu) quand `season-counter` atteint sa durée. Quand `year-counter` atteint `total-ticks-per-year`, `year-index` avance et `current-year-type` est lu dans `year-types`.

#### Transhumance (`generate-transhumance`, `create-transhumant-foyers`)

À l'entrée en Dabbuunde et en Nduungu, tous les foyers transhumants, leurs troupeaux et leurs campements temporaires quittent le modèle. Puis :

| Saison d'entrée | Arrivées | Zone d'entrée | `planned-days` |
|---|---|---|---|
| Nduungu | `influx-Nduungu` | 3 rangées sud | `nduungu-duration` |
| Ceedu | `influx-Ceedu` | 3 rangées nord | `ceedu-duration + ceetcelde-duration` |
| Ceetcelde | `influx-Ceetcelde` | 3 rangées nord | `ceetcelde-duration` |

Chaque foyer arrive sur un patch non clôturé portant moins de 2 campements, y crée un campement temporaire, prend `herder-type` = `moyen`, un type de berger tiré selon `good-shepherd-trans-percentage`, et connaît un rayon de 3 patchs. La première arrivée de Nduungu a lieu au premier tick.

#### Herbe (`grow-grass`, `assign-grass-proportions`, `update-UF-and-MAD`, `update-grass-quality`)

Croissance logistique discrète de chaque composante, plafonnée par sa capacité :

```
M(t+1) = M + r · m · M · (K·p − M) / (K·p)          monocotylédones
D(t+1) = D + r · m · D · (K·(1−p) − D) / (K·(1−p))  dicotylédones
```

| Saison | `r` | `m` |
|---|---|---|
| Nduungu | 0,2 | 1 |
| Dabbuunde | −0,001 ; −0,5 si `current-grass ≥ 0,95 K` | `decreasing-factor` |
| Ceedu, Ceetcelde | −0,001 | `decreasing-factor` |

Chaque stock a un plancher de 1 kg. En fin d'année, les patchs sous 100 kg repartent à 50 + 50 kg et `p` est retiré selon le sol.

Valeurs nutritives fixées à chaque changement de saison (Boudet, 1975) :

| Saison | Mono UF | Mono MAD | Dicot UF | Dicot MAD |
|---|---|---|---|---|
| Nduungu | 0,5 | 34,4 | 0,77 | 108,5 |
| Dabbuunde | 0,53 | 41,1 | 0,84 | 93,5 |
| Ceedu | 0,405 | 1 | 0,6 | 65,5 |
| Ceetcelde | 0,285 | 0,2 | 0,4 | 89 |

La qualité est calculée chaque jour à partir des UF et MAD moyennes pondérées par les stocks : `good` si UF ≥ 0,6 et MAD ≥ 53 ; `average` si 0,45 ≤ UF ≤ 0,6 et 25 ≤ MAD ≤ 53 ; `poor` sinon.

#### Ressources ligneuses (`grow-tree-resources`, `update-tree-nutritional-values`)

Chaque jour, pour chaque population :

1. `max-wood-stock` = bois maximal par arbre × effectif ; croissance logistique du bois avec `r` = 0,01 (feuilles `dispo`/`croissance`) ou 0,0005 (feuilles `chute`/`sol`).
2. Si `wood-ratio` < 0,05, un arbre meurt (`trees-killed` + 1) ; la population disparaît à effectif nul.
3. Les maxima de feuilles, de fruits et du nombre de fruits sont multipliés par l'effectif et par `wood-ratio`.
4. Fruits : `r` = 0,02 en `dispo`/`croissance` ; en `chute`, −1 au-dessus de 80 % du maximum, −0,05 en dessous. Toute perte passe au sol (`soil-current-fruit-stock`, plafonné au maximum de fruits), qui décroît ensuite de 0,5 % par jour. `germinated-seed-nb` décroît de 0,1 % par jour.
5. Feuilles : `r` = 0,02 en `dispo`/`croissance` ; en `chute`, −0,5 au-dessus de 70 % du maximum, −0,01 en dessous ; en `sol`, −0,8 au-dessus de 80 %, −0,1 en dessous.

Forme commune : `Δ = r · S · (S_max − S) / S_max`, chaque terme arrondi à une décimale, plancher de 1 kg pour feuilles et fruits. Statuts et valeurs nutritives sont relus dans `tree_nutrition.csv` à chaque changement de saison.

#### Vieillissement et régénération (`update-tree-age`, `renew-tree-population`)

En début d'année :

- âges 1 à 4 : passage à l'âge suivant, effectif × `young-regen-rate` / 100 ;
- âges 5 à 7 : passage à l'âge suivant, effectif × 0,95 ;
- les cohortes atteignant 8 ans fusionnent avec la population adulte du même type sur le patch, dont l'effectif est d'abord multiplié par 0,99 ; leurs stocks s'additionnent dans la limite des maxima ;
- recrutement par type et par patch :

```
recrues = ⌊ (fruits_au_sol / poids_fruit) · graines_par_fruit · germination/100
          + graines_ingérées · min(germination/100 + 0,2 si dormance, 1) ⌋
```

plafonné à `max-tree-number`. Les recrues forment une population d'âge 1 ; stocks au sol et graines ingérées sont remis à zéro.

#### Déplacement des troupeaux (`move`, `find-best-patches`, `go-back-home`)

Le troupeau part de `current-home-patch`. Patchs viables : connus, plus de 100 kg d'herbe, non clôturés, moins de 2 campements, à moins de 12 km ; hors Caangol en Nduungu ; sans campement permanent pour les transhumants. Les 5 meilleurs selon l'utilité du berger (§ 3.2) sont retenus et le troupeau vise le plus proche (`daily-trip` = distance).

| Situation | Distance | Action |
|---|---|---|
| Campement permanent | ≥ 6 | Installe un campement temporaire sur le patch et ajoute un rayon de 2 patchs à l'espace connu |
| Campement permanent | < 6 | Aller-retour (`daily-trip` × 2) |
| Campement temporaire, transhumant | ≥ 2 | Déplace le campement si le patch n'a ni foyer ni campement (+ rayon 2), sinon aller-retour |
| Campement temporaire, local | ≥ 2 | Revient au campement permanent si le patch est dans `original-camp-known-space` ; sinon déplace le campement temporaire si le patch a de la place (+ rayon 2), sinon aller-retour |
| Campement temporaire | < 2 | Aller-retour |
| Aucun patch viable | — | Transhumant : patch non clôturé du campement ou voisin direct. Local : retour au campement permanent, divagation sur un patch non clôturé de `original-camp-known-space` |

#### Alimentation (`eat`, `consume-grass`, `consume-tree-resources`)

**Besoins** selon `daily-trip` (par kg MS ingestible) :

| Distance | UF | MAD (g) |
|---|---|---|
| ≤ 7 | 0,37 | 20 |
| 7–15 | 0,43 | 24 |
| > 15 | 0,5 | 28 |

`daily-needs-DM = max-daily-DM-ingestible-per-head × head` ; besoins UF et MAD = coefficient × ingestion maximale × effectif.

**Préférence herbacée** : `preference-mono` = 0,8 en Nduungu ; ailleurs 0,8 si `(MAD/UF)_mono × M ≥ (MAD/UF)_dicot × D`, 0,3 sinon.

**Ingestion visée** (UF moyenne du patch, rapportée à 1 UF/kg) :

- bovins : `0,7 · daily-needs-DM + 0,3 · daily-needs-DM · UF_moy`
- ovins : `0,5 · daily-needs-DM + 0,5 · daily-needs-DM · UF_moy`, plafonnée à `daily-needs-DM`.

**Herbe** : prélèvement de `min(M, visé × préférence)` et `min(D, visé × (1 − préférence))`. S'y ajoute le piétinement (Diawara, 2018), retiré au prorata de `p` :

```
MLVstk = 0,2 · e^(−0,00068 · M) + 0,165 · e^(−0,00092 · D)
Piétinement = MLVstk × head
```

**Ligneux** : le complément `daily-needs-DM − DM-ingested` est plafonné à 30 % (bovins) ou 50 % (ovins) de `daily-needs-DM`. Populations éligibles : effectif et stocks de feuilles et fruits positifs. Il est couvert en deux temps.

D'abord, les fruits et feuilles au sol sont prélevés en premier et en accès libre : ni le type de berger, ni l'âge, ni le type, ni la phénologie de la population ne limitent ce prélèvement. Une même part du stock au sol est ramassée dans toutes les populations du patch (à hauteur du besoin), seule la part ratio-consumable est ingérée, et les graines des fruits ingérés s'ajoutent à germinated-seed-nb.
Ensuite, feuilles et fruits sur l'arbre sont prélevées, pour le besoin restant, selon le type de berger.

| Berger | Populations ciblées | Seuil de prélèvement | Réduction du bois (kg/kg MS) |
|---|---|---|---|
| bon | ≥ 6 ans, nutritives ou fruitières | 0,1 | 0 |
| bon, à défaut | ≥ 6 ans, tous types | 0,4 | 0,1 |
| mauvais | tous âges et types | 0,6 | 0,3 |

Sont retenues les populations dont les feuilles ou les fruits dépassent seuil × maximum. Feuilles consommables : `min(stock, max × max(accessibilité, seuil))` en `dispo`/`croissance`, `min(stock, max)` en `chute`. Fruits consommables : même règle en `dispo`/`croissance`, `max(stock, max)` en `chute`, nnuls en sol (traités à l'étape 1) et si leur UF vaut 0. La même fraction du disponible est prélevée dans chaque population ; seule la part ratio-consumable des fruits est ingérée. Les stocks sur l'arbre ne descendent pas sous 1 kg. Le bois est réduit quand les feuilles prélevées dépassent `max-leaf-stock × leaves-percent-accessible`. Les graines des fruits ingérés s'ajoutent à `germinated-seed-nb`. UF, MAD et MS ligneuses s'ajoutent à l'ingéré.

**Sur-émondage** : pour un mauvais berger dont la ration provient à 50 % ou plus de prélèvements sur l'arbre (les fruits ramassés au sol ne comptent pas), un arbre d'une population ciblée meurt. Ses stocks sont retirés au prorata. Comme la part ligneuse des bovins est plafonnée à 30 %, seuls les troupeaux ovins déclenchent l'émondage. Ce comportement est attendu : sur le terrain, les bergers coupent surtout pour les moutons, les bovins consommant peu de feuilles. Pour les ovins, le seuil (50 %) est égal au plafond : l'émondage ne survient que lorsque le troupeau atteint exactement son plafond ligneux sur l'arbre, ce qui le rend rare quand des fruits au sol sont disponibles.

#### État corporel (`update-corporal-conditions`)

```
fE = clamp((UF_ing − besoin_UF) / (0,9 · head · ingestion_max − besoin_UF), 0, 0,5)
fP = clamp((MAD_ing − besoin_MAD) / (50 · head · ingestion_max − besoin_MAD), 0, 0,5)
weight-gain = (fE + fP) · 1,4 · UBT − 0,7 · UBT          (kg/tête/jour, de −0,7 à +0,7 UBT)
live-weight = min(live-weight + weight-gain · head, max-live-weight)
NEC bovins = (live-weight − 148,99 · head) / (48,6 · head)
NEC ovins  = (live-weight − 21,21 · head) / (5,75 · head)
```

La NEC est bornée à [1 ; 5].

#### Piétinement des jeunes arbres (`trample-trees`)

Espérance de `0,001 × head` arbres détruits par jour : la partie entière est retirée, la partie décimale l'est avec cette probabilité. La cible est une population de moins de 4 ans, nutritive ou fruitière en priorité, sinon de tout type (ses stocks étant alors réduits au prorata). Les arbres détruits s'ajoutent à `trees-killed`.

`trees-killed` cumule donc trois mécanismes : piétinement (dépendant surtout de l'effectif et de la présence des troupeaux, dominé par les bovins), sur-émondage (ovins, mauvais berger) et dépérissement (wood-ratio < 0,05). Sa saisonnalité ne peut être attribuée à l'un d'eux sans compteurs séparés.

#### Stratégies des foyers (`choose-strategy-for-*`, `do-first-strategy`, `do-second-strategy`, `do-transhumant-strategy`, `join-herd`)

Chaque jour, pour chaque troupeau présent :

- **NEC ≤ seuil de satisfaction → exploration** : le foyer visite un patch inconnu tiré au hasard à 6 km ou moins de son campement et ajoute à son espace connu les patchs de la ligne campement–destination. S'il n'en reste aucun, il explore au-delà de 6 km, dans la limite de 6 explorations lointaines par an (`far-exploration-count` ≤ 5).
- **NEC ≤ 1 → départ** : un troupeau local quitte la zone (`have-left`, masqué, rattaché au campement permanent) jusqu'au jour `retard-jours` de l'année suivante ; un foyer transhumant quitte définitivement le modèle avec ses deux troupeaux et son campement.

Les foyers transhumants se placent chaque jour sur le campement de leur troupeau bovin (ovin à défaut).

#### Retour des troupeaux (`call-back-herds`)

Les troupeaux partis réapparaissent avec `live-weight = initial-live-weight`, NEC = 5 (recalculée au tick suivant à partir du poids) et `ticks-left-year` = 0.

#### Espace connu (`update-known-space`, `renew-known-space`)

Chaque jour, le foyer ajoute les patchs connus de ses troupeaux, puis chaque troupeau ajoute ceux de son foyer. `close-known-space` et `distant-known-space` sont recalculés (6 km) autour du foyer et autour du campement de chaque troupeau ; `original-camp-known-space` est recalculé pour les troupeaux locaux. En début d'année, chaque foyer ne connaît plus que le rayon de 3 patchs autour de sa position, transmis à ses troupeaux, et `far-exploration-count` revient à 0.

#### Résidus de culture (`stock-residu-cultures`)

Au début de chaque Dabbuunde, `stock-residu` de chaque foyer augmente de `surface-agriculture × production-residu-hectare-agriculture`. Ce stock n'est pas consommé.

#### Indicateurs annuels (`evaluate-presence-satisfaction-for-transhumants`, `evaluate-MST-Time`, `evaluate-MST-have-left`)

Chaque jour, `days-present` augmente et `presence-satisfaction = days-present / planned-days × 100` ; un foyer est compté satisfait une fois par séjour quand ce ratio atteint `min-time-ratio`. En fin d'année : `percent-satisfied-year = satisfaits / (influx-Ceedu + influx-Ceetcelde + influx-Nduungu)` (calculé si au moins un influx est non nul), puis moyenne sur les années écoulées ; `mst-*-left = 1 − moyenne(ticks-left-year) / total-ticks-per-year`, puis moyenne sur les années.

---

## 5. Points de vigilance dans le code

| Élément | Comportement du code |
|---|---|
| Eau | Mares statiques, `daily-water-consumption` non soustraite, pas de contrainte d'abreuvement |
| Reforestation | `reforestation-plot` des foyers est copié avant la création des parcelles (reste à 0 et donc pas d'assignation aux foyers). Le COGES n'a pas de règle de gestion en l'état |
| Procédures non appelées | `recalcul-herd-parameters`, `manage-water-points`, `nearest-with-space`, `color-grass` ; `show-tree-populations-info` sert au débogage |
| Fruits au sol | La part ramassée mais non ingérée (`1 − ratio-consumable`) est retirée du stock au sol : ses graines sont perdues pour la germination |
| Bilan nutritionnel | Énergie et protéines s'additionnent dans le gain de poids (compensation possible), alors que l'equilibre Energie et matière azotée est plus complexe dans la réalité. Des analyses zootechniques plus poussées sont nécessaires |

---

## 6. Références
## 6. Références

- Amougou Messi G., 1998. *Méthodes d'estimation et variations de la composition corporelle des vaches zébu Gobra et taurin N'dama en fonction du niveau d'alimentation*. Thèse de sciences vétérinaires, Université Cheikh Anta Diop (UCAD), Dakar.
- Aubert S., Botta A., 2022. *Les communs*. Éditions Quae. https://doi.org/10.35690/978-2-7592-3464-6
- Aubert S., Dutilly C., 2024. Une approche par les communs pour faire valoir le pastoralisme dans les politiques publiques. *Natures Sciences Sociétés*. https://doi.org/10.1051/nss/2023045
- Bah A., Touré I., Le Page C., Balde S., Badiane D., 2003. Contribution des systèmes multi-agents pour la compréhension du multi usage de l'espace et des ressources autour d'un forage au Sahel : le cas de Thieul au Sénégal. 11 p.
- Bah A., Touré I., Le Page C., Ickowicz A., Diop A. T., 2006. An agent-based model to understand the multiple uses of land and resources around drillings in Sahel. *Mathematical and Computer Modelling* 44 (5-6), 513–534. https://doi.org/10.1016/j.mcm.2005.02.014
- Barral H., 1982. *Le Ferlo des forages : gestion ancienne et actuelle de l'espace pastoral. Étude de géographie humaine*.
- Bommel P., 2009. *Définition d'un cadre méthodologique pour la conception de modèles multi-agents adaptée à la gestion des ressources renouvelables*. Thèse d'informatique, Université Montpellier II.
- Bonté B., Muller J.-P., Duboz R., 2012. Modeling the Minsky triad: a framework to perform reflexive M&S studies. *Proceedings of the 2012 Winter Simulation Conference (WSC)*, IEEE, 1–12. https://doi.org/10.1109/WSC.2012.6465110
- Boudet G., 1975. *Manuel sur les pâturages tropicaux et les cultures fourragères*. Manuels et précis d'élevage, n° 4.
- Boudet G., Rivière R., 1968. Emploi pratique des analyses fourragères pour l'appréciation des pâturages tropicaux. *Revue d'élevage et de médecine vétérinaire des pays tropicaux* 21 (2), 227. https://doi.org/10.19182/remvt.7588
- Boudon R., 2004. Théorie du choix rationnel ou individualisme méthodologique ? *Revue du MAUSS* 24 (2), 281–309. https://doi.org/10.3917/rdm.024.0281
- Brandt M., Tucker C. J., Kariryaa A., Rasmussen K., Abel C., Small J., Chave J., Rasmussen L. V., Hiernaux P., Diouf A. A., Kergoat L., Mertz O., Igel C., Gieseke F., et al., 2020. An unexpectedly large count of trees in the West African Sahara and Sahel. *Nature* 587 (7832), 78–82. https://doi.org/10.1038/s41586-020-2824-5 — Données : ORNL DAAC, ds_id=2117.
- CIRAD, 2005. *« Pastoralisme et environnement au Sahel » (PESah)*. Rapport final n° 2005-5, PPZS.
- CIRDES, 2007. *Valoriser les savoirs locaux sur l'intégration agriculture élevage pour une gestion durable des écosystèmes des savanes subhumides de l'Afrique*. Rapport final, 101 p.
- Comité Technique « Foncier et Développement », 2017. *Opportunités et défis d'une approche par les communs de la terre et des ressources qu'elle porte*. Agence Française de Développement (AFD), 86 p.
- Comité Technique « Foncier et Développement », 2023. Préserver le pastoralisme. Les défis de la reconnaissance des communs pastoraux dans un contexte de crise multidimensionnelle en Afrique de l'Ouest. *Les notes de synthèse – Foncier et développement* n° 35. https://www.foncier-developpement.fr/wp-content/uploads/Note-de-synthese_Numero35_Pastoralisme.pdf
- Diawara M. O., Hiernaux P., Mougin E., Grippa M., Delon C., Diakité H. S., 2018. Effets de la pâture sur la dynamique de la végétation herbacée au Sahel (Gourma, Mali) : une approche par modélisation. *Cahiers Agricultures* 27 (1), 15010. https://doi.org/10.1051/cagri/2018002
- Étienne M., 2009. *Co-construction d'un modèle d'accompagnement selon la méthode ARDI : guide méthodologique*. 76 p.
- Étienne M., Le Page C., Trébuil G., 2016. *A step-by-step guidelines to the construction of a conceptual model with the PARDI method*. CIRAD.
- Fecherolle D., 2016. *Caractérisation de la régénération naturelle ligneuse dans le Ferlo (Sénégal)*. Mémoire de fin d'études, Université Catholique de Louvain, 172 p.
- Guérin H., 1987. *Alimentation des ruminants domestiques sur pâturages naturels sahéliens et sahélo-soudaniens : étude méthodologique dans la région du Ferlo au Sénégal*. Thèse d'agronomie-zootechnie, ENSA Montpellier.
- Hiernaux P., Cissé M. I., Diarra L., De Leeuw P. N., 1994. Fluctuations saisonnières de la feuillaison des arbres et des buissons sahéliens. Conséquences pour la quantification des ressources fourragères. *Revue d'élevage et de médecine vétérinaire des pays tropicaux* 47 (1), 117–125. https://doi.org/10.19182/remvt.9123
- Le Houérou H. N., 1980. *Les fourrages ligneux en Afrique – État actuel des connaissances*. Centre International pour l'élevage en Afrique.
- Mathias J.-D., Deffuant G., Brias A., 2024. From tipping point to tipping set: Extending the concept of regime shift to uncertain dynamics for real-world applications. *Ecological Modelling* 496, 110801.
- Müller B., Bohn F., Dreßler G., Groeneveld J., Klassert C., Martin R., Schlüter M., Schulze J., Weise H., Schwarz N., 2013. Describing human decisions in agent-based models – ODD + D, an extension of the ODD protocol. *Environmental Modelling & Software* 48, 37–48. https://doi.org/10.1016/j.envsoft.2013.06.003
- Ngom D., Fall T., Sarr O., Diatta S., Akpo L. E., 2013. Caractéristiques écologiques du peuplement ligneux de la réserve de biosphère du Ferlo (Nord Sénégal). *Journal of Applied Biosciences* 65. https://doi.org/10.4314/jab.v65i0.89644
- Poupon H., 1980. *Structure et dynamique de la strate ligneuse d'une steppe sahélienne au nord du Sénégal*. Thèse de sciences naturelles, Université Paris-Sud, centre d'Orsay.
- Touré I., Bah A., D'Aquino P., Dia I., 2003. Cartes à dire d'experts, cartes à dire d'acteurs. Vers une approche partagée des modèles de représentation spatiale d'espaces agro-pastoraux sahéliens.
- Vall E., 2020. *Guide harmonisé de Notation de l'État Corporel (NEC) pour les animaux de ferme du Sahel*. CIRAD, n° 9.
- Vendel F., 2025. Thèse de doctorat, chapitre 4 : *DundiModel : des savoirs multiples catalysés dans un modèle à base d'agents*.
- von Neumann J., Morgenstern O., 2007. *Theory of games and economic behavior: 60th anniversary commemorative edition*. Princeton University Press.
- Wilensky U., 1999. *NetLogo*. Evanston, IL : Center for Connected Learning and Computer-Based Modeling, Northwestern University.
