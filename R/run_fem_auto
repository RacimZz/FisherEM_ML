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
