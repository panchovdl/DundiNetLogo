__includes["calculStat.nls"]
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
  let all-camps camps
  let total-UBT-created 0
  let candidate-foyers 0

  ask all-camps [
    set candidate-foyers candidate-foyers + round (available-space * 0.8)
  ]

  ; Calculer le nombre de bons et mauvais bergers en fonction du pourcentage
  let num-good-shepherd round (candidate-foyers * (good-shepherd-percentage / 100))
  let num-bad-shepherd candidate-foyers - num-good-shepherd

  ; Créer une liste des types de bergers en fonction des proportions
  let shepherd-types []
  repeat num-good-shepherd [ set shepherd-types lput "bon" shepherd-types ]
  repeat num-bad-shepherd [ set shepherd-types lput "mauvais" shepherd-types ]

  ; Mélanger la liste pour attribuer les types aléatoirement
  set shepherd-types shuffle shepherd-types

  ; Compteur pour suivre l'index dans la liste des types
  let shepherd-type-index 0

  ;; On va créer les foyers camp par camp, foyer par foyer, jusqu'à atteindre sum-UBT
  let camp-list sort all-camps
  let camp-index 0
  let max-try 10000

  while [total-UBT-created < sum-UBT and max-try > 0] [
    if camp-index >= length camp-list [
      set camp-index 0
    ]
    let this-camp item camp-index camp-list
    ; Boucle de création des foyers
    ask this-camp [
      if shepherd-type-index >= length shepherd-types [
        ;; Plus de shepherd dispo ? On arrête
        stop
      ]
      let my-camp self
      hatch-foyers 1 [
        set color brown
        set size 0.1
        set shape "person"
        set pasture-strategy "directed"

        set cattle-herd-count 0
        set sheep-herd-count 0
        set shepherd-type item shepherd-type-index shepherd-types
        set shepherd-type-index shepherd-type-index + 1

        set herder-type determine-herder-type
        set-herd-sizes

        ; Définir les variables d'agriculture
        set stock-residu 0                 ; pas de residu de culture initialement
        set surface-agriculture 1 / 100      ; surface en km²  (de base : 1 hectare par surface agricole )

        ;Définir les variables d'exploration
        set far-exploration-count 0       ; Compteur d'exploration au loin
        set close-exploration-count 0     ; Compteur d'exploration proche


        ; Définir la taille des troupeaux de bovins en fonction de la catégorie
        if cattle-herd-size = "grand" [set cattle-herd-count random 20 + 30]
        if cattle-herd-size = "moyen" [set cattle-herd-count random 15 + 10]
        if cattle-herd-size = "petit" [set cattle-herd-count random 9 + 1]


        ; Définir la taille des troupeaux de moutons en fonction de la catégorie
        if sheep-herd-size = "grand" [set sheep-herd-count random 40 + 30]
        if sheep-herd-size = "moyen" [set sheep-herd-count random 20 + 10]
        if sheep-herd-size = "petit" [set sheep-herd-count random 9 + 1]

        let foyer-UBT ((cattle-herd-count * 1) + (sheep-herd-count * 0.16 ))

        set original-home-camp my-camp  ; Assigne le campement capturé au foyer
        set current-home-camp original-home-camp
        set original-home-patch [patch-here] of original-home-camp  ; Stocke la position du campement
        set current-home-patch original-home-patch
        set known-space patches in-radius 3
        set close-known-space known-space with [
          distance [current-home-patch] of myself <= 6
        ] ; end set close-known-space
        set distant-known-space known-space who-are-not close-known-space

        set cattle-low-threshold-cc 1
        set sheep-low-threshold-cc 1
        set cattle-high-threshold-cc 3
        set sheep-high-threshold-cc 3


        set far-exploration-count 0       ; Compteur d'exploration au loin
        set close-exploration-count 0     ; Compteur d'exploration proche
           ;; Vérifions si on dépasse sum-UBT
        ifelse total-UBT-created + foyer-UBT > sum-UBT [
          ;; On dépasse => Ajustement
          let diff (total-UBT-created + foyer-UBT - sum-UBT)
          ;; On essaie d'enlever quelques moutons d'abord (plus fin)
          let sheep_to_remove ceiling (diff / 0.16)
          if sheep_to_remove > sheep-herd-count [
            set sheep_to_remove sheep-herd-count
          ]
          set sheep-herd-count sheep-herd-count - sheep_to_remove

          let current_foyer_UBT ((cattle-herd-count * 1) + (sheep-herd-count * 0.16))
          if total-UBT-created + current_foyer_UBT > sum-UBT [
            let diff2 (total-UBT-created + current_foyer_UBT - sum-UBT)
            let cattle_to_remove ceiling diff2
            if cattle_to_remove > cattle-herd-count [
              set cattle_to_remove cattle-herd-count
            ]
            set cattle-herd-count cattle-herd-count - cattle_to_remove
          ]

          ;; Recalcul final de l'UBT du foyer
          set foyer-UBT ((cattle-herd-count * 1) + (sheep-herd-count * 0.16))
          set total-UBT-created total-UBT-created + foyer-UBT

          ;; On a atteint sum-UBT, on stocke les compteurs finaux
          set cattle-herd-count cattle-herd-count
          set sheep-herd-count sheep-herd-count

          ;; On a fini, on pourra arrêter la création
        ] [
          ;; On ne dépasse pas
          set total-UBT-created total-UBT-created + foyer-UBT
          set cattle-herd-count cattle-herd-count
          set sheep-herd-count sheep-herd-count
        ]

        if (cattle-herd-count = 0 and sheep-herd-count = 0) [
          die
        ]
      ]; end hatch-foyers
    ]; end ask camp

    if total-UBT-created >= sum-UBT [
      ;; sum-UBT atteint, on sort
      stop
    ]

    set camp-index camp-index + 1
    set max-try max-try - 1
  ]; end boucle création


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

    let my-pasture-strategy pasture-strategy
    let my-shepherd-type shepherd-type  ; Récupérer le herder-type du foyer
    let my-cattle-count cattle-herd-count
    let my-sheep-count sheep-herd-count
    ; Créer un troupeau de bovins pour le foyer
    let my-cattles []
    hatch-cattles 1 [

      ; caractéristiques physiologiques
      set head my-cattle-count
      if head = 0 [ die ]
      set UBT-size 1
      set corporal-condition 5
      set protein-condition 10
      set initial-live-weight 250 * UBT-size * head
      set live-weight initial-live-weight
      set max-live-weight 350 * head
      set min-live-weight 66 * head

      ; caractéristiques visuelles
      set color grey
      set shape "cow"
      set size calculate-herd-size head  ;; easier to see
      set label-color blue - 2
      set label head


      ; consommation et gain/perte de poids
      set max-daily-DM-ingestible-per-head 7.2 * UBT-size
      set daily-min-UF-needed-head 0.45 * max-daily-DM-ingestible-per-head          ; Quantité minimum d'Unité Fourragère à l'entretien d'un UBT
      set daily-min-MAD-needed-head 25  * max-daily-DM-ingestible-per-head        ; Quentité minimum de Matière Azotée Digestible à l'entretien d'un UBT
      set weight-gain 0
      set daily-water-consumption 22 * head * UBT-size; 22 l/UBT/J de consommation d'eau


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
      set close-known-space known-space in-radius 6
      set distant-known-space known-space who-are-not close-known-space
      set original-camp-known-space [close-known-space] of foyer-owner
      set have-left false
    ]
    ; Attribuer le troupeau créé à son propriétaire
    set cattle-herd my-cattles
    if cattle-herd = [] [
      set cattle-herd nobody]

    ; Créer un troupeau de petits ruminants pour le foyer
    let my-sheeps []
    hatch-sheeps 1 [

      ; caractéristiques physiologiques
      set head my-sheep-count
      if head = 0 [ die ]
      set UBT-size 0.16
      setxy random-xcor random-ycor
      set corporal-condition 5
      set protein-condition 10
      set initial-live-weight 250 * UBT-size * head
      set live-weight initial-live-weight
      set max-live-weight 80 * head
      set min-live-weight 21 * head

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
      set close-known-space known-space in-radius 6
      set distant-known-space known-space who-are-not close-known-space
      set have-left false
    ]
    ; Attribuer le troupeau créé à son propriétaire
    set sheep-herd my-sheeps
        if sheep-herd = [] [
      set sheep-herd nobody]
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


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; Initialisation des zones d'agriculture ;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to recalcul-herd-parameters
  set initial-live-weight 250 * UBT-size * head
  set live-weight initial-live-weight
  set max-live-weight 350 * head
  set min-live-weight 66 * head

  set max-daily-DM-ingestible-per-head 7.2 * UBT-size
  set daily-min-UF-needed-head 0.45 * max-daily-DM-ingestible-per-head
  set daily-min-MAD-needed-head 25  * max-daily-DM-ingestible-per-head
  set daily-water-consumption 22 * head * UBT-size
  set size calculate-herd-size head
  set label head
