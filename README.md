Voici une proposition de protocole ODD (en français) décrivant la version courante du code que vous avez fourni. Les principales évolutions par rapport à la version précédente (par exemple l’introduction explicite des points d’eau, la gestion des différentes saisons, le renouvellement des arbres, la prise en compte de l’année « bonne », « moyenne », « mauvaise » depuis un fichier, etc.) sont mises en avant au fil des rubriques.

---

## 1. **Overview**

### 1.a. **Purpose**

L’objectif du modèle est d’explorer la dynamique couplée entre :
1. Les ressources herbagères (herbe) et arborées (arbres) sur un territoire subdivisé en patches aux caractéristiques de sol différentes.  
2. Les troupeaux de différents types (bovins et ovins) appartenant à des foyers (associés à des campements).  
3. Les effets saisonniers (Nduungu, Dabbuunde, Ceedu, Ceetcelde) et la variabilité inter-annuelle du climat (années « bonnes », « moyennes » ou « mauvaises »).

La question centrale est de comprendre comment les stratégies simples de déplacement/pâturage et la variabilité climatique influencent la régénération (ou la dégradation) des pâturages et des arbres. On s’intéresse plus particulièrement à :  
- L’évolution spatio-temporelle de la ressource en herbe (avec différentes qualités saisonnières).  
- La dynamique de la population d’arbres (croissance, vieillissement, renouvellement).  
- Le bien-être (condition corporelle) des animaux, dépendant de la quantité d’herbe consommée, et la manière dont les points d’eau influencent la répartition spatiale du bétail (introduit dans cette version).

Les **motifs** (patterns) que l’on cherche à observer ou valider incluent :  
- La répartition saisonnière des troupeaux et la pression de pâturage sur les patches.  
- La dynamique de la biomasse herbagère à travers les saisons et au fil des années.  
- L’évolution des stocks de fruits, feuilles et bois dans les populations d’arbres, en lien avec la variabilité climatique.  
- L’influence des points d’eau sur la localisation des campements et des troupeaux.

### 1.b. **Entities, state variables, and scales**

**Entités et variables :**

1. **Patches** (cellules du paysage)  
   - **soil-type** : type de sol (Baldiol, Caangol, Sangre, Seeno ou vide), déterminant la capacité de production (K) et la sensibilité à la dégradation.  
   - **current-grass** : biomasse actuelle d’herbe.  
   - **K** : capacité maximale de biomasse herbagère (en MS).  
   - **grass-quality** : qualité de l’herbe en cours (saisonnière : « good », « average », « poor »).  
   - **degradation-level** (pas encore directement exploité, mais la variable `patch-sensitivity` est définie).  
   - **tree-cover** : densité d’arbres initiale (nombre d’arbres sur le patch).  
   - **max-tree-cover** : capacité maximale en arbres (valeur “potentielle”).  
   - **num-nutritious**, **num-less-nutritious**, **num-fruity** : décompte (initial) par type d’arbres potentiels.  
   - **has-pond**, **water-stock** : présence et stock d’eau d’une mare (point d’eau), introduit dans cette version.  
   - **init-camp-pref**, **park-restriction**, etc. : variables secondaires affectant notamment l’installation des campements.

