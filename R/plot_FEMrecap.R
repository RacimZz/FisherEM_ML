# ==============================================================================
# Script : plot_FEMrecap.R
# Auteurs : Racim ZENATI
# Date de création : Juin 2025
# Dernière modification : 
# Objet :
# Ce script permet de charger l’ensemble des résultats de classification 
# (issus d’une exploration FisherEM avec différents modèles/K/...),
# puis génère des visualisations automatiques via `FEMrecap()` :
#   - Courbes ICL vs K par modèle
#   - Barplot des ICL moyens par modèle
#   - Sauvegarde automatique dans le dossier "figures/"
# Il permet ainsi d’identifier le meilleur couple (modèle, K) global.
# ==============================================================================

library(FisherEM)
extract_all_rdata_rds <- function(root_dir) {
  all_files <- list.files(root_dir, pattern = "\\.(rds|RDS|rdata|RData)$", recursive = TRUE, full.names = TRUE)
  result_list <- list()
  
  for (file_path in all_files) {
    ext <- tools::file_ext(file_path)

    #cat("Traitement de :", file_path, "\n")
    
    tryCatch({
      if (tolower(ext) == "rds") {
        obj <- readRDS(file_path)
        result_list[[length(result_list) + 1]] <- obj
        
      } else if (tolower(ext) == "rdata") {
        env <- new.env()
        load(file_path, envir = env)
        # Si un seul objet, on prend directement, sinon on garde tout l'env
        objs <- as.list(env)
        if (length(objs) == 1) {
          result_list[[length(result_list) + 1]] <- objs[[1]]
        } else {
          result_list[[length(result_list) + 1]] <- objs
        }
        }
      
    }, error = function(e) {
      #cat("rreur lors du chargement de", file_path, ":", conditionMessage(e), "\n")
    })
  }
  
  #cat("erminé. Objets chargés :", length(result_list), "\n")
  return(result_list)
}


results <- extract_all_rdata_rds("results/")

# Charger FEMrecap
source("FEMrecap.R")

results_fem_only <- Filter(function(x) class(x) == "fem", results)
FEMrecap(results_fem_only, leg = "topright", printall = TRUE, file = "figures/")
