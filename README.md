# ODD du modèle DunDiModel V1

La gestion collective des ressources dans les systèmes pastoraux, met en évidence les défis liés à la reconnaissance des communs pastoraux dans un contexte de crises multidimensionnelles en Afrique de l'Ouest . Les recherches récentes ont exploré les approches par les communs pour valoriser le pastoralisme dans les politiques publiques, analysant les enjeux de reconnaissance, d'institutionnalisation et de valorisation économique des activités pastorales (Aubert et Dutilly, 2024). Ces travaux fournissent un cadre théorique pertinent pour le développement et l'application de **DundiModel**. 

Le modèle **DundiModel** est conçu pour simuler et analyser les dynamiques du pastoralisme dans les systèmes de gestion des communs, en particulier dans les environnements semi-arides. Il vise à étudier les interactions entre les pratiques pastorales, la gestion des ressources naturelles (telles que les pâturages et les forêts), et les variables climatiques saisonnières. En intégrant des éléments tels que les campements, les foyers, les troupeaux de bétail et les populations d'arbres, le modèle permet d'explorer comment les décisions de gestion collective influencent la durabilité des ressources et la résilience des communautés pastorales.

Ce modèle s'appuie sur des concepts clés du pastoralisme et de la gestion des communs, tels que la mobilité des troupeaux, l'accès partagé aux ressources, et les mécanismes de gouvernance locale. Il offre un outil pour tester divers scénarios de gestion et évaluer leurs impacts sur la productivité des pâturages, la santé des troupeaux, et la conservation des écosystèmes.

## 1. OVERVIEW

### 1.a. Purpose and patterns

Le but global du modèle reste d’étudier les dynamiques pastorales dans un contexte sahélien, en explorant comment l’environnement (végétation, disponibilité en eau, etc.) et les pratiques des éleveurs interagissent pour analyser :

- **Dans quelle mesure** la taille des éleveurs (petit, moyen, grand), la taille global de la population et la proportion de bergers « bons » ou « mauvais » influent sur la capacité du système à maintenir un **état corporel des troupeaux** (NEC) et une densité d'arbres adultes par unité de surface satisfaisants (MST-NEC, MST-Tree-by-soil-type) sur le long terme.
- **Comment** les stratégies de mobilité (en particulier la possibilité de créer des campements temporaires à plus de 6 km) modulent la pression de pâturage et la répartition des troupeaux.
- **La sensibilité** du système à la vitesse de croissance/décroissance de l’herbe (nouveau paramètre `decreasing-factor`).


En termes de **patterns** visés, on s’intéresse notamment à :

- La **distribution spatio-temporelle** des troupeaux et d’éventuelles zones localement surexploitées,
- La **MST-NEC** : maintien ou non d’un niveau acceptable d’état corporel pour les troupeaux,
- la **MST-Tree-by-soil-type** : maintien d'une densité d'arbre ou régénération de population jusqu'à atteindre un niveau acceptable pour les forestiers
- L’effet de la composition du cheptel (en termes de tailles d’élevage), de la taille totale du cheptel dans la zone et de la proportion de bergers bons/mauvais sur l’évolution de ces patterns.

### 2. Entities, state variables, and scales


- **Patches** :
	- **soil-type** (Baldiol, Caangol, Sangre, Seeno, etc.) : détermine la capacité de production (`K`), la sensibilité (`patch-sensitivity`).
	- **current-grass** : stock total d’herbe, **désormais décomposé** en `current-monocot-grass` et `current-dicot-grass`.
	- **monocot-UF-per-kg-MS**, **monocot-MAD-per-kg-MS**, **dicot-UF-per-kg-MS**, **dicot-MAD-per-kg-MS** : valeurs nutritives de chaque espèce (mises à jour chaque saison).
	- **p** : proportion de monocotylédones (générée à l’initialisation).
	- **grass-quality** : label (“good”, “average” ou “poor”).
	- **K** : capacité maximum en herbe.
    - **Nouveauté** : la **qualité** de l’herbe (`grass-quality`) dépend d’un calcul combinant la proportion monocot/dicot et de leurs UF/MAD respectives) et non plus d'un tirage aléatoire.

