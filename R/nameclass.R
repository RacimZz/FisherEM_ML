# ==============================================================================
# Script : nameclass.R
# Auteurs : 
# Date de création : Juillet 2025
# Dernière modification : Juillet 2025
# Objet :
# Ce script assigne un nom unique à chaque galaxie de toutes les sous-classifications effectué auparavant, 
# en combinant :
#   - la classification principale en 15 classes (A à O),
#   - la meilleure sous-classification locale trouvée automatiquement par classe.
# Le résultat est sauvegardé dans un fichier CSV avec un nom de sous-classe par spectre.
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
      #cat("Erreur lors du chargement de", file_path, ":", conditionMessage(e), "\n")
    })
  }
  
  #cat("Terminé. Objets chargés :", length(result_list), "\n")
  return(result_list)
}


results <- extract_all_rdata_rds("results/")
results_extract <- Filter(function(x) class(x) == "fem", results)

main_classif <- results_extract[[35]]
# Crée un vecteur vide pour stocker les noms de sous-classes
subclass_names <- rep(NA, length(main_classif$cls))

# Lettres pour les 15 classes principales (A à O)
letters_15 <- LETTERS[1:15]
base_path <- "1068/sous_classif/"

for (i in 1:15) {
    # tout d'abord il faut extraire toutess les sous classifications de la classe i
    class_path <- paste0(base_path, "class_", i, "/")
    extract_class <- extract_all_rdata_rds(class_path)
    results_extract <- Filter(function(x) class(x) == "fem", extract_class)
    
    if (length(results_extract) == 0) {
        cat("Pas de résultat pour la classe", i, "\n")
        next
    }

    # Trouver l’indice de l’objet avec le meilleur ICL
    icl_values <- sapply(results_extract, function(x) x$allCriteria$icl)
    best_idx <- which.max(icl_values)
    subcls <- results_extract[[best_idx]]
    
    # subcls contient maintenant la meilleure sous classification pour la classe i
    # On va maintenant construire les noms de sous-classes pour cette classe i

    # Vérifie que la taille est cohérente
    idx_main <- which(main_classif$cls == i)
    if (length(idx_main) != length(subcls$cls)) {
        warning(paste("Taille incohérente pour la classe", i))
        next
    }
    
    # Construit les noms de sous-classe (ex: A1, A2, ...)
    subclass_names[idx_main] <- paste0(letters_15[i], subcls$cls)
}


# Sauvegarde dans un dataframe avec les index d'origine
df_subclasses <- data.frame(index = 1:length(subclass_names),
                            subclass = subclass_names)

# écrire dans un CSV
write.csv(df_subclasses, "nameclass_standardise.csv", row.names = FALSE)
quit(save="no")
