__includes["calculStat.nls" "trees.nls" "camps.nls" "foyers.nls" "herds.nls" "agriculture.nls" "humans.nls" "grass.nls" "seasons.nls"]
extensions [csv table] ;profiler]


globals [
  size-x                 ; Taille horizontale du monde
  size-y                 ; Taille verticale du monde

  current-season         ; Saison actuelle
  last-season            ; Saison précédente
  season-counter         ; Compteur de saison
  year-types             ; Liste qui stocke les types d'années
  current-year-type      ; Le type d'année en cours (bonne, moyenne, mauvaise)
  total-ticks-per-year   ; Nombre total de ticks par année
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

  pB
  pM
  pS

  UBT_grand
  UBT_moyen
  UBT_petit


  seuil-bon-UF              ; Seuil UF pour une herbe de bonne qualité
  seuil-moyen-UF            ; Seuil UF pour une herbe de qualité moyenne
  seuil-bon-MAD
  seuil-moyen-MAD

  K-Baldiol                 ; seuil max d'herbe pour les différents types de sols
  K-Caangol
  K-Sangre
  K-Seeno

  production-residu-hectare-agriculture   ; production à l'hectare en tonne de résidu de culture


  initial-number-of-camps
  space-camp-min
  space-camp-max
  space-camp-standard-deviation
  space-camp-mean

  caangol-surface
  seeno-surface
  sangre-surface
  baldiol-surface

  listValueHerdeType
  sum-UBT

]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Breeding and characterization ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

breed [camps camp]
breed [foyers foyer]
breed [cattles cattle]
breed [sheeps sheep]
breed [tree-populations tree-population]
breed [mature-tree-pops mature-tree-pop]   ; Pour visualisation
breed [champs champ]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Variables des cellules ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


patches-own [


  ; Variables d'initialisation  et de temps

  soil-type                        ; Type de sol et de paysage
  init-camp-pref                   ; Préférence pour l'installation des campements (1 ou 2)

  ; Variables pour le tapis herbacée

  current-grass                    ; Couverture d'herbe en kg
  grass-end-nduungu                ; Couverture d'herbe le dernier jour du Nduungu
  K                                ; Montant d'herbe
  K-max                            ; Montant maximum d'herbe
  patch-sensitivity                ; Sensibilité à la dégradation
                                   ;  degradation-level                ; Niveau de dégradation

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
  init-patch-sensitivity


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;; Variables non initialisées (en cours) ;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  park-restriction                 ; Cellule protégée (parcelle de reforestation)
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
  protein-condition                ; Condition protéique
  initial-live-weight              ; poids vif à l'initialisation (kg)
  live-weight                      ; poids vif actuel (kg)
  max-live-weight                  ; Maximum de poids vif atteignable (kg)
  min-live-weight                  ; Minimum de poids vif atteignable (kg)
  weight-gain                      ; Gain ou perte de poids

  ; Alimentation spécifiques aux troupeaux
  UBT-size                         ; Proportion d'un individu en Unité de Bétail Tropical (une vache allaitante = 1)
  head                             ; Nombre d'individus
  max-daily-DM-ingestible-per-head ; Quantité maximale de MS qu'un individu peut consommer par jour
  daily-needs-DM
  daily-min-UF-needed-head         ; Quantité minimum d'Unité Fourragère à l'entretien d'un UBT
  daily-needs-UF                   ; Quantité minimum d'Unité Fourragère à l'entretien du troupeau
  daily-min-MAD-needed-head        ; Quantité minimum de Matière Azotée Digestible à l'entretien d'un UBT;
  daily-needs-MAD                  ; Quantité minimum de Matière Azotée Digestible à l'entretien du troupeau
  DM-ingested                      ; Quantité totale d'herbe ingérée (kg de MS)
  UF-ingested                      ; UF totales ingérées
  MAD-ingested                     ; MAD totales ingérées
  total-UF-ingested-from-trees
  total-MAD-ingested-from-trees
  total-DM-ingested-from-trees
  daily-water-consumption          ; Consommation d'eau quotidienne
  preference-mono                  ; Préférence pour les Graminées

  ; Caractéristiques des foyers partagé aux troupeaux (Utilisé autant par les troupeaux que les foyers)
  known-space                      ; Tout l'espace connu par les individus
  close-known-space                ; Espace connu à moins d'une journée de déplacement d'un troupeau (6km)
  distant-known-space              ; Espace connu à plus d'une journée de déplacement d'un troupeau (6km)

  ; Déplacement du campement
  current-home-camp                ; Campement actuel
  current-home-patch               ; Patch du campement actuel
  original-home-camp               ; Campement permanent
  original-home-patch              ; Patch du campement permanent
  temporary-home-camp              ; Campement temporaire
  temporary-home-patch             ; Patch du campement temporaire
  is-in-temporary-camp             ; Booléen indiquant à l'agent s'il est dans son campement permanent ou sur un temporaire

]



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Agents Campements ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