end

;;; /!\ Pas de contrôle de surface de culture dans les patchs voisins du campement. Il faudrait une variable interne aux patchs pour faire ce suivi /!\
to setup-agriculture                                                                                ; initialisation des champs agri
  ask patches with [any? turtles-here with [breed = foyers]] [                                      ; pour chaque patch avec un foyer
    let compte-surface-agri 0                                                                       ; surface totale agricole initialisée à 0
    ask turtles-here with [breed = foyers] [                                                        ; parcours des foyers pour création des champs
      ; créer les champs, réduire l'herbe disponible sur le patch
     let surface-agri surface-agriculture
      ifelse (compte-surface-agri + surface-agriculture) < 80 [                                     ; creation de champ si espace dispo sur le patch
        set K (K - (surface-agri * K-max))                                                          ; ajustement de l'herbe disponible sur le patch
        hatch-champs 1 [                                                                            ; creation du champ sur la parcelle
          set foyer-owner who
          set surface surface-agri
        ]
        set compte-surface-agri (compte-surface-agri + surface-agri)                                ; ajustement du compte de surface agricole de la parcelle
      ] [                                                                                           ; creation de champ dans le pâtch voisin si pas d'espace dispo sur le patch
        ask one-of neighbors [                                                                      ; selection d'une parcelle voisine
        set K (K - K-max * surface-agri)                                                            ; ajustement de l'herbe disponible sur le patch
        hatch-champs 1 [                                                                            ; creation du champ sur parcelle voisine
          set foyer-owner who
          set surface surface-agri
          ]
        ]
      ]
    ]
  ]
end

