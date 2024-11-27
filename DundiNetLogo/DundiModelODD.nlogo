extensions [csv]

globals [
  size-x                 ; Taille horizontale du monde
  size-y                 ; Taille verticale du monde

  current-season         ; Saison actuelle
  last-season            ; Saison précédente
  season-counter         ; Compteur de saison
  renewal-flag           ; Flag pour indiquer si la saison de renouvellement a eu lieu
  year-types             ; Liste qui stocke les types d'années
  current-year-type      ; Le type d'année en cours (bonne, moyenne, mauvaise)
  total-ticks-per-year   ; Nombre total de ticks par année
  year-counter           ; Compteur de ticks dans l'année
  year-index             ; Indice de l'année en cours
  max-grass              ; pour visualisation
  max-trees              ; pour visualisation

  tree-age-data          ; liste qui stocke les valeurs max de fruits, feuilles, bois et sensibilité pour cette catégorie d'arbres
  tree-nutrition-data    ; liste qui stocke les valeurs en UF (Unité Fourragère en Kcal/kg MS ingéré) et MAD (Matière Azotée Digestible en g/kg MS ingéré)

  nduungu-duration       ; Nombre de ticks pour la saison des pluies
  dabbuunde-duration     ; Nombre de ticks pour la saison sèche froide
  ceedu-duration         ; Nombre de ticks pour la saison sèche chaude
  ceetcelde-duration     ; Nombre de ticks pour la période de soudure


  seuil-bon              ; Seuil pour une herbe de bonne qualité
  seuil-moyen            ; Seuil pour une herbe de qualité moyenne
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

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; Variables des cellules ;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


patches-own [


  ; Variables d'initialisation  et de temps

  soil-type                        ; Type de sol et de paysage
  init-camp-pref                   ; Préférence pour l'installation des campements (1 ou 2)

  ticks-since-dabbuunde            ; Compteur de ticks depuis le début de Dabbuunde
  total-dry-season-ticks           ; Nombre de jours de saison sèche hors période de soudure


  ; Variables pour le tapis herbacée

  current-grass                    ; Couverture d'herbe en kg
  grass-end-nduungu                ; Couverture d'herbe le dernier jour du Nduungu
  K                                ; Montant maximum d'herbe
  patch-sensitivity                ; Sensibilité à la dégradation
  degradation-level                ; Niveau de dégradation

  grass-quality                    ; Qualité actuelle de l'herbe
  q                                ; Ratio de qualité
  p                                ; Proportion de monocotylédone
  current-monocot-grass            ; Stock d'herbe des monocotylédones en kg
  current-dicot-grass              ; Stock d'herbe des dicotylédones en kg
  monocot-grass-end-nduungu        ; Stock d'herbe des monocotylédones en kg en fin de saison des pluies
  dicot-grass-end-nduungu          ; Stock d'herbe des dicotylédones en kg en fin de saison des pluies

  monocot-UF-per-kg-MS             ; UF/kg MS pour les monocotylédones
  monocot-MAD-per-kg-MS            ; MAD/kg MS pour les monocotylédones
  dicot-UF-per-kg-MS               ; UF/kg MS pour les dicotylédones
  dicot-MAD-per-kg-MS              ; MAD/kg MS pour les dicotylédones


  ; Variables d'initialisation des populations ligneuses

  tree-cover                       ; Couverture d'arbres
  max-tree-cover                   ; Maximum d'individus atteignable sur un km²
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
  weight-gain                      ; Gain ou perte de poids

  ; Alimentation spécifiques aux troupeaux
  UBT-size                         ; Proportion d'un individu en Unité de Bétail Tropical (une vache allaitante = 1)
  head                             ; Nombre d'individus
  max-daily-DM-ingestible-per-head ; Quantité maximale de MS qu'un individu peut consommer par jour
  daily-min-UF-needed-head         ; Quantité minimum d'Unité Fourragère à l'entretien d'un UBT
  daily-min-MAD-needed-head        ; Quentité minimum de Matière Azotée Digestible à l'entretien d'un UBT;
  DM-ingested                      ; Quantité totale d'herbe ingérée (kg de MS)
  UF-ingested                      ; UF totales ingérées
  MAD-ingested                     ; MAD totales ingérées
  energy-ingested                  ; Quantité d'énergie ingérée (MCal)
  daily-water-consumption          ; Consommation d'eau quotidienne

  ; Caractéristiques des foyers partagé aux troupeaux (Utilisé autant par les troupeaux que les foyers)
  known-space                      ; Tout l'espace connu par les individus
  close-known-space                ; Espace connu à moins d'une journée de déplacement d'un troupeau (12km)
  original-camp-known-space        ; Espace connu à moins d'une journée de déplacement du campement principal pour un troupeau
  distant-known-space              ; Espace connu à plus d'une journée de déplacement d'un troupeau (12km)

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
  sheep-herd                       ; Troupeau de moutons associé
  sheep-herd-size                  ; Taille du troupeau d'ovins associé
  shepherd-type
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

 ; Relations
  friends                          ; Amis de l'agent
]



  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;; Agents troupeau de petits ruminants ;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

sheeps-own [
  foyer-owner                      ; Foyer du troupeau
  shepherd-type                      ; Caractéristique d'élevage du foyer (grand moyen petit)
  pasture-strategy                 ; Stratégies de pâturage
  have-left
]



  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;; Agents troupeau de bovins ;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

cattles-own [
  foyer-owner                      ; Foyer du troupeau
  shepherd-type                    ; Caractéristique d'élevage du foyer (grand moyen petit)
  pasture-strategy                 ; Stratégies de pâturage
  have-left
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


to show-tree-populations-info ; Procédure pour afficher les populations d'arbres
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
    ask tree-populations-here [
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
  resize-world -11 11 -11 11  ; Fixer les limites du monde à -11 à 11 en x et y
  set-patch-size 20  ; Ajuster la taille des patches


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
  show tree-age-data
  load-tree-nutrition-data "tree_nutrition.csv" ; valeurs pour les qualités nutritives selon type d'arbre, saison, type de sol


  ; Initialiser les durées des saisons
  update-year-type
  set-season-durations


  ; Définir les seuils
  set seuil-bon 70    ; Qualité de l'herbe - à ajuster selon les données du manuel de Boudet (1975)
  set seuil-moyen 55  ; À ajuster
  set max-grass 300000 ; pour visualisation
  set max-trees 15000 ; pour visualisation
  ask patches [
    set max-tree-cover 2000] ; pour visualisation


  ; Lancer l'environnement
  setup-landscape  ; Créer les unités de paysage
  setup-water-patches ; Créer les mares
  setup-camps  ; Créer les campements
  setup-foyers ; Créer les foyers
  setup-herds  ; Créer les troupeaux
  setup-trees  ; Créer les arbres


  ;Visualiser l'environnement
  update-visualization
  display-labels

  reset-ticks

end


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; Initialisation des patches ;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup-landscape
  ask patches [
    if soil-type = "Baldiol" [
      set K 120000  ; Stock de production maximal de Matière Sèche (MS - DM[en]) sur 1 km² pour "Baldiol"
      set current-grass K
      assign-grass-proportions
      set num-nutritious round (tree-cover * 0.5)
      set num-less-nutritious round (tree-cover * 0.25)
      set num-fruity round (tree-cover * 0.25)
      set patch-sensitivity 2
    ]
    if soil-type = "Caangol" [
      set K 300000  ; Stock de production maximal de Matière Sèche (MS - DM[en]) sur 1 km² pour Caangol
      set current-grass K
      assign-grass-proportions
      set num-nutritious round (tree-cover * 0.5)
      set num-less-nutritious round (tree-cover * 0.25)
      set num-fruity round (tree-cover * 0.25)
      set patch-sensitivity 2
    ]
    if soil-type = "Sangre" [
      set K 80000  ; Stock de production maximal de Matière Sèche (MS - DM[en]) sur 1 km² pour Sangre
      set current-grass K
      assign-grass-proportions
      set num-nutritious round (tree-cover * 0.8)
      set num-less-nutritious round (tree-cover * 0.25)
      set num-fruity round (tree-cover * 0.0001)
      set patch-sensitivity 3
    ]
    if soil-type = "Seeno" [
      set K 200000  ; Stock de production maximal de Matière Sèche (MS - DM[en]) sur 1 km² pour Seeno
      set current-grass K
      assign-grass-proportions
      set num-nutritious round (tree-cover * 0.5)
      set num-less-nutritious round (tree-cover * 0.25)
      set num-fruity round (tree-cover * 0.25)
      set patch-sensitivity 1
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


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; Initialisation des campements ;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup-camps
  ask patches [
    if soil-type != "Caangol" [
      if any? neighbors with [soil-type = "Caangol"] [
        set init-camp-pref 1
      ]
      if any? neighbors with [any? neighbors with [soil-type = "Caangol"]] and init-camp-pref = 0 [
        set init-camp-pref 2
    ]    ]
  ]
  let eligible-patches patches with [soil-type != "Caangol" and has-pond = false]
  let camp-counter 0
  ; Boucle de création des campements
  while [camp-counter < initial-number-of-camps] [
    ; Sélectionner un patch éligible avec préférence 1
    let selected-patch one-of eligible-patches with [init-camp-pref = 2]

    ; Si aucun patch avec préférence 1 n'est disponible, sélectionner un patch avec préférence 2
    if selected-patch = nobody [
      set selected-patch one-of eligible-patches with [init-camp-pref = 1]
    ]

    ifelse selected-patch != nobody [
      ask selected-patch [
        ; Vérifier qu'il y a moins de 2 campements sur ce patch
        if count camps-here < 2 [
          ; Créer un nouveau campement
          sprout-camps 1 [
            set color brown
            set size 0.5
            set is-temporary false
            set shape "house"
            set wood-needs 100
            set wood-quantity 0
            set available-space generate-available-space
            setxy pxcor pycor
          ]
          set camp-counter camp-counter + 1
        ]
      ]
    ] [
      ask selected-patch [
        ; Vérifier qu'il y a moins de 2 campements sur ce patch
        if count camps-here < 2 [
          ; Créer un nouveau campement
          sprout-camps 1 [
            set color brown
            set size 0.5
            set shape "house"
            set is-temporary false
            set wood-needs 100
            set wood-quantity 0
            set available-space generate-available-space
            setxy pxcor pycor
          ]
          set camp-counter camp-counter + 1
        ]
      ]
    ]
  ]
end


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; Initialisation des foyers ;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup-foyers
  let total-foyers 0
  ask camps [
    let num-foyers round (available-space * 0.8)
    set total-foyers total-foyers + num-foyers
  ]

  ; Calculer le nombre de bons et mauvais bergers en fonction du pourcentage
  let num-good-shepherd round (total-foyers * (good-shepherd-percentage / 100))
  let num-bad-shepherd total-foyers - num-good-shepherd

  ; Créer une liste des types de bergers en fonction des proportions
  let shepherd-types []
  repeat num-good-shepherd [ set shepherd-types lput "bon" shepherd-types ]
  repeat num-bad-shepherd [ set shepherd-types lput "mauvais" shepherd-types ]

  ; Mélanger la liste pour attribuer les types aléatoirement
  set shepherd-types shuffle shepherd-types

  ; Compteur pour suivre l'index dans la liste des types
  let shepherd-type-index 0

  ; Boucle de création des foyers
  ask camps [
    let num-foyers round (available-space * 0.8)
    let this-camp self
    hatch-foyers num-foyers [
      set color brown
      set size 0.1
      set shape "person"
      set pasture-strategy "directed"
      set shepherd-type item shepherd-type-index shepherd-types
      set shepherd-type-index shepherd-type-index + 1
      set original-home-camp this-camp  ; Assigne le campement capturé au foyer
      set current-home-camp original-home-camp
      set original-home-patch [patch-here] of original-home-camp  ; Stocke la position du campement
      set current-home-patch original-home-patch
      set is-in-temporary-camp false
      set temporary-home-camp nobody
      set herder-type determine-herder-type
      set-herd-sizes
      set known-space patches in-radius 3
      set close-known-space known-space with [
        distance [current-home-patch] of myself <= 12
      ]
      set original-camp-known-space close-known-space
      set cattle-low-threshold-cc 2
      set cattle-low-threshold-pc 2
      set sheep-low-threshold-cc 3
      set sheep-low-threshold-pc 2
      set cattle-high-threshold-cc 4
      set cattle-high-threshold-pc 6
      set sheep-high-threshold-cc 4
      set sheep-high-threshold-pc 8
    ]
  ]
end

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; Qualification des tailles respectives des bovins et petits ruminants par foyer ;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to set-herd-sizes ; Valeurs à définir
  if herder-type = "grand" [
    let r random-float 1
    if r < 0.008 [
      set cattle-herd-size "grand"
      set sheep-herd-size "moyen"
    ]
    if r < 0.013 [
      set cattle-herd-size "grand"
      set sheep-herd-size "petit"
    ]
    if r < 0.1 [
      set cattle-herd-size "petit"
      set sheep-herd-size "grand"
    ]
    ifelse r < 0.29 [
      set cattle-herd-size "moyen"
      set sheep-herd-size "grand"
    ] [
      set cattle-herd-size "grand"
      set sheep-herd-size "grand"
    ]
  ]
  if herder-type = "moyen" [
    let r random-float 1
    if r < 0.13 [
      set cattle-herd-size "moyen"
      set sheep-herd-size "moyen"
    ]
    ifelse r < 0.27 [
      set cattle-herd-size "moyen"
      set sheep-herd-size "petit"
    ] [
      set cattle-herd-size "petit"
      set sheep-herd-size "moyen"
    ]
  ]
  if herder-type = "petit" [
    set cattle-herd-size "petit"
    set sheep-herd-size "petit"
  ]
end


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; Initialisation des troupeaux ;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup-herds ; Valeurs à définir
  ask foyers [
    let cattle-herd-count 0
    let sheep-herd-count 0

    ; Définir la taille des troupeaux de bovins en fonction de la catégorie
    if cattle-herd-size = "grand" [set cattle-herd-count random 20 + 30]
    if cattle-herd-size = "moyen" [set cattle-herd-count random 15 + 10]
    if cattle-herd-size = "petit" [set cattle-herd-count random 5 + 5]

    ; Définir la taille des troupeaux de moutons en fonction de la catégorie
    if sheep-herd-size = "grand" [set sheep-herd-count random 40 + 30]
    if sheep-herd-size = "moyen" [set sheep-herd-count random 20 + 10]
    if sheep-herd-size = "petit" [set sheep-herd-count random 10 + 5]

    let my-pasture-strategy pasture-strategy
    let my-shepherd-type shepherd-type  ; Récupérer le herder-type du foyer

    ; Créer un troupeau de bovins pour le foyer
    let my-cattles []
    hatch-cattles 1 [

          ; caractéristiques physiologiques
      set head cattle-herd-count
      set UBT-size 1
      set corporal-condition 5
      set protein-condition 10
      set initial-live-weight (250 * UBT-size * head)
      set live-weight initial-live-weight

          ; caractéristiques visuelles
      set color white
      set shape "cow"
      set size calculate-herd-size head  ;; easier to see
      set label-color blue - 2
      set label head


          ; consommation et gain/perte de poids
      set max-daily-DM-ingestible-per-head 6.25 * UBT-size
      set daily-min-UF-needed-head 0.45 * max-daily-DM-ingestible-per-head         ; Quantité minimum d'Unité Fourragère à l'entretien d'un UBT
      set daily-min-MAD-needed-head 25 * max-daily-DM-ingestible-per-head        ; Quentité minimum de Matière Azotée Digestible à l'entretien d'un UBT
      set energy-ingested 0
      set weight-gain 0
      set daily-water-consumption 22 * head * UBT-size ; 22 l/UBT/J de consommation d'eau

          ; relations avec soi et les reste (propriétaire, environnement)
      set foyer-owner myself
      set my-cattles self  ; Stocker la tortue dans une variable temporaire
      set pasture-strategy my-pasture-strategy  ; Transmettre la stratégie de pâturage
      set shepherd-type my-shepherd-type  ; Transmettre le shepherd-type du foyer

          ; Campements associés
      set original-home-patch [original-home-patch] of foyer-owner
      set original-home-camp [original-home-camp] of foyer-owner
      set current-home-patch original-home-patch
      set current-home-camp original-home-camp
      set is-in-temporary-camp false
      set temporary-home-camp nobody
      move-to current-home-patch
      set xcor xcor + (random-float 0.8 - 0.4)  ;; Décalage entre -0.4 et +0.4
      set ycor ycor + (random-float 0.8 - 0.4)

          ; Espace connu et déplacements
      set known-space [known-space] of foyer-owner
      set original-camp-known-space known-space
      set close-known-space known-space in-radius 12
      set distant-known-space known-space with [
        distance [current-home-patch] of myself > 12
      ]
      set have-left false
    ]

    ; Attribuer le troupeau créé à son propriétaire
    set cattle-herd my-cattles
    ; Créer un troupeau de petits ruminants pour le foyer
    let my-sheeps []
    hatch-sheeps 1 [

          ; caractéristiques physiologiques
      set head sheep-herd-count
      set UBT-size 0.16
      setxy random-xcor random-ycor
      set corporal-condition 5
      set protein-condition 10
      set initial-live-weight 250 * UBT-size * head
      set live-weight initial-live-weight

          ; caractéristiques visuelles
      set color black
      set shape "sheep"
      set size calculate-herd-size head  ;; easier to see
      set label-color blue - 2
      set label head

          ; consommation et gain/perte de poids
      set max-daily-DM-ingestible-per-head 7.2 * UBT-size
      set daily-min-UF-needed-head 0.45 * max-daily-DM-ingestible-per-head          ; Quantité minimum d'Unité Fourragère à l'entretien d'un UBT
      set daily-min-MAD-needed-head 25  * max-daily-DM-ingestible-per-head        ; Quentité minimum de Matière Azotée Digestible à l'entretien d'un UBT
      set energy-ingested 0
      set weight-gain 0
      set daily-water-consumption 22 * head * UBT-size; 22 l/UBT/J de consommation d'eau

          ; relations avec soi et les reste (propriétaire, environnement)
      set foyer-owner myself
      set my-sheeps self  ; Stocker la tortue dans une variable temporaire
      set pasture-strategy my-pasture-strategy  ; Transmettre la stratégie de pâturage
      set shepherd-type my-shepherd-type  ; Transmettre le shepherd-type du foyer

          ; Campements associés
      set original-home-patch [original-home-patch] of foyer-owner
      set original-home-camp [original-home-camp] of foyer-owner
      set current-home-patch original-home-patch
      set current-home-camp original-home-camp
      set is-in-temporary-camp false
      set temporary-home-camp nobody
      move-to current-home-patch

          ; Espace connu et déplacements
      set known-space [known-space] of foyer-owner
      set original-camp-known-space known-space
      set close-known-space known-space in-radius 12
      set distant-known-space known-space with [
        distance [current-home-patch] of myself > 12
      ]
      set have-left false

    ]

    ; Attribuer le troupeau créé à son propriétaire
    set sheep-herd my-sheeps
  ]
end


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; Initialisation des arbres ;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup-trees ; Valeurs d'initialisation (âge minimum des arbres découverts)
  ask patches [
    ; Liste des types d'arbres à traiter
    ; Si le nombre d'arbres est supérieur à 0, procéder à l'initialisation
    if num-nutritious > 0 [
      let input-tree-type "nutritive"

      ; Répartir la population en groupes d'âge
      let age-distribution split-population num-nutritious
      let num-ages length age-distribution
      let indices range length age-distribution

      ; Boucle sur les âges
      foreach indices [ [i]->
        let pop-size item i age-distribution
        let tree-age ifelse-value (i < 7) [i + 1] [8]
        ; Obtenir les données pour ce type d'arbre et cet âge
        let age-data get-age-data input-tree-type tree-age
        if age-data != [] [
          ; Extraire les valeurs de stocks et de sensibilité
          let max-fruit item 0 age-data
          let max-leaf item 1 age-data
          let max-wood item 2 age-data
          let sensitivity item 3 age-data
          ; Stocker les valeurs dans les variables de patch
          set intermediate-patch-pop-size pop-size
          set intermediate-patch-tree-age tree-age
          set intermediate-patch-tree-type input-tree-type
          set init-patch-max-fruit-stock max-fruit * pop-size
          set init-patch-max-leaf-stock max-leaf * pop-size
          set init-patch-max-wood-stock max-wood * pop-size
          set init-patch-sensitivity sensitivity

          ; Créer une population d'arbres sur le patch
          sprout-tree-populations 1 [
            set tree-type intermediate-patch-tree-type
            set tree-pop-age intermediate-patch-tree-age
            set population-size intermediate-patch-pop-size

            ifelse population-size = 0 [
              ; Si la population est nulle, définir toutes les ressources à zéro
              set current-wood-stock 0
              set current-fruit-stock 0
              set current-leaf-stock 0
              set max-wood-stock 0
              set max-fruit-stock 0
              set max-leaf-stock 0
              hide-turtle
            ] [
              ; Initialiser les stocks actuels
              set max-fruit-stock init-patch-max-fruit-stock
              set max-leaf-stock init-patch-max-leaf-stock
              set max-wood-stock init-patch-max-wood-stock
              set current-fruit-stock (max-fruit-stock / 2)
              set current-leaf-stock (max-leaf-stock / 2)
              set current-wood-stock max-wood-stock
              set tree-sensitivity init-patch-sensitivity
              let nutritive-nutritional-values get-tree-nutritional-values tree-type [soil-type] of patch-here current-season
              set tree-UF-per-kg-MS item 0 nutritive-nutritional-values
              set tree-MAD-per-kg-MS item 1 nutritive-nutritional-values

              hide-turtle
            ]
          ]
        ]
      ]
    ]


    if num-less-nutritious > 0 [
      ; Répartir la population en groupes d'âge*
      let input-tree-type "lessNutritive"
      let age-distribution split-population num-less-nutritious
      let num-ages length age-distribution
      let indices range length age-distribution
      ; Boucle sur les âges
      foreach indices [ [i]->
        let pop-size item i age-distribution
        let tree-age ifelse-value (i < 7) [i + 1] [8]
        ; Obtenir les données pour ce type d'arbre et cet âge
        let age-data get-age-data input-tree-type tree-age

        ; Vérifier si les données pour cet âge existent
        if age-data != [] [
          ; Extraire les valeurs de stocks et de sensibilité
          let max-fruit item 0 age-data
          let max-leaf item 1 age-data
          let max-wood item 2 age-data
          let sensitivity item 3 age-data

          ; Stocker les valeurs dans les variables de patch
          set intermediate-patch-pop-size pop-size
          set intermediate-patch-tree-age tree-age
          set intermediate-patch-tree-type input-tree-type
          set init-patch-max-fruit-stock max-fruit * pop-size
          set init-patch-max-leaf-stock max-leaf * pop-size
          set init-patch-max-wood-stock max-wood * pop-size
          set init-patch-sensitivity sensitivity


          ; Créer une population d'arbres sur le patch
          sprout-tree-populations 1 [
            set tree-type intermediate-patch-tree-type
            set tree-pop-age intermediate-patch-tree-age
            set population-size intermediate-patch-pop-size

            ifelse population-size = 0 [
              ; Si la population est nulle, définir toutes les ressources à zéro
              set current-wood-stock 0
              set current-fruit-stock 0
              set current-leaf-stock 0
              set max-wood-stock 0
              set max-fruit-stock 0
              set max-leaf-stock 0
              hide-turtle
            ] [
              ; Initialiser les stocks actuels
              set max-fruit-stock init-patch-max-fruit-stock
              set max-leaf-stock init-patch-max-leaf-stock
              set max-wood-stock init-patch-max-wood-stock
              set current-fruit-stock (max-fruit-stock / 2)
              set current-leaf-stock (max-leaf-stock / 2)
              set current-wood-stock max-wood-stock
              set tree-sensitivity init-patch-sensitivity
              let nutritive-nutritional-values get-tree-nutritional-values tree-type [soil-type] of patch-here current-season
              set tree-UF-per-kg-MS item 0 nutritive-nutritional-values
              set tree-MAD-per-kg-MS item 1 nutritive-nutritional-values

              hide-turtle
            ]
          ]
        ]
      ]
    ]


    if num-fruity > 0 [
      let input-tree-type "fruity"
      ; Répartir la population en groupes d'âge
      let age-distribution split-population num-fruity
      let num-ages length age-distribution
      let indices range length age-distribution
      ; Boucle sur les âges
      foreach indices [ [i]->
        let pop-size item i age-distribution
        let tree-age ifelse-value (i < 7) [i + 1] [8]

        ; Obtenir les données pour ce type d'arbre et cet âge
        let age-data get-age-data input-tree-type tree-age

        ; Vérifier si les données pour cet âge existent
        if age-data != [] [
          ; Extraire les valeurs de stocks et de sensibilité
          let max-fruit item 0 age-data
          let max-leaf item 1 age-data
          let max-wood item 2 age-data
          let sensitivity item 3 age-data

          ; Stocker les valeurs dans les variables de patch
          set intermediate-patch-pop-size pop-size
          set intermediate-patch-tree-age tree-age
          set intermediate-patch-tree-type input-tree-type
          set init-patch-max-fruit-stock max-fruit * pop-size
          set init-patch-max-leaf-stock max-leaf * pop-size
          set init-patch-max-wood-stock max-wood * pop-size
          set init-patch-sensitivity sensitivity


          ; Créer une population d'arbres sur le patch
          sprout-tree-populations 1 [
            set tree-type intermediate-patch-tree-type
            set tree-pop-age intermediate-patch-tree-age
            set population-size intermediate-patch-pop-size

            ifelse population-size = 0 [
              ; Si la population est nulle, définir toutes les ressources à zéro
              set current-wood-stock 0
              set current-fruit-stock 0
              set current-leaf-stock 0
              set max-wood-stock 0
              set max-fruit-stock 0
              set max-leaf-stock 0
              hide-turtle
            ] [
              ; Initialiser les stocks actuels
              set max-fruit-stock init-patch-max-fruit-stock
              set max-leaf-stock init-patch-max-leaf-stock
              set max-wood-stock init-patch-max-wood-stock
              set current-fruit-stock (max-fruit-stock / 2)
              set current-leaf-stock (max-leaf-stock / 2)
              set current-wood-stock max-wood-stock
              set tree-sensitivity init-patch-sensitivity
              let nutritive-nutritional-values get-tree-nutritional-values tree-type [soil-type] of patch-here current-season
              set tree-UF-per-kg-MS item 0 nutritive-nutritional-values
              set tree-MAD-per-kg-MS item 1 nutritive-nutritional-values

              hide-turtle
            ]
            ]
          ]
        ]
    ]
    let mature-tree-populations tree-populations-here with [tree-pop-age >= 8]
    if any? mature-tree-populations [
      let total-population sum [population-size] of mature-tree-populations
      ;; Créer une tortue pour représenter les arbres matures
      sprout-mature-tree-pops 1 [
        set shape "tree"
        set color green
        set size calculate-tree-icon-size total-population  ;; Taille proportionnelle à la population
                                                            ;; Positionner la tortue au centre du patch avec un décalage aléatoire
        set xcor xcor + (random-float 0.9 - 0.45)
        set ycor ycor + (random-float 0.9 - 0.45)
      ]
    ]
  ]

end




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Visualisation ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to update-visualization
  if visualization-mode = "soil-type" [
    ask patches [
      if soil-type = "Baldiol" [set pcolor green]
      if soil-type = "Caangol" [set pcolor orange]
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
  if visualization-mode = "grass-qualit" [
    display-grass-quality
  ]
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Stepping ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



  ;;;;;;;;;;;;;;;;;;;;
  ;;; Step général ;;;
  ;;;;;;;;;;;;;;;;;;;;

to go

  ; Mise à jour du modèle général et temporalité
  update-season
  if current-season != last-season [
    update-UF-and-MAD                 ; Mettre à jour les valeurs de MAD et UF pour le tapis herbacé
    update-tree-nutritional-values    ; Mettre à jour les valeurs de MAD et UF pour les arbres
    update-grass-quality              ; Indiquer la qualité de l'herbe
    set last-season current-season    ; Permet au counter d'identifier quand la saison change
    update-tree-visualisation
  ]

  ; Vérifiez si une année complète s'est écoulée
  if year-counter >= total-ticks-per-year [
    set year-counter 0                ; Au premier jour de chaque nouvelle année, remet le compteur d'année à 0
    set renewal-flag false            ; Au premier jour de chaque nouvelle année, relance la création d'une nouvelle population d'arbres d'un an
    update-year-type                  ; Au premier jour de chaque nouvelle année, redéfinit si l'année sera bonne, moyenne, mauvaise
    set-season-durations              ; Au premier jour de chaque nouvelle année et en fonction de l'année, redéfinit les durées pour chacune des siaosn pour l'année en cours
    update-tree-age                   ; Au premier jour de chaque nouvelle année, fait grandir les populations d'arbres d'un an
    renew-tree-population             ; Au premier jour de chaque nouvelle année, crée une nouvelle population d'arbres d'un an
    ask patches [assign-grass-proportions  ]        ; Au premier jour de chaque nouvelle année, relance la génération aléatoire des proportions en monocotylédone et dicotylédone
    call-back-herds
  ]

  ; Mise à jour des ressources
  grow-grass
  grow-tree-resources

  ; Activités des agents
  move-and-eat                        ; Activités quotidiennes du couple Berger-Troupeau

  choose-strategy                     ; Choix stratégiques pastoraux du chef de ménage

  ; Visuel
  ask patches [
    color-grass
    ;color-trees
  ]

  update-visualization
  tick
end

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; Retour des troupeaux ;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to call-back-herds
  ;; Retour des troupeaux de bovins
  ask cattles with [have-left = true] [
    show-turtle
    set have-left false
  ]

  ;; Retour des troupeaux de moutons
  ask sheeps with [have-left = true] [
    show-turtle
    set have-left false
  ]
end


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; Mise à jour des saisons ;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to update-season
  ; Incrémentation des saisons et années
  set season-counter season-counter + 1
  set year-counter year-counter + 1

  if current-season = "Nduungu" and season-counter >= nduungu-duration [
    ; Stocker la biomasse à la fin de Nduungu
    ask patches [
      set monocot-grass-end-nduungu current-monocot-grass
      set dicot-grass-end-nduungu current-dicot-grass
      set ticks-since-dabbuunde 0  ; Réinitialiser le compteur de ticks depuis Dabbuunde
    ]
    set current-season "Dabbuunde"
    set season-counter 0
  ]
  if current-season = "Dabbuunde" and season-counter >= dabbuunde-duration [
    set current-season "Ceedu"
    set season-counter 0
  ]
  if current-season = "Ceedu" and season-counter >= ceedu-duration [
    set current-season "Ceetcelde"
    set season-counter 0
  ]
  if current-season = "Ceetcelde" and season-counter >= ceetcelde-duration [
    set current-season "Nduungu"
    set season-counter 0
    ; Mise à jour de l'année
  ]
end


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; Mise à jour des valeurs nutritives de l'herbe ;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to update-UF-and-MAD
  ask patches [
    ; Définir les valeurs pour les monocotylédones et dicotyledones
    if current-season = "Nduungu" [
      set monocot-UF-per-kg-MS 0.7
      set monocot-MAD-per-kg-MS 80
      set dicot-UF-per-kg-MS 0.7
      set dicot-MAD-per-kg-MS 80
    ]
    if current-season = "Dabbuunde" [
      set monocot-UF-per-kg-MS 0.7
      set monocot-MAD-per-kg-MS 80
      set dicot-UF-per-kg-MS 0.7
      set dicot-MAD-per-kg-MS 80
    ]
    if current-season = "Ceedu" [
      set monocot-UF-per-kg-MS 0.7
      set monocot-MAD-per-kg-MS 80
      set dicot-UF-per-kg-MS 0.7
      set dicot-MAD-per-kg-MS 80
    ]
    if current-season = "Ceetcelde" [
      set monocot-UF-per-kg-MS 0.7
      set monocot-MAD-per-kg-MS 80
      set dicot-UF-per-kg-MS 0.7
      set dicot-MAD-per-kg-MS 80
    ]
  ]
end



  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; Mise à jour des valeurs nutritives des arbres ;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to update-tree-nutritional-values
  ask tree-populations [
    let nutritional-values get-tree-nutritional-values tree-type [soil-type] of patch-here current-season
    set tree-UF-per-kg-MS item 0 nutritional-values
    set tree-MAD-per-kg-MS item 1 nutritional-values
  ]
end




  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; Mise à jour des proportions d'herbe ;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to assign-grass-proportions ; Réassigner la proportion de monocotylédones (p) en fonction du type de sol

    if soil-type = "Baldiol" [
      set p random-float (0.0 - 0.2) + 0.4  ; Intervalle [0.4, 0.6]
    ]
    if soil-type = "Caangol" [
      set p random-float (0.0 - 0.3) + 0.5  ; Intervalle [0.5, 0.8]
    ]
    if soil-type = "Sangre" [
      set p random-float (0.0 - 0.3) + 0.2  ; Intervalle [0.2, 0.5]
    ]
    if soil-type = "Seeno" [
      set p random-float (0.0 - 0.2) + 0.8  ; Intervalle [0.6, 0.8]
    ]

    ; Assurer que p est entre 0 et 1
    set p max list 0.2 (min list p 1)

    ; Réinitialiser les stocks d'herbe en fonction des nouvelles proportions
    set current-monocot-grass current-grass * p
    set current-dicot-grass current-grass * (1 - p)
end




  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; Mise à jour de la qualité de l'herbe ;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to update-grass-quality ; - Version 2
  ask patches [
    ; Calculer le rapport MAD/UF pour les monocotylédones
    let monocot-MAD-UF-ratio monocot-MAD-per-kg-MS / monocot-UF-per-kg-MS
    ; Calculer le rapport MAD/UF pour les dicotylédones
    let dicot-MAD-UF-ratio dicot-MAD-per-kg-MS / dicot-UF-per-kg-MS

    ; Calculer la moyenne pondérée des rapports en fonction de la proportion de chaque type
    let average-MAD-UF-ratio (monocot-MAD-UF-ratio * p) + (dicot-MAD-UF-ratio * (1 - p))


    ; Déterminer la qualité de l'herbe en fonction du rapport moyen MAD/UF
    ifelse average-MAD-UF-ratio >= seuil-bon [
      set grass-quality "good"
      ] [ ifelse average-MAD-UF-ratio >= seuil-moyen [
        set grass-quality "average"
      ] [
        set grass-quality "poor"
      ]
      ; Assigner q basé sur la qualité actuelle de l'herbe
      set q grass-quality-to-q grass-quality
    ]
  ]
end
;to update-grass-quality - version 1
 ; ask patches [
  ;  if (any? patches with [grass-quality-nduungu = 0 and grass-quality-ceetcelde = 0]) [  ; Vérifie si c'est la première année
   ;   if soil-type = "Baldiol" [                                                              ; qualité : "good" = 3 ; "average" = 2 ; "bad" = 1
    ;    let rand random-float 1
     ;   if current-season = "Ceedu" [
      ;    ifelse rand < 0.5 [set grass-quality-ceedu "good"]
       ;   [ifelse rand < 0.75 [set grass-quality-ceedu "average"]
        ;    [set grass-quality-ceedu "poor"]]
;        ]
 ;       if current-season = "Nduungu" [
  ;        ifelse rand < 0.25 [set grass-quality-nduungu "good"]
   ;       [ifelse rand < 0.5 [set grass-quality-nduungu "average"]
    ;        [set grass-quality-nduungu "poor"]]
     ;   ]
      ;  if current-season = "Dabbuunde" [
       ;   ifelse rand < 0.1 [set grass-quality-dabbuunde "good"]
        ;  [ifelse rand < 0.3 [set grass-quality-dabbuunde "average"]
         ;   [set grass-quality-dabbuunde "poor"]]
;        ]
 ;       if current-season = "Ceetcelde" [
  ;        ifelse rand < 0.4 [set grass-quality-ceetcelde "good"]
   ;       [ifelse rand < 0.7 [set grass-quality-ceetcelde "average"]
    ;        [set grass-quality-ceetcelde "poor"]]
     ;   ]
      ;]
;      if soil-type = "Caangol" [
 ;       let rand random-float 1
  ;      if current-season = "Ceedu" [
   ;       ifelse rand < 0.5 [set grass-quality-ceedu "good"]
    ;      [ifelse rand < 0.75 [set grass-quality-ceedu "average"]
     ;       [set grass-quality-ceedu "poor"]]
      ;  ]
;        if current-season = "Nduungu" [
 ;         ifelse rand < 0.25 [set grass-quality-nduungu "good"]
  ;        [ifelse rand < 0.5 [set grass-quality-nduungu "average"]
   ;         [set grass-quality-nduungu "poor"]]
    ;    ]
;        if current-season = "Dabbuunde" [
 ;         ifelse rand < 0.1 [set grass-quality-dabbuunde "good"]
  ;        [ifelse rand < 0.3 [set grass-quality-dabbuunde "average"]
   ;         [set grass-quality-dabbuunde "poor"]]
    ;    ]
;        if current-season = "Ceetcelde" [
 ;         ifelse rand < 0.4 [set grass-quality-ceetcelde "good"]
  ;        [ifelse rand < 0.7 [set grass-quality-ceetcelde "average"]
   ;         [set grass-quality-ceetcelde "poor"]]
    ;    ]
     ; ]
;      if soil-type = "Sangre" [
 ;       let rand random-float 1
  ;      if current-season = "Ceedu" [
   ;       ifelse rand < 0.5 [set grass-quality-ceedu "good"]
    ;      [ifelse rand < 0.75 [set grass-quality-ceedu "average"]
     ;       [set grass-quality-ceedu "poor"]]
      ;  ]
       ; if current-season = "Nduungu" [
        ;  ifelse rand < 0.25 [set grass-quality-nduungu "good"]
         ; [ifelse rand < 0.5 [set grass-quality-nduungu "average"]
          ;  [set grass-quality-nduungu "poor"]]
        ;]
        ;if current-season = "Dabbuunde" [
         ; ifelse rand < 0.1 [set grass-quality-dabbuunde "good"]
          ;[ifelse rand < 0.3 [set grass-quality-dabbuunde "average"]
           ; [set grass-quality-dabbuunde "poor"]]
        ;]
        ;if current-season = "Ceetcelde" [
         ; ifelse rand < 0.4 [set grass-quality-ceetcelde "good"]
          ;[ifelse rand < 0.7 [set grass-quality-ceetcelde "average"]
           ; [set grass-quality-ceetcelde "poor"]]
        ;]
      ;]
 ;     if soil-type = "Seeno" [
 ;       let rand random-float 1
 ;       if current-season = "Ceedu" [
  ;        ifelse rand < 0.5 [set grass-quality-ceedu "good"]
  ;        [ifelse rand < 0.75 [set grass-quality-ceedu "average"]
 ;           [set grass-quality-ceedu "poor"]]
 ;       ]
;        if current-season = "Nduungu" [
 ;         ifelse rand < 0.25 [set grass-quality-nduungu "good"]
 ;         [ifelse rand < 0.5 [set grass-quality-nduungu "average"]
 ;           [set grass-quality-nduungu "poor"]]
 ;       ]
  ;      if current-season = "Dabbuunde" [
 ;         ifelse rand < 0.1 [set grass-quality-dabbuunde "good"]
 ;         [ifelse rand < 0.3 [set grass-quality-dabbuunde "average"]
 ;           [set grass-quality-dabbuunde "poor"]]
  ;      ]
  ;      if current-season = "Ceetcelde" [
   ;       ifelse rand < 0.4 [set grass-quality-ceetcelde "good"] ;
  ;        [ifelse rand < 0.7 [set grass-quality-ceetcelde "average"]
;            [set grass-quality-ceetcelde "poor"]]
;        ]
;      ]
;      if current-season = "Ceedu" [set grass-quality grass-quality-ceedu]
;      if current-season = "Nduungu" [set grass-quality grass-quality-nduungu]
;      if current-season = "Dabbuunde" [set grass-quality grass-quality-dabbuunde]
;      if current-season = "Ceetcelde" [set grass-quality grass-quality-ceetcelde]


      ; Assigner q basé sur la qualité actuelle de l'herbe
;      set q grass-quality-to-q grass-quality
;      set p grass-quality-to-p grass-quality
   ; (Si vous avez besoin de stocker q, vous pouvez le faire ici)


 ;   ] [
    ;; Pour les années suivantes, réutilise la qualité de l'herbe de l'année précédente ;; Abandonné après discussion car inadapté selon le discours des acteurs
    ;  if current-season = "Ceedu" [set grass-quality grass-quality-ceedu]
     ; if current-season = "Nduungu" [set grass-quality grass-quality-nduungu]
      ;if current-season = "Dabbuunde" [set grass-quality grass-quality-dabbuunde]
      ;if current-season = "Ceetcelde" [set grass-quality grass-quality-ceetcelde]
    ;]
  ;]

;end


to update-tree-visualisation
  ;; Supprimer les anciennes icônes
  ask mature-tree-pops [ die ]
  ;; Créer de nouvelles icônes pour les arbres matures
  ask patches [
    let mature-tree-populations tree-populations-here with [tree-pop-age >= 8]
    if any? mature-tree-populations [
      let total-population sum [population-size] of mature-tree-populations
      sprout-mature-tree-pops 1 [
        set shape "tree"
        set color green
        set size calculate-tree-icon-size total-population
        set xcor xcor + (random-float 0.9 - 0.45)
        set ycor ycor + (random-float 0.9 - 0.45)
      ]
    ]
  ]
end


to grow-grass  ; - Version 2.2.
  ask patches [
    if current-season = "Nduungu" [
      ; Croissance logistique pendant Nduungu
      let r_grass 0.1  ; Taux de croissance, ajustez selon vos besoins
                 ; Croissance logistique pour les monocotylédones
      let new-mono-grass current-monocot-grass + r_grass * current-monocot-grass * (K * p - current-monocot-grass) / (K * p)
      set current-monocot-grass min (list new-mono-grass (K * p))

      ; Croissance logistique pour les dicotylédones
      let new-dicot-grass current-dicot-grass + r_grass * current-dicot-grass * (K * (1 - p) - current-dicot-grass) / (K * (1 - p))
      set current-dicot-grass min (list new-dicot-grass (K * (1 - p)))

      ; Mettre à jour le stock total d'herbe
      set current-grass current-monocot-grass + current-dicot-grass
      ;  let new-current-grass current-grass + r * current-grass * (K - current-grass) / K
      ;  set current-grass min (list new-current-grass K)

    ]
    if current-season = "Dabbuunde" or current-season = "Ceedu" [
      ; Initialiser total-ticks-to-mid-ceedu si nécessaire
      if ticks-since-dabbuunde = 0 [
        set total-dry-season-ticks (dabbuunde-duration + ceedu-duration)
      ]
      if ticks-since-dabbuunde <= total-dry-season-ticks [
        ; Perte de biomasse décroissante jusqu'à la mi-Ceedu
        let loss_percentage 0.2
        let proportion_of_period ticks-since-dabbuunde / total-dry-season-ticks
        ; Calculer la perte par tick pour les monocotylédones
        let per_tick_loss_mono (2 * monocot-grass-end-nduungu * (loss_percentage / total-dry-season-ticks)) * (1 - proportion_of_period)
        set current-monocot-grass current-monocot-grass - per_tick_loss_mono

        ; Calculer la perte par tick pour les dicotylédones
        let per_tick_loss_dicot (2 * dicot-grass-end-nduungu * (loss_percentage / total-dry-season-ticks)) * (1 - proportion_of_period)
        set current-dicot-grass current-dicot-grass - per_tick_loss_dicot

        ; Mettre à jour le stock total d'herbe
        set current-grass current-monocot-grass + current-dicot-grass

        ; Incrémenter ticks-since-dabbuunde
        set ticks-since-dabbuunde ticks-since-dabbuunde + 1
      ]
      if current-season = "Ceetcelde" [
        ; Réduction constante pour les deux types
        let reduction_rate 0.99  ; Même pour les deux types

        set current-monocot-grass current-monocot-grass * reduction_rate
        set current-dicot-grass current-dicot-grass * reduction_rate

        ; Mettre à jour le stock total d'herbe
        set current-grass current-monocot-grass + current-dicot-grass
      ]
      ; Assurer que les valeurs restent positives
      if current-monocot-grass < 0 [ set current-monocot-grass 0.000000001 ]
      if current-dicot-grass < 0 [ set current-dicot-grass 0.000000001]
      if current-grass < 0 [ set current-grass 0.000000001 ]
    ]
  ]
end
;to grow-grass - Version 1
;  let r 0
;  if current-season = "Ceedu" [set r 0.00001]
;  if current-season = "Ceetcelde" [set r 0.000005]
;  if current-season = "Dabbuunde" [set r 0.000002]
;  if current-season = "Nduungu" [set r 0.01]


to update-tree-age
  ; Si une année s'est écoulée
  let advancing-populations []
  ; 2. Incrémenter l'âge de toutes les populations d'arbres
  ask tree-populations [
    if tree-pop-age < 8 [
      set tree-pop-age tree-pop-age + 1
      ; Mettre à jour les stocks maximaux pour le nouvel âge
      let age-data get-age-data tree-type tree-pop-age
      let max-fruit item 0 age-data
      let max-leaf item 1 age-data
      let max-wood item 2 age-data
      let sensitivity item 3 age-data
      set max-wood-stock max-wood * population-size
      set max-fruit-stock max-fruit * population-size
      set max-leaf-stock max-leaf * population-size
      set tree-sensitivity sensitivity

      if tree-pop-age = 8 [
        set advancing-populations lput (list patch-here tree-type population-size current-fruit-stock current-leaf-stock current-wood-stock) advancing-populations
        die
      ]
    ]
  ]

  ; Traiter les populations avancées
  foreach advancing-populations [ any-adv-population ->
    let adv-patch item 0 any-adv-population
    let adv-tree-type item 1 any-adv-population
    let adv-pop-size item 2 any-adv-population
    let adv-fruit-stock item 3 any-adv-population
    let adv-leaf-stock item 4 any-adv-population
    let adv-wood-stock item 5 any-adv-population
    let existing-population one-of tree-populations with [
      patch-here = adv-patch and tree-type = adv-tree-type and tree-pop-age = 8
    ]
    ifelse existing-population != nobody [
      ; Ajouter la taille de la population qui passe à l'âge 8
      ask existing-population [
        set population-size population-size + adv-pop-size
        ; Mettre à jour les stocks maximaux
        let age-data get-age-data tree-type tree-pop-age
        let max-fruit item 0 age-data
        let max-leaf item 1 age-data
        let max-wood item 2 age-data
        set max-wood-stock max-wood * population-size
        set max-fruit-stock max-fruit * population-size
        set max-leaf-stock max-leaf * population-size

        set current-fruit-stock current-fruit-stock + adv-fruit-stock
        set current-leaf-stock current-leaf-stock + adv-leaf-stock
        set current-wood-stock current-wood-stock + adv-wood-stock
        ; Mettre à jour les stocks actuels si nécessaire
      ]


    ] [
      ; Créer une nouvelle population d'arbres à l'âge 8
      ask adv-patch [
        sprout-tree-populations 1 [
          set tree-type adv-tree-type
          set tree-pop-age 8
          set population-size adv-pop-size
          ; Initialiser les stocks
          let age-data get-age-data tree-type tree-pop-age
          let max-fruit item 0 age-data
          let max-leaf item 1 age-data
          let max-wood item 2 age-data
          set max-fruit-stock item 0 max-fruit * population-size
          set max-leaf-stock item 1 max-leaf * population-size
          set max-wood-stock item 2 max-wood  * population-size
          ; Initialiser les stocks actuels
          set current-fruit-stock adv-fruit-stock
          set current-leaf-stock adv-leaf-stock
          set current-wood-stock adv-wood-stock
          hide-turtle
        ]
      ]
    ]
  ]
end



  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; Mise à jour des types d'années ;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to update-year-type
  ; Vérifier qu'on ne dépasse pas la liste
  if year-counter >= total-ticks-per-year [
    set year-index year-index + 1
  ]
  ; Obtenir le type d'année
  set current-year-type item year-index year-types
end



  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; Mise à jour des durées de saison en fonction du type d'année ;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to set-season-durations
  if current-year-type = "bonne" [
    ;; Par exemple : les bonnes années peuvent avoir une plus longue saison de croissance
    set nduungu-duration 120
    set dabbuunde-duration 60
    set ceedu-duration 175
    set ceetcelde-duration 10
  ]
  if current-year-type = "moyenne" [
    set nduungu-duration 90
    set dabbuunde-duration 60
    set ceedu-duration 175
    set ceetcelde-duration 40
  ]
  if current-year-type = "mauvaise" [
    set nduungu-duration 60
    set dabbuunde-duration 60
    set ceedu-duration 175
    set ceetcelde-duration 70
  ]

  ; calculer le nombre de ticks dans l'année
  set total-ticks-per-year nduungu-duration + dabbuunde-duration + ceedu-duration + ceetcelde-duration
end



  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; Création de nouvelles populations d'arbres d'un an ;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to renew-tree-population
  let total-new-trees 0
  ; Cette procédure sera appelée uniquement en Nduungu une fois par saison
  if renewal-flag = false [
    ask patches [
      let new-trees-by-type []

      ; Calculer le nombre de nouvelles pousses pour chaque type d'arbre sur le patch
      ask tree-populations-here [
        ; Récupérer le taux de germination pour le type d'arbre et la qualité de l'année
        let germination-rate get-germination-rate tree-type current-year-type
        ; Calculer les nouvelles pousses
        let new-trees floor (current-fruit-stock * germination-rate)

        ; Ajouter les nouvelles pousses au total pour ce type d'arbre
        let current-type-entry filter [x -> item 0 x = tree-type] new-trees-by-type
        ifelse length current-type-entry > 0 [
          ; Si le type existe déjà, additionner les nouvelles pousses à la quantité existante
          let existing-entry first current-type-entry
          set new-trees-by-type replace-item (position existing-entry new-trees-by-type) new-trees-by-type
          (list tree-type (item 1 existing-entry + new-trees))
        ] [
          ; Sinon, créer une nouvelle entrée pour ce type d'arbre
          set new-trees-by-type lput (list tree-type new-trees) new-trees-by-type
        ]
      ]

      ; Créer de nouvelles populations d'arbres pour chaque type d'arbre en fonction des nouvelles pousses calculées
      foreach new-trees-by-type [ [type-and-count] ->
        let new-tree-type item 0 type-and-count
        let number item 1 type-and-count
        if number > 0 [
          sprout-tree-populations 1 [
            set tree-type new-tree-type
            set tree-pop-age 1
            set population-size number
            ; Initialiser les stocks actuels
            let age-data get-age-data tree-type tree-pop-age
            set max-fruit-stock item 0 age-data * population-size
            set max-leaf-stock item 1 age-data * population-size
            set max-wood-stock item 2 age-data * population-size
            set current-fruit-stock (max-fruit-stock / 2)
            set current-leaf-stock (max-leaf-stock / 2)
            set current-wood-stock max-wood-stock
            set tree-sensitivity item 3 age-data
            let nutritional-values get-tree-nutritional-values tree-type [soil-type] of patch-here current-season
            set tree-UF-per-kg-MS item 0 nutritional-values
            set tree-MAD-per-kg-MS item 1 nutritional-values
            hide-turtle
          ]
        ]
      ]
      ; Marquer le renouvellement comme effectué pour cette saison
      set renewal-flag true
    ]
  ]
end



  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; Croissance des stocks des ressources des arbres ;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to grow-tree-resources
  ask tree-populations with [population-size > 0] [
        let age-data get-age-data tree-type tree-pop-age
        let max-fruit item 0 age-data
        let max-leaf item 1 age-data
        let max-wood item 2 age-data
        set max-wood-stock max-wood * population-size

    ; Réactualiser le max de bois en fonction de la population restante


    ; Croissance ou décroissance logistique du bois
    let wood-growth growth-wood-logistic tree-type tree-pop-age population-size current-wood-stock max-wood-stock
    let new-wood-stock current-wood-stock + wood-growth
    set current-wood-stock min (list new-wood-stock max-wood-stock)

    ; Ratio de bois par population
    set wood-ratio calculate-wood-ratio

    ; Réactualiser le max de fruits et feuilles  en fonction de la population restante et du bois
    set max-fruit-stock max-fruit * population-size * wood-ratio
    set max-leaf-stock max-leaf * population-size * wood-ratio

    ; Croissance ou décroissance logistique des fruits
    let fruit-growth growth-fruit-logistic tree-type tree-pop-age population-size current-fruit-stock max-fruit-stock
    let new-fruit-stock current-fruit-stock + fruit-growth
    set current-fruit-stock min (list new-fruit-stock max-fruit-stock)

    ; Croissance ou décroissance logistique des feuilles
    let leaf-growth growth-leaf-logistic tree-type tree-pop-age population-size current-leaf-stock max-leaf-stock
    let new-leaf-stock current-leaf-stock + leaf-growth
    set current-leaf-stock min (list new-leaf-stock max-leaf-stock)
  ]

end


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; Stratégie alimentaire du troupeau ;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to move-and-eat ; Mouvement et consommation des troupeaux - bovins puis ovins

  ask cattles with [have-left = false] [
  ;; Find the best patch within known space
    let best-patch find-best-nearest-patch known-space
    let my-home-patch current-home-patch
    move-to current-home-patch
    set DM-ingested 0
    set UF-ingested 0
    set MAD-ingested 0

    if best-patch != nobody [
      ;; Calculate the distance between the best patch and the current home patch
      let distance-to-home distance best-patch

      ;; If the best patch is more than 12 units away from the current home patch
      ifelse distance-to-home >= 12 [

        ;; Check if the herd is not already in a temporary camp
        ifelse not is-in-temporary-camp [

          ;; Create a temporary camp if not already in one
          set current-home-patch best-patch
          set is-in-temporary-camp true
          move-to current-home-patch
          set xcor xcor + (random-float 0.9 - 0.45)
          set ycor ycor + (random-float 0.9 - 0.45)

          ;; Add patches within a radius of 3 cells around the camp to known-space
          let nearby-patches [patches in-radius 3] of current-home-patch
          set known-space (patch-set known-space nearby-patches)

          ;; Update close-known-space and distant
          set close-known-space known-space in-radius 12
          set distant-known-space known-space who-are-not close-known-space

        ] [ ;; The herd is already in a temporary camp

          ;; Check if the best patch is in the original camp known space
          ifelse member? best-patch original-camp-known-space [

            ;; Move to the best patch
            move-to best-patch
            set xcor xcor + (random-float 0.9 - 0.45)
            set ycor ycor + (random-float 0.9 - 0.45)

            ;; Return to the original camp
            set current-home-patch original-home-patch
            set current-home-camp original-home-camp
            set is-in-temporary-camp false
            set known-space [known-space] of foyer-owner
            set close-known-space [close-known-space] of foyer-owner
            set distant-known-space [distant-known-space] of foyer-owner

          ] [
            ;; Create a temporary camp
            set current-home-patch best-patch
            set is-in-temporary-camp true
            move-to current-home-patch
            set xcor xcor + (random-float 0.9 - 0.45)
            set ycor ycor + (random-float 0.9 - 0.45)

            ;; Add patches within a radius of 3 cells around the camp to known-space
            let nearby-patches [patches in-radius 3] of current-home-patch
            set known-space (patch-set known-space nearby-patches)

            ;; Update close-known-space and distant
            set close-known-space known-space in-radius 12
            set distant-known-space known-space who-are-not close-known-space
          ]
        ]
      ] [ ;; The best patch is within 12 units of the current home patch

        ;; Move to the best patch
        move-to best-patch
        set xcor xcor + (random-float 0.9 - 0.45)
        set ycor ycor + (random-float 0.9 - 0.45)
      ]
    ]
    ; Déterminer la préférence pour les monocotylédones
    let preference-mono 0.5  ; Valeur par défaut

    ifelse current-season = "Nduungu" [
      ; En Nduungu, préférence de 80% pour les monocotylédones
      set preference-mono 0.8
    ] [
      ; Pendant les autres saisons, préférence de 80% pour l'espèce avec le ratio MAD/UF le plus élevé
      let monocot-MAD-UF-ratio [monocot-MAD-per-kg-MS] of patch-here / [monocot-UF-per-kg-MS] of patch-here
      let dicot-MAD-UF-ratio [dicot-MAD-per-kg-MS] of patch-here / [dicot-UF-per-kg-MS] of patch-here

      ifelse monocot-MAD-UF-ratio >= dicot-MAD-UF-ratio [
        set preference-mono 0.8
      ] [
        set preference-mono 0.5
      ]
    ]

    ; Calculer l'UF/kg MS moyen du fourrage disponible
    let monocot-prop [current-monocot-grass] of patch-here / [current-grass] of patch-here
    let average-UF-per-kg-MS ([monocot-UF-per-kg-MS] of patch-here * monocot-prop) + ([dicot-UF-per-kg-MS] of patch-here * (1 - monocot-prop))

    ; Calculer la MAD/kg MS moyenne du fourrage disponible
    let dicot-prop [current-monocot-grass] of patch-here / [current-grass] of patch-here
    let average-MAD-per-kg-MS ([monocot-MAD-per-kg-MS] of patch-here * preference-mono) + ([dicot-MAD-per-kg-MS] of patch-here * (1 - preference-mono))

    ; Calculer la quantité de MS à consommer en fonction de la valeur moyenne du fourrage disponible en UF. Plus la valeur est forte, plus il en mangera
    let desired-MS-intake-per-head (max-daily-DM-ingestible-per-head * 0.5  + (max-daily-DM-ingestible-per-head * 0.5)  * average-UF-per-kg-MS)
    ; Assurer que la consommation ne dépasse pas max-daily-DM-ingestible-per-head
    set desired-MS-intake-per-head min list desired-MS-intake-per-head max-daily-DM-ingestible-per-head

    ; Calculer les besoins énergétiques (UF) et protéiques (MAD) qui peut évoluer à chaque step en fonction du nombre de tête dans le troupeau
    let daily-needs-UF daily-min-UF-needed-head * head
    let daily-needs-MAD daily-min-UF-needed-head * head

    ; Consommer l'herbe
    consume-grass patch-here (desired-MS-intake-per-head * head) p preference-mono

    ; Calculer le reste de MS à consommer en fonction de la consommation journalière maximale et la quantité voulue à consommer par le troupeau
    let remaining-DM-to-consume (max-daily-DM-ingestible-per-head * head) - (desired-MS-intake-per-head * head)

    if remaining-DM-to-consume > 0 [
      consume-tree-resources patch-here remaining-DM-to-consume
    ]

    ; Mettre à jour la condition corporelle en fonction des UF et MAD ingérées
    update-corporal-conditions head UF-ingested MAD-ingested daily-needs-UF daily-needs-MAD preference-mono
  ]

  ;; Mouvement et consommation des ovins (à adapter de manière similaire)
  ask sheeps with [have-left = false] [
    ;; Find the best patch within known space
    let best-patch find-best-nearest-patch known-space
    let my-home-patch current-home-patch
    move-to current-home-patch
    set DM-ingested 0
    set UF-ingested 0
    set MAD-ingested 0

    if best-patch != nobody [
      ;; Calculate the distance between the best patch and the current home patch
      let distance-to-home distance best-patch

      ;; If the best patch is more than 12 units away from the current home patch
      ifelse distance-to-home >= 12 [

        ;; Check if the herd is not already in a temporary camp
        ifelse not is-in-temporary-camp [

          ;; Create a temporary camp if not already in one
          set current-home-patch best-patch
          set is-in-temporary-camp true
          move-to current-home-patch
          set xcor xcor + (random-float 0.9 - 0.45)
          set ycor ycor + (random-float 0.9 - 0.45)

          ;; Add patches within a radius of 3 cells around the camp to known-space
          let nearby-patches [patches in-radius 3] of current-home-patch
          set known-space (patch-set known-space nearby-patches)

          ;; Update close-known-space and distant
          set close-known-space known-space in-radius 12
          set distant-known-space known-space who-are-not close-known-space

        ] [ ;; The herd is already in a temporary camp

          ;; Check if the best patch is in the original camp known space
          ifelse member? best-patch original-camp-known-space [

            ;; Move to the best patch
            move-to best-patch
            set xcor xcor + (random-float 0.9 - 0.45)
            set ycor ycor + (random-float 0.9 - 0.45)

            ;; Return to the original camp
            set current-home-patch original-home-patch
            set current-home-camp original-home-camp
            set is-in-temporary-camp false
            set known-space [known-space] of foyer-owner
            set close-known-space [close-known-space] of foyer-owner
            set distant-known-space [distant-known-space] of foyer-owner

          ] [
            ;; Create a temporary camp
            set current-home-patch best-patch
            set is-in-temporary-camp true
            move-to current-home-patch
            set xcor xcor + (random-float 0.9 - 0.45)
            set ycor ycor + (random-float 0.9 - 0.45)

            ;; Add patches within a radius of 3 cells around the camp to known-space
            let nearby-patches [patches in-radius 3] of current-home-patch
            set known-space (patch-set known-space nearby-patches)

            ;; Update close-known-space and distant
            set close-known-space known-space in-radius 12
            set distant-known-space known-space who-are-not close-known-space
          ]
        ]
      ] [ ;; The best patch is within 12 units of the current home patch

        ;; Move to the best patch
        move-to best-patch
        set xcor xcor + (random-float 0.9 - 0.45)
        set ycor ycor + (random-float 0.9 - 0.45)
      ]
    ]
    ; Déterminer la préférence pour les monocotylédones
    let preference-mono 0.5  ; Valeur par défaut

    ifelse current-season = "Nduungu" [
      ; En Nduungu, préférence de 80% pour les monocotylédones
      set preference-mono 0.8
    ] [
      ; Pendant les autres saisons, préférence de 80% pour l'espèce avec le ratio MAD/UF le plus élevé
      let monocot-MAD-UF-ratio [monocot-MAD-per-kg-MS] of patch-here / [monocot-UF-per-kg-MS] of patch-here
      let dicot-MAD-UF-ratio [dicot-MAD-per-kg-MS] of patch-here / [dicot-UF-per-kg-MS] of patch-here

      ifelse monocot-MAD-UF-ratio >= dicot-MAD-UF-ratio [
        set preference-mono 0.8
      ] [
        set preference-mono 0.5
      ]
    ]

    ; Calculer l'UF/kg MS moyen du fourrage disponible
    let monocot-prop [current-monocot-grass] of patch-here / [current-grass] of patch-here
    let average-UF-per-kg-MS ([monocot-UF-per-kg-MS] of patch-here * monocot-prop) + ([dicot-UF-per-kg-MS] of patch-here * (1 - monocot-prop))

    ; Calculer la MAD/kg MS moyenne du fourrage disponible
    let dicot-prop [current-monocot-grass] of patch-here / [current-grass] of patch-here
    let average-MAD-per-kg-MS ([monocot-MAD-per-kg-MS] of patch-here * preference-mono) + ([dicot-MAD-per-kg-MS] of patch-here * (1 - preference-mono))

    ; Calculer la quantité de MS à consommer en fonction de la valeur moyenne du fourrage disponible en UF. Plus la valeur est forte, plus il en mangera
    let desired-MS-intake-per-head (max-daily-DM-ingestible-per-head * 0.5  + (max-daily-DM-ingestible-per-head * 0.5)  * average-UF-per-kg-MS)
    ; Assurer que la consommation ne dépasse pas max-daily-DM-ingestible-per-head
    set desired-MS-intake-per-head min list desired-MS-intake-per-head max-daily-DM-ingestible-per-head

    ; Calculer les besoins énergétiques (UF) et protéiques (MAD) qui peut évoluer à chaque step en fonction du nombre de tête dans le troupeau
    let daily-needs-UF daily-min-UF-needed-head * head
    let daily-needs-MAD daily-min-UF-needed-head * head

    ; Consommer l'herbe
    consume-grass patch-here (desired-MS-intake-per-head * head) p preference-mono

    ; Calculer le reste de MS à consommer en fonction de la consommation journalière maximale et la quantité voulue à consommer par le troupeau
    let remaining-DM-to-consume (max-daily-DM-ingestible-per-head * head) - (desired-MS-intake-per-head * head)

    if remaining-DM-to-consume > 0 [
      consume-tree-resources patch-here remaining-DM-to-consume
    ]

    ; Mettre à jour la condition corporelle en fonction des UF et MAD ingérées
    update-corporal-conditions head UF-ingested MAD-ingested daily-needs-UF daily-needs-MAD preference-mono
  ]

end




  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; Procédure d'ingestion de l'herbe  ;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Procédure pour consommer l'herbe
to consume-grass [patch-to-eat amount monocot-prop preference-mono]


  ; Obtenir les quantités disponibles d'herbe par type sur le patch
  let mono-grass-available [current-monocot-grass] of patch-to-eat
  let dicot-grass-available [current-dicot-grass] of patch-to-eat

  ; Calculer les quantités consommées par type sur le patch
  let mono-ingested min list mono-grass-available (amount * preference-mono)
  let dicot-ingested min list dicot-grass-available (amount * (1 - preference-mono))
  set DM-ingested mono-ingested + dicot-ingested

  ; Calculer les UF ingérées
  let mono-UF-ingested mono-ingested * [monocot-UF-per-kg-MS] of patch-to-eat
  let dicot-UF-ingested dicot-ingested * [dicot-UF-per-kg-MS] of patch-to-eat
  set UF-ingested mono-UF-ingested + dicot-UF-ingested

  ; Calculer les MAD ingérées
  let mono-MAD-ingested mono-ingested * [monocot-MAD-per-kg-MS] of patch-to-eat
  let dicot-MAD-ingested dicot-ingested * [dicot-MAD-per-kg-MS] of patch-to-eat
  set MAD-ingested mono-MAD-ingested + dicot-MAD-ingested

  ; Calculer les effets de piétinement
  let trampling-effect calculate-trampling-effect current-monocot-grass current-dicot-grass head

 ;   ; La quantité d'herbe consommée est limitée par ce qui est disponible
;  ask patch-to-eat [
 ;   set current-grass current-grass - (grass-ingered + trampling-effect)
 ; ]
 ; report grass-ingered  ; Retourner la quantité d'herbe consommée

    ; Réduire les stocks d'herbe sur le patch
  ask patch-to-eat [
    set current-monocot-grass current-monocot-grass - (mono-ingested + (trampling-effect * monocot-prop))
    set current-dicot-grass current-dicot-grass - (dicot-ingested + (trampling-effect * (1 - monocot-prop)))
    set current-grass current-monocot-grass + current-dicot-grass
    if current-monocot-grass < 0 [ set current-monocot-grass 0 ]
    if current-dicot-grass < 0 [ set current-dicot-grass 0 ]
    if current-grass < 0 [ set current-grass 0 ]
  ]
end


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; Procédure d'ingestion des feuilles et fruits  ;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to consume-tree-resources [patch-of-grass-eaten remaining-needs]
  ;; Obtenir les populations d'arbres matures sur le patch
  let all-trees tree-populations-on patch-of-grass-eaten
  let consumption-treshold 0.07
  let wood-reduction-per-kg-MS 0.1; Cf Hiernaux 1994
  let consumable-trees all-trees
  ;; Arbres de plus de 5 ans
  let mature-trees all-trees with [tree-pop-age >= 6 ]

    ;; Déterminer les arbres ciblés en fonction du type de troupeau
  if shepherd-type = "bon" [
    set consumption-treshold 0.3
    ;; Priorité aux types "nutritive" et "fruity"
    set consumable-trees mature-trees with [ tree-type = "nutritive" or tree-type = "fruity" ]
    if not any? consumable-trees [
      ;; Si pas d'arbres "nutritive" ou "fruity", prendre les "less-nutritive"
      set consumption-treshold 0.5
      set wood-reduction-per-kg-MS 0.3
      set consumable-trees mature-trees with [ tree-type = "lessNutritive" ]
    ]
  ]
  if shepherd-type = "bad" [
    ;; Tous les arbres, pas de distinction
    set consumable-trees all-trees
    set consumption-treshold 0.8
    set wood-reduction-per-kg-MS 0.6
  ]

  if any? consumable-trees [
    ;; Créer une liste des populations consommables et leurs `max-consumable`
  ;; Filtrer les arbres en fonction de la disponibilité des ressources
  set consumable-trees consumable-trees with [
    (current-leaf-stock + current-fruit-stock) >= (consumption-treshold * (max-leaf-stock + max-fruit-stock))
  ]
    let tree-max-consumable []
    let total-available 0

    ask consumable-trees [
      let max_consumable (max-leaf-stock + max-fruit-stock)
      set total-available total-available + max_consumable
      set tree-max-consumable lput (list self max_consumable) tree-max-consumable
    ]

    ;; Déterminer la quantité à consommer
    let amount-to-consume min list remaining-needs total-available

    if amount-to-consume <= 0 [ set amount-to-consume 0 ]

    ;; Variables pour accumuler les UF et MAD ingérées
    let total-UF-ingested-from-trees 0
    let total-MAD-ingested-from-trees 0
    let total-DM-ingested-from-trees 0

    ;; Distribuer la consommation proportionnellement
    foreach tree-max-consumable [ [tree-and-max] ->
      let one-mature-tree-population item 0 tree-and-max
      let max-consumable item 1 tree-and-max
      let share (max-consumable / total-available)
      let amount-consumed (amount-to-consume * share)
      let total_resources ([current-leaf-stock] of one-mature-tree-population + [current-fruit-stock] of one-mature-tree-population)
      if total_resources > 0 [
        let leaves_share ([current-leaf-stock] of one-mature-tree-population / total_resources)
        let fruits_share ([current-fruit-stock] of one-mature-tree-population / total_resources)
        let leaves_consumed amount-consumed * leaves_share
        let fruits_consumed amount-consumed * fruits_share

        ;; Mettre à jour les stocks dans la population d'arbres
        ask one-mature-tree-population [
          set current-leaf-stock current-leaf-stock - leaves_consumed
          set current-fruit-stock current-fruit-stock - fruits_consumed
          if current-leaf-stock < 0 [ set current-leaf-stock 0 ]
          if current-fruit-stock < 0 [ set current-fruit-stock 0 ]
        ]

        ;; Calculer les UF et MAD ingérées depuis cette population
        ;; Hypothèse : les feuilles et les fruits ont les mêmes valeurs nutritives
        let UF-ingested-pop amount-consumed * [tree-UF-per-kg-MS] of one-mature-tree-population
        let MAD-ingested-pop amount-consumed * [tree-MAD-per-kg-MS] of one-mature-tree-population

        ;; Accumuler les valeurs
        set total-UF-ingested-from-trees total-UF-ingested-from-trees + UF-ingested-pop
        set total-MAD-ingested-from-trees total-MAD-ingested-from-trees + MAD-ingested-pop
        set total-DM-ingested-from-trees total-DM-ingested-from-trees + amount-consumed

      ]
    ]

    ;; Mettre à jour les variables du troupeau
    set UF-ingested UF-ingested + total-UF-ingested-from-trees
    set MAD-ingested MAD-ingested + total-MAD-ingested-from-trees
    set DM-ingested DM-ingested + total-DM-ingested-from-trees

    let proportion-from-trees (total-DM-ingested-from-trees / (DM-ingested * head))  ; proportion de la ration provenant des arbres
    if shepherd-type = "bad" [

      if proportion-from-trees > 0.8 [
        ;; Sélectionner un arbre au hasard parmi les arbres consommables
        if any? consumable-trees [
          let tree-to-kill one-of consumable-trees
          ask tree-to-kill [
            set current-fruit-stock current-fruit-stock - (max-fruit-stock / population-size)
            set current-leaf-stock current-leaf-stock - (max-leaf-stock / population-size)
            set current-wood-stock current-wood-stock - (max-wood-stock / population-size)
            set population-size population-size - 1  ; Supprime un arbre dans la population cible
          ]
        ]
      ]
      if random-float 1 < 0.05 [
        let young-trees all-trees with [ tree-pop-age < 4 ]
        if any? young-trees [
          let tree-to-kill one-of young-trees
          ask tree-to-kill [
            let trees-killed random 5 + 1
            set current-fruit-stock current-fruit-stock - (trees-killed * (max-fruit-stock / population-size))
            set current-leaf-stock current-leaf-stock - (trees-killed * (max-leaf-stock / population-size))
            set current-wood-stock current-wood-stock - (trees-killed * (max-wood-stock / population-size))
            set population-size population-size -  random 5 + 1  ; Supprime un à 5 arbres arbre dans la population cible

          ]
        ]
      ]
    ]
  ]
end


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; Mise à jour de la condition corporelle  ;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Procédure pour mettre à jour la condition corporelle des animaux
to update-corporal-conditions [heads total-UF-ingested total-MAD-ingested daily-needs-UF daily-needs-MAD preference-mono]
  ; Calcul de l'UFL/kg MS du fourrage consommé
  ; Nous considérons UF/kg MS ≈ UFL/kg MS pour les bovins
  ; Calcul de l'UFL/kg MS moyen du fourrage consommé
  set weight-gain 0
  let daily-needs-ratio-MAD-UF  daily-needs-MAD / daily-needs-UF
  let MAD-UF-ratio total-MAD-ingested / total-UF-ingested
;  perte de poids
;  ifelse (total-UF-ingested < daily-needs-UF) or (MAD-UF-ratio < daily-needs-ratio-MAD-UF) [
;    show "plop"
;    ; Calculer le déficit énergétique
;    let energy-deficit-factor (daily-needs-UF - total-UF-ingested) / ((0.80 * heads) - daily-needs-UF)
;
;    ; Calculer le déficit protéique
;    let mad-uf-deficit-factor (daily-needs-ratio-MAD-UF - MAD-UF-ratio) / ((52 * head) - daily-needs-ratio-MAD-UF)
;
;    ; Calculer le facteur combiné de déficit
;    let combined-deficit-factor (energy-deficit-factor + mad-uf-deficit-factor) / 2
;    set combined-deficit-factor max list 0 (min list combined-deficit-factor 1)
;
;show word "energy def fact " energy-deficit-factor
;
;show word "MAD UF def fact " mad-uf-deficit-factor
;    ; Calculer la perte de poids maximale possible (par exemple, 500 g/jour)
;    let maximum-weight-loss 500  ; en grammes par jour
;
;    ; Calculer la perte de poids
;    let weight-loss combined-deficit-factor * maximum-weight-loss
;show word "def fact " combined-deficit-factor
;    show word "max weight loss " maximum-weight-loss
;    ; Mettre à jour le poids vif en soustrayant la perte (convertie en kg)
;    set weight-gain (- weight-loss / 1000) * head  ; Convertir en kg et multiplier par le nombre de têtes
;show word "weight loss " weight-loss
;
;  ] [
    ; Calculer le facteur d'énergie
    let energy-factor (total-UF-ingested - daily-needs-UF) / ((0.80 * heads) - daily-needs-UF)
    ; Assurer que le facteur est entre 0 et 1
    set energy-factor max list -1 (min list energy-factor 1)

    let daily-ratio-need daily-needs-MAD / daily-needs-UF

    ; Calculer le facteur du ratio MAD/UF
    let protein-factor (total-MAD-ingested - daily-needs-MAD) / ((52 * head) - daily-needs-MAD)
    ; Assurer que le facteur est entre 0 et 1
    set protein-factor max list (- 1) (min list protein-factor 1)

    ; Calculer le gain de poids potentiel (en grammes par jour)
    let potential-weight-gain protein-factor * energy-factor * 700

    ; L'animal gagne du poids
    set weight-gain (potential-weight-gain / 1000) * head  ; Convertir en kg et multiplier par le nombre de têtes

;  ]
;show word "weight gain " weight-gain  ; Mettre à jour le poids vif
  set live-weight live-weight + weight-gain


  ; Calculer la NEC à partir du poids vif en considérant que les vaches sont toutes des N'dama
  let NEC (live-weight - 66.785) / 47.1

  ; Assurer que la NEC reste dans des limites raisonnables (par exemple, entre 1 et 5)
  if NEC < 1 [ set NEC 1 ]
  if NEC > 5 [ set NEC 5 ]

  ; Mettre à jour la condition corporelle avec la NEC
  set corporal-condition NEC


  ; Calculer le ratio de MAD consommé par rapport au MAD nécessaire
  let MAD-ratio total-MAD-ingested / daily-needs-MAD

  ; Mettre à jour la condition protéique
  set protein-condition protein-condition + (protein-condition * MAD-ratio)  ; Échelle de 0 à 10

  ; Assurer que la condition protéique reste entre 0 et 10
  if protein-condition < 0 [ set protein-condition 0 ]
  if protein-condition > 100 [ set protein-condition 100 ]

end




   ; set grass-eaten consume-grass patch-here daily-needs
 ;   let total-eaten grass-eaten
 ;   let remaining-needs daily-needs - grass-eaten
 ;   if remaining-needs > 0 [
 ;     let tree-eaten consume-tree-resources patch-here remaining-needs
;      set total-eaten total-eaten + tree-eaten
;    ]

 ;   ; Calcul de l'énergie ingérée
  ;  let energy-per-kg-dm 1.75  ;; MCal par kg de MS
   ; set energy-intake total-eaten * energy-per-kg-dm

    ; Calcul du gain de poids
 ;   let energy-per-kg-gain 7.5  ;; MCal par kg de gain de poids
 ;   set weight-gain energy-intake / energy-per-kg-gain

    ; Mise à jour du poids vif
   ; set live-weight live-weight + weight-gain

    ; Mise à jour de la condition corporelle
  ;  set corporal-condition live-weight / (initial-live-weight * head)
 ; ];

  ;; Mouvement et consommation des ovins
 ; ask sheeps [
    ;; Maintenant, trouver le best-patch pour le tick courant avec le known-space mis à jour
 ;   let best-patch find-best-nearest-patch known-space
;
    ;; Stocker le best-patch pour le prochain tick
 ;   set previously-visited-patch best-patch

 ;   let daily-needs max-daily-DM-ingestible-per-head * head
 ;   let grass-eaten 0

;    if best-patch != nobody [
;      move-to best-patch
;    ]

 ;   set grass-eaten consume-grass patch-here daily-needs
 ;   let total-eaten grass-eaten
 ;   let remaining-needs daily-needs - grass-eaten
 ;   if remaining-needs > 0 [
 ;     let tree-eaten consume-tree-resources patch-here remaining-needs
 ;     set total-eaten total-eaten + tree-eaten
;    ]
 ;   set corporal-condition (update-condition total-eaten daily-needs q) / head
 ; ]
;end


; Consommer de l'herbe sur un patch donné
;to-report consume-grass [patch-to-eat amount]
 ; let grass-available [current-grass] of patch-to-eat
;  let trampling-effect calculate-trampling-effect current-grass q head
 ; let grass-ingered min list grass-available amount  ; La quantité d'herbe consommée est limitée par ce qui est disponible
;  ask patch-to-eat [
 ;   set current-grass current-grass - (grass-ingered + trampling-effect)
 ; ]
 ; report grass-ingered  ; Retourner la quantité d'herbe consommée
;end




; Mettre à jour la condition corporelle en fonction de la nourriture consommée
;to-report update-condition [grass-eaten daily-needs quality-ratio]
;  let actual-condition 0
  ; Mettre à jour la condition corporelle en utilisant q
;  set actual-condition corporal-condition + (grass-eaten * quality-ratio - daily-needs)
;  report actual-condition
;  print actual-condition
;end


;;to-report calculate-trampling-effect [grass good-grass-prop heads] - Version 1
  ;; Calcul de l'effet de piétinement (MLVstk) en fonction de la biomasse (current-grass)
  ;; et de la proportion de dicotylédones (dicot)

  ;;let monocot-effect 0.2 * exp(-0.00068 * grass * (1 - good-grass-prop))  ; Effet sur les monocotylédones
 ;; let dicot-effect 0.165 * exp(-0.00092 * grass * good-grass-prop)  ; Effet sur les dicotylédones

  ;; Combiner les effets des deux types de végétation
 ;; let MLVstk monocot-effect + dicot-effect

  ;; Le MLVstk est multiplié par la taille du troupeau (head) pour avoir l'effet total sur le patch
 ;; report MLVstk * heads
;;end

; Mettre à jour la condition corporelle en fonction de la nourriture consommée
;to-report update-condition [grass-eaten daily-needs quality-ratio]
 ; let actual-condition 0
  ; Mettre à jour la condition corporelle en utilisant q
  ;set actual-condition corporal-condition + (grass-eaten * quality-ratio - daily-needs)
  ;report actual-condition
  ;print actual-condition
;end


; Trouver le meilleur patch : d'abord la qualité, ensuite la quantité, enfin la proximité
to-report find-best-nearest-patch [known-spaces]
  let viable-patches known-space with [current-grass > 1]

  ifelse any? viable-patches [
    ifelse shepherd-type = "good" [
    ; Étape 1 : Sélectionner les patches avec la meilleure qualité d'herbe
    let best-quality-patches viable-patches with-max [q]

    ; Étape 2 : Parmi les patches avec la meilleure qualité, sélectionner ceux avec la plus grande quantité d'herbe
    let max-grass-patches best-quality-patches with-max [current-grass]

    ; Étape 3 : Choisir le patch le plus proche parmi ceux avec la meilleure qualité et la plus grande quantité d'herbe
    report min-one-of max-grass-patches [distance myself]
    ] [

      ; Étape 2 : Parmi les patches avec la meilleure qualité, sélectionner ceux avec la plus grande quantité d'herbe
      let max-grass-patches viable-patches with-max [current-grass]

      ; Étape 3 : Choisir le patch le plus proche parmi ceux avec la meilleure qualité et la plus grande quantité d'herbe
      report min-one-of max-grass-patches [distance myself]
    ]
  ] [
    report nobody  ; Si aucun patch viable n'est trouvé
  ]
end

to choose-strategy
  ask foyers [
    ;; Récupérer les conditions corporelles des troupeaux de bovins
    let cattle-cc round [corporal-condition] of cattle-herd
    let cattle-pc round [protein-condition] of cattle-herd

    ;; Récupérer les conditions corporelles des troupeaux de moutons
    let sheep-cc round [corporal-condition] of sheep-herd
    let sheep-pc round [protein-condition] of sheep-herd


    ;; Vérifier si **les deux** conditions des troupeaux sont en dessous des seuils
    let cattle-both-starving (cattle-cc < cattle-low-threshold-cc) and (cattle-pc < cattle-low-threshold-pc)
    let sheep-both-starving (sheep-cc < sheep-low-threshold-cc) and (sheep-pc < sheep-low-threshold-pc)

    ;; Vérifier si **une des deux** conditions est en dessous du seuil
    let cattle-one-starving (cattle-cc < cattle-low-threshold-cc) or (cattle-pc < cattle-low-threshold-pc)
    let sheep-one-starving (sheep-cc < sheep-low-threshold-cc) or (sheep-pc < sheep-low-threshold-pc)


    ;; Si **une des deux** conditions des troupeaux est en dessous du seuil, exécuter `do-first-strategy`
    if cattle-one-starving [
      do-first-strategy
    ]
     if sheep-one-starving [
      do-first-strategy
    ]

    ;; Si **les deux** conditions des deux troupea sont en dessous des seuils, quitter le modèle
    if cattle-both-starving or cattle-cc <= 1 [
      ;; Masquer et déplacer le troupeau de bovins
      ask cattle-herd [
        do-second-strategy
      ]
    ]
   if sheep-both-starving or sheep-cc <= 1 [
      ;; Masquer et déplacer le troupeau de moutons
      ask sheep-herd [
        do-second-strategy
      ]
    ]
  ]
end

to do-first-strategy
  ;; Store the foyer's variables in local variables
  let home-patch original-home-patch
  let my-known-space known-space
  let my-distant-known-space distant-known-space
  ;; Find patches within 12 units of home-patch and not in known-space
  let undiscovered-patches patches with [
    distance home-patch <= 12 and not member? self my-known-space
  ]

  ifelse any? undiscovered-patches [
    ;; Se déplacer vers un patch aléatoire parmi ces patches
    move-to one-of undiscovered-patches
    ;; Obtenir les patches sur la ligne entre la nouvelle position et le campement
    let line-patches patches-between patch-here home-patch
    ;; Ajouter ces patches au known-space du foyer
    set known-space (patch-set known-space line-patches)
    ;; Retourner au campement principal
    move-to home-patch
    ;; ajouter les patches aux catégories d'espaces connus
    set close-known-space known-space in-radius 12
    set original-camp-known-space close-known-space
    ;; Partager le known-space mis à jour avec les troupeaux
    ask cattle-herd [
      set known-space [known-space] of foyer-owner
      set original-camp-known-space [original-camp-known-space] of foyer-owner
      if is-in-temporary-camp = false [
        set close-known-space [close-known-space] of foyer-owner
      ]
    ]
    ask sheep-herd [
      set known-space [known-space] of foyer-owner
      set original-camp-known-space [original-camp-known-space] of foyer-owner
      if is-in-temporary-camp = false [
        set close-known-space [close-known-space] of foyer-owner
      ]
    ]
  ] [
    if any? friends [
      call-one-friend
    ]
    let further-undiscovered-patches patches with [distance home-patch > 12 and not member? self my-known-space]
    if any? further-undiscovered-patches [
      move-to further-undiscovered-patches
      let line-patches patches-between patch-here home-patch
      ;; Ajouter ces patches au known-space du foyer
      set known-space (patch-set known-space line-patches)
      ;; Retourner au campement principal
      move-to home-patch
      ;; ajouter les patches aux catégories d'espaces connus
      set close-known-space known-space in-radius 12
      set original-camp-known-space close-known-space
      set distant-known-space known-space with [distance home-patch > 12]
      ask cattle-herd [
        set known-space [known-space] of foyer-owner
        set original-camp-known-space [original-camp-known-space] of foyer-owner
        ifelse is-in-temporary-camp = false [
          set close-known-space [close-known-space] of foyer-owner
          set distant-known-space [distant-known-space] of foyer-owner
        ] [
          set close-known-space known-space in-radius 12
          set distant-known-space known-space with [distance home-patch > 12]
        ]
      ]
      ask sheep-herd [
        set known-space [known-space] of foyer-owner
        set original-camp-known-space [original-camp-known-space] of foyer-owner
        ifelse is-in-temporary-camp = false [
          set close-known-space [close-known-space] of foyer-owner
          set distant-known-space [distant-known-space] of foyer-owner
        ] [
          set close-known-space known-space in-radius 12
          set distant-known-space known-space with [distance home-patch > 12]
        ]
      ]
    ]
  ]
end

to do-second-strategy
  set live-weight initial-live-weight  ; Réinitialiser le poids vif
  set corporal-condition 5             ; NEC maximum
  set protein-condition 10             ; Condition protéique maximale
  move-to original-home-patch          ; Déplacer au campement principal
  set have-left true
  hide-turtle
end

to call-one-friend


end
;  to color-trees  ;; patch procedure
;  set pcolor scale-color (green - 1) trees 0 (2 * max-grass-height)


to manage-water-points
  ask patches with [water-point = true] [
    set water-point false
  ]
  ask n-of 5 patches [
    set water-point true
  ]
end

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

to color-grass  ;; patch procedure
  set pcolor scale-color yellow current-grass max-grass 0
end

to display-labels
  ask turtles [set label ""]
  ask turtles [set label head]

end



  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;; Procédures d'ouverture des fichiers ;;;;;;;;;;;;;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



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




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Ouverture des fichiers pour les stocks et la sensibilité des arbres selon leur type et l'age ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to load-tree-age-data [filename]
  set tree-age-data []
  file-open filename
  ; Lire les données ligne par ligne
  while [not file-at-end?] [
    let line csv:from-row file-read-line
    ; Convertir les éléments en types appropriés
    let trees-type item 0 line        ; "nutritive", "lessNutritive", "fruity"
    let ages item 1 line ; Âge (1 à 8)
    let max-fruits item 2 line
    let max-leaves item 3 line
    let max-woods item 4 line
    let sensitivities item 5 line
    ; Ajouter les données à la liste `tree-age-data`
    set tree-age-data lput (list trees-type ages max-fruits max-leaves max-woods sensitivities) tree-age-data
  ]
  file-close
end




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Ouverture des fichiers pour les valeurs nutritionnelles selon leur type, le type de sol et la saison ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to load-tree-nutrition-data [filename]
  set tree-nutrition-data []
  file-open filename
  ; Lire les données ligne par ligne
  while [not file-at-end?] [
    let line csv:from-row file-read-line
    ; Convertir les éléments en types appropriés
    let trees-type item 0 line        ; "nutritive", "lessNutritive", "fruity"
    let landscapes item 1 line ; "Baldiol", "Sangre", "Seeno", "Caangol"
    let seasons item 2 line
    let tree-UF-data item 3 line
    let tree-MAD-data item 4 line
    ; Ajouter les données à la liste `tree-nutrition-data`
    set tree-nutrition-data lput (list trees-type landscapes seasons tree-UF-data tree-MAD-data) tree-nutrition-data
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




to-report determine-herder-type
  ;; Ensure the sum of the proportions is 100
  let proportion-small-herders (100 - (proportion-big-herders + proportion-medium-herders))
  let total-proportion proportion-big-herders + proportion-medium-herders + proportion-small-herders
  let r random-float 100
  ifelse r < proportion-big-herders [
    report "grand"
  ] [
    ifelse r < (proportion-big-herders + proportion-medium-herders) [
      report "moyen"
    ] [
      report "petit"
    ]
  ]
end


to-report calculate-herd-size [heads]
  ;; Assurer que head est dans les limites minHead et maxHead
  let minHead 5
  let maxHead 70
  let minSize 0.1
  let maxSize 0.9
  let adjusted-head max list minHead (min list head maxHead)
  report minSize + ((adjusted-head - minHead) / (maxHead - minHead)) * (maxSize - minSize)
end


; Fonctions pour calculer les populations initiales en fonction du type d'arbre, de l'âge et de la taille de la population
to-report get-age-data [trees-type ages]
  ; Filtrer les données en utilisant une variable nommée 'x' pour chaque élément
  let data-filtered filter [ x ->
    (item 0 x) = trees-type and
    (item 1 x) = ages
  ] tree-age-data

  ; Vérifier s'il y a des données filtrées
  ifelse (length data-filtered > 0)  [
    let age-data first data-filtered

    ; Retourner une liste sans le type et l'âge, seulement les stocks et la sensibilité
    report (list (item 2 age-data) (item 3 age-data) (item 4 age-data) (item 5 age-data))
  ] [
    ; Si aucune donnée trouvée, retourner des valeurs par défaut
    report (list 0 0 0 0)
  ]
end




to-report get-tree-nutritional-values [trees-type soil season]
  ; Parcourir la structure `tree-nutritional-values` pour trouver les valeurs correspondantes
  let data-filtered filter [i ->
    (item 0 i) = tree-type and
    (item 1 i) = soil-type and
    (item 2 i) = season
  ] tree-nutrition-data
  ifelse (length data-filtered > 0) [
    let nutrition-value first data-filtered
    report (list (item 3 nutrition-value) (item 4 nutrition-value))
  ] [
    ; Valeurs par défaut si aucune correspondance trouvée
    report (list 0 0 0 0)
  ]
end



to-report split-population [total-population]
  let age-groups []

  ; Calculer la population pour l'âge 8 (80% du total)
  let age8-population round (total-population * 0.8)

  ; Calculer la population restante à répartir entre les âges 1 à 7
  let remaining-population total-population - age8-population

  ; Nombre d'âges pour la répartition restante (1 à 7)
  let num-younger-ages 7

  ; Répartition uniforme de la population restante
  let base-population round (remaining-population / num-younger-ages)
  let leftover remaining-population mod num-younger-ages

  ; Initialiser la liste des groupes d'âge pour les âges 1 à 7
  repeat num-younger-ages [
    set age-groups lput base-population age-groups
  ]

  ; Distribuer le reste sur les premiers âges
  if leftover > 0 [
    let i 0
    while [i < leftover] [
      set age-groups replace-item i age-groups ((item i age-groups) + 1)
      set i i + 1
    ]
  ]
  ; Ajouter la population de l'âge 8 à la fin de la liste
  set age-groups lput age8-population age-groups
  ; La liste `age-groups` contient maintenant les populations pour les âges 1 à 8
  ; Index 0 correspond à l'âge 1, index 7 correspond à l'âge 8
  report age-groups
end




to-report calculate-wood-ratio

  if max-wood-stock = 0 [
    report 1  ; Éviter la division par zéro
  ]
  ifelse max-wood-stock = 0 [
    report 0
  ] [
    report current-wood-stock / max-wood-stock
  ]
end

to-report calculate-tree-icon-size [populations]
  ;; Définir les valeurs minimales et maximales pour le mapping
  let minPopulation 0
  let maxPopulation 10000  ;; Ajustez cette valeur en fonction de vos données réelles
  let minSize 0.1
  let maxSize 1.5
  ;; Assurer que population est dans les limites
  let adjusted-population max list minPopulation (min list populations maxPopulation)
  report minSize + ((adjusted-population - minPopulation) / (maxPopulation - minPopulation)) * (maxSize - minSize)
end



to-report grass-quality-to-q [quality]
  if quality = "good" [ report 1 ]
  if quality = "average" [ report 0.7 ]
  if quality = "poor" [ report 0.5 ]
  report 0.0  ; Valeur par défaut si la qualité n'est pas reconnue
end



; Obtenir le taux de germination en fonction du type d'arbre et de la qualité de l'année
to-report get-germination-rate [tree-types year-type]
  let rate 0
  if tree-types
  = "nutritive" [
    if year-type = "bonne" [set rate 0.2]
    if year-type = "moyenne" [set rate 0.1]
    if year-type = "mauvaise" [set rate 0.05]
  ]
  if tree-type = "lessNutritive" [
    if year-type = "bonne" [set rate 0.15]
    if year-type = "moyenne" [set rate 0.08]
    if year-type = "mauvaise" [set rate 0.04]
  ]
  if tree-type = "fruity" [
    if year-type = "bonne" [set rate 0.25]
    if year-type = "moyenne" [set rate 0.15]
    if year-type = "mauvaise" [set rate 0.1]
  ]
  report rate
end




; Fonction pour calculer la croissance logistique des fruits
to-report growth-fruit-logistic [input-tree-type tree-age pop-size current-fruit max-fruit]
  let r 0
  ifelse  max-fruit = 0 [
    report 0  ; Pas de croissance si max-wood est zéro
  ] [
    if input-tree-type = "nutritive" [
      if current-season = "Nduungu" [set r 0.05]
      if current-season = "Ceedu" [set r -0.03]
      if current-season = "Dabbuunde" [set r 0.01]
      if current-season = "Ceetcelde" [set r 0.005]
    ]
    if input-tree-type = "lessNutritive" [
      if current-season = "Nduungu" [set r 0.04]
      if current-season = "Ceedu" [set r 0.025]
      if current-season = "Dabbuunde" [set r 0.01]
      if current-season = "Ceetcelde" [set r 0.005]
    ]
    if input-tree-type = "fruity" [
      if current-season = "Nduungu" [set r 0.06]
      if current-season = "Ceedu" [set r 0.04]
      if current-season = "Dabbuunde" [set r 0.02]
      if current-season = "Ceetcelde" [set r 0.01]
    ]
    let growth r * (precision current-fruit 5) * (precision (1 - (current-fruit / max-fruit)) 5)
    report growth
  ]
end

 ;Fonction pour calculer la croissance logistique des feuilles
to-report growth-leaf-logistic [input-tree-type tree-age pop-size current-leaf max-leaf]
  let r 0
  ifelse  max-leaf = 0 [
    report 0  ; Pas de croissance si max-wood est zéro
  ] [
    if input-tree-type = "nutritive" [
      if current-season = "Nduungu" [set r 0.05]
      if current-season = "Ceedu" [set r 0.03]
      if current-season = "Dabbuunde" [set r 0.01]
      if current-season = "Ceetcelde" [set r 0.005]
    ]
    if input-tree-type = "lessNutritive" [
      if current-season = "Nduungu" [set r 0.04]
      if current-season = "Ceedu" [set r 0.025]
      if current-season = "Dabbuunde" [set r 0.01]
      if current-season = "Ceetcelde" [set r 0.005]
    ]
    if input-tree-type = "fruity" [
      if current-season = "Nduungu" [set r 0.06]
      if current-season = "Ceedu" [set r 0.04]
      if current-season = "Dabbuunde" [set r 0.02]
      if current-season = "Ceetcelde" [set r 0.01]
    ]
    ; Afficher les valeurs pour débogage

    ; Vérifier que max-leaf n'est pas égal à zéro
    if max-leaf = 0 [
      report 0  ; Éviter la division par zéro
  ]
    let growth precision (r * (precision current-leaf 5) * (precision (1 - (current-leaf / max-leaf)) 5)) 5
    if abs(growth) > 1e10 [
    report 0
  ]report growth
  ]

end

;Fonction pour calculer la croissance logistique du bois
to-report growth-wood-logistic [input-tree-type tree-age pop-size current-wood max-wood]
  let r 0
  ifelse  max-wood = 0 [
    report 0  ; Pas de croissance si max-wood est zéro
  ] [
    if input-tree-type = "nutritive" [
      if current-season = "Nduungu" [set r 0.05]
      if current-season = "Ceedu" [set r 0.03]
      if current-season = "Dabbuunde" [set r 0.01]
      if current-season = "Ceetcelde" [set r 0.005]
    ]
    if input-tree-type = "lessNutritive" [
      if current-season = "Nduungu" [set r 0.04]
      if current-season = "Ceedu" [set r 0.025]
      if current-season = "Dabbuunde" [set r 0.01]
      if current-season = "Ceetcelde" [set r 0.005]
    ]
    if input-tree-type = "fruity" [
      if current-season = "Nduungu" [set r 0.06]
      if current-season = "Ceedu" [set r 0.04]
      if current-season = "Dabbuunde" [set r 0.02]
      if current-season = "Ceetcelde" [set r 0.01]
    ]

    let growth  r * (precision current-wood 5) * (precision (1 - (current-wood / max-wood)) 5)
  report growth
]
end



to-report calculate-trampling-effect [monocot-grass dicot-grass heads]
  ;; Calcul de l'effet de piétinement (MLVstk) en fonction de la biomasse (current-grass)
  ;; et de la proportion de dicotylédones (dicot)

  let monocot-effect 0.2 * exp(-0.00068 * monocot-grass)  ; Effet sur les monocotylédones
  let dicot-effect 0.165 * exp(-0.00092 * dicot-grass)  ; Effet sur les dicotylédones

  ;; Combiner les effets des deux types de végétation
  let MLVstk monocot-effect + dicot-effect

  ;; Le MLVstk est multiplié par la taille du troupeau (head) pour avoir l'effet total sur le patch
  report MLVstk * heads
end



to-report patches-between [ p1 p2 ]
  let x1 [ pxcor ] of p1
  let y1 [ pycor ] of p1
  let x2 [ pxcor ] of p2
  let y2 [ pycor ] of p2

  let distancex x2 - x1
  let distancey y2 - y1

  let n max (list abs distancex abs distancey)
   let result no-patches  ; Initialise un agentset vide

  ifelse n = 0 [
    set result patch x1 y1
  ] [
    let xinc dx / n
    let yinc dy / n
    let x x1
    let y y1
    repeat (n + 1) [
      set result (patch-set result patch round x round y)
      set x x + xinc
      set y y + yinc
    ]
  ]
  report result
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
678
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
0
0
1
ticks
30.0

BUTTON
68
10
141
43
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
146
10
209
43
NIL
go\n
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
9
83
207
116
initial-number-of-camps
initial-number-of-camps
0
200
131.0
1
1
NIL
HORIZONTAL

SLIDER
8
190
206
223
space-camp-mean
space-camp-mean
space-camp-min
space-camp-max
19.0
1
1
foyers
HORIZONTAL

SLIDER
9
119
207
152
space-camp-min
space-camp-min
0
100
8.0
1
1
NIL
HORIZONTAL

SLIDER
9
155
206
188
space-camp-max
space-camp-max
space-camp-min
50
37.0
1
1
NIL
HORIZONTAL

SLIDER
9
227
205
260
space-camp-standard-deviation
space-camp-standard-deviation
0
20
6.0
1
1
NIL
HORIZONTAL

MONITOR
9
265
96
310
Total Foyers
count foyers
17
1
11

MONITOR
10
365
96
410
Total cattles
sum [head] of cattles
17
1
11

MONITOR
9
315
96
360
Total Sheeps
sum [head] of sheeps
17
1
11

SLIDER
685
12
883
45
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
686
50
884
83
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
687
89
885
122
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
688
130
886
175
NIL
sum [water-stock] of patches
17
1
11

CHOOSER
523
495
679
540
visualization-mode
visualization-mode
"soil-type" "tree-cover" "grass-cover" "grass-qualit"
2

BUTTON
689
499
779
532
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
145
45
208
78
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
817
185
930
230
NIL
current-season
17
1
11

MONITOR
689
185
815
230
NIL
current-year-type
17
1
11

SLIDER
690
307
932
340
good-shepherd-percentage
good-shepherd-percentage
0
100
63.0
1
1
NIL
HORIZONTAL

SLIDER
689
236
931
269
proportion-big-herders
proportion-big-herders
0
100
22.0
1
1
NIL
HORIZONTAL

SLIDER
689
271
932
304
proportion-medium-herders
proportion-medium-herders
0
100
50.0
1
1
NIL
HORIZONTAL

PLOT
945
160
1145
310
Weight-gain
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
"cattles" 1.0 0 -16777216 true "" "plot mean [weight-gain] of cattles"
"sheeps" 1.0 0 -5516827 true "" "plot mean [weight-gain] of sheeps"
"0" 1.0 0 -5298144 true "" "plot 0"

PLOT
945
10
1145
160
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
"sheeps" 1.0 0 -5516827 true "" "plot count sheeps with [is-in-temporary-camp = true]"
"cattles" 1.0 0 -16449023 true "" "plot count cattles with [is-in-temporary-camp = true]"

PLOT
1145
10
1345
160
partis dans le saloum
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
"default" 1.0 0 -5516827 true "" "plot count sheeps with [have-left = true]"
"pen-1" 1.0 0 -16777216 true "" "plot count cattles with [have-left = true]"

PLOT
1145
160
1345
310
Live-weight
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
"Cattles" 1.0 0 -16777216 true "" "plot mean [live-weight] of cattles / count cattles"
"Sheeps" 1.0 0 -5516827 true "" "plot mean [live-weight] of sheeps / count sheeps"

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