2. **Tortues** :
   - **camps** (breed `[camps camp]`)  
     - **available-space** : nombre de foyers que le campement peut accueillir.  
     - **wood-needs** : besoins en bois.  
     - **wood-quantity** : quantité de bois disponible au campement (non encore fully implémenté).  

   - **foyers** (breed `[foyers foyer]`)  
     - **cattle-herd** et **sheep-herd** : troupeaux de bovins et ovins associés.  
     - **cattle-herd-size** et **sheep-herd-size** : catégories (grand, moyen, petit).  
     - **pasture-strategy** : stratégie de pâturage (ici « directed », cherchant les meilleures patches).  
     - **home-camp**, **home-patch** : localisation du foyer.  
     - **herder-type** : caractérisation de l’éleveur (grand, moyen, petit).  
     - **owned-trees-pop** : (pas encore pleinement utilisé).

   - **cattles** (breed `[cattles cattle]`)  
     - **head** : nombre d’individus du troupeau.  
     - **corporal-condition** : état corporel (santé globale).  
     - **daily-needs-per-head** : besoins quotidiens en herbe.  
     - **UBT-size** : conversion en Unité de Bétail Tropical (vache allaitante = 1, ovin < 1).  
     - **known-space** : espace (ensemble de patches) que le troupeau connaît (rayon autour du foyer).  
     - **acceptable-distance-from-camp**, **daily-water-consumption** : distance et besoins en eau (introduit ou affiné dans cette version).  

   - **sheeps** (breed `[sheeps sheep]`)  
     - Analogues à `cattles` (head, daily-needs-per-head, etc.), avec un coefficient de conversion (UBT-size=0.16).  

   - **tree-populations** (breed `[tree-populations tree-population]`)  
     - **tree-type** : « nutritive », « less-nutritive » ou « fruity ».  
     - **tree-pop-age** : âge (1 à 8).  
     - **population-size** : effectif d’arbres dans cette cohorte.  
     - **current-fruit-stock**, **current-leaf-stock**, **current-wood-stock** : stocks de ressources actualisés.  
     - **max-fruit-stock**, **max-leaf-stock**, **max-wood-stock** : capacités maximales pour ce cohort d’arbres.  
     - **tree-sensitivity** : sensibilité à la dégradation (selon type/âge).  

3. **Globals**  
   - **size-x, size-y** : dimensions du monde (fixées ici de -11 à 11).  
   - **current-season**, **last-season**, **season-counter** : gestion de la saison.  
   - **year-types, current-year-type, total-ticks-per-year, year-counter, year-index** : lecture du type d’année et suivi du temps annuel.  
   - **nduungu-duration, dabbuunde-duration, ceedu-duration, ceetcelde-duration** : durées des saisons (selon le type d’année).  
   - **herd-gain-from-food** : taux (éventuellement pour calcul condition corporelle).  
   - **tree-data** : stockage des infos lues dans un CSV (capacités de fruits, feuilles, bois, etc.).  
   - **renewal-flag** : indicateur de renouvellement annuel des arbres (nouvelle germination).  
   - **total-dry-season-ticks, ticks-since-dabbuunde, grass-end-nduungu** : variables pour calculer la perte d’herbe en saisons sèches.  

**Échelles spatiales et temporelles :**  
- Le monde est un grid NetLogo de patches, dimensionné de -11 à 11 en x et y (soit 23 × 23 = 529 patches).  
- Un tick correspond schématiquement à 1 jour. Les saisons ont un nombre variable de ticks (par exemple Nduungu = 120 jours, Ceedu = 175, etc., pour les « bonnes » années). Une année regroupe Nduungu + Dabbuunde + Ceedu + Ceetcelde.  
- La simulation peut s’étendre sur plusieurs années, gérée par `year-counter` et `year-index`.  

### 1.c. **Process overview and scheduling**

À chaque appel de `go` (un pas de temps = 1 jour) :  
1. **update-season** : Incrémente `season-counter` et `year-counter`, change la saison si on atteint la durée fixée (p. ex., passer de Nduungu à Dabbuunde).  
2. **assign-grass-quality** (uniquement au changement de saison) : Définit la « qualité » de l’herbe (good/average/poor) par patch, selon le type de sol et un tirage aléatoire.  
3. Si la saison = `Nduungu`, alors **renew-tree-population** si pas déjà fait cette année (germination de nouveaux arbres en fonction du type d’année).  
4. **grow-grass** : Mise à jour de la biomasse d’herbe. Pendant Nduungu, croissance logistique. Pendant la saison sèche, décroissance (progressive ou exponentielle selon les phases).  
5. **grow-tree-resources** : Mise à jour (logistique) des stocks de fruit, feuilles et bois, dépendant de la saison et du ratio actuel (`wood-ratio`).  
6. **move-and-eat** : Les troupeaux (cattles et sheeps) cherchent le « meilleur » patch (qualité, quantité) parmi leur `known-space` et s’y déplacent. Ils consomment l’herbe disponible ; leur condition corporelle est modifiée en conséquence.  
7. **manage-water-points** : (dans ce code, un mécanisme un peu expérimental) gère l’activation/désactivation de certains patches en tant que points d’eau.  
8. Mise à jour visuelle (changement de la couleur du patch selon la quantité d’herbe).  
9. Si `year-counter >= total-ticks-per-year`, on incrémente l’index d’année, on met à jour le type d’année, on recalcule les durées de saison, on appelle **update-tree-age** (vieillissement des cohortes d’arbres) et on réinitialise `year-counter`.

