__includes["calculStat.nls" "landUnits.nls" "camps.nls" "tree-populations.nls" "herds.nls" "crop-lands.nls" "households.nls" "seasons.nls" "reporters.nls" "loading-files.nls"]
extensions [csv table GIS]; profiler]


globals [
  soilGrid                   ;stock gis soil db
  treeGrid               ; stock trees soil DB
  size-x                 ; Taille horizontale du monde
  size-y                 ; Taille verticale du monde
  current-plot-id
  current-season         ; Saison actuelle
  last-season            ; Saison précédente
  season-counter         ; Compteur de saison
  year-types             ; Liste qui stocke les types d'années
  current-year-type      ; Le type d'année en cours (bonne, moyenne, mauvaise)
  total-ticks-per-year   ; Nombre total de ticks par année
  total-ticks-simu
  year-counter           ; Compteur de ticks dans l'année
  year-index             ; Indice de l'année en cours

  nduungu-duration       ; Nombre de ticks pour la saison des pluies
  dabbuunde-duration     ; Nombre de ticks pour la saison sèche froide
  ceedu-duration         ; Nombre de ticks pour la saison sèche chaude
  ceetcelde-duration     ; Nombre de ticks pour la période de soudure

  max-grass              ; pour visualisation
  max-trees              ; pour visualisation

  ; Tables qui enregistrent les valeurs des arbres en fonction de différents paramètres (type, age, sol et saison)

  tree-age-table ; table: (tree-type, age) -> [max-fruits max-leaves max-woods sensitivities]
  tree-nutrition-table ; table associative: (tree-type, soil, season) -> [UF MAD]
  tree-germination-table

  pB                     ; Proportion de grands éleveurs (troupeaux de grande taille) dans la population
  pM                     ; Proportion d'éleveurs moyens (troupeaux de taille moyenne) dans la population
  pS                     ; Proportion de petits éleveurs (troupeaux de petite taille) dans la population

  UBT_grand              ; Nombre d'UBT pour un grand troupeau
  UBT_moyen              ; Nombre d'UBT pour un troupeau moyen
  UBT_petit              ; Nombre d'UBT pour un petit troupeau


  seuil-bon-UF           ; Seuil UF pour une herbe de bonne qualité
  seuil-moyen-UF         ; Seuil UF pour une herbe de qualité moyenne
  seuil-bon-MAD          ; Seuil MAD pour une herbe de bonne qualité
  seuil-moyen-MAD        ; Seuil MAD pour une herbe de qualité moyenne

  K-Baldiol              ; Seuils maximum d'herbe pour les différents types de sols
  K-Caangol
  K-Sangre
  K-Seeno

  production-residu-hectare-agriculture   ; production à l'hectare en tonne de résidu de culture


  initial-number-of-camps          ; Nombre de campements permanents installés à l'initialisation du modèle
  space-camp-min                   ; Espace minimum disponible pour les foyers dans les campements permanents
  space-camp-max                   ; Espace maximum disponible pour les foyers dans les campements permanents
  space-camp-standard-deviation    ; Écart-type de l'espace des campements
  space-camp-mean                  ; Moyenne de l'espace des campements
  reforestation-plots-nb           ; Nombre de parcelles de reforestation
  radius-close                     ; Valeur de la distance maximal pour tre considr comme proche du campement (in update-known-space)
  caangol-surface                  ; Nombre de km² de Caangol
  seeno-surface                    ; Nombre de km² de Seeno
  sangre-surface                   ; Nombre de km² de Sangre
  baldiol-surface                  ; Nombre de km² de Baldiol

  listValueHerdeType               ; Pour visualiser dans l'interface
  sum-UBT                          ; Total d'UBT dan la simulation


  total-UBT-created                ; Variable de vérification du nombre d'UBT créé pendant la procédure de création pour
  ticks-with-transhumants          ; Compteur de jours où il y a des éleveurs transhumants dans la zone

]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Breeding and characterization ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

breed [camps camp]
breed [foyers foyer]
breed [cattles cattle]
breed [sheeps sheep]
breed [tree-populations tree-population]
breed [mature-tree-nutritive-pops mature-tree-nutritive-pop]             ; Pour visualisation
breed [mature-tree-less-nutritive-pops mature-less-nutritive-tree-pop]   ; Pour visualisation
breed [mature-tree-fruity-pops mature-tree-fruity-pop]                   ; Pour visualisation
breed [champs champ]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Variables des cellules ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

patches-own [


  ; Variables d'initialisation  et de temps

  soil-type                        ; Type de sol et de paysage
  init-camp-pref                   ; Préférence pour l'installation des campements (1 ou 2)
  has-camps                        ; Identifie si le patch a un campement

  ; Variables pour le tapis herbacée

  current-grass                    ; Couverture d'herbe en kg
  K                                ; Montant maximum d'herbe
  K-max                            ; Montant maximum d'herbe
  patch-sensitivity                ; Sensibilité à la dégradation
 ;degradation-level                ; Niveau de dégradation

  grass-quality                    ; Qualité actuelle de l'herbe
  q                                ; Ratio de qualité
  p                                ; Proportion de monocotylédone
  current-monocot-grass            ; Stock d'herbe des monocotylédones en kg
  current-dicot-grass              ; Stock d'herbe des dicotylédones en kg

  monocot-UF-per-kg-MS             ; UF/kg MS pour les monocotylédones
  monocot-MAD-per-kg-MS            ; MAD/kg MS pour les monocotylédones
  dicot-UF-per-kg-MS               ; UF/kg MS pour les dicotylédones
  dicot-MAD-per-kg-MS              ; MAD/kg MS pour les dicotylédones


  ; Variables d'initialisation des populations ligneuses

  tree-cover                       ; Couverture d'arbres
  max-tree-cover                   ; maximum d'arbres atteignable par cellule (pour visualisation)
  max-tree-number                   ; Maximum d'individus atteignable sur un km² (définit selon le type de sol)
  num-nutritious                   ; Nombre d'arbres appréciés par le bétail en fonction du tree-cover
  num-less-nutritious              ; Nombre d'arbres peu / pas apprécié par le bétail en fonction du tree-cover
  num-fruity                       ; Nombre d'arbres fruitiers (jujubier, baobab, balanites) par le bétail en fonction du tree-cover


  ; passage intermédiaire des données du fichier tree_infos pour les transférer à chaque population
  intermediate-patch-pop-size
  intermediate-patch-tree-age
  intermediate-patch-tree-type

  init-patch-max-fruit-stock
  init-patch-max-leaf-stock
  init-patch-max-wood-stock
  init-patch-accessible
  init-patch-fruits-nb
  init-patch-seeds-nb




  ; Variables des parcelles de reforestation

  is-fenced                        ; Cellule protégée (parcelle de reforestation)
  plot-id                          ; Assignation d'un ID si c'est une parcelle de reforestation



  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Variables non initialisées (en cours) ;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  water-point                      ; Point d'eau (booléen)
  has-pond                         ; Booléen, détermine s'il y a une mare
  water-stock                      ; Stock d'eau dans la mare
]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Ensemble des agents ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

