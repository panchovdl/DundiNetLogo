# ODD du modèle DunDi

## Purpose

La gestion collective des ressources dans les systèmes pastoraux, met en évidence les défis liés à la reconnaissance des communs pastoraux dans un contexte de crises multidimensionnelles en Afrique de l'Ouest . Les recherches récentes ont exploré les approches par les communs pour valoriser le pastoralisme dans les politiques publiques, analysant les enjeux de reconnaissance, d'institutionnalisation et de valorisation économique des activités pastorales (Aubert et Dutilly, 2024). Ces travaux fournissent un cadre théorique pertinent pour le développement et l'application de **DundiModel**. 

Le modèle **DundiModel** est conçu pour simuler et analyser les dynamiques du pastoralisme dans les systèmes de gestion des communs, en particulier dans les environnements semi-arides. Il vise à étudier les interactions entre les pratiques pastorales, la gestion des ressources naturelles (telles que les pâturages et les forêts), et les variables climatiques saisonnières. En intégrant des éléments tels que les campements, les foyers, les troupeaux de bétail et les populations d'arbres, le modèle permet d'explorer comment les décisions de gestion collective influencent la durabilité des ressources et la résilience des communautés pastorales.

Ce modèle s'appuie sur des concepts clés du pastoralisme et de la gestion des communs, tels que la mobilité des troupeaux, l'accès partagé aux ressources, et les mécanismes de gouvernance locale. Il offre un outil pour tester divers scénarios de gestion et évaluer leurs impacts sur la productivité des pâturages, la santé des troupeaux, et la conservation des écosystèmes.

## Entities, State Variables, and Scales

#### **Entities**
1. **Patchs (Unités spatiales) :**
   - Représentent des cellules dans une grille spatiale définie par `size-x` et `size-y`.
   - Chaque patch est caractérisé par :
     - **Variables de ressources :** 
       - `current-grass`, `grass-quality` : État et qualité du tapis herbacé.
       - `monocot-grass`, `dicot-grass` : Stocks d'herbes monocotylédones et dicotylédones.
       - `tree-cover`, `water-stock` : Couverture ligneuse et disponibilité en eau.
     - **Variables de sensibilité et de dégradation :** 
       - `patch-sensitivity`, `degradation-level` : Capacité du patch à se régénérer ou à se dégrader.
     - **Catégorisation :**
       - `soil-type` : Type de sol.
       - `water-point` et `has-pond` : Indiquent la présence d'un point d'eau ou d'une mare.

2. **Agents (Breeds) :**
   - **Camps (Campements) :** Représentent les regroupements humains, potentiellement fixes ou mobiles, impliqués dans la gestion des ressources.
   - **Foyers (Households) :** Unités socio-économiques, correspondant à des familles ou groupes de gestion.
   - **Cattles (Bétails) et Sheeps (Moutons) :** Représentent les troupeaux qui se déplacent et exploitent les ressources (herbes, points d’eau).
   - **Tree-populations (Populations d’arbres) :** Regroupements de végétaux (comme baobabs ou balanites) qui interagissent avec le sol et les troupeaux.

#### **State Variables**
Les entités sont caractérisées par un ensemble de variables d'état qui influencent leur comportement et leurs interactions :
1. **Patchs :**
   - Ressources disponibles :
     - `current-grass`, `K` (capacité de charge), `grass-end-nduungu`.
     - Stock et qualité d'herbes monocotylédones et dicotylédones (`monocot-grass`, `dicot-grass`).
   - État écologique :
     - `patch-sensitivity`, `degradation-level`.
     - Variables relatives à la couverture et au type de sol (`tree-cover`, `soil-type`).
   - Présence d’eau :
     - `water-stock`, `water-point`.
   - Restrictions :
     - `park-restriction` : Zones protégées.

2. **Agents :**
   - **Camps et foyers :** Peuvent inclure des variables telles que la localisation, les besoins en ressources, ou des indicateurs de bien-être.
   - **Bétails et moutons :**
     - Localisation actuelle (par rapport aux patchs).
     - Besoins nutritionnels, influencés par les stocks d’herbes et leur qualité (`monocot-UF-per-kg-MS`, `dicot-UF-per-kg-MS`).
   - **Arbres :**
     - Âge des arbres (`tree-age`), capacité à fournir des ressources (fruits, feuilles, bois).

3. **Variables globales :**
   - **Climat :** 
     - `current-season`, `last-season`, `nduungu-duration` (saison des pluies), etc.
   - **Temporalité :** 
     - `year-types`, `year-counter`.

#### **Scales**
1. **Temporelle :**
   - Chaque simulation est découpée en "ticks", représentant des jours, des semaines, ou des mois.
   - Les années sont segmentées en saisons (pluies, soudure, sécheresses), définies par des durées spécifiques (`nduungu-duration`, `ceetcelde-duration`).
   - L'horizon temporel peut couvrir plusieurs années pour observer des dynamiques à long terme.

2. **Spatiale :**
   - La grille spatiale est une représentation discrète d’un paysage semi-aride.
   - Les dimensions (`size-x`, `size-y`) dépendent de la configuration initiale, chaque cellule correspondant à une unité de paysage, comme 1 hectare.
   - Les interactions entre entités (par exemple, déplacements des troupeaux) sont limitées par la proximité spatiale (zones adjacentes ou accessibles).

---

Si vous souhaitez des précisions supplémentaires sur une entité, un processus ou une variable, je peux approfondir davantage.

# Références 

- Aubert S., Dutilly C. 2024. Une approche par les communs pour faire valoir le pastoralisme dans les politiques publiques. Nat. Sci. Soc.,https://doi.org/10.1051/nss/2023045
- CTFD, 2023, Préserver le pastoralisme Les défis de la reconnaissance des communs pastoraux dans un contexte de crise multidimensionnelle en Afrique de l’Ouest, Les notes de Synthèse, Foncier et développement, https://www.foncier-developpement.fr/wp-content/uploads/Note-de-synthese_Numero35_Pastoralisme.pdf