- **Tortues** (Agents) : 
	- **Foyers** (households) :
	    - Variables clés : `
		    - **Nouveau** shepherd-type` (bon ou mauvais), 
		    - `herder-type` (grand, moyen ou petit),
		    - `cattle-herd` et `sheep-herd` (références aux troupeaux associées), etc.
	    - **Nouveauté** : Les foyers fixent certains seuils d’alerte (NEC minimale) `cattle/sheep-low-threshold-cc` `cattle/sheep-high-threshold-cc` et décident de la stratégie globale de mobilité (ex. “explorer plus loin”, “rester” ou "quitter la zone").
	    - **Nouveauté** : le foyer gère aussi un “compteur d’exploration” (`far-exploration-count`, `close-exploration-count`) pour définir combien de tentatives d’exploration à distance il s’autorise.

	- **Troupeaux** (bovins et ovins) :
	    - Variables physiologiques (nombre de têtes, NEC, poids vif, taille en UBT, nutriments ingérés, matière sèche ingérée),
	    - Variables de position spatiale : `current-home-patch`, `temporary-home-camp`, **et** un ensemble de champs relatifs à la **connaissance de l’espace** (`known-space`, `close-known-space`, `distant-known-space`).
	    - **Nouveauté** : prise en compte de **deux espèces d’herbes** et donc de deux types de valeurs UF/MAD ingérées à chaque repas :`daily-needs-UF/MAD`(besoins nutritionnels quotidiens), `max-daily-DM-ingestible-per-head`(quantité maximum ingérable en une journée), `preference-mono` (saisonnier)..

	- **Campements** (permanents ou temporaires) :
	    - Ils ont une capacité `available-space`, un besoin en bois (pas développé ici) et un booléen `is-temporary` qui indique si le campement est temporaire (Campement de transhumance).
	    - Les troupeaux reviennent dans leur campement d’origine (permanent) en début de nouvelle année (ou quand le meilleur patch est situé dans la zone du campement principal).

	- **Tree-populations** :
	    - **tree-type** : « nutritive », « less-nutritive » ou « fruity ».
	    - **tree-pop-age** : âge (1 à 8).
	    - **population-size** : effectif d’arbres dans cette cohorte.
	    - **current-fruit-stock**, **current-leaf-stock**, **current-wood-stock** : stocks de ressources actualisés.
	    - **max-fruit-stock**, **max-leaf-stock**, **max-wood-stock** : capacités maximales pour cette cohorte d’arbres.
	    - **tree-UF-per-kg-MS** & **tree-MAD-per-kg-MS** valeurs nutritionnelles pour les feuilles et fruits des arbres, dépendant du type d'arbre 
	    - **tree-sensitivity** : sensibilité à la dégradation (selon type/âge) - Non mobilisé dans l'immédiat. 

**Échelles spatiales et temporelles** : 

- Un patch représente 1 km² ; la grille fait environ 23×23 km (coordonnées -11 à 11).
- Le pas de temps est le “jour” (tick) ; chaque saison (Nduungu, Dabbuunde, Ceedu, Ceetcelde) dure un certain nombre de jours dépendant du type d’année (bonne, moyenne, mauvaise).

### 3. Process overview and scheduling

**À chaque tick** (un jour), le modèle exécute :

1. **Mise à jour de la saison** (procédure `update-season`) :
    - Incrémente un compteur de saison, et passe à la saison suivante lorsque la durée prévue est atteinte.
    - Au changement de saison, **on met à jour les valeurs** UF et MAD pour la monocot et la dicot (`update-UF-and-MAD`), car elles dépendent de la phénologie saisonnière.
    - **update-grass-quality** : attribue un label “good”/“average”/“poor” en fonction des valeurs moyennes (UF, MAD)