---

## 2. **Design concepts**

### 2.a. **Basic principles**

Le modèle s’appuie sur l’idée que :

- La production herbagère est conditionnée par la saison (pluie/saison sèche) et se modélise sous forme de croissance logistique (jusqu’à une capacité maximale K).  
- Les arbres ont des cohorts par classe d’âge, avec des stocks (fruit, feuilles, bois) qui croissent de manière logistique ; il existe un renouvellement (germination) dépendant du type d’année (bonne, moyenne, mauvaise).  
- Les troupeaux se déplacent dans un espace connu (`known-space`), sélectionnant le patch offrant la meilleure qualité d’herbe et la quantité la plus élevée, tout en considérant la proximité.  
- Les ressources en eau (mares) influencent l’installation des campements et peuvent, à terme, influer sur la répartition spatiale du bétail.

### 2.b. **Emergence**

Les phénomènes émergents attendus sont :  
- Les patrons de répartition spatio-temporelle de la biomasse herbagère (pics et creux de production).  
- L’évolution de la couverture arborée selon l’alternance des années (germination, mortalité potentielle, vieillissement).  
- L’éventuelle dégradation (non encore pleinement implémentée) et la possible reforestation dans certains patches.  
- La dynamique de condition corporelle des troupeaux, selon la disponibilité de pâturage.

### 2.c. **Adaptation**

Les agents (bovins et ovins) ont une forme simple d’adaptation : ils « cherchent » à se nourrir en allant sur le patch jugé le plus profitable (enherbement et qualité). Les foyers ont une stratégie unique (`"directed"`) qui oriente leurs troupeaux.  

### 2.d. **Learning**

Il n’y a pas d’apprentissage cumulatif explicite. Les animaux n’actualisent pas leur `known-space` au fil du temps (celui-ci est simplement défini comme un rayon autour du foyer).

### 2.e. **Prediction**

Pas de mécanisme de prédiction ; les troupeaux ne tentent pas d’anticiper les futures disponibilités.

### 2.f. **Sensing**

- Les troupeaux perçoivent la quantité et la qualité d’herbe de tous les patches dans leur rayon `known-space`.  
- Les points d’eau (implémentation partielle) pourraient être détectés pour y accéder ; dans cette version, la logique est encore rudimentaire (on active certains patches comme `water-point`, mais pas de recherche d’eau explicite chez les troupeaux).

### 2.g. **Interaction**

Interaction principalement indirecte via la consommation d’herbe (compétition pour la ressource). Les foyers ne se coordonnent pas entre eux, mais l’épuisement de la ressource localement force un déplacement.

### 2.h. **Stochasticity**

Le hasard intervient dans :  
- Les tirages de la qualité de l’herbe lors des changements de saison (rand < 0.5 → “good”, etc.).  
- Le placement initial des campements et foyers (patchs préférés, distribution normale autour d’une moyenne).  
- La dynamique de germination d’arbres (taux dépendant du type d’année, mais le nombre exact de nouveaux arbres résulte de tirages sur `current-fruit-stock`).  
- Les tailles de troupeaux (aléatoire dans une fourchette selon la catégorie grand/moyen/petit).

### 2.i. **Collectives**

On peut considérer qu’un foyer (et ses troupeaux) forme un collectif minimal. Toutefois, il n’y a pas de mécanisme d’organisation collective entre foyers.

### 2.j. **Observation**

Le modèle fournit des indicateurs :  
- **count foyers**, **sum [head] of cattles**, **sum [head] of sheeps** en interface.  
- Visualisation de la couverture en herbe par échelle de couleur (pcolor).  
- Identification de la saison en cours et du type d’année (`current-season`, `current-year-type`).  
- On peut imaginer mesurer l’évolution de la biomasse totale d’herbe, du stock d’arbres, de la condition corporelle moyenne, etc.

---

## 3. **Details**

### 3.a. **Initialization**

