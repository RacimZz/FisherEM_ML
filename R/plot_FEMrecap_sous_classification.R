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
      #cat("Erreur lors du chargement de", file_path, ":", conditionMessage(e), "\n")
    })
  }
  
  #cat("Terminé. Objets chargés :", length(result_list), "\n")
  return(result_list)
}


# batch_recap.R

source("FEMrecap.R")

# Boucle sur les 15 classes
for (i in 1:15) {
  
  cat("\n========================================================================\n")
  cat("Traitement de la classe", i, "\n")
  
  # Chemins
  path_results <- sprintf("/sous_classif/class_%d/", i) # à adapter selon votre structure de répertoire
  path_figures <- sprintf("/figures/class_%d/", i) # à adapter selon votre structure de répertoire
  
  # Charger tous les objets RData/RDS
  results <- extract_all_rdata_rds(path_results)
  
  cat("Objets chargés :", length(results), "\n")
  
  # Garder uniquement les objets de classe "fem"
  results_fem_only <- Filter(function(x) class(x) == "fem", results)
  cat("Objets de classe 'fem' :", length(results_fem_only), "\n")
  
  # Vérifier si c'est vide
  if (length(results_fem_only) == 0) {
    cat("Aucun objet 'fem' trouvé. Récapitulatif non généré.\n")
  } else {
    # Générer les récapitulatifs
    FEMrecap(
      results_fem_only,
      leg = "topright",
      printall = TRUE,
      file = path_figures
    )
    cat("Récapitulatif sauvegardé dans :", path_figures, "\n")
  }
}

quit(save = "no")