camps-own [
  available-space                  ; Nombre de foyers associés
  is-temporary                     ; Booléen indiquant si le camp est temporaire
  wood-needs                       ; Besoins en bois
  wood-quantity                    ; Quantité de bois dans le campement
]



;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Agents Foyers ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

foyers-own [


  ; Gestion du troupeau
  cattle-herd                      ; Troupeau de bovins associé
  cattle-herd-size                 ; Taille du troupeau de bovins associé
  cattle-herd-count
  sheep-herd                       ; Troupeau de moutons associé
  sheep-herd-size                  ; Taille du troupeau d'ovins associé
  sheep-herd-count
  shepherd-type                    ; Type de berger du foyer
  herder-type                      ; Caractéristique d'élevage du foyer (grand moyen petit)
  pasture-strategy                 ; Stratégies de pâturage

  ; Surveillance de l'état du troupeau
  ; Bovins
  cattle-low-threshold-cc          ; limite basse NEC
  cattle-low-threshold-pc          ; limite basse MAD
  cattle-high-threshold-cc         ; limite haute NEC
  cattle-high-threshold-pc         ; limite haute MAD
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
  friends                          ; Amis de l'agent
  far-exploration-count            ; Compteur d'exploration au loin
  close-exploration-count          ; Compteur d'exploration proche
  cattleNEC-satisfaction
  sheepNEC-satisfaction
]



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Agents troupeau de petits ruminants ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

sheeps-own [
  foyer-owner                      ; Foyer du troupeau
  shepherd-type                    ; Caractéristique d'élevage du foyer (grand moyen petit)
  pasture-strategy                 ; Stratégies de pâturage
  have-left                        ; Indique si le troupeau est parti vers le sud ou hors de la zone de l'UP
  leaves-eaten
  fruits-eaten
  original-camp-known-space        ; Espace connu à moins d'une journée de déplacement du campement principal pour un troupeau
]



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;; Agents troupeau de bovins ;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

cattles-own [
  foyer-owner                      ; Foyer du troupeau
  shepherd-type                    ; Caractéristique d'élevage du foyer (grand moyen petit)
  pasture-strategy                 ; Stratégies de pâturage
  have-left                        ; Indique si le troupeau est parti vers le sud ou hors de la zone de l'UP
  leaves-eaten
  fruits-eaten
  original-camp-known-space        ; Espace connu à moins d'une journée de déplacement du campement principal pour un troupeau
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
  max-fruit-stock                  ; Stock maximal de fruit pour la population
  max-leaf-stock                   ; Stock maximal de fruit pour la population
  max-wood-stock                   ; Stock maximal de fruit pour la population
  wood-ratio                       ; Ratio entre le stock actuel et le stock maximal de bois
  tree-sensitivity                 ; Sensibilité de l'arbre à la coupe et la pluviométrie

  ; Relatif à l'énergie et la valeur de matière azotée dans les feuilles et furilles
  tree-UF-per-kg-MS                ; UF/kg MS pour les arbres
  tree-MAD-per-kg-MS               ; MAD/kg MS pour les arbres
]

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;; Agents champs ;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

