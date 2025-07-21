# ==============================================================================
# Script : run_fem_auto.R
# Auteur : Racim ZENATI
# Date : Juillet 2025
# Objet :
# Ce script exécute automatiquement le pipeline Fisher-EM sur un ensemble
# de modèles statistiques en testant les valeurs de K dans un intervalle donné.
#
# Il appelle le script `automatic_fem.R` en ligne de commande via `system()`
# en lui passant les chemins d'entrée/sortie, l'intervalle [Kmin, Kmax],
# et les noms de modèles à tester.
#
# 🔧 Dépendances :
#   - Le fichier `automatic_fem.R` doit être accessible dans le répertoire courant
#   - Le package `FisherEM` (appelé dans le script appelé)
#
# 📂 Paramètres :
#   - data_path  : chemin vers les données prétraitées (au format `.RData` ou `.RDS`)
#   - save_path  : dossier de sauvegarde des résultats `.RDS`
#   - Kmin/Kmax  : bornes inférieures et supérieures du nombre de clusters à tester
#   - models     : vecteur de noms de modèles Fisher-EM à exécuter
#
# Résultat :
#   - Résultats sauvegardés dans `save_path` sous forme de fichiers RDS nommés
#     "AutomaticFem<Model>K<K>.RDS"
# ==============================================================================

# fisher.R
Sys.info()["nodename"]
sessionInfo()

# Chemins à adapter
data_path <- "../Data/sp4567scale.RData"
save_path <- "../results/AUTOMATIC/"
Kmin <- 15
Kmax <- 20  
models <- c('DkBk','DkB','DBk','DB','AkjBk','AkjB','AkBk','AkB','AB')

# Construction de la commande système
args <- paste(
  shQuote(data_path),
  Kmin,
  Kmax,
  shQuote(save_path),
  paste(models, collapse = " ")
)

# Appel du script avec arguments
cmd <- paste("Rscript automatic_fem.R", args)
cat("▶️ Exécution de :", cmd, "\n")

system(cmd)
quit(save="no")
