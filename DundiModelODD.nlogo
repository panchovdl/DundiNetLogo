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
  total-dry-season-ticks ; Nombre de jours de saison sèche hors période de soudure

  herd-gain-from-food
  max-grass              ; pour visualisation
  max-trees              ; pour visualisation

  tree-data              ; liste qui stocke les valeurs max de fruits, feuilles, bois et sensibilité pour cette catégorie d'arbres

  nduungu-duration       ; nombre de ticks pour la saison des pluies
  dabbuunde-duration     ; nombre de ticks pour la saison sèche froide
  ceedu-duration         ; nombre de ticks pour la saison sèche chaude
  ceetcelde-duration     ; nombre de ticks pour la période de soudure
]

breed [camps camp]
breed [foyers foyer]
breed [cattles cattle]
breed [sheeps sheep]
breed [tree-populations tree-population]

patches-own [
  soil-type  ; Type de sol

  current-grass  ; Couverture d'herbe
  grass-end-nduungu ; Couverture d'herbe le dernier jour du Nduungu
  K  ; montant maximum d'herbe
  patch-sensitivity ; sensibilité à la dégradation
  degradation-level ; niveau de dégradation

  grass-quality ; qualité actuelle de l'herbe
  grass-quality-ceedu ; qualité de l'herbe en ceedu de l'année actuelle
  grass-quality-ceetcelde ; qualité de l'herbe en ceetcelde de l'année actuelle
  grass-quality-nduungu ; qualité de l'herbe en nduungu de l'année actuelle
  grass-quality-dabbuunde ; qualité de l'herbe en dabbuunde de l'année actuelle
  prev-grass-quality-ceedu ; qualité de l'herbe en ceedu de l'année précédente - mémoire
  prev-grass-quality-ceetcelde ; qualité de l'herbe en ceetcelde de l'année précédente - mémoire
  prev-grass-quality-nduungu ; qualité de l'herbe en cnduungu de l'année précédente - mémoire
  prev-grass-quality-dabbuunde ; qualité de l'herbe en dabbuunde de l'année précédente - mémoire


  ticks-since-dabbuunde  ; Compteur de ticks depuis le début de Dabbuunde


  ; initialisation
  tree-cover  ; Couverture d'arbres
  max-tree-cover ; maximum d'individus atteignable sur un km²
  num-nutritious ; nombre d'arbres appréciés par le bétail(pterocarpus lucens, acacia) en fonction du tree-cover
  num-less-nutritious ; nombre d'arbres peu / pas apprécié par le bétail en fonction du tree-cover
  num-fruity ; nombre d'arbres fruitiers (jujubier, baobab, balanites) par le bétail en fonction du tree-cover
  ; passage intermédiaire des données du fichier tree_infos pour les transférer à chaque population
  intermediate-patch-pop-size
  intermediate-patch-tree-age
  intermediate-patch-tree-type

  init-patch-max-fruit-stock
  init-patch-max-leaf-stock
  init-patch-max-wood-stock
  init-patch-sensitivity



  park-restriction ; cellule protégée (parcelle de reforestation)
  init-camp-pref  ; Préférence pour l'installation des campements (1 ou 2)
  water-point  ; Point d'eau (booléen)
  has-pond ; Booléen, détermine s'il y a une mare
  water-stock ; Stock d'eau dans la mare
]

turtles-own [
  corporal-condition  ; État de santé de l'agent
  daily-needs-per-head  ; Besoins quotidiens
  head ; nombre d'individus
  known-space ; espace connu par les individus
  acceptable-distance-from-camp ; distance maximale
  acceptable-distance-from-wp
  daily-water-consumption ; Consommation d'eau quotidienne
  UBT-size ; proportion d'un individu en Unité de Bétail Tropical (une vache allaitante = 1)
]

camps-own [
  available-space  ; Nombre de foyers associés
  wood-needs  ; Besoins en bois
  wood-quantity  ; Quantité de bois disponible
]

foyers-own [
  cattle-herd  ; Troupeau de bovins associé
  cattle-herd-size ; taille du troupeau de bovins associé
  sheep-herd  ; Troupeau de moutons associé
  sheep-herd-size ; Taille du troupeau d'ovins associé
  pasture-strategy  ; Stratégies de pâturage
  home-camp ; Campement du foyer
  home-patch ; patch du campement du foyer
  herder-type ; Caractéristique d'élevage du foyer (grand moyen petit)
  owned-trees-pop ; population d'arbres associée
]