champs-own [
  foyer-owner                      ; Foyer du champ
  surface                          ; Surface du champ
]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Initialisation du monde et des agents ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to setup
  clear-all
  resize-world -11 11 -11 11  ; Fixer les limites du monde à -11 à 11 en x et y
  set-patch-size 20  ; Ajuster la taille des patches
  set listValueHerdeType []

  ; Chargement des valeurs environnementales
  load-environment "environment_vel.txt"
  set current-season "Nduungu"  ; Initialiser à la première saison
  set last-season "none"  ;; Initialiser last-season
  set season-counter 0  ; Compteur de saison initialisé à 0


  ;;; Chargement des variables temporelles
  load-climate-variables "year-type.txt"
  set year-index 0  ; Indice de l'année en cours
  set year-counter 0  ; Compteur de ticks dans l'année


  ; Chargement des valeurs spécifiques aux ressouces pastorales
  load-tree-age-data "tree_info.csv" ; valeurs pour les ages
  load-tree-nutrition-data "tree_nutrition.csv" ; valeurs pour les qualités nutritives selon type d'arbre, saison, type de sol


  ; Initialiser les durées des saisons
  update-year-type
  set-season-durations

  set initial-number-of-camps number-of-camps
  set space-camp-min 2
  set space-camp-max 15
  set space-camp-standard-deviation 5
  set space-camp-mean (space-camp-min + space-camp-max) / 2

  set pB proportion-big-herders / 100
  set pM proportion-medium-herders / 100
  set pS (100 - (proportion-big-herders + proportion-medium-herders)) / 100

  set UBT_grand 100
  set UBT_moyen 50
  set UBT_petit 10


  ; Ici, on calcule sum-UBT à partir du avg-UBT-per-camp
  set sum-UBT (initial-number-of-camps * avg-UBT-per-camp)

  ; définir les seuil max d'herbe par type de sol
  set K-Baldiol 120000
  set K-Caangol 300000
  set K-Sangre 80000
  set K-Seeno 200000

  ; seuils de production des champs
  set production-residu-hectare-agriculture 1           ; kg de matière sèche par hectare

  ; Lancer l'environnement
  setup-landscape  ; Créer les unités de paysage
  setup-water-patches ; Créer les mares
  setup-camps  ; Créer les campements
  setup-foyers ; Créer les foyers
  setup-herds  ; Créer les troupeaux
  setup-trees  ; Créer les arbres
  setup-agriculture   ; créer les champs



  update-UF-and-MAD
  update-grass-quality


  set caangol-surface count patches with [soil-type = "Caangol"]
  set sangre-surface count patches with [soil-type = "Sangre"]
  set baldiol-surface count patches with [soil-type = "Baldiol"]
  set seeno-surface count patches with [soil-type = "Seeno"]

  ; Définir les seuils
  set seuil-bon-UF 0.6    ; Qualité de l'herbe - à ajuster selon les données du manuel de Boudet (1975)
  set seuil-moyen-UF 0.45  ; À ajuster
  set seuil-bon-MAD 53
  set seuil-moyen-MAD 25
  set max-grass max [K] of patches ; pour visualisation
  set max-trees max [tree-cover] of patches


  ;Visualiser l'environnement
  reset-ticks
  calculStat
  update-visualization
  display-labels


end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Initialisation des patches ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup-landscape
  ask patches [
    set max-tree-cover tree-cover
    if soil-type = "Baldiol" [
      set K K-Baldiol  ; Stock de production de Matière Sèche (MS - DM[en]) sur 1 km² pour "Baldiol"
      set K-max K-Baldiol ; stock max
      set current-grass 40
      set num-nutritious round (tree-cover * 0.5)
      set num-less-nutritious round (tree-cover * 0.25)
      set num-fruity round (tree-cover * 0.25)
      set patch-sensitivity 2
      set max-tree-number 8000
    ]
    if soil-type = "Caangol" [
      set K K-Caangol  ; Stock de production de Matière Sèche (MS - DM[en]) sur 1 km² pour Caangol
      set K-max K-Caangol ; stock max
      set current-grass 40
      set num-nutritious round (tree-cover * 0.5)
      set num-less-nutritious round (tree-cover * 0.25)
      set num-fruity round (tree-cover * 0.25)
      set patch-sensitivity 2
      set max-tree-number 20000
    ]
    if soil-type = "Sangre" [
      set K K-Sangre  ; Stock de production de Matière Sèche (MS - DM[en]) sur 1 km² pour Sangre
      set K-max K-Sangre ; stock max
      set current-grass 40
      set num-nutritious round (tree-cover * 0.8)
      set num-less-nutritious round (tree-cover * 0.25)
      set num-fruity round (tree-cover * 0.0001)
      set patch-sensitivity 3
      set max-tree-number 15000
    ]
    if soil-type = "Seeno" [
      set K K-Seeno  ; Stock de production de Matière Sèche (MS - DM[en]) sur 1 km² pour Seeno
      set K-max K-Seeno ; stock max
      set current-grass 40
      set num-nutritious round (tree-cover * 0.5)
      set num-less-nutritious round (tree-cover * 0.25)
      set num-fruity round (tree-cover * 0.25)
      set patch-sensitivity 1
      set max-tree-number 5000
    ]
    if soil-type = "" [
      set current-grass 1
      set K 1  ; Stock de production maximal de Matière Sèche (MS - DM[en]) sur 1 km² pour Seeno
               ;     if current-season = "Nduungu" [set grass-quality "average"] ;; A garder si jamais on simplifie la règle
               ;     if current-season = "Dabbuunde" [set grass-quality "poor"] ;; A garder si jamais on simplifie la règle
               ;     if current-season = "Ceedu" [set grass-quality "good"] ;; A garder si jamais on simplifie la règle
               ;     if current-season = "Ceetcelde" [set grass-quality "average"] ;; A garder si jamais on simplifie la règle
    ]
    set water-point false  ; Initialement, aucun point d'eau
    set has-pond false  ; Initialement, aucune mare
    set water-stock 0  ; Initialement, aucun stock d'eau dans les mares
    assign-grass-proportions
  ]
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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Stepping ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