2. **Mise à jour annuelle** - Si on termine une année (`year-counter >= total-ticks-per-year`) :
	- on remet `year-counter` à 0,
	- **update-year-type** : lit la liste `year-types`, passe à l’année suivante (bonne, moyenne, mauvaise),
	- **set-season-durations** : redéfinit nduungu-duration, dabbuunde-duration, etc.
	- **call-back-herds** : (retour des troupeaux s’ils étaient partis loin),
	- **update-tree-age**, **renew-tree-population** (pour la composante arborée).
1. **Croissance de l’herbe** (procédure `grow-grass`) :
    - **Nouveau** : la **biomasse** est scindée en `current-monocot-grass` et `current-dicot-grass`, chacune soumise à une **croissance logistique** (ou décroissance) modulée par la saison et multipliée par le **paramètre** `decreasing-factor`.
    - La somme `current-grass` = `current-monocot-grass + current-dicot-grass`.
1. **Mise à jour de la qualité de l’herbe** (`update-grass-quality`) :
    - **Nouveau** : on calcule un ratio UF et MAD moyen (pondéré par la proportion monocot/dicot), ce qui nous donne un label “good” / “average” / “poor” pour le patch.
1. **Comportements des troupeaux** :
    - a) **Remise à zéro** du cumul de la consommation quotidienne (`DM-ingested`, `UF-ingested`, etc.)
    - b) **Déplacements** (procédure `move`) :
        - Le troupeau consulte son **`known-space`** (patches qu’il “connaît”).
        - Il cherche un “meilleur patch” (selon la qualité vs quantité d’herbe, dépendant du type de berger) et se déplace vers celui-ci.
        - **S’il est trop loin** (> 6 km), **il peut créer un campement temporaire** (changement de `current-home-patch`).
    - c) **Consommation** (procédure `eat`) :
        - Le troupeau calcule ses besoins en UF/MAD journaliers.
        - **Nouveau** : la consommation est répartie entre la monocot et la dicot selon une **préférence** (ex. plus de monocotylédones en saison des pluies, etc.).
        - Ajustement de la **NEC** en fonction de l’UF/MAD réellement ingérées.
        - S'il a encore faim et qu'il peut encore consommer de la matière sèche, il va consommer les ressources ligneuses (consume-tree-resources). L'impact de cette consommation sur les arbres dépend du type de berger (`shepherd-type`)
        - Il va dégrader les jeunes arbres par le piétinement.  L'impact du piétinement sur les arbres dépend du type de berger (`shepherd-type`)
1. **Stratégies pastorales gérées par les foyers** :
    - **Nouveau** : Les foyers lancent la procédure `choose-strategy-for-cattles` (et/ou `choose-strategy-for-sheeps`) pour voir si l’état corporel de leurs troupeaux est acceptable.
    - Si la NEC est trop basse (comparée aux seuils du foyer), le foyer peut décider de “forcer” un mouvement d’exploration (procédure `do-first-strategy`) ou même “faire partir” le troupeau (procédure `do-second-strategy`), simulant une transhumance prolongée (troupeau qui quitte la zone).
    - Chaque foyer **met à jour** son **espace connu** (`known-space`) en y ajoutant des patches explorés, et compte le nombre d’explorations lointaines (`far-exploration-count`).
2. **Collecte d’indicateurs** et **visualisation** :
    - Calcul de MST-NEC, MST-Tree-By-Soil-Type (pas détaillé ici), etc.
    - Tracé de courbes, mise à jour des couleurs des patches selon la quantité/qualité de l’herbe.

L’ordre d’exécution dans la boucle `go` est donc : (i) temps/saison, (ii) croissance de l’herbe, (iii) comportements des troupeaux (déplacement+consommation), (iv) stratégies depuis le foyer (seuils d’alerte, etc.), (v) stats & visualisation.

---

## B. DESIGN CONCEPTS

### Basic principles

On conserve la base : la dynamique pastorale au Sahel, combinant variabilité saisonnière, gestion de la mobilité par les éleveurs, consommation de fourrage par les troupeaux, etc. **La nouveauté** est d’introduire des **valeurs nutritionnelles distinctes** (UF/MAD) pour les deux grands types d’herbe (monocot vs dicot), et d’ajouter une différenciation fine entre bergers “bons”/“mauvais”.

