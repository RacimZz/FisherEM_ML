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
