# ==============================================================================
# Script : FEMrecap.R
# Auteur : Didier FRAIX-BURNET
# Date de création : Avril 2024
# Modifié par : Racim ZENATI
# Dernière modification : Juin 2025
# Objet : Visualisation comparative des modèles FisherEM via les courbes ICL
# Ce script génère automatiquement :
#   - des graphes ICL vs K pour chaque modèle testé
#   - un graphe récapitulatif par facette
#   - un barplot de la moyenne des ICL pour chaque modèle
# Sortie : fichiers .png ou affichage direct
# ==============================================================================

FEMrecap <- function(SSPdata = NULL, xrange = NULL, yrange = NULL, leg = NULL, printall = FALSE, file = NULL) {

  # Vérifie que ggplot2 est bien installé
  if (!requireNamespace("ggplot2", quietly = TRUE)) stop("ggplot2 est requis.")
  library(ggplot2)

  # Vérifie que les données sont bien de type 'fem' ou liste de 'fem'
  if (class(SSPdata) != "fem" & class(SSPdata) != "list") stop("SSPdata doit être de classe fem ou list (de fem).")
  
  # Si une seule classification est fournie, on la met dans une liste
  if (class(SSPdata) == "fem") {
    SSPdata <- list(SSPdata)
  }
  if (class(SSPdata[[1]]) != "fem") stop("SSPdata doit être une liste de fem.")

  # Fusion des critères de tous les objets fem
  all_data <- do.call(rbind, lapply(SSPdata, function(obj) {
    df <- as.data.frame(obj$allCriteria)
    df
  }))
  
  # On remplace les -Inf de l'ICL par NA pour éviter les bugs d'affichage
  all_data$icl[which(all_data$icl == -Inf)] <- NA
  
  if (nrow(all_data) == 0) {
    warning("Aucun modèle valide à tracer.")
    return(NULL)
  }

  # Affiche dans la console le modèle optimal selon l’ICL
  opt_idx <- which.max(all_data$icl)
  cat("🔎 Optimum:", all_data$model[opt_idx], "| K =", all_data$K[opt_idx], "| ICL =", round(all_data$icl[opt_idx], 2), "\n")
  
  if (printall) print(all_data)  # Option d'affichage de toutes les lignes

  # Définit les plages des axes si non spécifiées
  if (is.null(yrange)) yrange <- range(all_data$icl, na.rm = TRUE)
  if (is.null(xrange)) xrange <- range(all_data$K, na.rm = TRUE)
  
  # On traite chaque modèle individuellement
  models <- unique(all_data$model)
  for (mod in models) {
    model_data <- subset(all_data, model == mod)
    
    xrange <- c(min(all_data$K), max(all_data$K) + 2)  # Extension possible de l’axe X
    
    # Graphe 1 : ICL vs K pour le modèle actuel
    p <- ggplot(model_data, aes(x = K, y = icl)) +
      geom_line(color = "steelblue", size = 1.2) +
      geom_point(color = "darkred", size = 2) +
      labs(title = paste("ICL vs K pour le modèle", mod), x = "K", y = "ICL") +
      scale_x_continuous(breaks = sort(unique(model_data$K)), limits = xrange) +
      scale_y_continuous(limits = yrange) +
      theme_light(base_size = 14)
    
    # Graphe 2 : Facettes par modèle
    p2 <- ggplot(all_data, aes(x = K, y = icl)) +
      geom_line(aes(color = model, group = model), size = 1) +
      geom_point(aes(color = model), size = 1.5) +
      facet_wrap(~model, scales = "free_y") +
      scale_x_continuous(limits = xrange) +
      labs(title = "Courbe ICL vs K par modèle", x = "K", y = "ICL") +
      theme_light(base_size = 12) +
      theme(legend.position = "none")
    
    # Si un chemin de fichier est fourni, on sauvegarde les graphes
    if (!is.null(file)) {
      dirpath <- dirname(file)
      if (!dir.exists(dirpath)) dir.create(dirpath, recursive = TRUE)
      ggsave(filename = paste0(file, "each_model/_", mod, ".png"), plot = p, width = 8, height = 6)
      ggsave(filename = paste0(file, "_ICL_vs_K_par_model.png"), plot = p2, width = 8, height = 6)
    } else {
      print(p2)  # Sinon on affiche dans la console
    }
  }

  # Graphe 3 : barplot de la moyenne des ICL par modèle
  best_icl <- aggregate(icl ~ model, data = all_data, mean, na.rm = TRUE)
  p3 <- ggplot(best_icl, aes(x = reorder(model, icl), y = icl, fill = model)) +
    geom_bar(stat = "identity") +
    labs(title = "moyenne des ICL par modèle", y = "ICL", x = "Modèle") +
    theme_light(base_size = 18) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  # Sauvegarde ou affichage du barplot
  if (!is.null(file)) {
    dirpath <- dirname(file)
    if (!dir.exists(dirpath)) dir.create(dirpath, recursive = TRUE)
    ggsave(filename = paste0(file,"_ICL_vs_K_barplot.png"), plot = p3, width = 8, height = 6)
  } else {
    print(p3)
  }
}