### Emergence

Le modèle permet d’observer :

- L’émergence d’éventuelles **zones surexploitées** en fin de saison sèche,
- Des évolutions différentes de l’état corporel et de la distribution spatiale selon la **proportion** de “mauvais” bergers (qui consomment potentiellement plus vite la ressource),
- La **capacité** du système à conserver un niveau de NEC (MST-NEC) sur plusieurs années, ou au contraire à s’effondrer si la ressource n’est plus suffisante.
- La **capacité** du système à rétablir une densité acceptable d'arbres adultes sur plusieurs années (MST-Tree-by-soil-type), ou au contraire à dégrader le système écologique si les prélèvements sont trop importants ou les pratiques mal adaptées.

### Adaptation et objectifs

- Les troupeaux **cherchent** un patch plus favorable pour se nourrir au quotidien (en fonction de la saison, de la qualité, etc.).
- Les foyers, via `choose-strategy-for-cattles/sheeps`, adaptent une **stratégie globale** : “explorer localement” vs “explorer plus loin” vs “laisser partir le troupeau”, etc.
- Les bergers bons tentent de préserver un certain équilibre ; les bergers mauvais ont une stratégie plus extractive.

### Learning et prediction

Pas d’apprentissage évolutif, mais un stockage simple des patches visités (mise à jour de `known-space`). Les décisions se font sur la base d’une **information historique** (patch connu ou non) et d’indicateurs (NEC, distance).

### Sensing

- Les troupeaux perçoivent la disponibilité en herbe (monocot/dicot) et peuvent estimer leur ratio UF/MAD localement.
- Les foyers gardent en mémoire la “carte” des patches déjà explorés (i.e. `known-space`).

### Interaction

L’interaction est majoritairement indirecte, 
- via la compétition pour la ressource. Les troupeaux peuvent se retrouver sur les mêmes patches, ce qui accélère la déplétion de l’herbe.
- via la dégradation des jeunes arbres par le piétinement des troupeaux


### Stochasticity

- Répartition initiale de la monocot/dicot.
- Ordre aléatoire d’exécution des troupeaux.
- Choix entre patches équivalents.
- Attribution aléatoire du type de berger (selon `good-shepherd-percentage`).
- Tirages initiaux de la proportion `p` (monocot/dicot) dans chaque patch, etc.

### Collectives

Le collectif se manifeste dans les campements, qui regroupent foyers et troupeaux. La formation de campements temporaires peut créer des regroupements spatiaux saisonniers.

### Observation

Les **indicateurs** collectés incluent entre autres :

- **MST-NEC** : indicateur sur la durée de satisfaction de la note d’état corporel.
- **MST-Tree-By-Soil-Type** : indicateur sur la durée de satisfaction de proportion d'arbre par unité de surface par rappot à l'objectif fixé
- **Taux de “partance”** (combien de troupeaux quittent la zone),
- **Structures** d’occupation spatiale (cartographie des known-spaces).

---

## C. DETAILS

### 1. Initialization

La procédure `setup` :

1. **clear-all** + dimensions du monde (`resize-world -11 11 -11 11`).
2. **load-environment** (`environment_vel.txt`) : affecte `soil-type`, `tree-cover`, etc.
3. **load-climate-variables** (`year-type.txt`) : construit la liste `year-types`.
4. **setup-landscape** : pour chaque patch, initialise `K`, `patch-sensitivity`, **p** (proportion monocot), `current-monocot-grass`, `current-dicot-grass`.
5. **setup-water-patches** : sélectionne éventuellement certains patches comme points d’eau (optionnel).
6. **setup-camps** : crée un nombre donné de campements (paramètre `initial-number-of-camps`).
7. **setup-foyers** : pour chaque campement, crée des foyers. On y attribue un type d’éleveur (petit, moyen, grand) selon `pB, pM`, et un type de berger (bon/mauvais) selon `good-shepherd-percentage`.
8. **setup-herds** : chaque foyer reçoit un troupeau de bovins (`cattles`) et un de petits ruminants (`sheeps`), initialisés en poids vif, NEC, etc.
9. **setup-trees** : (on le garde pour la partie arborée), on répartit les populations d’arbres selon un CSV.
10. **update-UF-and-MAD**, **update-grass-quality** : première mise à jour,
11. `reset-ticks` + lancement d’affichage.