turtles-own [

  ; Etat corporel des troupeaux
  corporal-condition               ; État de santé de l'agent - en valeur de NEC (Note d'Etat Corporel)
  initial-live-weight              ; poids vif à l'initialisation (kg)
  live-weight                      ; poids vif actuel (kg)
  max-live-weight                  ; Maximum de poids vif atteignable (kg)
  min-live-weight                  ; Minimum de poids vif atteignable (kg)
  weight-gain                      ; Gain ou perte de poids
  ticks-left-year                  ; Nombre de jours que le troupeau a quitté la zone sur l'année

  ; Alimentation spécifiques aux troupeaux
  UBT-size                         ; Proportion d'un individu en Unité de Bétail Tropical (une vache allaitante = 1)
  head                             ; Nombre d'individus
  max-daily-DM-ingestible-per-head ; Quantité maximale de MS qu'un individu peut consommer par jour
  daily-needs-DM                   ; Quantité maximale de MS que l'agent troupeau peut consommer par jour
  desired-DM-intake                ; Quantité de MS que le troupeau veut consommer en fonction de la qualité du fourrage
  daily-min-UF-needed-head         ; Quantité minimum d'Unité Fourragère à l'entretien d'un UBT
  daily-needs-UF                   ; Quantité minimum d'Unité Fourragère à l'entretien du troupeau
  daily-min-MAD-needed-head        ; Quantité minimum de Matière Azotée Digestible à l'entretien d'un UBT;
  daily-needs-MAD                  ; Quantité minimum de Matière Azotée Digestible à l'entretien du troupeau
  DM-ingested                      ; Quantité totale d'herbe ingérée (kg de MS)
  UF-ingested                      ; UF totales ingérées
  MAD-ingested                     ; MAD totales ingérées
  total-UF-ingested-from-trees     ; UF totales consommées sur les arbres
  total-MAD-ingested-from-trees    ; MAD totales consommées sur les arbres
  total-DM-ingested-from-trees     ; MS totales consommées sur les arbres
  daily-water-consumption          ; Consommation d'eau quotidienne
  preference-mono                  ; Préférence pour les Graminées

  ; Caractéristiques des foyers partagé aux troupeaux (Utilisé autant par les troupeaux que les foyers)
  known-space                      ; Tout l'espace connu par les individus
  close-known-space                ; Espace connu à moins d'une journée de déplacement d'un troupeau (6km)
  distant-known-space              ; Espace connu à plus d'une journée de déplacement d'un troupeau (6km)
  daily-trip                       ; Distance parcourue dans la journée
  is-transhumant                   ; Booléen qui définit si le foyer et ses troupeaux associés sont transhumants

  ; Déplacement du campement
  current-home-camp                ; Campement actuel
  current-home-patch               ; Patch du campement actuel
  original-home-camp               ; Campement permanent
  original-home-patch              ; Patch du campement permanent
  prev-home-patch                  ; Patch du campement de la veille
  is-in-temporary-camp             ; Booléen indiquant à l'agent s'il est dans son campement permanent ou sur un temporaire
  reforestation-plot               ; Parcelle de reforestation
]



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Agents Campements ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

camps-own [
  available-space                  ; Nombre de foyers associés
  is-temporary                     ; Booléen indiquant si le camp est temporaire
  wood-needs                       ; Besoins en bois
  wood-quantity                    ; Quantité de bois dans le campement
  foyers-hosted                    ; Nombre de foyers qui composent le campement
]



;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Agents Foyers ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

foyers-own [


  ; Gestion du troupeau
  cattle-herd                      ; Troupeau de bovins associé
  cattle-herd-size                 ; Taille du troupeau de bovins associé ("grand", "moyen", "petit")
  cattle-herd-count                ; Valeur numérique de la taille du troupeau en fonction du cattle-herd-size (aléatoire dans une intervalle)
  sheep-herd                       ; Troupeau de moutons associé
  sheep-herd-size                  ; Taille du troupeau d'ovins associé
  sheep-herd-count                 ; Valeur numérique de la taille du troupeau en fonction du sheep-herd-size (aléatoire dans une intervalle)
  shepherd-type                    ; Type de berger du foyer
  herder-type                      ; Caractéristique d'élevage du foyer (grand moyen petit)

  planned-days                     ; Nombre de jours de présence attendus
  days-present                     ; Nombre de jours de présence effective
  presence-satisfaction            ; Seuil de satisfaction de présence des transhumants dans la zone
  counted-satisfied?               ; Compteur du nombre de foyers satisfaits du temps de présence dans l'année


  ; Surveillance de l'état du troupeau
                          ; Bovins
  cattle-low-threshold-cc          ; Limite basse NEC
  cattle-low-threshold-pc          ; Limite basse MAD
  cattle-high-threshold-cc         ; Limite haute NEC
  cattle-high-threshold-pc         ; Limite haute MAD
                          ; Ovins
  sheep-low-threshold-cc           ; limite basse NEC
  sheep-low-threshold-pc           ; limite basse MAD
  sheep-high-threshold-cc          ; limite haute NEC
  sheep-high-threshold-pc          ; limite haute MAD


  ; Pratiques sylvicoles
  owned-trees-pop                  ; Population d'arbres associée

 ; Pratiques agriculture
  stock-residu                     ; residu de paille d'agriculture
  surface-agriculture              ; surface cultivée par le foyer

 ; Relations
  ;friends                          ; Amis de l'agent
  far-exploration-count            ; Compteur d'exploration au loin
  close-exploration-count          ; Compteur d'exploration proche
  cattleNEC-satisfaction           ; Evaluation de la satisfaction de l'éleveur sur la condition corporelle de son troupeau (Bovin)
  sheepNEC-satisfaction            ; Evaluation de la satisfaction de l'éleveur sur la condition corporelle de son troupeau (Ovin)
  transCattleNEC-satisfaction      ; [Transhumant] Evaluation de la satisfaction de l'éleveur sur la condition corporelle de son troupeau (Bovin)
  transSheepNEC-satisfaction       ; [Transhumant] Evaluation de la satisfaction de l'éleveur sur la condition corporelle de son troupeau (Ovin)
]



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Agents troupeau de petits ruminants ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

sheeps-own [
  foyer-owner                      ; Foyer du troupeau
  shepherd-type                    ; Caractéristique d'élevage du foyer (grand moyen petit)
  have-left                        ; Indique si le troupeau est parti vers le sud ou hors de la zone de l'UP
  leaves-eaten                     ; Quantité en kg de MS de feuilles consommées dans la journée
  fruits-eaten                     ; Quantité en kg de MS de fruits consommés dans la journée
  original-camp-known-space        ; Espace connu à moins d'une journée de déplacement du campement principal pour un troupeau
  mean-DM-ingested                 ; Moyenne de MS ingérée par individu dans le troupeau
  best-patches                     ; Collection des 3 meilleurs patches d'herbe de la journée
]



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Agents troupeau de bovins ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

cattles-own [
  foyer-owner                      ; Foyer du troupeau
  shepherd-type                    ; Caractéristique d'élevage du foyer (grand moyen petit)
  have-left                        ; Indique si le troupeau est parti vers le sud ou hors de la zone de l'UP
  leaves-eaten                     ; Quantité en kg de MS de feuilles consommées dans la journée
  fruits-eaten                     ; Quantité en kg de MS de fruits consommés dans la journée
  original-camp-known-space        ; Espace connu à moins d'une journée de déplacement du campement principal pour un troupeau
  mean-DM-ingested                 ; Moyenne de MS ingérée par individu dans le troupeau
  best-patches                     ; Collection des 3 meilleurs patches d'herbe de la journée
]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Agents populations d'arbres ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