;;;;;;;;;;;;;;;;;;;;
;;; Step général ;;;
;;;;;;;;;;;;;;;;;;;;

to go
  ;  profiler:reset
  ;  profiler:start


  ; Mise à jour du modèle général et temporalité
  update-season

  ; Mise à jour saisonnière
  if current-season != last-season [
    update-UF-and-MAD                 ; Mettre à jour les valeurs de MAD et UF pour le tapis herbacé
    update-tree-nutritional-values    ; Mettre à jour les valeurs de MAD et UF pour les arbres
    set last-season current-season    ; Permet au counter d'identifier quand la saison change
    update-tree-visualisation
  ]


  ; Mise à jour annuelle
  if year-counter >= total-ticks-per-year [
    ask patches with [current-grass < 200] [
      set current-monocot-grass 100
      set current-dicot-grass 100
      set current-grass current-monocot-grass + current-dicot-grass
    ]
    set year-counter 0                            ; Au premier jour de chaque nouvelle année, remet le compteur d'année à 0
    update-year-type                              ; Au premier jour de chaque nouvelle année, redéfinit si l'année sera bonne, moyenne, mauvaise
    set-season-durations                          ; Au premier jour de chaque nouvelle année et en fonction de l'année, redéfinit les durées pour chacune des siaosn pour l'année en cours
    update-tree-age                               ; Au premier jour de chaque nouvelle année, fait grandir les populations d'arbres d'un an
    renew-tree-population                         ; Au premier jour de chaque nouvelle année, crée une nouvelle population d'arbres d'un an
    ask patches [assign-grass-proportions]        ; Au premier jour de chaque nouvelle année, relance la génération aléatoire des proportions en monocotylédone et dicotylédone
                                                  ; Retour des troupeaux et mise à jour de l'espace connu
    call-back-herds
    ask foyers [
      set far-exploration-count 0                 ; Compteur d'exploration au loin
      set close-exploration-count 0               ; Compteur d'exploration proche
      set known-space patches in-radius 3         ; Remise à 0
    ]
    ask cattles [set known-space [known-space] of foyer-owner]
    ask sheeps [set known-space [known-space] of foyer-owner]
  ]


  ; Mise à jour quotidienne des ressources
  grow-grass
  update-grass-quality              ; Indiquer la qualité de l'herbe
  grow-tree-resources
  if mean [current-leaf-stock] of tree-populations < 0 [
    show-tree-populations-info]


  ; Activités des agents
  if count cattles > 0 [
    ask cattles [
      set DM-ingested 0
      set UF-ingested 0
      set MAD-ingested 0
      set total-UF-ingested-from-trees 0
      set total-MAD-ingested-from-trees 0
      set total-DM-ingested-from-trees 0
      set fruits-eaten 0
      set leaves-eaten 0
    ] ; end ask cattles
  ] ; end count cattles
  if count sheeps > 0 [
    ask sheeps [
      set DM-ingested 0
      set UF-ingested 0
      set MAD-ingested 0
      set total-UF-ingested-from-trees 0
      set total-MAD-ingested-from-trees 0
      set total-DM-ingested-from-trees 0
      set fruits-eaten 0
      set leaves-eaten 0
    ]
  ]
  ask cattles with [have-left = false] [
    move
    update-known-space
    eat
    update-corporal-conditions head UBT-size UF-ingested MAD-ingested daily-needs-UF daily-needs-MAD max-daily-DM-ingestible-per-head preference-mono
    trample-trees
  ]
  ask sheeps with [have-left = false] [
    move
    update-known-space
    eat
    update-corporal-conditions head UBT-size UF-ingested MAD-ingested daily-needs-UF daily-needs-MAD max-daily-DM-ingestible-per-head preference-mono
    trample-trees
  ]

  ; Activités des Foyers
  ask foyers [
    if cattle-herd != nobody [
      choose-strategy-for-cattles]
    if sheep-herd != nobody [
      choose-strategy-for-sheeps]
    ; Choix stratégiques pastoraux du chef de ménage
    update-known-space
  ]

  ; Mise à jour des valeurs Stats pour visualisation
  calculStat

  ; Visuel
  update-visualization
  update-plot

  tick
  ;  profiler:stop
  ;  print profiler:report
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;             DISPLAY                 ;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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