sheeps-own [
  foyer-owner ; foyer du troupeau
  pasture-strategy  ; Stratégies de pâturage
  home-patch ;
]

cattles-own [
  foyer-owner ; foyer du troupeau
  pasture-strategy  ; Stratégies de pâturage
  home-patch ;
]

tree-populations-own [
  tree-type              ; "nutritive", "less-nutritive", "fruit"
  tree-pop-age           ; Âge de la population (1 à 8)
  population-size        ; Nombre d'arbres dans cette population
  current-fruit-stock    ; Stock de fruits
  current-leaf-stock     ; Stock de feuilles
  current-wood-stock     ; Stock de bois
  max-fruit-stock        ; Stock maximal de fruit pour la population
  max-leaf-stock         ; Stock maximal de fruit pour la population
  max-wood-stock         ; Stock maximal de fruit pour la population
  wood-ratio             ; Ratio entre le stock actuel et le stock maximal de bois
  tree-sensitivity
]

to setup
  clear-all
  resize-world -11 11 -11 11  ; Fixer les limites du monde à -11 à 11 en x et y
  set-patch-size 20  ; Ajuster la taille des patches

  load-environment "environment_vel.txt"
  set current-season "Nduungu"  ; Initialiser à la première saison
  set last-season "none"  ;; Initialiser last-season
  set season-counter 0  ; Compteur de saison initialisé à 0

  ; Lire les types d'années depuis le fichier .txt
  load-climate-variables "year-type.txt"
  set year-index 0  ; Indice de l'année en cours
  set year-counter 0  ; Compteur de ticks dans l'année

  ; Initialiser les durées des saisons
  update-year-type
  set-season-durations

  load-tree-data "tree_info.csv"
  show tree-data

  set max-grass 200000
  set max-trees 15000
  setup-landscape  ; Créer les unités de paysage
  setup-water-patches ; Créer les mares
  setup-camps  ; Créer les campements
  setup-foyers ; Créer les foyers
  setup-herds  ; Créer les troupeaux
  setup-trees  ; Initialiser les arbres
               ;ask turtles [hide-turtle]
  update-visualization
  display-labels
  reset-ticks
end

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

to load-tree-data [filename]
  set tree-data []
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
    ; Ajouter les données à la liste `tree-data`

    set tree-data lput (list trees-type ages max-fruits max-leaves max-woods sensitivities) tree-data
  ]
  file-close
end

to update-year-type
  ; Déterminer l'année en cour
  ; Vérifier qu'on ne dépasse pas la liste
  if year-counter >= total-ticks-per-year [
    set year-index year-index + 1
  ]
  ; Obtenir le type d'année
  set current-year-type item year-index year-types
end

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

