globals [
  size-x  ; Taille horizontale du monde
  size-y  ; Taille verticale du monde
  current-season  ; Saison actuelle
  last-season ;
  season-counter  ; Compteur de saison
  herd-gain-from-food
  max-grass ; pour visualisation
  max-trees ; pour visualisation
  year-types  ; Liste qui stocke les types d'années
  current-year-type  ; Le type d'année en cours (bonne, moyenne, mauvaise)
  nduungu-duration ; nombre de ticks pour la saison des pluies
  dabbuunde-duration ; nombre de ticks pour la saison sèche froide
  ceedu-duration ; nombre de ticks pour la saison sèche chaude
  ceetcelde-duration ; nombre de ticks pour la période de soudure
]

breed [camps camp]
breed [foyers foyer]
breed [cattles cattle]
breed [sheeps sheep]
breed [fruityTrees fruityTree]
breed [nutritiousTrees nutritiousTree]
breed [lessNutritiousTrees lessNutritiousTree]

patches-own [
  soil-type  ; Type de sol

  current-grass  ; Couverture d'herbe
  K  ; montant maximum d'herbe
  grass-quality-ceedu
  grass-quality-ceetcelde
  grass-quality-nduungu
  grass-quality-dabbuunde
  prev-grass-quality-ceedu
  prev-grass-quality-ceetcelde
  prev-grass-quality-nduungu
  prev-grass-quality-dabbuunde
  biomass-end-nduungu

  tree-cover  ; Couverture d'arbres
  num-nutritious
  num-less-nutritious
  num-fruity


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

fruityTrees-own [
  pop-size
  age
  sensibility
  fruit-stock
  leaf-stock
  wood-stock
]

nutritiousTrees-own [
  pop-size
  age
  sensibility
  fruit-stock
  leaf-stock
  wood-stock
]

lessNutritiousTrees-own [
  pop-size
  age
  sensibility
  fruit-stock
  leaf-stock
  wood-stock
]

to setup
  clear-all
  resize-world -11 11 -11 11  ; Fixer les limites du monde à -11 à 11 en x et y
  set-patch-size 20  ; Ajuster la taille des patches
  load-environment "environment_vel.txt"
  set current-season "Nduungu"  ; Initialiser à la première saison
  set last-season "none"  ;; Initialiser last-season
  set season-counter 0  ; Compteur de saison initialisé à 0
  set max-grass 200000
  set max-trees 15000
  setup-landscape  ; Créer les unités de paysage
  setup-water-patches ; Créer les mares
  setup-camps  ; Créer les campements
  setup-foyers ; Créer les foyers
  setup-herds  ; Créer les troupeaux
  ;;setup-trees  ; Initialiser les arbres
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

to set-season-durations
  if current-year-type = "bonne" [
    ;; Par exemple : les bonnes années peuvent avoir une plus longue saison de croissance
    set nduungu-duration 10
    set dabbuunde-duration 5
    set ceedu-duration 8
    set ceetcelde-duration 9
  ]
  if current-year-type = "moyenne" [
    set nduungu-duration 8
    set dabbuunde-duration 6
    set ceedu-duration 6
    set ceetcelde-duration 9
  ]
  if current-year-type = "mauvaise" [
    set nduungu-duration 6
    set dabbuunde-duration 8
    set ceedu-duration 4
    set ceetcelde-duration 9
  ]
end

to setup-landscape
  ask patches [
    if soil-type = "Baldiol" [
      set current-grass 150000
      set K 150000  ; Stock de production maximal de Matière Sèche (MS - DM[en]) sur 1 km² pour "Baldiol"
      set num-nutritious round (tree-cover * 0.5)
      set num-less-nutritious round (tree-cover * 0.25)
      set num-fruity round (tree-cover * 0.25)
    ]
    if soil-type = "Caangol" [
      set current-grass 120000
      set K 120000  ; Stock de production maximal de Matière Sèche (MS - DM[en]) sur 1 km² pour Caangol
      set num-nutritious round (tree-cover * 0.5)
      set num-less-nutritious round (tree-cover * 0.25)
      set num-fruity round (tree-cover * 0.25)
    ]
    if soil-type = "Sangre" [
      set current-grass 90000
      set K 90000  ; Stock de production maximal de Matière Sèche (MS - DM[en]) sur 1 km² pour Sangre
      set num-nutritious round (tree-cover * 0.5)
      set num-less-nutritious round (tree-cover * 0.25)
      set num-fruity round (tree-cover * 0.25)
    ]
    if soil-type = "Seeno" [
      set current-grass 200000
      set K 200000  ; Stock de production maximal de Matière Sèche (MS - DM[en]) sur 1 km² pour Seeno
      set num-nutritious round (tree-cover * 0.5)
      set num-less-nutritious round (tree-cover * 0.25)
      set num-fruity round (tree-cover * 0.25)
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
    if soil-type != "caangol" [
     if any? neighbors with [soil-type = "caangol"] [
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
      move-to one-of [neighbors] of home-patch
      set my-sheeps self  ; Stocker la tortue dans une variable temporaire
    ]
    set sheep-herd my-sheeps
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
  grow-grass
  move-and-eat

  ask turtles [
    manage-water-points
 ;   come-back
  ]
  ask patches [
    color-grass
    ;color-trees
  ]

  tick
end

to update-season
  set season-counter season-counter + 1
  if current-season = "Ceedu" and season-counter >= ceedu-duration [
    set current-season "Ceetcelde"
    set season-counter 0
  ]
  if current-season = "Ceetcelde" and season-counter >= ceetcelde-duration [
    set current-season "Nduungu"
    set season-counter 0
  ]
  if current-season = "Nduungu" and season-counter >= nduungu-duration [
    set current-season "Dabbuunde"
    set season-counter 0
  ]
  if current-season = "Dabbuunde" and season-counter >= dabbuunde-duration [
    set current-season "Ceedu"
    set season-counter 0
  ]
end

to assign-grass-quality
  ask patches [
    if (any? patches with [prev-grass-quality-ceetcelde = 0 and grass-quality-ceetcelde = 0]) [  ; Vérifie si c'est la première année
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
      set prev-grass-quality-ceedu grass-quality-ceedu
      set prev-grass-quality-nduungu grass-quality-nduungu
      set prev-grass-quality-dabbuunde grass-quality-dabbuunde
      set prev-grass-quality-ceetcelde grass-quality-ceetcelde
    ]

  ;; Pour les années suivantes, réutilise la qualité de l'herbe de l'année précédente
  if current-season = "Ceedu" [set grass-quality-ceedu prev-grass-quality-ceedu]
  if current-season = "Nduungu" [set grass-quality-nduungu prev-grass-quality-nduungu]
  if current-season = "Dabbuunde" [set grass-quality-dabbuunde prev-grass-quality-dabbuunde]
  if current-season = "Ceetcelde" [set grass-quality-ceetcelde prev-grass-quality-ceetcelde]
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
      let r 0.01  ; Taux de croissance pendant Nduungu
      let new-current-grass current-grass + r * current-grass * (K - current-grass) / K
      set current-grass min (list new-current-grass K)

      ; À la fin de Nduungu, stocker la biomasse pour référence future
      if season-counter = nduungu-duration [
        set biomass-at-end-of-nduungu current-grass
      ]
    ]

    if current-season = "Dabbuunde" or current-season = "Ceedu" [
      ; Perte de biomasse du début de Dabbuunde jusqu'à la mi-Ceedu
      let total_loss_duration (duration-of-dabbuunde + (duration-of-ceedu / 2))  ; 60 + 60 = 120 ticks
      ; Calculer le temps écoulé depuis le début de Dabbuunde
      let time_elapsed season-counter + (if current-season = "Ceedu" [duration-of-dabbuunde] [0])
      ; S'assurer que le temps écoulé ne dépasse pas la durée totale de perte
      if time_elapsed <= total_loss_duration [
        ; Calculer le ratio de temps écoulé
        let time_ratio time_elapsed / total_loss_duration
        ; Définir le pourcentage de perte désiré entre 20% et 50%
        let min_loss_percentage 0.20
        let max_loss_percentage 0.50
        let desired_loss_percentage (min_loss_percentage + max_loss_percentage) / 2  ; 35% en moyenne
        let total_biomass_loss desired_loss_percentage * biomass-at-end-of-nduungu
        ; Calculer le taux de perte initial par tick
        let initial_loss_rate (2 * total_biomass_loss) / total_loss_duration
        ; Calculer la perte de biomasse par tick, diminuant avec le temps
        let biomass_loss_per_tick initial_loss_rate * (1 - (time_elapsed / total_loss_duration))
        ; Appliquer la perte
        set current-grass current-grass - biomass_loss_per_tick
        if current-grass < 0 [ set current-grass 0 ]
      ]
    ]

    if current-season = "Ceetcelde" [
      ; Réduction constante de 10% par tick
      let biomass_loss current-grass * 0.10
      set current-grass current-grass - biomass_loss
      if current-grass < 0 [ set current-grass 0 ]
    ]
  ]
end

;  ask patches [
;    let new-current-grass current-grass + r * current-grass * (K - current-grass) / K
;    set current-grass min (list new-current-grass K)  ; Assurez-vous que la couverture d'herbe ne dépasse pas K
;  ]
;end

to color-grass  ;; patch procedure
  set pcolor scale-color yellow current-grass max-grass 0
end

;to color-trees  ;; patch procedure
;  set pcolor scale-color (green - 1) trees 0 (2 * max-grass-height)

to move-and-eat
  ask cattles [
    ;let best-patch max-one-of known-space with [current-grass > 0]
    let MySpace known-space with [current-grass > 0]
    let best-patch  one-of MySpace with-max [current-grass]
    if best-patch != nobody [
      move-to best-patch
      let grass-eaten min (list [current-grass] of best-patch daily-needs-per-head)
      set corporal-condition (corporal-condition + grass-eaten - daily-needs-per-head)

      ask best-patch [
        set current-grass current-grass - (grass-eaten)
      ]
    ]
  ]

  ask sheeps [
     let best-patch max-one-of known-space with [current-grass > 0] [current-grass]
    if best-patch != nobody [
      move-to best-patch
      let grass-eaten min (list [current-grass] of best-patch daily-needs-per-head)
      ask best-patch [
        set current-grass current-grass - (grass-eaten)
      ]
      set corporal-condition (corporal-condition + grass-eaten - daily-needs-per-head)
    ]
  ]
end

to manage-water-points
  ask patches with [water-point = true] [
    set water-point false
  ]
  ask n-of 5 patches [
    set water-point true
  ]
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
12.0
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
0.0
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
0.0
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
0.0
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
