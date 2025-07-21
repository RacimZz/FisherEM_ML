
# 🧠 FisherEM SDSS Spectra Classification Pipeline (R version)

Ce repository R contient l'ensemble des scripts que j'ai développés et exécutés dans le cadre de mon stage au laboratoire IPAG (Institut de Planétologie et d'Astrophysique de Grenoble), visant à effectuer une classification non-supervisée de spectres de galaxies SDSS à l'aide de l'algorithme **Fisher-EM**.

## 📁 Structure du pipeline R

### 1. Prétraitement des données

- **Fichier original** : `sppart4567fwbnnCZ.RData` (spectres de galaxies SDSS)
- **Standardisation** : les spectres sont normalisés et enregistrés dans `sppart4567scaled.RData`.

Utilisé dans **toutes les étapes suivantes**.

---

### 2. Classification principale avec FisherEM

- **Script** : `run_fem_auto.R`
- **But** : Explorer plusieurs valeurs de K (ex: 10 à 40) et plusieurs modèles FisherEM (`DkBk`, `DBk`, `AkB`, etc.).
- **Exécution** : sur les machines de calcul de l'IPAG (via batchs/SSH)

> Plusieurs exécutions ont été faites avec différents Kmin/Kmax pour mieux explorer l'espace des partitions.

---

### 3. Choix de l'optimum via critère ICL

- **Script** : `plot_FEMrecap.R`
- **Fonction clé** : `FEMrecap()`
- **But** : Afficher graphiquement les performances ICL de chaque modèle selon K, pour choisir le meilleur clustering.

> L'optimum retenu : **modèle DBk avec K = 15**.

---

### 4. Visualisation des moyennes de chaque classe de l'optimum (K=15)

- **Script** : `mspsplit_sous_classification.R`
- **Fonction clé** : `mspsplit_paper()`
- **But** : Afficher les courbes moyennes + dispersion (quantiles) pour chaque groupe de la classification `DBk K=15`
- **Exécution** : La boucle est à enlever, et on exécute le contenue de celle ci sur la classification `DBk K=15`
- **Output** : 1 PDFs, comme celui affiché sur [La partie mspsplit du README.md.](README.md)


---

### 5. Sous-classification de chaque classe (15 classes)

- **Script** : `run_fem_auto_sous_classification.R`
- **But** : Appliquer à chaque classe principale l'algorithme FisherEM pour trouver des sous-groupes (ex: K = 30 à 40).
- **Exécution** : boucle sur `class_1`, ..., `class_15`

---

### 6. Choix des meilleurs sous-classifications

- **Script** : `plot_FEMrecap_sous_classification.R`
- **Fonction** : boucle sur chaque répertoire `sous_classif/class_i/`
- **But** : Identifier l'optimum local (ICL max) pour chaque sous-classification

---

### 7. Visualisation de toutes les sous-classifications optimales

- **Script** : `mspsplit_sous_classification.R`
- **But** : Générer les courbes moyennes + quantiles pour **chaque sous-classe optimale** trouvée dans l'étape 6
- **Output** : 15 PDFs

- **Script** : `results_mspsplit.R`
- **But** : Fusionner les 15 PDF en **une grille 5x3** au format PDF final `sous_classification_finale.pdf`

➡️[La sous classification obtenue](PDFs/sous_classification_finale.pdf)

---

### 8. Attribution des noms de sous-classes normalisés

- **Script** : `nameclass.R`
- **But** : Créer un vecteur donnant à chaque individu un nom de sous-classe du type `A1`, `C5`, `M2`, etc.
- **Logique** :
    - Les lettres `A à O` représentent les 15 classes principales
    - Le numéro correspond à la sous-classe locale obtenue à l'étape 7
- **Output** : fichier CSV `nameclass_standardise.csv`

---

## 📄 Liste des fichiers R et rôles

| Fichier | Rôle |
|--------|------|
| `run_fem_auto.R` | Lancer FisherEM sur les données complètes pour trouver l'optimum global |
| `plot_FEMrecap.R` | Affiche les courbes ICL pour comparer les modèles/K |
| `mspsplit_sous_classification.R` | Affiche la moyenne + dispersion (quantiles) pour chaque classe ou sous-classe |
| `run_fem_auto_sous_classification.R` | Appliquer FisherEM sur chaque classe séparément |
| `plot_FEMrecap_sous_classification.R` | Boucle sur les 15 classes pour tracer les ICL |
| `results_mspsplit.R` | Crée le PDF final avec toutes les sous-classifications en grille |
| `nameclass.R` | Associe à chaque individu un nom de sous-classe au format `A1`...`O5` |

---

## ⚙️ Dépendances / Packages R

```r
install.packages(c("FisherEM", "ggplot2", "magick", "scales"))
```

---

## 👨‍🔬 Encadrement

- **Racim Zenati** – Étudiant à l'INP-ENSIMAG
- Stage IPAG encadré par :
  - **Didier Fraix-Burnet** (chercheur CNRS)
  - **Hugo Chambon** (doctorant en astrophysique)

---

## 📎 Données manipulées

- `sppart4567fwbnnCZ.RData` : spectres SDSS
- `sppart4567scaled.RData` : spectres standardisés
- `lambdasbin.RData` : vecteur des longueurs d'onde
- `results/` : résultats des classifications principales
- `sous_classif/class_i/` : sous-classifications par classe principale

---

## 📌 Notes

- Tous les fichiers `.RData` sont à charger avec `load()`
- Tous les répertoires doivent exister avant l'exécution (ex: `figures/`, `PDFs/`, etc.)
- Les fichiers `.R` peuvent être lancés depuis un terminal avec :

```bash
Rscript nom_du_script.R
```