end
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


to display-labels
  ask turtles [set label ""]
  ask turtles [set label head]

end


to update-plot
  let _typeF (list "petit" "moyen" "grand")
  let _listString  [herder-type] of foyers
  set listValueHerdeType (map [x ->
    ifelse-value (x = "petit") [1]
    [ifelse-value (x = "moyen") [2]
      [ifelse-value (x = "grand") [3]
        [0]]]] _listString)
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Ouverture des fichiers pour l'environnement spatial du modèle ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to load-environment [filename]
  file-open filename
  while [not file-at-end?] [
    let data read-from-string file-read-line
    let value item 0 data
    let px item 1 data
    let py item 2 data
    let tree-count item 3 data
    let nom_puular item 7 data
    let low-topo-zone item 6 data
    ask patch px py [
      set soil-type nom_puular
      set tree-cover tree-count
      set init-camp-pref low-topo-zone]
  ]
  file-close
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Ouverture des fichiers pour les caractéristiques temporelles du monde ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to load-climate-variables [filename]
  set year-types []
  file-open filename
  while [not file-at-end?] [
    let line file-read-line
    ; Ajouter le type d'année à la liste
    set year-types lput line year-types
  ]
  file-close
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;; Reporters ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to-report generate-available-space
  set available-space 0
  while [available-space < space-camp-min or available-space > space-camp-max] [  ; Respecter les fences
    set available-space random-normal space-camp-mean space-camp-standard-deviation  ; Utiliser la moyenne et l'écart type
  ]
  report round available-space  ; Arrondir au nombre entier le plus proche
end


to-report patches-between [ p1 p2 ]
  let x1 [ pxcor ] of p1
  let y1 [ pycor ] of p1
  let x2 [ pxcor ] of p2
  let y2 [ pycor ] of p2

  let distancex x2 - x1
  let distancey y2 - y1

  let n max (list abs distancex abs distancey)
  let xinc distancex / n
  let yinc distancey / n
  let x x1
  let y y1
  let result patch-set patch x1 y1
  repeat n [
    set x x + xinc
    set y y + yinc
    set result (patch-set result patch round x round y)
  ]
  report result
end

to-report meanKnownSpace [agents]
  ; Initialiser une variable pour stocker la somme des counts
  let _total-count 0
  ; Initialiser une variable pour stocker le nombre de moutons
  let _number-of-sheep count agents
  ; Parcourir chaque mouton et compter les patches
  ask agents [
    let patches-agentset [distant-known-space] of self  ; Récupérer l'agentset des patches pour ce mouton
    let count-patches count patches-agentset /  count patches          ; Compter le nombre de patches
    set _total-count _total-count + count-patches         ; Ajouter à la somme totale
  ]

  ;; Calculer la moyenne
  ifelse _number-of-sheep = 0 [report 0]
  [report _total-count / _number-of-sheep * 100]
end
@#$#@#$#@
GRAPHICS-WINDOW
100
10
568
479
-1
-1
20.0
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
2
15
97
48
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
20
121
75
154
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
3
286
92
331
Total Foyers
totalFoyers
17
1
11

MONITOR
3
386
92
431
Total cattles
totalCattles
17
1
11

MONITOR
3
336
92
381
Total Sheeps
totalSheeps
17
1
11