tree-populations-own [

  ; Caractéristiques des populations d'arbres
  tree-type                        ; "nutritive", "less-nutritive", "fruit"
  tree-pop-age                     ; Âge de la population (1 à 8)
  population-size                  ; Nombre d'arbres dans cette population

  ; Relatif à la quantité de ressources
  current-fruit-stock              ; Stock de fruits
  current-leaf-stock               ; Stock de feuilles
  current-wood-stock               ; Stock de bois
  soil-current-fruit-stock         ; Stock de fruits au sol pour germination
  max-fruit-stock                  ; Stock maximal de fruit pour la population
  max-leaf-stock                   ; Stock maximal de fruit pour la population
  max-wood-stock                   ; Stock maximal de fruit pour la population
  wood-ratio                       ; Ratio entre le stock actuel et le stock maximal de bois
  max-fruit-nb                     ; Limite maximale du nombre de fruits par population (selon type, age)
  max-seed-nb                      ; Limite maximale du nombre de graines par population (selon type, age)
  fruit-nb                         ; Nombre de fruits
  seed-nb                          ; Nombre de graines
  leaves-percent-accessible        ; pourcentage de ressources en feuilles accessible (déterminé selon la taille, la phénologie spécifique à l'arbre et de la saison)
  fruits-percent-accessible        ; pourcentage de ressources en fruits accessible (déterminé selon la taille, la phénologie spécifique à l'arbre et de la saison)
  germinated-seed-nb               ; Nombre de graines passées par le tractus digestif des chèvres

  germination-rate                 ; Taux de germination
  young-regen-rate                 ; Taux de régénération des jeunes plants (jusqu'à 4 ans)
  dormance-needed                  ; Besoin des graines de passer par le tractus digestif des chèvres (simulé en laboratoire par le passage à l'acide)
  one-fruit-weight                 ; Poids d'un fruit
  one-seed-weight                  ; Poids d'une graine
  seed-nb-per-fruit                ; Nomrbe de graines par fruit
  ratio-consumable                 ; Part consommable dans un fruit


  ; Relatif à l'énergie et la valeur de matière azotée dans les feuilles et feuilles
  leaves-status                    ; Statut phénologique des feuilles (Chute, au sol, disponible)
  leaves-UF-per-kg-MS              ; Valeur fourragère (UF) par kg de MS des feuilles
  leaves-MAD-per-kg-MS             ; Matière Azotée Digestible (MAD) par kg de MS des feuilles
  fruits-status                    ; Statut phénologique des fruits (Chute, au sol, croissance, disponible)
  fruits-UF-per-kg-MS              ; Valeur fourragère (UF) par kg de MS des fruits
  fruits-MAD-per-kg-MS             ; Matière Azotée Digestible (MAD) par kg de MS des fruits
]

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;; Agents champs ;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

champs-own [
  foyer-owner                      ; Foyer du champ
  surface                          ; Surface du champ
]



to show-tree-populations-info      ; Procédure pour afficher les populations d'arbres
                                   ; Compter le nombre total de populations d'arbres
  let total-populations count tree-populations
  show (word "Nombre total de populations d'arbres : " total-populations)

  ; Vérifier si le nombre total est bien de 24
  ifelse total-populations = 24 [
    show "Le modèle a correctement 24 populations d'arbres."
  ] [
    show (word "ATTENTION : Le modèle n'a que " total-populations " populations d'arbres.")
  ]

  ; Parcourir chaque patch contenant des populations d'arbres
  ask patches with [any? tree-populations-here] [
    ; Compter le nombre de populations d'arbres sur ce patch
    let pop-count count tree-populations-here
    ; Afficher les informations pour ce patch
    show (word "Patch (" pxcor ", " pycor "): " pop-count " populations.")

    ; Itérer sur chaque population d'arbres et afficher les détails
    ask tree-populations-here with [current-leaf-stock < 0 or current-fruit-stock < 0] [
      show (word "  Type d'arbre: " tree-type
        ", Âge: " tree-pop-age
        ", Taille de la population: " population-size
        ", Stock max de bois" max-wood-stock
        ", Stock actuel de bois" current-wood-stock
        ", Stock max de fruits" max-fruit-stock
        ", Stock actuel de fruits" current-fruit-stock
        ", Stock max de feuilles" max-leaf-stock
        ", Stock actuel de feuilles" current-leaf-stock)
    ]
  ]
end




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Initialisation du monde et des agents ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to setup
  clear-all
  resize-world -11 11 -11 11                      ; Fixer les limites du monde à -11 à 11 en x et y
  set-patch-size 22                               ; Ajuster la taille des patches


  ; Chargement des valeurs environnementales
  load-environment "environment_vel.txt"
  set current-season "Nduungu"                    ; Initialiser à la première saison
  set last-season "none"                          ; Initialiser last-season
  set season-counter 0                            ; Compteur de saison initialisé à 0
  load-gis

  ;;; Chargement des variables temporelles
  load-climate-variables "year-type.txt"
  set year-index 0                                ; Indice de l'année en cours
  set year-counter 0                              ; Compteur de ticks dans l'année


  ; Chargement des valeurs spécifiques aux populations ligneuses
  load-tree-age-data "tree_info.csv"                ; valeurs pour les âges
  load-tree-nutrition-data "tree_nutrition.csv"     ; valeurs pour les qualités nutritives selon type d'arbre, saison, type de sol
  load-tree-germination-data "germination_rate.csv" ; valeurs pour les valeurs de régénération selon type d'arbre et type de sol

  ; Initialiser les durées des saisons
  update-year-type
  set-season-durations
  set-initial-values

  ; Lancer l'environnement et les agents
  setup-landscape                                 ; Créer les unités de paysage
  setup-water-patches                             ; Créer les mares
  setup-camps                                     ; Créer les campements

  setup-foyers                                    ; Créer les foyers
  setup-herds                                     ; Créer les troupeaux
  setup-trees                                     ; Créer les arbres
  setup-crop-lands                                ; Créer les champs
  ask camps with [not any? foyers-hosted] [die]
  setup-reforestation-plots                       ; Créer les parcelles de reforestation
  assign-camps-to-reforestation-plots             ; Assigner les campements aux parcelles (COGES)

  update-UF-and-MAD                               ; Mise à jour des valeurs nutritionnelles
  update-grass-quality                            ; Mise à jour de la qualité de l'herbe

  set max-grass max [K] of patches                ; pour visualisation
  set max-trees max [tree-cover] of patches


  ;Visualiser l'environnement
  reset-ticks
  calculStat                                      ; Calculs statistiques globaux pour exploration de modèle
  update-visualization
  ;display-labels

end

to load-gis
  set soilGrid gis:load-dataset "data/soils.shp"
  set treeGrid  gis:load-dataset "data/trees.shp"
  ;;fait le lien entre le système de coordonnée netlogo et celui des données
  gis:set-world-envelope gis:envelope-of soilGrid ;; par défaut

  ;show gis:property-names soil
  gis:apply-coverage soilGrid "NOM_PUULAR" soil-type
  gis:apply-coverage treeGrid "CT" tree-cover
end


to set-initial-values

  set listValueHerdeType []

  ; Définir les campements et l'espace disponible
  set initial-number-of-camps number-of-camps
  set space-camp-min 1
  set space-camp-max 100
  set space-camp-standard-deviation 20
  set space-camp-mean (space-camp-min + space-camp-max) / 2
  set reforestation-plots-nb reforestation-plots-number

  ; Définir les proportions des types d'éleveurs
  set pB proportion-big-herders / 100
  set pM proportion-medium-herders / 100
  set pS (100 - (proportion-big-herders + proportion-medium-herders)) / 100

  ; Définir la taille des troupeaux en UBT
  set total-UBT-created 0
  set UBT_grand 100
  set UBT_moyen 50
  set UBT_petit 10

  ; Ici, on calcule sum-UBT à partir du avg-UBT-per-camp (slider dans la
  set sum-UBT (initial-number-of-camps * avg-UBT-per-camp)

  ; Définir les seuil max d'herbe par type de sol kg MS / km²
  set K-Baldiol 120000
  set K-Caangol 300000 * 0.9
  set K-Sangre 80000 * 0.7
  set K-Seeno 200000 * 0.9

  ; Définir les seuils
  set seuil-bon-UF 0.6    ; Qualité de l'herbe - à ajuster selon les données du manuel de Boudet (1975)
  set seuil-moyen-UF 0.45
  set seuil-bon-MAD 53
  set seuil-moyen-MAD 25
  set radius-close 6

  ; Seuils de production des champs
  set production-residu-hectare-agriculture 1           ; kg de matière sèche par hectare

  ; calculs des MST temps
  ; Transhumants
  set percent-satisfied-year 0
  set mst-temps-passe-annee 0
  set serie-mst-temps-passe []
  ; Locaux
  set mst-cattle-left-simu 1
  set mst-sheep-left-simu 1
  set serie-mst-cattle-left []
  set serie-mst-sheep-left []

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Initialisation des patches avec mare ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup-water-patches
  let eligible-patches patches with [init-camp-pref >= 2]

  let ponds-4-months-count 0
  let ponds-5-months-count 0
  let ponds-6-months-count 0

  while [any? eligible-patches and (ponds-4-months-count < max-ponds-4-months or ponds-5-months-count < max-ponds-5-months or ponds-6-months-count < max-ponds-6-months)] [
    let water-patch one-of eligible-patches
    ask water-patch [
      set has-pond true
      set pcolor blue
      ifelse ponds-4-months-count < max-ponds-4-months [
        set water-stock 1000
        set ponds-4-months-count ponds-4-months-count + 1
      ] [
        ifelse ponds-5-months-count < max-ponds-5-months [
          set water-stock 2000
          set ponds-5-months-count ponds-5-months-count + 1
        ] [
          set water-stock 3000
          set ponds-6-months-count ponds-6-months-count + 1
        ]
      ]
    ]
  ]
  set eligible-patches patches with [init-camp-pref >= 2 and not any? patches in-radius 5 with [has-pond]]

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Visualisation ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to update-visualization
  if visualization-mode = "soil-type" [
    ask patches [
      if soil-type = "Baldiol" [set pcolor green - 1.2]
      if soil-type = "Caangol" [set pcolor grey + 3]
      if soil-type = "Sangre" [set pcolor red]
      if soil-type = "Seeno" [set pcolor yellow]
      if soil-type = "" [set pcolor grey]
    ]
  ]
  if visualization-mode = "tree-cover" [
    ask patches [
      set pcolor scale-color green tree-cover max-trees 0
    ]
  ]
  if visualization-mode = "grass-cover" [
    ask patches [
      set pcolor scale-color yellow current-grass max-grass 0
    ]
  ]
  if visualization-mode = "grass-quality" [
    display-grass-quality
  ]

  if visualization-mode = "known-space" [
    display-knownSpace
  ]
  ask patches [
    if is-fenced = true [set pcolor orange]]

end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Stepping ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;
;;; Step général ;;;
;;;;;;;;;;;;;;;;;;;;

to go
;    profiler:reset
;   profiler:start



  ; Mise à jour du modèle général et temporalité
  update-season



  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Mises à jour saisonnières ;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ; Mise à jour saisonnière
  if current-season != last-season [
    generate-transhumance
    update-UF-and-MAD                             ; Mettre à jour les valeurs de MAD et UF pour le tapis herbacé
    update-tree-nutritional-values                ; Mettre à jour les valeurs de MAD et UF pour les arbres
    set last-season current-season                ; Permet au counter d'identifier quand la saison change
    update-tree-visualisation
  ]




  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Mises à jour annuelles ;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  if year-counter >= total-ticks-per-year [

    ask patches with [current-grass < 100] [
      set current-monocot-grass 50
      set current-dicot-grass 50
      set current-grass current-monocot-grass + current-dicot-grass
    ]


    ; Scheduler
    set year-counter 0                            ; Au premier jour de chaque nouvelle année, remet le compteur d'année à 0
    update-year-type                              ; Au premier jour de chaque nouvelle année, redéfinit si l'année sera bonne, moyenne, mauvaise
    set-season-durations                          ; Au premier jour de chaque nouvelle année et en fonction de l'année, redéfinit les durées pour chacune des siaosn pour l'année en cours

    ; Environnement
    update-tree-age                               ; Au premier jour de chaque nouvelle année, fait grandir les populations d'arbres d'un an
    renew-tree-population                         ; Au premier jour de chaque nouvelle année, crée une nouvelle population d'arbres d'un an
    assign-grass-proportions                      ; Au premier jour de chaque nouvelle année, relance la génération aléatoire des proportions en monocotylédone et dicotylédone



    ; Evaluation MST transhumants
    if influx-Ceedu > 0 or influx-Ceetcelde > 0 or influx-Nduungu > 0 [
    evaluate-MST-Time
    ]
    evaluate-mst-have-left

    ;; remettre à zéro pour l’année suivante
    set mst-temps-passe-annee 0

] ; fin renouvellement annuel

  if year-counter = retard-jours [
    call-back-herds                               ; Retour des troupeaux et mise à jour de l'espace connu
  ]

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Mises à jour quotidiennes ;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ; Mise à jour quotidienne des ressources
  grow-grass
  update-grass-quality                            ; Indiquer la qualité de l'herbe
  grow-tree-resources

  if mean [current-leaf-stock] of tree-populations < 0 [
    show-tree-populations-info]

  ;--------------------;
  ; Actions des agents ;
  ;--------------------;

  ; Troupeau
  ask cattles with [have-left = false] [
    move
    eat
    update-corporal-conditions head UBT-size UF-ingested MAD-ingested daily-needs-UF daily-needs-MAD max-daily-DM-ingestible-per-head preference-mono
    trample-trees
  ]
  ask cattles with [have-left = true] [
    set ticks-left-year ticks-left-year + 1
  ]

  ask sheeps with [have-left = false] [
    move
    eat
    update-corporal-conditions head UBT-size UF-ingested MAD-ingested daily-needs-UF daily-needs-MAD max-daily-DM-ingestible-per-head preference-mono
    trample-trees
  ]
  ask sheeps with [have-left = true] [
    set ticks-left-year ticks-left-year + 1
  ]


  ; Foyers
  ask foyers [
    join-herd
    ; Choix stratégiques pastoraux du chef de ménage
    if cattle-herd != nobody and [have-left] of cattle-herd = false [
      choose-strategy-for-cattles]
    if sheep-herd != nobody and [have-left] of sheep-herd = false [
      choose-strategy-for-sheeps]
  ]

  ; Mise à jour quotidienne de l'espace connu (tous agents non environnement)
  update-known-space

  ;-----------------------------------------;
  ; Evaluations quotidiennes et indicateurs ;
  ;-----------------------------------------;

  ; Evaluation des transhumants sur leur satisfaction de temps de présence effectif
  evaluate-presence-satisfaction-for-transhumants

  ; Mise à jour des valeurs Stats pour visualisation
  calculStat

  ; Visuel
  update-visualization
  update-plot

  tick


;    profiler:stop
;    print profiler:report
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Mise à jour des types d'années ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to update-year-type
  ; Vérifier qu'on ne dépasse pas la liste
  set year-index year-index + 1
  if year-index >= 20 [
    set year-index 1 ]
  ; Obtenir le type d'année
  set current-year-type item year-index year-types
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Evaluation de la satisfaction en temps de présence par les transhumants ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



  ;------------------------;
  ; Evaluation quotidienne ;
  ;------------------------;

to evaluate-presence-satisfaction-for-transhumants
  ;; --------- a. calcul de la satisfaction annuelle ----------
  ask foyers with [is-transhumant = true] [
    set days-present days-present + 1
    set presence-satisfaction (days-present / planned-days) * 100
    if ( counted-satisfied? = false) and (presence-satisfaction >= min-time-ratio) [
      set nb-satisfied-year nb-satisfied-year + 1
      set counted-satisfied? true
    ]
  ]
end


  ;---------------------;
  ; Evaluation annuelle ;
  ;---------------------;

to evaluate-MST-Time
  ;; a. on stocke la valeur annuelle

  let total-influx (influx-Ceedu + influx-Ceetcelde + influx-Nduungu)
  set percent-satisfied-year nb-satisfied-year / total-influx

  set serie-mst-temps-passe lput percent-satisfied-year serie-mst-temps-passe

  ; Pour l'indicateur SIMU
  set mean-mst-temps-passe sum serie-mst-temps-passe

  set mst-temps-passe-simu mean-mst-temps-passe / year-index
  ;; c. on remet à zéro pour la nouvelle année
  set nb-satisfied-year 0

end




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Evaluation du MST Have-left ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;---------------------;
  ; Evaluation annuelle ;
  ;---------------------;

; appelez‑la exactement où vous appelez déjà evaluate-MST-Time
to evaluate-MST-have-left
  ;; moyenne du nb de ticks « dehors » par troupeau
  let cattle-avg-left mean [ticks-left-year] of cattles
  let sheep-avg-left mean [ticks-left-year] of sheeps

  ;; normalisation 0‑1  → 1 = jamais dehors, 0 = tout le temps dehors
  ifelse total-ticks-per-year > 0 [
    set mst-cattle-left 1 - (cattle-avg-left / total-ticks-per-year)
  ] [
    set mst-cattle-left mst-cattle-left         ;; par sûreté si durée‑année = 0
  ]

  ifelse total-ticks-per-year > 0 [
    set mst-sheep-left 1 - (sheep-avg-left / total-ticks-per-year)
  ] [
    set mst-sheep-left mst-sheep-left        ;; par sûreté si durée‑année = 0
  ]

  ; Pour l'indicateur SIMU
  set serie-mst-cattle-left lput mst-cattle-left serie-mst-cattle-left
  set serie-mst-sheep-left lput mst-sheep-left serie-mst-sheep-left

  set mean-mst-cattle-left sum serie-mst-cattle-left
  set mean-mst-sheep-left sum serie-mst-sheep-left

  set mst-cattle-left-simu mean-mst-cattle-left / year-index
  set mst-sheep-left-simu mean-mst-sheep-left / year-index

end




;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Retour des troupeaux ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to call-back-herds
  ;; Retour des troupeaux de bovins
  ask cattles with [have-left = true] [
    show-turtle
    set live-weight initial-live-weight  ; Réinitialiser le poids vif
    set corporal-condition 5             ; NEC maximum
    set have-left false
    set ticks-left-year 0
  ]

  ;; Retour des troupeaux de moutons
  ask sheeps with [have-left = true] [
    show-turtle
    set live-weight initial-live-weight  ; Réinitialiser le poids vif
    set corporal-condition 5             ; NEC maximum
    set have-left false
    set ticks-left-year 0
  ]
end




;;;;;;;;;;;;;;;;;;;;;;;;
;;; MAJ espace connu ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

to update-known-space

  if year-counter <= 0 [
    renew-known-space
  ]
  ;; --- Foyers ---
  ask foyers [
    let new-space nobody
    if cattle-herd != nobody [
      set new-space (patch-set new-space (([known-space] of cattle-herd) with [not member? self [known-space] of myself]))
    ]
    if sheep-herd != nobody [
      set new-space (patch-set new-space (([known-space] of sheep-herd) with [not member? self [known-space] of myself]))
    ]
    ;; Nouveaux patches = ceux que le foyer n’a pas déjà
    if any? new-space [
      set known-space (patch-set known-space new-space)
    ]
    set close-known-space known-space with [distance myself <= radius-close]
    set distant-known-space known-space who-are-not close-known-space
  ]

  ;; --- Troupeaux ---
  update-herd-known-space cattles
  update-herd-known-space sheeps
end

to update-herd-known-space [herd]
  ask herd [
    let home-patch current-home-patch
    let new-space nobody
    set new-space ([known-space] of foyer-owner) with [not member? self [known-space] of myself]
    ;; Nouveaux patches = ceux que le foyer n’a pas déjà
    if any? new-space [
      set known-space (patch-set known-space new-space)
    ]
    if is-transhumant = false [
      ifelse current-home-patch != prev-home-patch [
        let original-camp-home-patch original-home-patch
        set original-camp-known-space known-space with [distance original-camp-home-patch <= radius-close]
      ] [
        set original-camp-known-space known-space with [distance home-patch <= radius-close]
      ]
    ]
    set close-known-space known-space with [distance home-patch <= radius-close]
    set distant-known-space known-space who-are-not close-known-space

    set prev-home-patch current-home-patch
  ]
end



to renew-known-space

  ; Agents (Rappel des agents et remise à jour de l'espace connu)
  ask foyers [
    set far-exploration-count 0                 ; Compteur d'exploration au loin
    set known-space patches in-radius 3         ; Remise à 0
  ]
  ask cattles [set known-space [known-space] of foyer-owner]
  ask sheeps [set known-space [known-space] of foyer-owner]

end


;;;;;;;;;;;;;;;;;;;;;;;;
;;; Gestion de l'eau ;;;
;;;;;;;;;;;;;;;;;;;;;;;;

to manage-water-points
  ask patches with [water-point = true] [
    set water-point false
  ]
  ask n-of 5 patches [
    set water-point true
  ]
end





;;;;;;;;;;;;;
;; Visuels ;;
;;;;;;;;;;;;;


; Qualité de l'herbe
to display-grass-quality

  ask patches [
    let max-q 1
    if grass-quality = "good" [
      ; set plabel grass-quality
      set pcolor scale-color green q max-q 0
    ]
    if grass-quality = "average" [
      ; set plabel grass-quality
      set pcolor scale-color green q max-q 0
    ]
    if grass-quality = "poor" [
      ; set plabel grass-quality
      set pcolor scale-color green q max-q 0
    ]
  ]
end


; Espace connu
to display-knownSpace
  ask patches [set pcolor white]
  ask foyers [
    ask known-space [set pcolor [who] of myself]
  ]
  ask cattles [
    ask known-space [set pcolor [who] of myself]
  ]
  ask sheeps [
    ask known-space [set pcolor [who] of myself]
  ]
end
to color-grass  ;; patch procedure
  set pcolor scale-color yellow current-grass max-grass 0
end

;to display-labels
 ; ask turtles [set label ""]
  ;ask turtles [set label head]

;end


; Plot Nombre d'éleveurs par taille
to update-plot
  let _typeF (list "petit" "moyen" "grand")
  let _listString  [herder-type] of foyers
  set listValueHerdeType (map [x ->
    ifelse-value (x = "petit") [1]
    [ifelse-value (x = "moyen") [2]
      [ifelse-value (x = "grand") [3]
        [0]]]] _listString)

end

; Visualisation des arbres
to update-tree-visualisation
  ;; Supprimer les anciennes icônes
  ask mature-tree-nutritive-pops [ die ]
  ask mature-tree-less-nutritive-pops [ die ]
  ask mature-tree-fruity-pops [ die ]
  ;; Créer de nouvelles icônes pour les arbres matures
  ask patches [
    let mature-tree-populations tree-populations-here with [tree-pop-age >= 8]
    let mature-tree-nutritive-populations tree-populations-here with [(tree-pop-age >= 8) and (tree-type = "nutritive")]
    if any? mature-tree-nutritive-populations [
      let total-nutritive-population sum [population-size] of mature-tree-nutritive-populations
      sprout-mature-tree-nutritive-pops 1 [
        set shape "tree"
        set color green
        set size calculate-tree-icon-size total-nutritive-population
        set xcor xcor + (random-float 0.9 - 0.45)
        set ycor ycor + (random-float 0.9 - 0.45)
      ]
    ]
    let mature-tree-less-nutritive-populations tree-populations-here with [(tree-pop-age >= 8) and (tree-type = "lessNutritive")]
    if any? mature-tree-less-nutritive-populations [
      let total-less-nutritive-population sum [population-size] of mature-tree-less-nutritive-populations
      sprout-mature-tree-less-nutritive-pops 1 [
        set shape "tree-less"
        set color green
        set size calculate-tree-icon-size total-less-nutritive-population
        set xcor xcor + (random-float 0.9 - 0.45)
        set ycor ycor + (random-float 0.9 - 0.45)
      ]
    ]
    let mature-tree-fruity-populations tree-populations-here with [(tree-pop-age >= 8) and (tree-type = "fruity")]
    if any? mature-tree-fruity-populations [
      let total-fruity-population sum [population-size] of mature-tree-fruity-populations
      sprout-mature-tree-fruity-pops 1 [
        set shape "tree-fruit"
        set color green
        set size calculate-tree-icon-size total-fruity-population
        set xcor xcor + (random-float 0.9 - 0.45)
        set ycor ycor + (random-float 0.9 - 0.45)
      ]
    ]
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
210
40
724
555
-1
-1
22.0
1
1
1
1
1
0
0
0
1
-11
11
-11
11
1
1
1
ticks
30.0

BUTTON
60
65
155
98
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
80
180
135
213
GO 10
while [ticks < 3650] [go]\n
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

MONITOR
750
60
845
105
Total Foyers
totalFoyers
17
1
11

MONITOR
750
160
845
205
Total Vaches
totalCattles
17
1
11

MONITOR
750
110
845
155
Total Moutons
totalSheeps
17
1
11

SLIDER
2425
55
2590
88
max-ponds-4-months
max-ponds-4-months
0
10
4.0
1
1
NIL
HORIZONTAL

SLIDER
2426
93
2586
126
max-ponds-5-months
max-ponds-5-months
0
10
7.0
1
1
NIL
HORIZONTAL

SLIDER
2426
132
2586
165
max-ponds-6-months
max-ponds-6-months
0
10
6.0
1
1
NIL
HORIZONTAL

MONITOR
2429
169
2564
214
NIL
waterStock
17
1
11

CHOOSER
40
420
170
465
visualization-mode
visualization-mode
"soil-type" "tree-cover" "grass-cover" "grass-quality" "known-space"
2

BUTTON
40
380
170
415
Changer Visu
  update-visualization
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
995
60
1065
105
Saison
current-season
17
1
11

MONITOR
920
60
997
105
Type
current-year-type
17
1
11

SLIDER
750
490
885
523
good-shepherd-percentage
good-shepherd-percentage
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
750
415
885
448
proportion-big-herders
proportion-big-herders
0
100
48.0
1
1
NIL
HORIZONTAL

SLIDER
750
450
885
483
proportion-medium-herders
proportion-medium-herders
0
100
0.0
1
1
NIL
HORIZONTAL

PLOT
1620
660
1955
810
Gain poids vif
NIL
NIL
0.0
10.0
-1.0
1.0
true
true
"" ""
PENS
"Vaches" 1.0 0 -16777216 true "" "plot cattlesWeightGain"
"Moutons" 1.0 0 -5516827 true "" "plot sheepsWeightGain"
"0" 1.0 0 -5298144 true "" "plot 0"

PLOT
1955
365
2260
510
Parti en demi transhumance
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"sheeps" 1.0 0 -5516827 true "" "plot sheepsTempCamp"
"cattles" 1.0 0 -16449023 true "" "plot cattlesTempCamp"

PLOT
1955
510
2260
660
partis hors de la zone
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -5516827 true "" "plot sheepsHaveLeft"
"pen-1" 1.0 0 -16777216 true "" "plot cattlesHaveLeft"

PLOT
1620
365
1955
510
Poids vif par tête - Vaches
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Moyenne" 1.0 0 -16777216 true "" "plot meanCattlesLiveWeight"
"Max" 1.0 0 -2674135 true "" "plot maxCattlesLiveWeight"
"Min" 1.0 0 -13791810 true "" "plot minCattlesLiveWeight"

PLOT
1960
660
2330
810
Espace connu + de 5 km ( moyenne locaux)
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Moutons" 1.0 0 -11221820 true "" "plot meanDistantKnownSpaceSheeps"
"Vaches" 1.0 0 -16777216 true "" "plot meanDistantKnownSpaceCattles"

PLOT
870
110
1065
280
Types d'éleveurs
   petit moyen grand
NIL
0.0
10.0
0.0
10.0
true
false
"set-plot-x-range 0 5\nset-plot-y-range 0 100\nset-histogram-num-bars 5" ""
PENS
"" 1.0 1 -16777216 true "" "histogram listValueHerdeType"

PLOT
1620
510
1955
660
Poids Vif par tête - Moutons
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Moyenne" 1.0 0 -16777216 true "" "plot meanSheepsLiveWeight"
"Max" 1.0 0 -2674135 true "" "plot maxSheepsLiveWeight"
"Min" 1.0 0 -13791810 true "" "plot minSheepsLiveWeight"

MONITOR
870
60
920
105
Année
year-index
17
1
11

PLOT
1480
90
1755
265
Biomasse (Kg MS) par hectare
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -13840069 true "" "plot meanGrass / 100"

PLOT
1120
365
1570
511
Consommation ressources arbres
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"fruits par les vaches" 1.0 0 -2674135 true "" "plot meanFruitsConsumedCattle"
"feuilles par les vaches" 1.0 0 -12087248 true "" "plot meanLeavesConsumedCattle"
"fruits par les moutons" 1.0 0 -612749 true "" "plot meanFruitsConsumedSheep"
"feuilles par les moutons" 1.0 0 -5509967 true "" "plot meanLeavesConsumedSheep"

SLIDER
240
655
350
688
SheepNECSatifactionIndex
SheepNECSatifactionIndex
0
5
3.0
1
1
NIL
HORIZONTAL

PLOT
1620
960
1955
1110
MST NEC
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"Moutons" 1.0 0 -13791810 true "" "plot  MSTSheep-NEC"
"Vaches" 1.0 0 -16777216 true "" "plot  MSTCattle-NEC"

SLIDER
240
615
350
648
CattleNECSatifactionIndex
CattleNECSatifactionIndex
0
5
3.0
1
1
NIL
HORIZONTAL

SLIDER
750
340
885
373
number-of-camps
number-of-camps
1
150
92.0
1
1
NIL
HORIZONTAL

PLOT
1620
810
1955
960
NEC moyenne
NIL
NIL
0.0
10.0
0.0
5.0
true
true
"" ""
PENS
"Vaches" 1.0 0 -16777216 true "" "plot meanCattlesNEC"
"Moutons" 1.0 0 -8275240 true "" "plot meanSheepsNEC"
"satis" 1.0 0 -2674135 true "" "plot SheepNECSatifactionIndex"

PLOT
1120
685
1470
831
Nombre moyen d'arbres par Hectare
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Caangol" 1.0 0 -16777216 true "" "plot meanTreesInCaangol"
"Baldiol" 1.0 0 -7500403 true "" "plot meanTreesInBaldiol"
"Seeno" 1.0 0 -2674135 true "" "plot meanTreesInSeeno"
"Sangre" 1.0 0 -955883 true "" "plot meanTreesInSangre"

SLIDER
240
805
350
838
SatisfactionMeanTreesInCaangol
SatisfactionMeanTreesInCaangol
50
150
101.0
1
1
NIL
HORIZONTAL

SLIDER
240
765
350
798
SatisfactionMeanTreesInSeeno
SatisfactionMeanTreesInSeeno
12
50
20.0
1
1
NIL
HORIZONTAL

SLIDER
240
845
350
878
SatisfactionMeanTreesInBaldiol
SatisfactionMeanTreesInBaldiol
0
100
40.0
1
1
NIL
HORIZONTAL

SLIDER
240
890
350
923
SatisfactionMeanTreesInSangre
SatisfactionMeanTreesInSangre
0
100
50.0
1
1
NIL
HORIZONTAL

PLOT
1120
830
1470
975
MST-tree par type de sol
NIL
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"Seeno" 1.0 0 -2674135 true "" "plot MST-Seeno"
"Baldiol" 1.0 0 -7500403 true "" "plot MST-Baldiol"
"Sangre" 1.0 0 -955883 true "" "plot MST-Sangre"
"Caangol" 1.0 0 -16777216 true "" "plot MST-Caangol"

BUTTON
80
140
135
173
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
40
470
170
503
Cacher arbres
ask tree-populations-here [hide-turtle]
NIL
1
T
PATCH
NIL
NIL
NIL
NIL
1

SLIDER
750
375
885
408
avg-UBT-per-camp
avg-UBT-per-camp
10
100
60.0
5
1
NIL
HORIZONTAL

MONITOR
750
210
845
255
Total UBT
sum-UBT
17
1
11

SLIDER
240
950
350
983
treshold-tree-satisfaction
treshold-tree-satisfaction
0.1
1
0.6
0.1
1
NIL
HORIZONTAL

PLOT
1120
975
1405
1121
Arbres tués (piétinement et coupe)
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot trees-killed"

TEXTBOX
1080
55
1105
1276
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
20
64.0
1

TEXTBOX
1690
55
1780
85
Sorties
25
55.0
1

TEXTBOX
1215
270
1415
296
Indicateurs Arbres
22
64.0
1

TEXTBOX
1585
270
1600
1280
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
20
64.0
1

TEXTBOX
2355
55
2380
1280
||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
20
64.0
1

TEXTBOX
1860
270
2095
295
Indicateurs Elevage
22
64.0
1

TEXTBOX
1085
1240
2375
1280
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
20
64.0
1

TEXTBOX
1226
974
1261
1119
i^\n |\n |\n 
1
0.0
1

TEXTBOX
0
335
18
545
||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
11
0.0
1

TEXTBOX
20
330
185
381
-----------------------------------------------------------VISU---------------------------------------------------------
11
0.0
1

TEXTBOX
20
510
185
550
---------------------------------------------------------------------------------------------------------------------------
11
0.0
1

TEXTBOX
190
335
208
550
||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
11
0.0
1

PLOT
1120
510
1570
686
Moyennes ressources arbres
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"moyenne feuilles kg" 1.0 0 -13840069 true "" "plot mean [current-leaf-stock] of tree-populations with [tree-pop-age >= 4]"
"moyenne fruits des arbres" 1.0 0 -5298144 true "" "plot mean [current-fruit-stock] of tree-populations with [tree-pop-age >= 4]"
"moyenne fruits au sol" 1.0 0 -6459832 true "" "plot mean [soil-current-fruit-stock] of tree-populations with [tree-pop-age >= 4]"

SLIDER
15
710
185
743
decreasing-factor
decreasing-factor
0
100
20.0
1
1
NIL
HORIZONTAL

BUTTON
80
105
135
138
NIL
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
15
745
185
778
FUtility
FUtility
0
1
0.4
0.1
1
NIL
HORIZONTAL

TEXTBOX
1085
45
2375
91
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
20
64.0
1

TEXTBOX
1085
260
2375
305
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
20
64.0
1

TEXTBOX
165
40
180
235
|||||||||||||||||||||||||||||||||||||||
12
14.0
1

TEXTBOX
35
40
50
235
||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--\n
12
14.0
1

TEXTBOX
35
210
180
246
------------------------------------------------------------------------
12
14.0
1

TEXTBOX
35
35
180
61
------------------------------------------------------------------------
12
14.0
1

TEXTBOX
70
43
145
61
Lancement
12
14.0
1

TEXTBOX
730
40
745
280
||||||||||||||||||||||||||||||||||||||||||||||||
12
0.0
1

TEXTBOX
730
260
865
286
------------------------------------------------------------------
10
0.0
1

TEXTBOX
850
40
865
280
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||-
12
0.0
1

TEXTBOX
730
35
865
60
------------------------------------------------------------------
10
0.0
1

TEXTBOX
775
40
825
58
Entrées
12
0.0
1

TEXTBOX
890
350
975
368
Campements
12
0.0
1

TEXTBOX
890
385
980
403
UBT par camp
12
0.0
1

TEXTBOX
890
435
1005
470
Proportions taille d'éleveurs
12
0.0
1

TEXTBOX
890
500
1050
520
Proportion bons bergers
12
0.0
1

TEXTBOX
760
320
910
338
Variables d'entrées
12
0.0
1

TEXTBOX
730
315
1070
345
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
10
0.0
1

TEXTBOX
730
320
745
815
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
12
0.0
1

TEXTBOX
730
405
1070
423
------------------------------------------------------------------------------------
10
0.0
1

TEXTBOX
730
480
1080
498
------------------------------------------------------------------------------------
10
0.0
1

TEXTBOX
730
795
1070
820
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
10
0.0
1

TEXTBOX
1055
320
1070
815
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
12
0.0
1

TEXTBOX
210
555
235
1085
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
20
0.0
1

TEXTBOX
210
545
725
616
-------------------------------------------------------------------------. -------------------------------------------------------------------------
20
0.0
1

TEXTBOX
295
565
680
601
Critères de satisfaction sur l'état de santé du bétail sur la base de la Note d'Etat Corporel (NEC)
15
0.0
1

TEXTBOX
360
670
420
688
Moutons
12
0.0
1

TEXTBOX
360
625
415
643
Vaches\n
12
0.0
1

TEXTBOX
425
610
700
700
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
5
0.0
1

TEXTBOX
700
555
725
1085
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||-
20
0.0
1

TEXTBOX
255
710
725
760
Critères de satistaction du nombre d'arbres (+ de 4 ans)\npar hectare et par type de sol
15
0.0
1

TEXTBOX
360
810
650
836
Savane arborée sur sol limoneux (Caangol)
12
0.0
1

TEXTBOX
360
890
700
920
Savane arbustive à arborée sur sol argileux, cuirassé (Sangre)
12
0.0
1

TEXTBOX
360
850
660
880
Savane arbustive à arborée sur sol sablonneux (Baldiol)
12
0.0
1

TEXTBOX
360
770
650
796
Steppe arbustive sur sol sablonneux (Seeno)
12
0.0
1

TEXTBOX
210
690
725
760
-------------------------------------------------------------------------. -------------------------------------------------------------------------
20
0.0
1

TEXTBOX
360
955
690
990
Proportion de surface par type de sol pour laquelle le critère de satisfaction des arbres doit être atteint
12
0.0
1

TEXTBOX
210
930
725
948
-------------------------------------------------------------------------
20
0.0
1

TEXTBOX
210
1045
725
1095
--------------------------------------------------------------------------------------------------------------------------------------------------
20
0.0
1

PLOT
1135
90
1480
265
Biomasse moyenne consommé (par les locaux)
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Moutons" 1.0 0 -8990512 true "" "plot meanSheepsGrassEaten"
"Vaches" 1.0 0 -16777216 true "" "plot meanCattlesGrassEaten"

PLOT
1120
1120
1405
1240
Population d'arbres d'un an
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot sum [population-size] of tree-populations  with [tree-pop-age = 1]"

SLIDER
750
540
885
573
reforestation-plots-number
reforestation-plots-number
0
20
5.0
1
1
NIL
HORIZONTAL

SLIDER
750
575
885
608
COGES-camps
COGES-camps
2
10
2.0
1
1
NIL
HORIZONTAL

TEXTBOX
730
525
1070
543
------------------------------------------------------------------------------------
10
0.0
1

TEXTBOX
890
550
1055
568
Parcelles de reforestation
12
0.0
1

TEXTBOX
890
575
1050
605
Nombre de campements par COGES
12
0.0
1

SLIDER
750
665
885
698
influx-Ceedu
influx-Ceedu
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
750
700
885
733
influx-Nduungu
influx-Nduungu
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
750
630
885
663
influx-Ceetcelde
influx-Ceetcelde
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
240
1005
350
1038
min-time-ratio
min-time-ratio
0
100
30.0
1
1
NIL
HORIZONTAL

PLOT
1960
1110
2260
1240
MST Temps passé
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot percent-satisfied-year"

PLOT
1960
960
2260
1110
MST NEC Transhumants
NIL
NIL
0.0
1.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -12345184 true "" "plot MSTTransSheep-NEC"
"pen-1" 1.0 0 -16777216 true "" "plot MSTTransCattle-NEC"

PLOT
1960
810
2260
960
NEC Moyenne Transhumants
NIL
NIL
0.0
5.0
0.0
5.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot meanTransCattlesNEC"
"pen-1" 1.0 0 -8990512 true "" "plot meanTransSheepsNEC"
"pen-2" 1.0 0 -2674135 true "" "plot CattleNECSatifactionIndex"

TEXTBOX
730
615
1070
633
------------------------------------------------------------------------------------
12
0.0
1

TEXTBOX
890
670
1040
700
Nb de transhumants arrivés en SSF
12
0.0
1

TEXTBOX
890
705
1040
735
Nb de transhumants arrivés en SSC
12
0.0
1

TEXTBOX
890
635
1020
665
Nb de transhumants arrivés en SP
12
0.0
1

SLIDER
750
755
885
788
good-shepherd-trans-percentage
good-shepherd-trans-percentage
0
100
100.0
1
1
NIL
HORIZONTAL

TEXTBOX
730
735
1080
753
------------------------------------------------------------------------------------
12
0.0
1

TEXTBOX
890
750
1040
805
Proportion de bons bergers parmi les éleveurs transhumants
12
0.0
1

TEXTBOX
210
976
745
994
-------------------------------------------------------------------------
20
0.0
1

TEXTBOX
360
1000
695
1045
Proportion de temps minimal de présence satisfaisant pour les transhumant par rapport à la durée prévue initialement
12
0.0
1

PLOT
1620
1110
1885
1230
Transhumants satisfait sur total Trans par an
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mst-temps-passe-simu"

PLOT
735
830
1070
1110
Populations par ages
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"7 Y" 1.0 0 -7500403 true "" "plot meanTrees7yearsByPatch"
"6 Y" 1.0 0 -2674135 true "" "plot meanTrees6yearsByPatch"
"5 Y" 1.0 0 -955883 true "" "plot meanTrees5yearsByPatch"
"4 Y" 1.0 0 -6459832 true "" "plot meanTrees4yearsByPatch"
"3 Y" 1.0 0 -1184463 true "" "plot meanTrees3yearsByPatch"
"2 Y" 1.0 0 -10899396 true "" "plot meanTrees2yearsByPatch"
"1 Y" 1.0 0 -13840069 true "" "plot meanTrees1yearsByPatch"
"pen-8" 1.0 0 -14835848 true "" ""
"pen-9" 1.0 0 -11221820 true "" ""

TEXTBOX
5
656
200
711
----------------------------------------------------------------SENSIBILITE--------------------------------------------------------------
12
0.0
1

TEXTBOX
5
660
20
825
|||||||||||||||||||||||||||||||||
12
0.0
1

TEXTBOX
185
660
200
825
|||||||||||||||||||||||||||||||||
12
0.0
1

TEXTBOX
5
785
200
826
------------------------------------------------------------------------------------------------------------------------------------------------
12
0.0
1

PLOT
755
1125
955
1275
plot 1
NIL
NIL
0.0
1.0
0.0
1.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mst-cattle-left-simu"
"pen-1" 1.0 0 -2674135 true "" "plot mst-sheep-left-simu"

SLIDER
15
260
187
293
retard-jours
retard-jours
0
100
0.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

lander
false
0
Polygon -7500403 true true 45 75 150 30 255 75 285 225 240 225 240 195 210 195 210 225 165 225 165 195 135 195 135 225 90 225 90 195 60 195 60 225 15 225 45 75

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

tree-fruit
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152
Circle -2674135 true false 135 150 30
Circle -2674135 true false 195 165 30
Circle -2674135 true false 75 120 30
Circle -2674135 true false 60 180 30
Circle -2674135 true false 90 45 30
Circle -2674135 true false 165 45 30
Circle -2674135 true false 195 105 30
Circle -2674135 true false 135 90 30

tree-less
false
0
Circle -7500403 true true 90 135 60
Circle -7500403 true true 165 105 60
Circle -7500403 true true 135 120 60
Circle -7500403 true true 225 120 60
Circle -7500403 true true 25 105 70
Circle -7500403 true true 125 55 80
Rectangle -6459832 true false 135 165 165 300
Circle -7500403 true true 118 44 32
Rectangle -6459832 true false 165 165 255 180
Rectangle -6459832 true false 60 165 135 180
Rectangle -6459832 true false 60 105 75 165
Rectangle -6459832 true false 15 150 60 165
Rectangle -6459832 true false 120 105 135 165
Rectangle -6459832 true false 240 105 255 165
Rectangle -6459832 true false 240 165 285 180
Rectangle -6459832 true false 180 105 195 165
Rectangle -6459832 true false 240 105 300 120
Rectangle -6459832 true false 180 90 225 105
Circle -7500403 true true 210 90 30
Circle -7500403 true true 165 60 60
Circle -7500403 true true 135 30 60
Circle -7500403 true true 90 60 60
Circle -7500403 true true 60 90 60
Circle -7500403 true true 35 70 50
Circle -7500403 true true 15 90 30
Circle -7500403 true true 0 135 30
Circle -7500403 true true 225 90 60
Circle -7500403 true true 15 120 30
Circle -7500403 true true 210 105 30
Circle -7500403 true true 210 150 30
Circle -7500403 true true 270 105 30
Circle -7500403 true true 270 150 30
Circle -7500403 true true 90 120 60

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="oat_pierre" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <exitCondition>ticks = 3650</exitCondition>
    <metric>totalFoyers</metric>
    <metric>totalSheeps</metric>
    <metric>totalCattles</metric>
    <metric>waterStock</metric>
    <metric>sheepsTempCamp</metric>
    <metric>cattlesTempCamp</metric>
    <metric>sheepsHaveLeft</metric>
    <metric>cattlesHaveLeft</metric>
    <metric>sheepsWeightGain</metric>
    <metric>cattlesWeightGain</metric>
    <metric>meanSheepsLiveWeight</metric>
    <metric>maxSheepsLiveWeight</metric>
    <metric>minSheepsLiveWeight</metric>
    <metric>meanCattlesLiveWeight</metric>
    <metric>maxCattlesLiveWeight</metric>
    <metric>minCattlesLiveWeight</metric>
    <metric>meanSheepsNEC</metric>
    <metric>meanCattlesNEC</metric>
    <metric>MSTSheep-NEC</metric>
    <metric>MSTCattle-NEC</metric>
    <metric>totalTrees8years</metric>
    <metric>totalTrees7years</metric>
    <metric>totalTrees6years</metric>
    <metric>totalTrees5years</metric>
    <metric>totalTrees4years</metric>
    <metric>totalTrees3years</metric>
    <metric>totalTrees2years</metric>
    <metric>totalTrees1years</metric>
    <metric>totalTreesOldes</metric>
    <metric>totalTreesYoung</metric>
    <metric>traj-trees</metric>
    <metric>MST-trees</metric>
    <metric>meanTreesInCaangol</metric>
    <metric>meanTreesInSangre</metric>
    <metric>meanTreesInBaldiol</metric>
    <metric>meanTreesInSeeno</metric>
    <metric>traj-satisfaction-Seeno</metric>
    <metric>traj-satisfaction-Baldiol</metric>
    <metric>traj-satisfaction-Sangre</metric>
    <metric>traj-satisfaction-Caangol</metric>
    <metric>MST-Seeno</metric>
    <metric>MST-Baldiol</metric>
    <metric>MST-Sangre</metric>
    <metric>MST-Caangol</metric>
    <metric>totalGrass</metric>
    <metric>totalTrees</metric>
    <metric>meanGrass</metric>
    <metric>meanFruitsConsumedCattle</metric>
    <metric>meanLeavesConsumedCattle</metric>
    <metric>meanFruitsConsumedSheep</metric>
    <metric>meanLeavesConsumedSheep</metric>
    <metric>sumSmallHerder</metric>
    <metric>sumMediumHerder</metric>
    <metric>sumLargeHerder</metric>
    <enumeratedValueSet variable="SatisfactionMeanTreesInCaangol">
      <value value="93"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-ponds-5-months">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="visualization-mode">
      <value value="&quot;grass-cover&quot;"/>
    </enumeratedValueSet>
    <steppedValueSet variable="good-shepherd-percentage" first="0" step="10" last="100"/>
    <enumeratedValueSet variable="SatisfactionMeanTreesInBaldiol">
      <value value="40"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-ponds-6-months">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="SheepNECSatifactionIndex">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="SatisfactionMeanTreesInSeeno">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="CattleNECSatifactionIndex">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-camps">
      <value value="1"/>
      <value value="10"/>
      <value value="50"/>
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="TreeDensitySatisfaction-olds">
      <value value="6010"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max-ponds-4-months">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion-big-herders">
      <value value="34"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="SatisfactionMeanTreesInSangre">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="proportion-medium-herders">
      <value value="33"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
