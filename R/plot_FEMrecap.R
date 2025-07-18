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
icl_values <- sapply(results_fem_only, function(x) x$allCriteria$icl)

FEMrecap(results_fem_only, leg = "topright", printall = TRUE, file = "figures/")