to stock-residu-cultures                                                                            ; production des stocks de résidu de culture
  ask patches with [any? turtles-here with [breed = foyers]] [                                       ; trouver tous les foyers de la carte
    ask turtles-here with [breed = foyers] [
     set stock-residu (stock-residu +  surface-agriculture * production-residu-hectare-agriculture)
    ]
  ]
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Retour des troupeaux ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to call-back-herds
  ;; Retour des troupeaux de bovins
  ask cattles with [have-left = true] [
    show-turtle
    set live-weight initial-live-weight  ; Réinitialiser le poids vif
    set corporal-condition 5             ; NEC maximum
    set protein-condition 10             ; Condition protéique maximale
    set have-left false
  ]

  ;; Retour des troupeaux de moutons
  ask sheeps with [have-left = true] [
    show-turtle
    set live-weight initial-live-weight  ; Réinitialiser le poids vif
    set corporal-condition 5             ; NEC maximum
    set protein-condition 10             ; Condition protéique maximale
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
    set current-season "Dabbuunde"
    set season-counter 0
    stock-residu-cultures         ; Début du dabbuunde : recolte des cultures et stock des residus
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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Mise à jour des valeurs nutritives de l'herbe. Mise à jour par saison ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to update-UF-and-MAD
  ask patches [
    ; Définit pour les deux espèces les valeurs en UF et MAD par kg de MS (valeurs de Boudet, 1975, "Manuel sur les pâturages tropicaux et cultures fourragères" en prenant comme référence une valeur proche des graminées les plus présents (monocotylédones) et zornia comme légumineuse (dicotylédone))
    if current-season = "Nduungu" [
      set monocot-UF-per-kg-MS 0.5
      set monocot-MAD-per-kg-MS 60
      set dicot-UF-per-kg-MS 0.6
      set dicot-MAD-per-kg-MS 100
    ]
    if current-season = "Dabbuunde" [
      set monocot-UF-per-kg-MS 0.6
      set monocot-MAD-per-kg-MS 20
      set dicot-UF-per-kg-MS 0.8
      set dicot-MAD-per-kg-MS 110
    ]
    if current-season = "Ceedu" [
      set monocot-UF-per-kg-MS 0.45
      set monocot-MAD-per-kg-MS 1
      set dicot-UF-per-kg-MS 0.6
      set dicot-MAD-per-kg-MS 30
    ]
    if current-season = "Ceetcelde" [
      set monocot-UF-per-kg-MS 0.4
      set monocot-MAD-per-kg-MS 0.01
      set dicot-UF-per-kg-MS 0.4
      set dicot-MAD-per-kg-MS 30
    ]
  ]
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Mise à jour des valeurs nutritives des arbres. Mise à jour par saison ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to update-tree-nutritional-values
  ask tree-populations [
    let nutritional-values get-tree-nutritional-values tree-type [soil-type] of patch-here current-season
    set tree-UF-per-kg-MS item 0 nutritional-values
    set tree-MAD-per-kg-MS item 1 nutritional-values
  ]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Mise à jour des proportions d'herbe. Mise à jour par an ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to assign-grass-proportions ; Réassigner la proportion de monocotylédones (p) en fonction du type de sol

  if soil-type = "Baldiol" [
    set p random-float (0.0 - 0.2) + 0.3  ; Intervalle [0.3, 0.5]
  ]
  if soil-type = "Caangol" [
    set p random-float (0.0 - 0.3) + 0.1  ; Intervalle [0.1, 0.4]
  ]
  if soil-type = "Sangre" [
    set p random-float (0.0 - 0.3) + 0.3  ; Intervalle [0.3, 0.6]
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




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Mise à jour de la qualité de l'herbe selon les proportions des deux espèces herbacées. Mise à jour quotidienne ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to update-grass-quality ; - Version 2
  ask patches [
    ; Calculer le rapport MAD/UF pour les monocotylédones
    let mean-UF-per-kg-DM  ((monocot-UF-per-kg-MS * current-monocot-grass) + (dicot-UF-per-kg-MS * current-dicot-grass)) / (current-monocot-grass + current-dicot-grass)
    let mean-MAD-per-kg-DM  ((monocot-MAD-per-kg-MS * current-monocot-grass) + (dicot-MAD-per-kg-MS * current-dicot-grass)) / (current-monocot-grass + current-dicot-grass)
    ; Déterminer la qualité de l'herbe en fonction du rapport moyen MAD/UF
    ifelse ((mean-UF-per-kg-DM >= seuil-bon-UF) AND (mean-MAD-per-kg-DM >= seuil-bon-MAD)) [
      set grass-quality "good"
      ] [ ifelse ((mean-UF-per-kg-DM >= seuil-moyen-UF) AND (mean-MAD-per-kg-DM >= seuil-moyen-MAD))  [
        set grass-quality "average"
      ] [
        set grass-quality "poor"
      ]
      ; Assigner q basé sur la qualité actuelle de l'herbe
    ]
    set q grass-quality-to-q grass-quality
  ]
end


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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Mise à jour du stock de l'herbe selon les proportions des deux espèces herbacées. Mise à jour quotidienne ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


to grow-grass  ; - Version 2.2.

  let multiplier decreasing-factor
  ask patches [
    let r_grass 0 ; Taux de croissance de l'herbe, uniforme pour tous les types d'herbe
                  ; Croissance logistique pendant Nduungu
    let new-mono-grass 0
    let new-dicot-grass 0
    if current-season = "Nduungu" [
      set r_grass 0.2
      set multiplier 1
    ]
    if current-season = "Dabbuunde" [
      set r_grass -0.05
      if current-grass >= (0.9 * K) [ set r_grass -0.4]
    ]
    if current-season = "Ceedu" [
      set r_grass -0.01
    ]
    if current-season = "Ceetcelde" [
      set r_grass -0.02
    ]

    ; Croissance logistique pour les dicotylédones
    set new-mono-grass current-monocot-grass + r_grass * current-monocot-grass * multiplier * (K * p - current-monocot-grass) / (K * p)
    ; Croissance logistique pour les dicotylédones
    set new-dicot-grass current-dicot-grass + r_grass * current-dicot-grass * multiplier * (K * (1 - p) - current-dicot-grass) / (K * (1 - p))


    set current-monocot-grass min (list new-mono-grass (K * p))
    set current-dicot-grass min (list new-dicot-grass (K * (1 - p)))
    ; Mettre à jour le stock total d'herbe
    set current-grass current-monocot-grass + current-dicot-grass

    ;  let new-current-grass current-grass + r * current-grass * (K - current-grass) / K
    ;  set current-grass min (list new-current-grass K)


    ; Assurer que les valeurs restent positives
    if current-monocot-grass <= 0 [ set current-monocot-grass 1 ]
    if current-dicot-grass <= 0 [ set current-dicot-grass 1]
    if current-grass <= 0 [ set current-grass 1 ]
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
      ifelse population-size > 0 [
        set max-wood-stock max-wood * population-size
        set max-fruit-stock max-fruit * population-size
        set max-leaf-stock max-leaf * population-size
      ] [
        set max-wood-stock 0
        set max-fruit-stock 0
        set max-leaf-stock 0
      ]
        set tree-sensitivity sensitivity

      if tree-pop-age = 8 and population-size > 0 [
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
  set year-index year-index + 1
  if year-index >= 20 [
    set year-index 1 ]
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
  ask patches [
    let new-trees-by-type []

    ; Calculer le nombre de nouvelles pousses pour chaque type d'arbre sur le patch
    ask tree-populations-here [
      ; Récupérer le taux de germination pour le type d'arbre et la qualité de l'année
      let germination-rate get-germination-rate tree-type current-year-type
      ; Calculer les nouvelles pousses
      let new-trees floor ((current-fruit-stock * 100 ) * germination-rate)
      set new-trees min (list new-trees [max-tree-number] of patch-here)

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
    let wood-growth growth-wood-logistic tree-type current-wood-stock max-wood-stock current-season

    let new-wood-stock current-wood-stock + wood-growth
    set current-wood-stock min (list new-wood-stock max-wood-stock)
    if current-wood-stock < 0.4 * max-wood-stock [
      set current-wood-stock (0.4 * max-wood-stock)]

    ; Ratio de bois par population
    set wood-ratio calculate-wood-ratio

    ; Réactualiser le max de fruits et feuilles  en fonction de la population restante et du bois
    set max-fruit-stock max-fruit * population-size * wood-ratio
    set max-leaf-stock max-leaf * population-size * wood-ratio

    ; Croissance ou décroissance logistique des fruits
    let fruit-growth growth-fruit-logistic tree-type current-fruit-stock max-fruit-stock current-season ([soil-type] of patch-here)
    let new-fruit-stock current-fruit-stock + fruit-growth
    set current-fruit-stock min (list new-fruit-stock max-fruit-stock)
    if current-fruit-stock <= 0 [set current-fruit-stock 1 ]

    ; Croissance ou décroissance logistique des feuilles
    let leaf-growth growth-leaf-logistic tree-type current-leaf-stock max-leaf-stock current-season ([soil-type] of patch-here)
    let new-leaf-stock current-leaf-stock + leaf-growth
    set current-leaf-stock min (list new-leaf-stock max-leaf-stock)
    if current-leaf-stock <= 0 [set current-leaf-stock 1 ]
  ]
  ask tree-populations with [population-size <= 0] [die]

end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Stratégie alimentaire du troupeau ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to move ; Mouvement des troupeaux - bovins puis ovins

  ;; Find the best patch within known space
  let best-patch find-best-nearest-patch known-space shepherd-type head max-daily-DM-ingestible-per-head current-season
  let my-known-space known-space
  move-to current-home-patch
  ifelse best-patch != nobody [
    ;; Calculate the distance between the best patch and the current home patch
    let distance-to-home distance best-patch

    ;; If the best patch is more than 6 units away from the current home patch
    ifelse distance-to-home >= 6 [

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
        set known-space (patch-set my-known-space nearby-patches)

      ] [ ;; The herd is already in a temporary camp

        ;; Check if the best patch is in the original camp known space
        ifelse member? best-patch original-camp-known-space [

          ;; Move to the best patch
          move-to best-patch
          set current-home-patch original-home-patch
          set is-in-temporary-camp false
          set xcor xcor + (random-float 0.9 - 0.45)
          set ycor ycor + (random-float 0.9 - 0.45)

        ] [
          ;; Create a temporary camp
          set current-home-patch best-patch
          set is-in-temporary-camp true
          move-to current-home-patch
          set xcor xcor + (random-float 0.9 - 0.45)
          set ycor ycor + (random-float 0.9 - 0.45)

          ;; Add patches within a radius of 3 cells around the camp to known-space
          let nearby-patches [patches in-radius 3] of current-home-patch
          set known-space (patch-set my-known-space nearby-patches)
        ]
      ]
    ] [ ;; The best patch is within 6 units of the current home patch

      ;; Move to the best patch
      move-to best-patch
      set xcor xcor + (random-float 0.9 - 0.45)
      set ycor ycor + (random-float 0.9 - 0.45)
    ]
  ] [
    if is-in-temporary-camp = true [
      move-to original-home-patch
      set current-home-patch original-home-patch
      set is-in-temporary-camp false]
    stop
  ]

end

to eat

  ; Calculer les besoins énergétiques (UF) et protéiques (MAD) qui peut évoluer à chaque step en fonction du nombre de tête dans le troupeau
  set daily-needs-UF daily-min-UF-needed-head * head
  set daily-needs-MAD daily-min-MAD-needed-head * head
  set daily-needs-DM max-daily-DM-ingestible-per-head * head

  ; Déterminer la préférence pour les monocotylédones

  set preference-mono 0.5  ; Valeur par défaut

  ifelse current-season = "Nduungu" [
    ; En Nduungu, préférence de 80% pour les monocotylédones
    set preference-mono 0.8
  ] [
    ; Pendant les autres saisons, préférence de 80% pour l'espèce avec le ratio MAD/UF le plus élevé
    let monocot-MAD-UF-ratio (([monocot-MAD-per-kg-MS] of patch-here / [monocot-UF-per-kg-MS] of patch-here) * current-monocot-grass)
    let dicot-MAD-UF-ratio (([dicot-MAD-per-kg-MS] of patch-here / [dicot-UF-per-kg-MS] of patch-here) * current-dicot-grass)

    ifelse monocot-MAD-UF-ratio >= dicot-MAD-UF-ratio [
      set preference-mono 0.8
    ] [
      set preference-mono 0.3
    ]
  ]

  ; Calculer l'UF/kg MS moyen du fourrage disponible
  let monocot-prop ([current-monocot-grass] of patch-here / [current-grass] of patch-here)
  let average-UF-per-kg-MS ([monocot-UF-per-kg-MS] of patch-here * monocot-prop) + ([dicot-UF-per-kg-MS] of patch-here * (1 - monocot-prop))

  ; Calculer la MAD/kg MS moyenne du fourrage disponible
  let dicot-prop [current-dicot-grass] of patch-here / [current-grass] of patch-here
  let average-MAD-per-kg-MS ([monocot-MAD-per-kg-MS] of patch-here * monocot-prop) + ([dicot-MAD-per-kg-MS] of patch-here * (1 - monocot-prop))

  ; Calculer la quantité de MS à consommer en fonction de la valeur moyenne du fourrage disponible en UF. Plus la valeur est forte, plus il en mangera
  let desired-MS-intake (daily-needs-DM * 0.7  + ((daily-needs-DM * 0.3)  * average-UF-per-kg-MS))
  ; Assurer que la consommation ne dépasse pas max-daily-DM-ingestible-per-head
  set desired-MS-intake min list desired-MS-intake daily-needs-DM

  ; Consommer l'herbe
  consume-grass patch-here desired-MS-intake p preference-mono

  let max-tree-ratio 0.5  ;; Valeur par défaut pour bovins
  if breed = sheeps [
    set max-tree-ratio 0.8
  ]

  ; Calculer le reste de MS à consommer en fonction de la consommation journalière maximale et la quantité voulue à consommer par le troupeau
  let remaining-DM-to-consume (desired-MS-intake - DM-ingested)

  set remaining-DM-to-consume min (list remaining-DM-to-consume (daily-needs-DM * max-tree-ratio))

  if remaining-DM-to-consume > 0 and DM-ingested > 0.2 [
    consume-tree-resources patch-here remaining-DM-to-consume
  ]

end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Procédure d'ingestion de l'herbe  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Procédure pour consommer l'herbe
to consume-grass [patch-to-eat amount-to-consume monocot-prop pref-mono]

  ; Obtenir les quantités disponibles d'herbe par type sur le patch
  let mono-grass-available [current-monocot-grass] of patch-to-eat
  let dicot-grass-available [current-dicot-grass] of patch-to-eat

  ; Calculer les quantités consommées par type sur le patch
  let mono-ingested min (list mono-grass-available (amount-to-consume * pref-mono))

  let dicot-ingested min (list dicot-grass-available (amount-to-consume * (1 - pref-mono)))
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
    if current-monocot-grass < 0 [ set current-monocot-grass 0.001 ]
    if current-dicot-grass < 0 [ set current-dicot-grass 0.001 ]
    if current-grass < 0 [ set current-grass 0.002 ]
  ]
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Procédure d'ingestion des feuilles et fruits  ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to consume-tree-resources [patch-of-grass-eaten remaining-needs] ;; contexte troupeau
                                                                 ;; Obtenir les populations d'arbres matures sur le patch
  let all-trees tree-populations-on patch-of-grass-eaten
  let consumption-treshold 0
  let wood-reduction-per-kg-MS 0; Cf Hiernaux 1994
                                ;; Arbres de plus de 5 ans
  set all-trees all-trees with [population-size > 0 and current-leaf-stock > 0 and current-fruit-stock > 0]
  let mature-trees all-trees with [tree-pop-age >= 6]
  let good-trees []
  ;; Déterminer les arbres ciblés en fonction du type de troupeau
  if shepherd-type = "bon" [
    set consumption-treshold 0.3
    ;; Priorité aux types "nutritive" et "fruity"
    set good-trees mature-trees with [ tree-type = "nutritive" or tree-type = "fruity" ]
    if not any? good-trees [
      ;; Si pas d'arbres "nutritive" ou "fruity", prendre les "less-nutritive"
      set consumption-treshold 0.5
      set wood-reduction-per-kg-MS 0.3
      set good-trees mature-trees with [ tree-type = "lessNutritive" ]
    ]
  ]
  if shepherd-type = "mauvais" [
    ;; Tous les arbres, pas de distinction
    set consumption-treshold 0.8
    set wood-reduction-per-kg-MS 0.6
    set good-trees all-trees
  ]
  if any? good-trees [
    ;; Créer une liste des populations consommables et leurs `max-consumable`
    ;  ;; Filtrer les arbres en fonction de la disponibilité des ressources
    ;  set good-trees good-trees with [
    ;    (current-leaf-stock >= (consumption-treshold * max-leaf-stock)) or (current-fruit-stock >= (consumption-treshold * max-fruit-stock))
    ;
    ;  ]
    let tree-max-consumable []
    let total-available 0
    ask good-trees [
      if current-leaf-stock >= 0.1 and current-fruit-stock >= 0.1 [
        let max_consumable (current-leaf-stock + current-fruit-stock)
        set total-available total-available + max_consumable
        set tree-max-consumable lput (list who max_consumable) tree-max-consumable
      ]
    ]
    ; Déterminer la quantité à consommer
    let amount-to-consume min list remaining-needs total-available
    if amount-to-consume <= 0 [ set amount-to-consume 0 ]

    ;; Distribuer la consommation proportionnellement
    foreach tree-max-consumable [ [i] ->
      let who-one-tree-population item 0 i
      let one-tree-population turtle who-one-tree-population
      let max-consumable item 1 i

      let share precision (max-consumable / total-available) 5

      let amount-consumed (amount-to-consume * share)

      let total_resources ([current-leaf-stock] of one-tree-population + [current-fruit-stock] of one-tree-population)

      if total_resources > 1 [
        let leaves_share ([current-leaf-stock] of one-tree-population / total_resources)
        let fruits_share ([current-fruit-stock] of one-tree-population / total_resources)
        let leaves-consumed amount-consumed * leaves_share
        set leaves-eaten leaves-consumed
        let fruits-consumed amount-consumed * fruits_share
        set fruits-eaten fruits-consumed

        ;; Mettre à jour les stocks dans la population d'arbres
        ask one-tree-population [
          set current-leaf-stock max list (current-leaf-stock - leaves-consumed) 0
          set current-fruit-stock  max list (current-fruit-stock - fruits-consumed) 0
          if current-leaf-stock <= 0 [ set current-leaf-stock 1 ]
          if current-fruit-stock <= 0 [ set current-fruit-stock 1 ]
          if current-wood-stock <= 0 [
            die
            set trees-killed trees-killed + [population-size] of self
          ]
        ]

        ;; Calculer les UF et MAD ingérées depuis cette population
        ;; Hypothèse : les feuilles et les fruits ont les mêmes valeurs nutritives
        let UF-ingested-pop amount-consumed * [tree-UF-per-kg-MS] of one-tree-population
        let MAD-ingested-pop amount-consumed * [tree-MAD-per-kg-MS] of one-tree-population

        ;; Accumuler les valeurs
        set total-UF-ingested-from-trees total-UF-ingested-from-trees + UF-ingested-pop
        set total-MAD-ingested-from-trees total-MAD-ingested-from-trees + MAD-ingested-pop
        set total-DM-ingested-from-trees total-DM-ingested-from-trees + amount-consumed

      ] ;; end if
    ];; end foreach
     ;; context troupeau
     ;; Mettre à jour les variables du troupeau
    set UF-ingested UF-ingested + total-UF-ingested-from-trees
    set MAD-ingested MAD-ingested + total-MAD-ingested-from-trees
    set DM-ingested DM-ingested + total-DM-ingested-from-trees

    let proportion-from-trees (total-DM-ingested-from-trees / DM-ingested)   ; proportion de la ration provenant des arbres
    if shepherd-type = "mauvais" [

      if proportion-from-trees >= 0.5 [
        ;; Sélectionner un arbre au hasard parmi les arbres consommables
        if any? good-trees [
          let tree-to-kill one-of good-trees
          ask tree-to-kill [
            set current-fruit-stock current-fruit-stock - (max-fruit-stock / population-size)
            set current-leaf-stock current-leaf-stock - (max-leaf-stock / population-size)
            set current-wood-stock current-wood-stock - (max-wood-stock / population-size)
            set population-size population-size - 1  ; Supprime un arbre dans la population cible
            set trees-killed trees-killed + 1
            if current-leaf-stock <= 0 [ set current-leaf-stock 1 ]
            if current-fruit-stock <= 0 [ set current-fruit-stock 1 ]
            if current-wood-stock <= 0 [
              die
              set trees-killed trees-killed + [population-size] of self
            ]
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
to update-corporal-conditions [heads UBT total-UF-ingested total-MAD-ingested daily-need-UF daily-need-MAD max-daily-DM-ingestible-head pref-mono]
  ; Calcul de l'UFL/kg MS du fourrage consommé
  ; Nous considérons UF/kg MS ≈ UFL/kg MS pour les bovins
  ; Calcul de l'UFL/kg MS moyen du fourrage consommé
  set weight-gain 0
  let daily-needs-ratio-MAD-UF  daily-need-MAD / daily-need-UF
  let MAD-UF-ratio total-MAD-ingested / total-UF-ingested
  let max-UF-ingestible 0.80 * heads * max-daily-DM-ingestible-head
  let max-MAD-ingestible 52 * heads * max-daily-DM-ingestible-head

  ; Calculer le facteur d'énergie
  let energy-factor ((total-UF-ingested - daily-need-UF) / (max-UF-ingestible - daily-need-UF))
  ; Assurer que le facteur est entre 0 et 0.5
  let energy-factor-total max list 0 (min list energy-factor 0.5)

  ; Calculer le facteur du ratio MAD/UF
  let protein-factor ((total-MAD-ingested - daily-need-MAD) / (max-MAD-ingestible - daily-need-MAD))

  ; Assurer que le facteur est entre 0 et 0.5
  let protein-factor-total max list 0 (min list protein-factor 0.5)
  ; Calculer le gain de poids potentiel (en grammes par jour)
  set weight-gain ((protein-factor-total + energy-factor-total) * 1.4 * UBT) - 0.7 * UBT
  ; Mettre à jour le poids vif à partir du gain de poids par tête de bétail
  set live-weight (live-weight + (weight-gain * head))
  if live-weight > max-live-weight [ set live-weight max-live-weight]

  ; Calculer la NEC à partir du poids vif en considérant que les vaches sont toutes des N'dama. (AMOUGOU MESSI G., 1998. Méthode d’estimation et variation de la composition corporelle des vaches zébu Gobra et Taurin N’Dama en fonction du niveau d’alimentation. Thèse de Doctorat Vétérinaire EISMV, Dakar, Sénégal, 102 p)

  if breed = cattles [
    set corporal-condition (live-weight - (66.785 * head) ) / (47.1 * head)
  ]

  ; régression linéaire à partir des valeurs de https://reca-niger.org/IMG/pdf/FT_embouche_ovine_Cirdes.pdf

  if breed = sheeps [
    set corporal-condition (live-weight - (21.21 * head)) / ( 5.75 * head)
  ]

  ; Assurer que la NEC reste dans des limites raisonnables (par exemple, entre 1 et 5)
  if corporal-condition < 1 [ set corporal-condition 1 ]
  if corporal-condition > 5 [ set corporal-condition 5 ]

end

to trample-trees
  ;; ---- CHANCE DE DÉGRADER DES JEUNES ARBRES  ---- D'abord les arbres nutritifs et fruitiers, ensuite les moins nutritifs
  let all-trees tree-populations-on patch-here
  let chance-unitaire 0.0001
  let chance-troupeau (head * chance-unitaire)         ;; Valeur attendue : ex. 0.3 => 30% de chance de retirer 1 arbre
  let trees-trampled floor chance-troupeau
  let fractional (chance-troupeau - trees-trampled)

  ;; Appliquer ce retrait à la population de jeunes arbres
  let young-good-trees all-trees with [tree-pop-age < 4 and (tree-type = "nutritive" or tree-type = "fruity") and population-size > 0 ]   ;; par ex. définition "jeunes" < 4
  ifelse any? young-good-trees [
    ;; Retirer guaranteed arbres "garantis"
    ask one-of young-good-trees [
      if trees-trampled > 0 [
        set population-size max list 0 (population-size - trees-trampled)
        if population-size > 0 [
          set trees-killed trees-killed + trees-trampled
        ] ; end trees-killed
      ] ; end first supp
        ;; Test probabiliste pour éventuellement en retirer un  supplémentaire
      if random-float 1 < fractional [
        set population-size max list 0 (population-size - 1)
        if population-size > 0 [
          set trees-killed trees-killed + 1
        ]; end trees-killed
       if population-size = 0 [
         die
        ] ; end killing tree-population with population size <= 0
      ] ; end additional supp
    ] ; end ask one-of
  ] [
    let young-trees all-trees with [tree-pop-age < 4 and population-size > 0]
    ifelse any? young-trees [
      ;; Retirer guaranteed arbres "garantis"
      ask one-of young-trees [
        if trees-trampled > 0 [
          set current-fruit-stock current-fruit-stock - (trees-trampled * (max-fruit-stock / population-size))
          set current-leaf-stock current-leaf-stock - (trees-trampled * (max-leaf-stock / population-size))
          set current-wood-stock current-wood-stock - (trees-trampled * (max-wood-stock / population-size))
          set population-size max list 0 (population-size - trees-trampled)
          if population-size > 0 [
            set trees-killed trees-killed + trees-trampled
          ] ; end trees-killed
          if population-size = 0 [
            die
          ] ; end killing tree-population with population size <= 0
        ] ; end first supp
          ;; Test probabiliste pour éventuellement en retirer un  supplémentaire
        if random-float 1 < fractional [
          set current-fruit-stock current-fruit-stock - (max-fruit-stock / population-size)
          set current-leaf-stock current-leaf-stock - (max-leaf-stock / population-size)
          set current-wood-stock current-wood-stock - (max-wood-stock / population-size)
          set population-size max list 0 (population-size - 1)
          if population-size > 0 [
            set trees-killed trees-killed + 1
          ] ; end trees-killed
          if population-size = 0 [
            die
          ] ; end killing tree-population with population size <= 0
        ] ; end additional supp
      ] ; end ask one-of
    ] [
      stop
    ] ; end ifelse young-trees
  ] ; end ifelse young-good-trees

end




to choose-strategy-for-cattles
  ;; Récupérer les conditions corporelles des troupeaux de bovins
  let cattle-cc  [corporal-condition] of cattle-herd

  ;; Si **une des deux** conditions des troupeaux est en dessous du seuil, exécuter `do-first-strategy`
  if cattle-cc <= cattle-high-threshold-cc [
    do-first-strategy
  ]
  ;; Si **les deux** conditions des deux troupea sont en dessous des seuils, quitter le modèle
  if cattle-cc <= cattle-low-threshold-cc [
    ;; Masquer et déplacer le troupeau de bovins
    if [have-left] of cattle-herd = FALSE [
      ask cattle-herd  [
        do-second-strategy
      ]
    ]
  ]
end


to choose-strategy-for-sheeps
  ;; Récupérer les conditions corporelles des troupeaux de moutons
  let sheep-cc [corporal-condition] of sheep-herd

  if sheep-cc <= sheep-high-threshold-cc  [
    do-first-strategy
  ]
  if sheep-cc <= sheep-low-threshold-cc [
    ;; Masquer et déplacer le troupeau de moutons
    if [have-left] of sheep-herd = FALSE [
      ask sheep-herd [
        do-second-strategy
      ]
    ]
  ]
end

to do-first-strategy

  ;; Store the foyer's variables in local variables
  let home-patch current-home-patch
  let my-known-space known-space
  ;; Find patches within 12 units of home-patch and not in known-space
  let close-undiscovered-patches patches with [
    distance home-patch <= 6 and not member? self my-known-space
  ]

  ifelse any? close-undiscovered-patches [
    ;; Se déplacer vers un patch aléatoire parmi ces patches
    move-to one-of close-undiscovered-patches
    ;; Obtenir les patches sur la ligne entre la nouvelle position et le campement
    let line-patches patches-between patch-here home-patch
    ;; Ajouter ces patches au known-space du foyer
    set known-space (patch-set my-known-space line-patches)
    ;; Retourner au campement principal
    move-to original-home-patch
  ] [
    ;    if any? friends [
    ;      call-one-friend
    ;    ]
    ifelse far-exploration-count <= 5 [
      let further-undiscovered-patches patches with [distance home-patch > 6 and not member? self my-known-space]
      if any? further-undiscovered-patches [
        move-to one-of further-undiscovered-patches
        let line-patches patches-between patch-here home-patch
        ;; Ajouter ces patches au known-space du foyer
        set known-space (patch-set my-known-space line-patches)
        ;; Retourner au campement principal
        move-to original-home-patch
        set far-exploration-count far-exploration-count + 1
      ]
    ] [
      stop
    ]
  ]

end

to do-second-strategy
  move-to original-home-patch          ; Déplacer au campement principal
  set have-left true
  set is-in-temporary-camp false
  hide-turtle
end

to call-one-friend


end
;  to color-trees  ;; patch procedure
;  set pcolor scale-color (green - 1) trees 0 (2 * max-grass-height)


to update-known-space
  let home-patch current-home-patch
  if breed = cattles or breed = sheeps [
    set known-space (patch-set known-space ([known-space] of foyer-owner))
  ]
  if breed = foyers [
    if cattle-herd != nobody [
      set known-space (patch-set known-space ([known-space] of cattle-herd))]
    if sheep-herd != nobody [
      set known-space (patch-set known-space ([known-space] of sheep-herd))]
  ]
  ; Pour tous les agents : recalcul du close et du distant-known-space
  set close-known-space known-space with [distance home-patch <= 6]
  set distant-known-space known-space who-are-not close-known-space
  if breed = cattles or breed = sheeps [
    set original-camp-known-space [close-known-space] of foyer-owner
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
  set tree-age-table table:make
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
    ; Ajouter les données à la table `tree-age-table`
    table:put tree-age-table (list trees-type ages) (list max-fruits max-leaves max-woods sensitivities)
  ]
  file-close
end




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Ouverture des fichiers pour les valeurs nutritionnelles selon leur type, le type de sol et la saison ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to load-tree-nutrition-data [filename]
  set tree-nutrition-table table:make
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
    table:put tree-nutrition-table (list trees-type landscapes seasons) (list tree-UF-data tree-MAD-data)
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
  ; On vérifie si la clé existe dans la table
  ifelse table:has-key? tree-age-table (list trees-type ages) [
    report table:get tree-age-table (list trees-type ages)
  ] [
    ; Si aucune donnée trouvée, retourner des valeurs par défaut
    report (list 0 0 0 0)
  ]
end




to-report get-tree-nutritional-values [trees-type soil season]
  ; Parcourir la structure `tree-nutritional-values` pour trouver les valeurs correspondantes
  ifelse table:has-key? tree-nutrition-table (list trees-type soil season) [
    report table:get tree-nutrition-table (list trees-type soil season)
  ] [
    report (list 0 0) ; Valeurs par défaut si introuvable
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

  ifelse max-wood-stock <= 0 [
    report 1  ; Éviter la division par zéro
  ] [
    report current-wood-stock / max-wood-stock
  ]
end

to-report calculate-tree-icon-size [populations]
  ;; Définir les valeurs minimales et maximales pour le mapping
  let minPopulation 0
  let maxPopulation 8000  ;; Ajustez cette valeur en fonction de vos données réelles
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
    if year-type = "moyenne" [set rate 0.05]
    if year-type = "mauvaise" [set rate 0.01]
  ]
  if tree-type = "lessNutritive" [
    if year-type = "bonne" [set rate 0.15]
    if year-type = "moyenne" [set rate 0.08]
    if year-type = "mauvaise" [set rate 0.01]
  ]
  if tree-type = "fruity" [
    if year-type = "bonne" [set rate 0.25]
    if year-type = "moyenne" [set rate 0.15]
    if year-type = "mauvaise" [set rate 0.01]
  ]
  report rate
end




; Fonction pour calculer la croissance logistique des fruits
to-report growth-fruit-logistic [input-tree-type current-fruit max-fruit season landscape]
  let r 0
  ifelse  max-fruit <= 0.0001 [
    report 0  ; Pas de croissance si max-wood est zéro
  ] [
    if input-tree-type = "nutritive" [
      if landscape = "Baldiol" [
        if season = "Nduungu" [set r 0.05]
        if season = "Ceedu" [set r -0.03]
        if season = "Dabbuunde" [set r 0.01]
        if season = "Ceetcelde" [set r -0.01]
      ]
      if landscape = "Caangol" [
        if season = "Nduungu" [set r 0.05]
        if season = "Ceedu" [set r -0.03]
        if season = "Dabbuunde" [set r 0.01]
        if season = "Ceetcelde" [set r 0.005]
      ]
      if landscape = "Seeno" [
        if season = "Nduungu" [set r 0.1]
        if season = "Ceedu" [set r -0.3]
        if season = "Dabbuunde" [set r 0.02]
        if season = "Ceetcelde" [set r -0.005]
      ]
      if landscape = "Sangre" [
        if season = "Nduungu" [set r 0.05]
        if season = "Ceedu" [set r -0.03]
        if season = "Dabbuunde" [set r -0.01]
        if season = "Ceetcelde" [set r 0.005]
      ]
    ]
    if input-tree-type = "lessNutritive" [
      if landscape = "Baldiol" [
        if season = "Nduungu" [set r 0.05]
        if season = "Ceedu" [set r -0.03]
        if season = "Dabbuunde" [set r 0.01]
        if season = "Ceetcelde" [set r 0.005]
      ]
      if landscape = "Caangol" [
        if season = "Nduungu" [set r 0.05]
        if season = "Ceedu" [set r -0.03]
        if season = "Dabbuunde" [set r 0.01]
        if season = "Ceetcelde" [set r 0.005]
      ]
      if landscape = "Seeno" [
        if season = "Nduungu" [set r 0.05]
        if season = "Ceedu" [set r -0.03]
        if season = "Dabbuunde" [set r 0.01]
        if season = "Ceetcelde" [set r 0.005]
      ]
      if landscape = "Sangre" [
        if season = "Nduungu" [set r 0.05]
        if season = "Ceedu" [set r -0.03]
        if season = "Dabbuunde" [set r 0.01]
        if season = "Ceetcelde" [set r 0.005]
      ]
    ]
    if input-tree-type = "fruity" [
      if landscape = "Baldiol" [
        if season = "Nduungu" [set r 0.05]
        if season = "Ceedu" [set r -0.03]
        if season = "Dabbuunde" [set r 0.01]
        if season = "Ceetcelde" [set r 0.005]
      ]
      if landscape = "Caangol" [
        if season = "Nduungu" [set r 0.05]
        if season = "Ceedu" [set r -0.05]
        if season = "Dabbuunde" [set r 0.03]
        if season = "Ceetcelde" [set r -0.05]
      ]
      if landscape = "Seeno" [
        if season = "Nduungu" [set r 0.05]
        if season = "Ceedu" [set r -0.03]
        if season = "Dabbuunde" [set r 0.01]
        if season = "Ceetcelde" [set r 0.005]
      ]
      if landscape = "Sangre" [
        if season = "Nduungu" [set r 0.05]
        if season = "Ceedu" [set r -0.03]
        if season = "Dabbuunde" [set r 0.01]
        if season = "Ceetcelde" [set r 0.005]
      ]
    ]

    let growth r * (precision current-fruit 3) * (precision ((max-fruit - current-fruit) / max-fruit) 3)
  if abs(growth) > 1e10 [
    report 0
  ]
    report growth
  ]
end

;Fonction pour calculer la croissance logistique des feuilles
to-report growth-leaf-logistic [input-tree-type current-leaf max-leaf season landscape]
  let r 0
  ifelse  max-leaf <= 0.0001 [
    report 0  ; Pas de croissance si max-wood est zéro
  ] [
    if input-tree-type = "nutritive" [
      if landscape = "Baldiol" [
        if season = "Nduungu" [set r 0.05]
        if season = "Ceedu" [set r -0.03]
        if season = "Dabbuunde" [set r 0.01]
        if season = "Ceetcelde" [set r 0.005]
      ]
      if landscape = "Caangol" [
        if season = "Nduungu" [set r 0.05]
        if season = "Ceedu" [set r -0.03]
        if season = "Dabbuunde" [set r 0.01]
        if season = "Ceetcelde" [set r 0.005]
      ]
      if landscape = "Seeno" [
        if season = "Nduungu" [set r 0.05]
        if season = "Ceedu" [set r -0.03]
        if season = "Dabbuunde" [set r 0.01]
        if season = "Ceetcelde" [set r 0.005]
      ]
      if landscape = "Sangre" [
        if season = "Nduungu" [set r 0.05]
        if season = "Ceedu" [set r -0.03]
        if season = "Dabbuunde" [set r 0.01]
        if season = "Ceetcelde" [set r 0.005]
      ]
    ]
    if input-tree-type = "lessNutritive" [
      if landscape = "Baldiol" [
        if season = "Nduungu" [set r 0.05]
        if season = "Ceedu" [set r -0.03]
        if season = "Dabbuunde" [set r 0.01]
        if season = "Ceetcelde" [set r 0.005]
      ]
      if landscape = "Caangol" [
        if season = "Nduungu" [set r 0.05]
        if season = "Ceedu" [set r -0.03]
        if season = "Dabbuunde" [set r 0.01]
        if season = "Ceetcelde" [set r 0.005]
      ]
      if landscape = "Seeno" [
        if season = "Nduungu" [set r 0.05]
        if season = "Ceedu" [set r -0.03]
        if season = "Dabbuunde" [set r 0.01]
        if season = "Ceetcelde" [set r 0.005]
      ]
      if landscape = "Sangre" [
        if season = "Nduungu" [set r 0.005]
        if season = "Ceedu" [set r -0.03]
        if season = "Dabbuunde" [set r -0.01]
        if season = "Ceetcelde" [set r 0.05]
      ]
    ]
    if input-tree-type = "fruity" [
      if landscape = "Baldiol" [
        if season = "Nduungu" [set r 0.05]
        if season = "Ceedu" [set r -0.03]
        if season = "Dabbuunde" [set r 0.01]
        if season = "Ceetcelde" [set r 0.005]
      ]
      if landscape = "Caangol" [
        if season = "Nduungu" [set r 0.05]
        if season = "Ceedu" [set r -0.03]
        if season = "Dabbuunde" [set r 0.01]
        if season = "Ceetcelde" [set r 0.005]
      ]
      if landscape = "Seeno" [
        if season = "Nduungu" [set r 0.05]
        if season = "Ceedu" [set r -0.03]
        if season = "Dabbuunde" [set r 0.01]
        if season = "Ceetcelde" [set r 0.005]
      ]
      if landscape = "Sangre" [
        if season = "Nduungu" [set r 0.05]
        if season = "Ceedu" [set r -0.03]
        if season = "Dabbuunde" [set r 0.01]
        if season = "Ceetcelde" [set r 0.005]
      ]
    ]
    let growth r * (precision current-leaf 3) * (precision ((max-leaf - current-leaf) / max-leaf) 3)
    if abs(growth) > 1e10 [
      report 0
    ]
    report growth
  ]

end

;Fonction pour calculer la croissance logistique du bois
to-report growth-wood-logistic [input-tree-type current-wood max-wood season]
  let r 0
  ifelse  max-wood = 0 [
    report 0  ; Pas de croissance si max-wood est zéro
  ] [
    if input-tree-type = "nutritive" [
      if season = "Nduungu" [set r 0.001]
      if season = "Ceedu" [set r 0.003]
      if season = "Dabbuunde" [set r 0.00001]
      if season = "Ceetcelde" [set r 0.00001]
    ]
    if input-tree-type = "lessNutritive" [
      if season = "Nduungu" [set r 0.004]
      if season = "Ceedu" [set r 0.002]
      if season = "Dabbuunde" [set r 0.00001]
      if season = "Ceetcelde" [set r 0.00001]
    ]
    if input-tree-type = "fruity" [
      if season = "Nduungu" [set r 0.006]
      if season = "Ceedu" [set r 0.004]
      if season = "Dabbuunde" [set r 000002]
      if season = "Ceetcelde" [set r 0.00001]
    ]

    let growth r * (precision current-wood 3) * (precision ((max-wood - current-wood) / max-wood) 3)
    if abs(growth) > 1e10 [
      report 0
    ]
    report growth
  ]
end



; Trouver le meilleur patch : d'abord la qualité, ensuite la quantité, enfin la proximité
to-report find-best-nearest-patch [known-spaces my-shepherd heads max-daily-DM-ingestible-heads seasons]
  let viable-patches known-spaces with [current-grass >= 40]
  let max-daily-ingestible (heads * max-daily-DM-ingestible-heads)
  if seasons = "Nduungu" [ set viable-patches viable-patches with [soil-type != "Caangol" and current-monocot-grass >= (0.5 * max-daily-ingestible)]]
  ifelse any? viable-patches [
    ifelse my-shepherd = "bon" [
      ; Étape 1 : Sélectionner les patches avec la meilleure qualité d'herbe
      ; Étape 2 : Parmi les patches avec la meilleure qualité, sélectionner ceux avec la plus grande quantité d'herbe
      let max-grass-patches viable-patches with [(current-grass >= max-daily-ingestible) = true]

      let best-quality-patches max-grass-patches with-max [q]

      ; Étape 3 : Choisir le patch le plus proche parmi ceux avec la meilleure qualité et la plus grande quantité d'herbe
      report min-one-of best-quality-patches [distance myself]
    ] [

      ; Étape 2 : Parmi les patches avec la meilleure qualité, sélectionner ceux avec la plus grande quantité d'herbe
      let max-grass-patches viable-patches with-max [current-grass]

      ; Étape 3 : Choisir le patch le plus proche parmi ceux avec la meilleure qualité et la plus grande quantité d'herbe
      report min-one-of max-grass-patches [distance myself]
    ]
  ] [

    ; Étape 2 : Parmi les patches avec la meilleure qualité, sélectionner ceux avec la plus grande quantité d'herbe
    let max-grass-patches viable-patches with-max [current-grass]

    ; Étape 3 : Choisir le patch le plus proche parmi ceux avec la meilleure qualité et la plus grande quantité d'herbe
    report min-one-of max-grass-patches [distance myself]
    ; Si aucun patch viable n'est trouvé
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