La procédure `setup` :  
1. `clear-all`, définition du monde (-11 à 11).  
2. Lecture de l’environnement depuis un fichier `environment_vel.txt`, qui assigne à chaque patch un type de sol (`soil-type`), le `tree-cover` et la préférence `init-camp-pref`.  
3. Lecture du fichier `year-type.txt` pour stocker la séquence des années (« bonne », « moyenne », « mauvaise »).  
4. Lecture de `tree_info.csv` pour alimenter la variable globale `tree-data` (qui contient pour chaque type d’arbre et chaque âge : stocks max de fruit, feuilles, bois, et sensibilité).  
5. Appel de `setup-landscape` pour initialiser les patches (K, current-grass, num-nutritious, etc., selon `soil-type`).  
6. Appel de `setup-water-patches` : on sélectionne certains patches éligibles pour y créer des mares (`has-pond = true`) avec un `water-stock` (1000, 2000 ou 3000, etc.), respectant des limites paramétrées par `max-ponds-4-months`, `max-ponds-5-months`, `max-ponds-6-months`.  
7. `setup-camps` : crée un certain nombre (`initial-number-of-camps`) de campements sur des patches où `soil-type != Caangol` et potentiellement proches de points d’eau.  
8. `setup-foyers` : chaque campement génère un nombre de foyers dépendant de `available-space`. Chaque foyer se voit attribuer un type d’éleveur (grand, moyen, petit) selon des probabilités fixes.  
9. `setup-herds` : création des troupeaux de bovins (`cattles`) et de moutons (`sheeps`) pour chaque foyer, détermination de la taille du troupeau (dans la fourchette adaptée à la catégorie).  
10. `setup-trees` : pour chaque patch, on répartit les arbres initiaux selon leur type et leur âge. On crée des individus de `tree-populations` avec le stock de fruits, feuilles et bois correspondant.  
11. Ajustements de la visualisation et `reset-ticks`.

### 3.b. **Input data**

Le modèle lit trois fichiers en entrée :  
1. **environment_vel.txt** : liste de lignes donnant, pour chaque patch, le type de sol, la densité initiale d’arbres, etc.  
2. **year-type.txt** : séquence des types d’années (ex. 10 lignes correspondant à 10 années).  
3. **tree_info.csv** : structure en colonnes (type d’arbre, âge, max-fruits, max-leaves, max-woods, sensibilité).

### 3.c. **Submodels**

Les principales fonctions et sous-modèles :

1. **update-season**  
   - Incrémente le compteur de saison et d’année (`season-counter`, `year-counter`).  
   - Change de saison quand on atteint la durée définie (nduungu-duration, etc.).  
   - Permet de mémoriser la quantité d’herbe à la fin de `Nduungu` (pour calculer la perte en saison sèche).  

2. **assign-grass-quality**  
   - À chaque changement de saison, pour chaque patch, on tire aléatoirement un état de qualité de l’herbe (good/average/poor) en fonction du type de sol. La première année, c’est 100 % aléatoire ; ensuite, on réutilise la qualité déjà stockée (modèle de « mémoire »).  

3. **update-year-type**, **set-season-durations**  
   - Permet de déterminer, à la fin d’une année, quel est le type d’année suivant dans la liste lue depuis `year-type.txt`.  
   - Fixe les durées de chaque saison (variables globales) selon le type d’année : par exemple, `nduungu-duration = 120` pour une année « bonne », 90 pour « moyenne », 60 pour « mauvaise », etc.

4. **grow-grass**  
   - En `Nduungu`, croissance logistique (`current-grass + r * current-grass * (K - current-grass)/K`).  
   - En saison sèche (`Dabbuunde + Ceedu`), perte progressive de biomasse, plus marquée en `Ceetcelde` (réduction de 1 % par tick).  
   - Le paramètre `grass-end-nduungu` sert de référence pour calculer la diminution en saison sèche.

5. **grow-tree-resources**  
   - Chaque population d’arbre (`tree-populations`) met à jour ses stocks (bois, feuilles, fruits) selon une formule logistique, dépendant d’un taux `r` propre à la saison et du ratio bois (`wood-ratio`).  
   - Le stock maximum dépend de l’âge et du type d’arbre (données issues de `tree-data`), ajusté par `population-size`.  

6. **renew-tree-population**  
   - Au début de Nduungu et seulement une fois par an, on calcule un nombre de nouvelles pousses (germe) pour chaque type de population d’arbre, proportionnel à `current-fruit-stock` multiplié par un taux de germination (différent selon « nutritive », « lessNutritive », « fruity » et selon le type d’année).  
   - De nouvelles populations de tree-populations sont créées avec age = 1, si le nombre de germes est > 0.