### 2. Input data

- **`environment_vel.txt`** : répartition spatiale des sols, couverture initiale d’herbe, etc.
- **`year-type.txt`** : séquence des types d’années (bonne/moyenne/mauvaise).
-  **`tree_info.csv`** : valeurs des stocks maximaux des ressources ligneuses, par type d'arbre et age
- **`tree_nutrition.csv`** : valeurs nutritionnelles pour les ressources ligneuses par type d'arbre

### 3. Submodels

Ici, on met en avant en détail **les procédures et sous-modèles ajoutés ou modifiés** :

1. **`grow-grass`**
    - **Nouveau** : on applique la formule de croissance logistique séparément pour `current-monocot-grass` et `current-dicot-grass`.
    - Les taux diffèrent selon la saison (croissance positive en saison des pluies, négative en saison sèche).
    - **Le paramètre `decreasing-factor`** intervient pour accélérer ou freiner cette croissance/décroissance.
2. **update-UF-and-MAD**
    - À chaque changement de saison, on affecte aux patches des valeurs (ex. en Nduungu : monocot-UF=0.5, monocot-MAD=60 ; dicot-UF=0.6, dicot-MAD=100, etc.).
    - Stockées dans `monocot-UF-per-kg-MS`, `monocot-MAD-per-kg-MS`, etc.
3. **`update-grass-quality`**
    - **Nouveau** : on calcule un ratio moyen d’UF et de MAD (pondéré par la biomasse monocot/dicot).
    - En fonction de ces valeurs et des seuils (`seuil-bon-UF`, `seuil-moyen-UF`, `seuil-bon-MAD`, etc.), on attribue une étiquette “good”, “average” ou “poor” au patch.
    - Cette étiquette sert ensuite dans la procédure de **choix du meilleur patch** (ex. un berger “bon” privilégie la “bonne qualité” ; un “mauvais” priorise la quantité).
4. **move**
	- Le troupeau identifie le “meilleur patch” dans `known-space` (critères différents si berger bon vs mauvais).
	- Se déplace (si distance > 6, alors crée un campement temporaire si le patch est au delà du campement principal et actualise `is-in-temporary-camp = true`).
5. **`eat`** et **`consume-grass`**
    - **Nouveau** : un troupeau calcule la quantité de DM à ingérer, puis répartit la consommation entre monocot et dicot selon une “préférence” (plus de monocot en Nduungu, etc.).
    - On soustrait la biomasse correspondante sur le patch (`current-monocot-grass`, `current-dicot-grass`).
    - On met à jour les ingérés en UF/MAD (`UF-ingested`, `MAD-ingested`), ce qui sert ensuite au calcul de la NEC.
6. **`update-corporal-conditions`** (NEC)
    - On convertit l’ingestion en gain ou perte de poids, puis on recalcule la NEC (avec des fonctions plus précises qu’avant : prise en compte du ratio MAD/UF).
    - **Nouveau** : la NEC est plafonnée entre 1 et 5, mais l’animal peut sortir du système si elle descend trop (via les stratégies d’abandon).
7. **`trample-trees`**
	-  Un troupeau a des chances de dégrader les jeunes arbres par le piétinement, dont la chance de dégrader une population est corrélé à la taille du troupeau
8. **choose-strategy-for-cattles/sheeps**
	- Le foyer compare la NEC du troupeau à ses seuils (ex. `cattle-low-threshold-cc`).
	- Si en dessous du premier seuil, exécute `do-first-strategy` (exploration plus poussée) ou `do-second-strategy` si le troupeau est en dessous du second seuil (marqué `have-left = true`).