SLIDER
2375
85
2540
118
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
2376
123
2536
156
max-ponds-5-months
max-ponds-5-months
0
10
0.0
1
1
NIL
HORIZONTAL

SLIDER
2376
162
2536
195
max-ponds-6-months
max-ponds-6-months
0
10
0.0
1
1
NIL
HORIZONTAL

MONITOR
2379
199
2514
244
NIL
waterStock
17
1
11

CHOOSER
720
380
815
425
visualization-mode
visualization-mode
"soil-type" "tree-cover" "grass-cover" "grass-quality" "known-space"
1

BUTTON
720
340
815
373
visualize
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

BUTTON
20
50
75
83
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

MONITOR
705
10
865
55
Season
current-season
17
1
11

MONITOR
625
10
705
55
Type of Year
current-year-type
17
1
11

SLIDER
573
135
706
168
good-shepherd-percentage
good-shepherd-percentage
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
570
60
706
93
proportion-big-herders
proportion-big-herders
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
572
98
707
131
proportion-medium-herders
proportion-medium-herders
0
100
7.0
1
1
NIL
HORIZONTAL

PLOT
1951
496
2261
646
Weight-gain
NIL
NIL
0.0
10.0
-2.0
2.0
true
true
"" ""
PENS
"cattles" 1.0 0 -16777216 true "" "plot cattlesWeightGain"
"sheeps" 1.0 0 -5516827 true "" "plot sheepsWeightGain"
"0" 1.0 0 -5298144 true "" "plot 0"

PLOT
1951
198
2261
348
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
1951
348
2261
498
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
1615
198
1950
348
CATTLE weight per head
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
"meanWeight" 1.0 0 -16777216 true "" "plot meanCattlesLiveWeight"
"maxWeight" 1.0 0 -2674135 true "" "plot maxCattlesLiveWeight"
"minWeight" 1.0 0 -13791810 true "" "plot minCattlesLiveWeight"

BUTTON
6
488
91
521
removeGrass
ask patches [set current-grass  0.1\nset current-monocot-grass 0.1\nset current-dicot-grass 0.1]
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
1660
863
1840
1008
distant-kown-space
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
"sheep" 1.0 0 -16777216 true "" "plot meanDistantKnownSpace"
"cattle" 1.0 0 -2674135 true "" "plot meanKnownSpace cattles"

PLOT
706
61
866
206
HistHerderType
listValueHerdeType
NIL
0.0
10.0
0.0
10.0
true
false
"set-plot-x-range 0 5\nset-plot-y-range 0 100\nset-histogram-num-bars 5" ""
PENS
"pen-0" 1.0 1 -16777216 true "" "histogram listValueHerdeType"

PLOT
1615
348
1950
498
SHEEP weight per head
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
"meanWeight" 1.0 0 -16777216 true "" "plot meanSheepsLiveWeight"
"maxWeight" 1.0 0 -2674135 true "" "plot maxSheepsLiveWeight"
"minWeight" 1.0 0 -13791810 true "" "plot minSheepsLiveWeight"

MONITOR
570
10
627
55
Year
year-index
17
1
11

PLOT
1296
862
1575
1008
mean grass per Ha
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
1011
342
1283
488
trees-evolve
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
"olds" 1.0 0 -16777216 true "" "plot totalTreesOldes"
"youngs" 1.0 0 -7500403 true "" "plot totalTreesYoung"
"satis" 1.0 0 -2674135 true "" "plot TreeDensitySatisfaction-olds"

PLOT
1282
196
1585
342
Tree  Consumption
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
"fruits cattle" 1.0 0 -2674135 true "" "plot meanFruitsConsumedCattle"
"leaves cattle" 1.0 0 -12087248 true "" "plot meanLeavesConsumedCattle"
"fruits sheep" 1.0 0 -612749 true "" "plot meanFruitsConsumedSheep"
"leaves sheep" 1.0 0 -5509967 true "" "plot meanLeavesConsumedSheep"

SLIDER
102
488
302
521
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
1615
648
1874
798
MST NEC
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
"sheep" 1.0 0 -13791810 true "" "plot  MSTSheep-NEC"
"cattle" 1.0 0 -16777216 true "" "plot  MSTCattle-NEC"

SLIDER
102
526
302
559
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
55
155
88
281
number-of-camps
number-of-camps
0
200
4.0
1
1
NIL
VERTICAL