7. **update-tree-age**  
   - Lorsqu’on boucle une année (c.-à-d. `year-counter` atteint `total-ticks-per-year`), chaque population d’arbres voit son âge (`tree-pop-age`) incrémenté.  
   - Si l’âge passe de 7 à 8, on fusionne avec la population déjà existante en âge 8 (ou on en crée une nouvelle si elle n’existe pas).

8. **move-and-eat**  
   - Chaque troupeau (cattle/sheep) :  
     1. Recherche le patch « viable » (dans `known-space`) qui a la meilleure qualité d’herbe, puis la plus grande quantité, puis est le plus proche.  
     2. Se déplace sur ce patch.  
     3. Consomme de l’herbe via `consume-grass` (retire `grass-eaten` du patch).  
     4. Met à jour la `corporal-condition` : `condition += (grass-eaten - daily-needs)`.  

9. **manage-water-points** (expérimental)  
   - Désactive tous les `water-point`, puis en sélectionne arbitrairement 5 (via `n-of 5 patches`) pour les activer. Permettrait (dans une version ultérieure) d’orienter la fréquentation des troupeaux.

10. **color-grass** et **update-visualization**  
    - Permettent de colorer les patches (p.ex. du jaune foncé au jaune clair) selon la quantité d’herbe, ou bien d’autres modes (sol, arbre).

**Paramètres principaux** (accessibles via l’interface) :

- `initial-number-of-camps`, `space-camp-min`, `space-camp-max`, `space-camp-mean`, `space-camp-standard-deviation` : contrôlent l’installation initiale des campements.  
- `max-ponds-4-months`, `max-ponds-5-months`, `max-ponds-6-months` : nombre de mares pouvant exister à 4, 5 ou 6 mois d’eau (avec stock d’eau distinct).  
- `herd-gain-from-food` (annoncé, mais pas encore massivement utilisé, la condition corporelle est plutôt gérée par l’écart `grass-eaten - daily-needs`).  
- `visualization-mode` : choix du type de coloration (soil-type, tree-cover, grass-cover).  

---

### **Commentaire sur les nouveautés (par rapport à la version précédente)**

- **Gestion explicite du cycle annuel** : on introduit `year-types` (bonne, moyenne, mauvaise) lus depuis un fichier, avec des durées de saisons différentes.  
- **Points d’eau (mares)** : des patches peuvent être marqués comme `has-pond` et disposent d’un `water-stock`. Une routine `manage-water-points` propose un test de variation des patches actifs comme points d’eau.  
- **Renouvellement des arbres** : un mécanisme `renew-tree-population` crée de jeunes arbres selon la production de fruits et le type d’année.  
- **Vieillissement des arbres** : la procédure `update-tree-age` fusionne les cohortes qui atteignent 8 ans.  
- **Pâturage plus détaillé** : la consommation d’herbe considère la qualité et la quantité.  
- **Gestion de la saison sèche** : utilisation de `grass-end-nduungu` pour moduler la décroissance de la biomasse jusqu’à la mi-Ceedu.

---

## Conclusion

Cette version du **DundiModel** poursuit l’objectif de représenter, de façon stylisée, l’usage pastoral d’un territoire sahélien avec une forte saisonnalité (Nduungu, Dabbuunde, Ceedu, Ceetcelde) et une variabilité inter-annuelle du climat. Les troupeaux, encadrés par des foyers, recherchent les meilleurs pâturages dans une zone de connaissance, tandis que la végétation (herbe et arbres) se renouvelle ou régresse selon la saison et le type d’année.

Le protocole ODD ci-dessus expose la structure générale, les entités et leurs variables, l’enchaînement des processus et la logique de conception (croissance logistique, germination, etc.). Les nouveautés majeures résident dans la gestion des points d’eau, l’introduction plus poussée des types d’années, et le sous-modèle de croissance/renouvellement arboré.

Ce document peut servir de base pour la **réplicabilité** et la **compréhension** du modèle, ainsi que pour sa future extension (par exemple : mortalité ou abattage des arbres, stratégie plus complexe de recherche d’eau par les troupeaux, interactions entre foyers, etc.).