9. **`known-space`** (mise à jour via `update-known-space`)
    - **Très important et nouveau** : chaque foyer et chaque troupeau maintient un ensemble de patches qu’il connaît (exploration).
    - Quand un troupeau **se déplace** ou lorsqu’un foyer déclenche une stratégie d’exploration, les patches traversés sont ajoutés à `known-space`.
    - On distingue `close-known-space` (moins de 6 km) et `distant-known-space` (plus de 6 km), influençant la décision de “créer un campement temporaire” ou non.

**Responsabilité foyer vs troupeau** :
    - Le **troupeau** a une routine quotidienne : “je me déplace vers un patch jugé favorable, je consomme l’herbe, je mets à jour ma NEC”.
    - Le **foyer**, de son côté, **monitore** l’état du troupeau (via `choose-strategy-for-cattles/sheeps`) :
        - S’il estime que la NEC est en-deçà d’un certain seuil (`cattle-low-threshold-cc` par ex.), il **peut décider** :
            - **`do-first-strategy`** = “forcer une exploration” : le troupeau part en reconnaissance d’un patch inconnu (ou peu connu) pour chercher de l’herbe plus abondante.
            - **`do-second-strategy`** = “envoyer le troupeau en transhumance lointaine” (dans le modèle : le troupeau quitte la zone, `have-left = true`).
        - Le foyer cumule ainsi un nombre d’explorations lointaines (`far-exploration-count`). Au-delà d’un certain seuil, il se peut qu’il n’ose plus s’éloigner.

**`move`** (dans le troupeau)
    - Le troupeau regarde son `known-space`, trouve un patch “optimal” (selon la “qualité” si berger bon, ou la “quantité” si berger mauvais), puis se déplace.
    - **S’il est à plus de 6 km du campement**, il **devient** (ou rejoint) un “campement temporaire” (changement de `current-home-patch`).
    - **Nouveau** : cette distinction permet d’avoir des troupeaux qui se positionnent plus loin (en “transhumance de proximité”), mais pas encore totalement “sortis” du modèle.

---

### Récapitulatif des **nouveautés** (par rapport à la version #2)

- **Scission de l’herbe** en deux espèces (monocot/dicot) et calcul UF/MAD distinct.
- **Paramètre `decreasing-factor`** pour tester la sensibilité de la dynamique de croissance/décroissance de l’herbe.
- **Gestion de la connaissance de l’espace** : `known-space`, `close-known-space`, `distant-known-space`, modulant la décision d’installer un campement temporaire.
- **Répartition des responsabilités** :
    - Les **troupeaux** gèrent le déplacement “quotidien” et la consommation,
    - Les **foyers** gèrent la stratégie plus globale (explorer plus loin, renvoyer le troupeau, etc.).
- **Indicateurs** : MST-NEC pour évaluer la soutenabilité pastorale selon la taille d’élevage et la proportion de bergers bons/mauvais.
- **Prise en compte** d’un “type de berger” : “bon” privilégie la qualité (ratio UF/MAD plus élevé), “mauvais” privilégie la quantité (risque surexploitation).

Tous ces changements renforcent la représentation des **stratégies pastorales** et la complexité de la ressource herbacée, permettant d’analyser plus précisément l’effet de la variabilité intra- et inter-annuelle, et la diversité des comportements d’éleveurs sur la résilience ou la dégradation du système.

---

# Références 

- Aubert S., Dutilly C. 2024. Une approche par les communs pour faire valoir le pastoralisme dans les politiques publiques. Nat. Sci. Soc.,https://doi.org/10.1051/nss/2023045
- CTFD, 2023, Préserver le pastoralisme Les défis de la reconnaissance des communs pastoraux dans un contexte de crise multidimensionnelle en Afrique de l’Ouest, Les notes de Synthèse, Foncier et développement, https://www.foncier-developpement.fr/wp-content/uploads/Note-de-synthese_Numero35_Pastoralisme.pdf