to setup-landscape
  ask patches [
    set max-tree-cover 20000
    if soil-type = "Baldiol" [
      set current-grass 150000
      set K 150000  ; Stock de production maximal de Matière Sèche (MS - DM[en]) sur 1 km² pour "Baldiol"
      set num-nutritious round (tree-cover * 0.5)
      set num-less-nutritious round (tree-cover * 0.25)
      set num-fruity round (tree-cover * 0.25)
      set patch-sensitivity 2
    ]
    if soil-type = "Caangol" [
      set current-grass 12000
      set K 120000  ; Stock de production maximal de Matière Sèche (MS - DM[en]) sur 1 km² pour Caangol
      set num-nutritious round (tree-cover * 0.5)
      set num-less-nutritious round (tree-cover * 0.25)
      set num-fruity round (tree-cover * 0.25)
      set patch-sensitivity 2
    ]
    if soil-type = "Sangre" [
      set current-grass 90000
      set K 90000  ; Stock de production maximal de Matière Sèche (MS - DM[en]) sur 1 km² pour Sangre
      set num-nutritious round (tree-cover * 0.5)
      set num-less-nutritious round (tree-cover * 0.25)
      set num-fruity round (tree-cover * 0.25)
      set patch-sensitivity 3
    ]
    if soil-type = "Seeno" [
      set current-grass 200000
      set K 200000  ; Stock de production maximal de Matière Sèche (MS - DM[en]) sur 1 km² pour Seeno
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
  ]
end

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

    ; Si un patch a été trouvé
    ifelse selected-patch != nobody [
      ask selected-patch [
        ; Vérifier qu'il y a moins de 2 campements sur ce patch
        if count camps-here < 2 [
          ; Créer un nouveau campement
          sprout-camps 1 [
            set color brown
            set size 0.5
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

to-report generate-available-space
  set available-space 0
  while [available-space < space-camp-min or available-space > space-camp-max] [  ; Respecter les fences
    set available-space random-normal space-camp-mean space-camp-standard-deviation  ; Utiliser la moyenne et l'écart type
  ]
  report round available-space  ; Arrondir au nombre entier le plus proche
end

to setup-foyers
  ; Boucle de création des foyers
  ask camps [
    let num-foyers round (available-space * 0.8)
    hatch-foyers num-foyers [
      set color brown
      set size 0.1
      set shape "person"
      set pasture-strategy "directed"
      set herder-type determine-herder-type
      set home-camp myself
      set home-patch patch-here  ; Stocker la position du foyer
      set-herd-sizes
      set known-space patches in-radius 3


    ]
  ]
end

to-report determine-herder-type
  let r random-float 1
  if r < 0.1 [report "moyen"]  ; 10% chance
  if r < 0.3 [report "petit"]  ; 20% chance (total 30% chance up to here)
  report "grand"  ; 70% chance
end

to set-herd-sizes
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

to setup-herds
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

    let my-cattles []
    hatch-cattles 1 [
      set color white
      set shape "cow"
      set size 0.3  ;; easier to see
      set label-color blue - 2
      set label head
      set head cattle-herd-count
      set UBT-size 1
      set acceptable-distance-from-camp 1
      set corporal-condition random (2 * herd-gain-from-food)
      set corporal-condition 10
      set daily-needs-per-head 3.6
      set foyer-owner myself
      set pasture-strategy my-pasture-strategy ; Transmettre la stratégie de pâturage
      set daily-water-consumption 22 * head * UBT-size ; 22 l/UBT/J de consommation d'eau
      move-to one-of [neighbors] of home-patch
      set known-space [known-space] of foyer-owner
      set my-cattles self  ; Stocker la tortue dans une variable temporaire
    ]
    set cattle-herd my-cattles

    let my-sheeps []
    hatch-sheeps 1 [
      set color black
      set shape "sheep"
      set size 0.3  ;; easier to see
      set label-color blue - 2
      set label head
      set head sheep-herd-count
      set UBT-size 0.16
      set corporal-condition random (2 * herd-gain-from-food)
      setxy random-xcor random-ycor
      set corporal-condition 5
      set acceptable-distance-from-camp 1
      set daily-needs-per-head 0.57
      set foyer-owner myself
      set home-patch [home-patch] of foyer-owner
      set known-space [known-space] of foyer-owner
      set pasture-strategy my-pasture-strategy  ; Transmettre la stratégie de pâturage
      set daily-water-consumption 22 * head * UBT-size; 22 l/UBT/J de consommation d'eau
      move-to home-patch
      set my-sheeps self  ; Stocker la tortue dans une variable temporaire
    ]
    set sheep-herd my-sheeps
  ]
end

to setup-trees

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

            ; Initialiser les stocks actuels
            set max-fruit-stock init-patch-max-fruit-stock
            set max-leaf-stock init-patch-max-leaf-stock
            set max-wood-stock init-patch-max-wood-stock
            set current-fruit-stock (max-fruit-stock / 2)
            set current-leaf-stock (max-leaf-stock / 2)
            set current-wood-stock max-wood-stock
            set tree-sensitivity init-patch-sensitivity

            hide-turtle
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

            ; Initialiser les stocks actuels
            set max-fruit-stock init-patch-max-fruit-stock
            set max-leaf-stock init-patch-max-leaf-stock
            set max-wood-stock init-patch-max-wood-stock
            set current-wood-stock max-wood-stock
            set current-fruit-stock (max-fruit-stock / 2)
            set current-leaf-stock (max-leaf-stock / 2)

            set tree-sensitivity init-patch-sensitivity

            hide-turtle
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

            ; Initialiser les stocks actuels
            set max-fruit-stock init-patch-max-fruit-stock
            set max-leaf-stock init-patch-max-leaf-stock
            set max-wood-stock init-patch-max-wood-stock
            set current-fruit-stock (max-fruit-stock / 2)
            set current-leaf-stock (max-leaf-stock / 2)
            set current-wood-stock max-wood-stock
            set tree-sensitivity init-patch-sensitivity
            set wood-ratio calculate-wood-ratio

            hide-turtle
          ]
        ]
      ]
    ]
  ]