PLOT
1615
498
1925
648
NEC mean
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
"Cattles" 1.0 0 -16777216 true "" "plot meanCattlesNEC"
"Sheeps" 1.0 0 -8275240 true "" "plot meanSheepsNEC"
"satis" 1.0 0 -2674135 true "" "plot SheepNECSatifactionIndex"

SLIDER
370
490
570
523
TreeDensitySatisfaction-olds
TreeDensitySatisfaction-olds
0
8000
5231.0
1
1
NIL
HORIZONTAL

PLOT
1021
488
1234
636
MST of olders trees
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
"default" 1.0 0 -16777216 true "" "plot MST-trees"

PLOT
1011
196
1283
342
Mean trees by soil-type
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
365
592
565
625
SatisfactionMeanTreesInCaangol
SatisfactionMeanTreesInCaangol
50
150
78.0
1
1
NIL
HORIZONTAL

SLIDER
365
556
565
589
SatisfactionMeanTreesInSeeno
SatisfactionMeanTreesInSeeno
12
50
21.0
1
1
NIL
HORIZONTAL

SLIDER
365
626
565
659
SatisfactionMeanTreesInBaldiol
SatisfactionMeanTreesInBaldiol
0
100
59.0
1
1
NIL
HORIZONTAL

SLIDER
365
662
565
695
SatisfactionMeanTreesInSangre
SatisfactionMeanTreesInSangre
0
100
53.0
1
1
NIL
HORIZONTAL

PLOT
1021
635
1234
780
MST-tree by soil
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
"Seeno" 1.0 0 -2674135 true "" "plot MST-Seeno"
"Baldiol" 1.0 0 -7500403 true "" "plot MST-Baldiol"
"pen-2" 1.0 0 -955883 true "" "plot MST-Sangre"
"pen-3" 1.0 0 -16777216 true "" "plot MST-Caangol"

BUTTON
20
85
75
118
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
6
526
91
559
hide trees
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
1063
925
1218
958
decreasing-factor
decreasing-factor
1
20
1.0
0.1
1
NIL
HORIZONTAL

SLIDER
3
156
36
281
avg-UBT-per-camp
avg-UBT-per-camp
10
800
125.0
5
1
NIL
VERTICAL

MONITOR
5
435
93
480
NIL
sum-UBT
17
1
11

SLIDER
366
719
566
752
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
1282
342
1507
488
trees-killed
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
996
22
1011
1134
||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
10
0.0
1

TEXTBOX
1013
15
2273
95
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- Outputs ------------------------------------------------------------------------ --------------------------------------------------------------------------------------------------------------------------------------------------
6
0.0
1

TEXTBOX
1203
122
1563
281
Trees Satisfaction
5
0.0
1

TEXTBOX
1590
100
1613
820
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
5
0.0
1

TEXTBOX
2272
19
2312
1134
||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
10
0.0
1

TEXTBOX
1856
126
2176
192
Herds Satisfaction
5
0.0
1

TEXTBOX
1016
815
2292
867
--------------------------------------------------------------------------------------------------------------------------------------------------
5
0.0
1

TEXTBOX
1013
1058
2269
1154
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
5
0.0
1

TEXTBOX
570
560
666
695
Per Ha\n------------------------
10
0.0
1

TEXTBOX
575
726
953
764
Ratio surface of each landscape filled condition 
1
0.0
1

TEXTBOX
1452
1028
1884
1080
Global Behaviors Informations\n
5
0.0
1

TEXTBOX
1126
969
1161
1114
i^\n |\n |\n 
1
0.0
1

TEXTBOX
1063
1039
1278
1065
For sensitivity analysis
1
0.0
1

TEXTBOX
680
295
698
476
||||||||||||||||||||||||||||||||||||||||||||||||||||
11
0.0
1

TEXTBOX
702
290
828
342
---------------------------------------------VISU------------------------------------------
11
0.0
1

TEXTBOX
700
438
826
561
---------------------------------------------------------------------------------------------
11
0.0
1

TEXTBOX
833
295
851
477
||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
11
0.0
1

PLOT
1266
491
1581
666
Mean tree resources
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
"mean leaves" 1.0 0 -13840069 true "" "plot mean [current-leaf-stock] of tree-populations"
"mean fruits" 1.0 0 -4699768 true "" "plot mean [current-fruit-stock] of tree-populations"

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
true
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