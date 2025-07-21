# ==============================================================================
# Script : run_fem_auto_sous_classification.R
# Auteur : Racim ZENATI
# Date : Juillet 2025
# Objet :
# Ce script exécute automatiquement le script `automatic_fem.R` sur les 15 classes
# obtenues lors d'une première classification globale (par exemple DBk avec K = 15).
# Chaque sous-ensemble est traité indépendamment pour effectuer une sous-classification
# avec l'algorithme Fisher-EM et différents modèles.
#
# Fonctionnement :
# - Pour chaque classe principale i = 1 à 15 :
#     - Charge les spectres de la classe i (fichier `class_i_scaled_DBk_15.Rdata`)
#     - Appelle `automatic_fem.R` avec les paramètres (Kmin, Kmax, modèles à tester)
#     - Sauvegarde les résultats dans le dossier `sous_classif/class_i/`
#
# 🔧 Dépendances :
#   - Le fichier `automatic_fem.R` doit être accessible dans le répertoire courant
#   - Le package `FisherEM` est utilisé par le script appelé
#   - Les fichiers `class_i_scaled_DBk_15.Rdata` doivent exister dans `../Data/`
#
# 📂 Paramètres :
#   - data_path  : chemin des fichiers RData contenant les spectres d’une classe
#   - save_path  : chemin de sauvegarde des fichiers résultats `.RDS`
#   - Kmin/Kmax  : plage des valeurs de K à tester (ici de 30 à 40)
#   - models     : liste des modèles Fisher-EM à évaluer
#
# Résultat :
#   - Génération automatique des fichiers `AutomaticFem<Model>K<K>.RDS`
#     pour chaque classe, stockés dans leurs répertoires respectifs.
#
# Exemple de structure produite :
#   - sous_classif/
#       ├── class_1/
#       │   ├── AutomaticFemDBkK30.RDS
#       │   └── ...
#       ├── class_2/
#       └── ...
# ==============================================================================

# fisher_batch.R
Sys.info()["nodename"]
sessionInfo()

# Chemins communs
save_path <- "sous_classif/"
Kmin <- 30
Kmax <- 40
models <- c('DkBk','DkB','DBk','DB','AkjBk','AkjB','AkBk','AkB','AB')

# on parcourt les 15 classes de la premiere classification (optimum obtenue dans run_fem_auto.R)
for (i in 1:15) {
  
  # Chemin spécifique
  data_path <- sprintf("../Data/class_%d_scaled_DBk_15.Rdata", i)
  save_path <- sprintf("sous_classif/class_%d/", i)

  # Construction des arguments
  args <- paste(
    shQuote(data_path),
    Kmin,
    Kmax,
    shQuote(save_path),
    paste(models, collapse = " ")
  )
  
  # Commande système
  cmd <- paste("Rscript automatic_fem.R", args)
  cat("\n=============================================================\n")
  cat("▶️ Exécution de :", cmd, "\n")
  
  # Lancement
  system(cmd)
}

quit(save="no")