end

to-report calculate-wood-ratio

  report current-wood-stock / max-wood-stock

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
; Fonctions pour calculer les populations initiales en fonction du type d'arbre, de l'âge et de la taille de la population

to-report get-age-data [trees-type ages]
  ; Filtrer les données en utilisant une variable nommée 'x' pour chaque élément
  let data-filtered filter [ x -> (item 0 x) = trees-type and (item 1 x) = ages ] tree-data

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
end

to go
  update-season
  if current-season != last-season [
    assign-grass-quality
    set last-season current-season
  ]

  if current-season = "Nduungu" [
    renew-tree-population
  ]

  grow-grass
  grow-tree-resources
  move-and-eat

  ask turtles [
    manage-water-points
    ;   come-back
  ]
  ask patches [
    color-grass
    ;color-trees
  ]

  ; Vérifiez si une année complète s'est écoulée
  if year-counter >= total-ticks-per-year [
    update-tree-age
    update-year-type
    set-season-durations
    set year-counter 0
    set renewal-flag false
  ]

  tick
end


to update-season
  set season-counter season-counter + 1
  set year-counter year-counter + 1

  if current-season = "Nduungu" and season-counter >= nduungu-duration [
    ; Stocker la biomasse à la fin de Nduungu
    ask patches [
      set grass-end-nduungu current-grass
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

to assign-grass-quality
  ask patches [
    ifelse (any? patches with [grass-quality-nduungu = 0 and grass-quality-ceetcelde = 0]) [  ; Vérifie si c'est la première année
      if soil-type = "Baldiol" [
        let rand random-float 1
        if current-season = "Ceedu" [
          ifelse rand < 0.5 [set grass-quality-ceedu "good"]
          [ifelse rand < 0.75 [set grass-quality-ceedu "average"]
            [set grass-quality-ceedu "poor"]]
        ]
        if current-season = "Nduungu" [
          ifelse rand < 0.25 [set grass-quality-nduungu "good"]
          [ifelse rand < 0.5 [set grass-quality-nduungu "average"]
            [set grass-quality-nduungu "poor"]]
        ]
        if current-season = "Dabbuunde" [
          ifelse rand < 0.1 [set grass-quality-dabbuunde "good"]
          [ifelse rand < 0.3 [set grass-quality-dabbuunde "average"]
            [set grass-quality-dabbuunde "poor"]]
        ]
        if current-season = "Ceetcelde" [
          ifelse rand < 0.4 [set grass-quality-ceetcelde "good"]
          [ifelse rand < 0.7 [set grass-quality-ceetcelde "average"]
            [set grass-quality-ceetcelde "poor"]]
        ]
      ]
      if soil-type = "Caangol" [
        let rand random-float 1
        if current-season = "Ceedu" [
          ifelse rand < 0.5 [set grass-quality-ceedu "good"]
          [ifelse rand < 0.75 [set grass-quality-ceedu "average"]
            [set grass-quality-ceedu "poor"]]
        ]
        if current-season = "Nduungu" [
          ifelse rand < 0.25 [set grass-quality-nduungu "good"]
          [ifelse rand < 0.5 [set grass-quality-nduungu "average"]
            [set grass-quality-nduungu "poor"]]
        ]
        if current-season = "Dabbuunde" [
          ifelse rand < 0.1 [set grass-quality-dabbuunde "good"]
          [ifelse rand < 0.3 [set grass-quality-dabbuunde "average"]
            [set grass-quality-dabbuunde "poor"]]
        ]
        if current-season = "Ceetcelde" [
          ifelse rand < 0.4 [set grass-quality-ceetcelde "good"]
          [ifelse rand < 0.7 [set grass-quality-ceetcelde "average"]
            [set grass-quality-ceetcelde "poor"]]
        ]
      ]
      if soil-type = "Sangre" [
        let rand random-float 1
        if current-season = "Ceedu" [
          ifelse rand < 0.5 [set grass-quality-ceedu "good"]
          [ifelse rand < 0.75 [set grass-quality-ceedu "average"]
            [set grass-quality-ceedu "poor"]]
        ]
        if current-season = "Nduungu" [
          ifelse rand < 0.25 [set grass-quality-nduungu "good"]
          [ifelse rand < 0.5 [set grass-quality-nduungu "average"]
            [set grass-quality-nduungu "poor"]]
        ]
        if current-season = "Dabbuunde" [
          ifelse rand < 0.1 [set grass-quality-dabbuunde "good"]
          [ifelse rand < 0.3 [set grass-quality-dabbuunde "average"]
            [set grass-quality-dabbuunde "poor"]]
        ]
        if current-season = "Ceetcelde" [
          ifelse rand < 0.4 [set grass-quality-ceetcelde "good"]
          [ifelse rand < 0.7 [set grass-quality-ceetcelde "average"]
            [set grass-quality-ceetcelde "poor"]]
        ]
      ]
      if soil-type = "Seeno" [
        let rand random-float 1
        if current-season = "Ceedu" [
          ifelse rand < 0.5 [set grass-quality-ceedu "good"]
          [ifelse rand < 0.75 [set grass-quality-ceedu "average"]
            [set grass-quality-ceedu "poor"]]
        ]
        if current-season = "Nduungu" [
          ifelse rand < 0.25 [set grass-quality-nduungu "good"]
          [ifelse rand < 0.5 [set grass-quality-nduungu "average"]
            [set grass-quality-nduungu "poor"]]
        ]
        if current-season = "Dabbuunde" [
          ifelse rand < 0.1 [set grass-quality-dabbuunde "good"]
          [ifelse rand < 0.3 [set grass-quality-dabbuunde "average"]
            [set grass-quality-dabbuunde "poor"]]
        ]
        if current-season = "Ceetcelde" [
          ifelse rand < 0.4 [set grass-quality-ceetcelde "good"]
          [ifelse rand < 0.7 [set grass-quality-ceetcelde "average"]
            [set grass-quality-ceetcelde "poor"]]
        ]
      ]
      if current-season = "Ceedu" [set grass-quality grass-quality-ceedu]
      if current-season = "Nduungu" [set grass-quality grass-quality-nduungu]
      if current-season = "Dabbuunde" [set grass-quality grass-quality-dabbuunde]
      if current-season = "Ceetcelde" [set grass-quality grass-quality-ceetcelde]
    ] [
      ;; Pour les années suivantes, réutilise la qualité de l'herbe de l'année précédente
      if current-season = "Ceedu" [set grass-quality grass-quality-ceedu]
      if current-season = "Nduungu" [set grass-quality grass-quality-nduungu]
      if current-season = "Dabbuunde" [set grass-quality grass-quality-dabbuunde]
      if current-season = "Ceetcelde" [set grass-quality grass-quality-ceetcelde]
    ]
  ]

end

;to grow-grass
;  let r 0
;  if current-season = "Ceedu" [set r 0.00001]
;  if current-season = "Ceetcelde" [set r 0.000005]
;  if current-season = "Dabbuunde" [set r 0.000002]
;  if current-season = "Nduungu" [set r 0.01]

to grow-grass
  ask patches [
    if current-season = "Nduungu" [
      ; Croissance logistique pendant Nduungu
      let r 0.1  ; Taux de croissance, ajustez selon vos besoins
      let new-current-grass current-grass + r * current-grass * (K - current-grass) / K
      set current-grass min (list new-current-grass K)
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
        let per_tick_loss (2 * grass-end-nduungu * (loss_percentage / total-dry-season-ticks)) * (1 - proportion_of_period)
        set current-grass current-grass - per_tick_loss
        if current-grass < 0 [ set current-grass 0 ]
        set ticks-since-dabbuunde ticks-since-dabbuunde + 1
      ]
    ]
    if current-season = "Ceetcelde" [
      ; Réduction constante de 10 % par tick
      set current-grass current-grass * 0.99
      if current-grass < 0 [ set current-grass 0 ]
    ]
  ]
end

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

; Fonction de renouvellement des arbres
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
            hide-turtle
          ]
        ]
      ]
      ; Marquer le renouvellement comme effectué pour cette saison
      set renewal-flag true
    ]
  ]
end

; Obtenir le taux de germination en fonction du type d'arbre et de la qualité de l'année
to-report get-germination-rate [tree-types year-type]
  let rate 0
  if tree-type = "nutritive" [
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

to grow-tree-resources
  ask tree-populations [


    ; Réactualiser le max de bois en fonction de la population restante

    let age-data get-age-data tree-type tree-pop-age
    set max-wood-stock item 2 age-data * population-size

    ; Croissance ou décroissance logistique du bois
    let wood-growth growth-wood-logistic tree-type tree-pop-age population-size
    let new-wood-stock current-wood-stock + wood-growth
    set current-wood-stock min (list new-wood-stock max-wood-stock)
    ; Ratio de bois par population

    set wood-ratio calculate-wood-ratio



    ; Réactualiser le max de fruits et feuilles  en fonction de la population restante et du bois

    set max-fruit-stock item 0 age-data * population-size * wood-ratio
    set max-leaf-stock item 1 age-data * population-size * wood-ratio


    ; Croissance ou décroissance logistique des fruits
    let fruit-growth growth-fruit-logistic tree-type tree-pop-age population-size
    let new-fruit-stock current-fruit-stock + fruit-growth
    set current-fruit-stock min (list new-fruit-stock max-fruit-stock)

    ; Croissance ou décroissance logistique des feuilles
    let leaf-growth growth-leaf-logistic tree-type tree-pop-age population-size
    let new-leaf-stock current-leaf-stock + leaf-growth
    set current-leaf-stock min (list new-leaf-stock max-leaf-stock)
  ]
end

; Fonction pour calculer la croissance logistique des fruits
to-report growth-fruit-logistic [input-tree-type tree-age pop-size]
  let r 0
  if input-tree-type = "nutritive" [
    if current-season = "Nduungu" [set r 0.05]
    if current-season = "Ceedu" [set r 0.03]
    if current-season = "Dabbuunde" [set r 0.01]
    if current-season = "Ceetcelde" [set r 0.005]
  ]
  if input-tree-type = "less-nutritive" [
    if current-season = "Nduungu" [set r 0.04]
    if current-season = "Ceedu" [set r 0.025]
    if current-season = "Dabbuunde" [set r 0.01]
    if current-season = "Ceetcelde" [set r 0.005]
  ]
  if input-tree-type = "fruit" [
    if current-season = "Nduungu" [set r 0.06]
    if current-season = "Ceedu" [set r 0.04]
    if current-season = "Dabbuunde" [set r 0.02]
    if current-season = "Ceetcelde" [set r 0.01]
  ]
  let growth r * current-fruit-stock * (1 - (current-fruit-stock / max-fruit-stock))
  report growth
end

 ;Fonction pour calculer la croissance logistique des feuilles
to-report growth-leaf-logistic [input-tree-type tree-age pop-size]
  let r 0
  if input-tree-type = "nutritive" [
    if current-season = "Nduungu" [set r 0.05]
    if current-season = "Ceedu" [set r 0.03]
    if current-season = "Dabbuunde" [set r 0.01]
    if current-season = "Ceetcelde" [set r 0.005]
  ]
  if input-tree-type = "less-nutritive" [
    if current-season = "Nduungu" [set r 0.04]
    if current-season = "Ceedu" [set r 0.025]
    if current-season = "Dabbuunde" [set r 0.01]
    if current-season = "Ceetcelde" [set r 0.005]
  ]
  if input-tree-type = "fruit" [
    if current-season = "Nduungu" [set r 0.06]
    if current-season = "Ceedu" [set r 0.04]
    if current-season = "Dabbuunde" [set r 0.02]
    if current-season = "Ceetcelde" [set r 0.01]
  ]
  let growth r * current-leaf-stock * (1 - (current-leaf-stock / max-leaf-stock))
  report growth
end

;Fonction pour calculer la croissance logistique du bois
to-report growth-wood-logistic [input-tree-type tree-age pop-size]
  let r 0
  if input-tree-type = "nutritive" [
    if current-season = "Nduungu" [set r 0.05]
    if current-season = "Ceedu" [set r 0.03]
    if current-season = "Dabbuunde" [set r 0.01]
    if current-season = "Ceetcelde" [set r 0.005]
  ]
  if input-tree-type = "less-nutritive" [
    if current-season = "Nduungu" [set r 0.04]
    if current-season = "Ceedu" [set r 0.025]
    if current-season = "Dabbuunde" [set r 0.01]
    if current-season = "Ceetcelde" [set r 0.005]
  ]
  if input-tree-type = "fruit" [
    if current-season = "Nduungu" [set r 0.06]
    if current-season = "Ceedu" [set r 0.04]
    if current-season = "Dabbuunde" [set r 0.02]
    if current-season = "Ceetcelde" [set r 0.01]
  ]

    let growth r * current-wood-stock * (1 - (current-wood-stock / max-wood-stock))
  report growth

end

;  ask patches [
;    let new-current-grass current-grass + r * current-grass * (K - current-grass) / K
;    set current-grass min (list new-current-grass K)  ; Assurez-vous que la couverture d'herbe ne dépasse pas K
;  ]
;end

;to color-trees  ;; patch procedure
;  set pcolor scale-color (green - 1) trees 0 (2 * max-grass-height)
to move-and-eat
  ; Mouvement et consommation des bovins
  ask cattles [
    let best-patch find-best-nearest-patch known-space
    if best-patch != nobody [
      move-to best-patch
      let grass-eaten consume-grass best-patch daily-needs-per-head
      update-condition grass-eaten daily-needs-per-head
    ]
  ]

  ; Mouvement et consommation des ovins
  ask sheeps [
    let best-patch find-best-nearest-patch known-space
    if best-patch != nobody [
      move-to best-patch
      let grass-eaten consume-grass best-patch daily-needs-per-head
      update-condition grass-eaten daily-needs-per-head
    ]
  ]
end

; Trouver le meilleur patch : d'abord la qualité, ensuite la quantité, enfin la proximité
to-report find-best-nearest-patch [known-spaces]
  let viable-patches known-space with [current-grass > 0]

  ifelse any? viable-patches [
    ; Étape 1 : Sélectionner les patches avec la meilleure qualité d'herbe
    let best-quality-patches viable-patches with-max [grass-quality]

    ; Étape 2 : Parmi les patches avec la meilleure qualité, sélectionner ceux avec la plus grande quantité d'herbe
    let max-grass-patches best-quality-patches with-max [current-grass]

    ; Étape 3 : Choisir le patch le plus proche parmi ceux avec la meilleure qualité et la plus grande quantité d'herbe
    report min-one-of max-grass-patches [distance myself]
  ] [
    report nobody  ; Si aucun patch viable n'est trouvé
  ]

end

; Consommer de l'herbe sur un patch donné
to-report consume-grass [patch-to-eat amount]
  let grass-available [current-grass] of patch-to-eat
  let grass-eaten min list grass-available amount  ; La quantité d'herbe consommée est limitée par ce qui est disponible
  ask patch-to-eat [
    set current-grass current-grass - grass-eaten
  ]
  report grass-eaten  ; Retourner la quantité d'herbe consommée
end

; Mettre à jour la condition corporelle en fonction de la nourriture consommée
to update-condition [grass-eaten daily-needs]
  set corporal-condition corporal-condition + (grass-eaten - daily-needs)
end

to manage-water-points
  ask patches with [water-point = true] [
    set water-point false
  ]
  ask n-of 5 patches [
    set water-point true
  ]
end


to color-grass  ;; patch procedure
  set pcolor scale-color yellow current-grass max-grass 0
end

to display-labels
  ask turtles [set label ""]
  ask turtles [set label head]

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
0.0
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
4.0
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
14.0
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
7.0
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
3.0
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
0.0
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
"soil-type" "tree-cover" "grass-cover"
1

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
NetLogo 6.0.4
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
0
@#$#@#$#@
