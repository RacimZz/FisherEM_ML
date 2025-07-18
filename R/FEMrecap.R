FEMrecap <- function(SSPdata = NULL, xrange = NULL, yrange = NULL, leg = NULL, printall = FALSE, file = NULL) {
  if (!requireNamespace("ggplot2", quietly = TRUE)) stop("ggplot2 est requis.")
  library(ggplot2)
  
  if (class(SSPdata) != "fem" & class(SSPdata) != "list") stop("SSPdata doit être de classe fem ou list (de fem).")
  
  if (class(SSPdata) == "fem") {
    SSPdata <- list(SSPdata)
  }
  if (class(SSPdata[[1]]) != "fem") stop("SSPdata doit être une liste de fem.")
  
  # Fusion des modèles et ICLs
  all_data <- do.call(rbind, lapply(SSPdata, function(obj) {
    df <- as.data.frame(obj$allCriteria)
    df
  }))
  
  all_data$icl[which(all_data$icl == -Inf)] <- NA
  
  if (nrow(all_data) == 0) {
    warning("Aucun modèle valide à tracer.")
    return(NULL)
  }
  
  # Affichage de l’optimum global
  opt_idx <- which.max(all_data$icl)
  cat("🔎 Optimum:", all_data$model[opt_idx], "| K =", all_data$K[opt_idx], "| ICL =", round(all_data$icl[opt_idx], 2), "\n")
  
  if (printall) print(all_data)
  
  # Définition des plages si besoin
  if (is.null(yrange)) yrange <- range(all_data$icl, na.rm = TRUE)
  if (is.null(xrange)) xrange <- range(all_data$K, na.rm = TRUE)
  
  models <- unique(all_data$model)
  for (mod in models) {
    model_data <- subset(all_data, model == mod)
    
    xrange <- c(min(all_data$K), max(all_data$K) + 2)  
    
    p <- ggplot(model_data, aes(x = K, y = icl)) +
      geom_line(color = "steelblue", size = 1.2) +
      geom_point(color = "darkred", size = 2) +
      labs(title = paste("ICL vs K pour le modèle", mod), x = "K", y = "ICL") +
      scale_x_continuous(breaks = sort(unique(model_data$K)), limits = xrange) +
      scale_y_continuous(limits = yrange) +
      theme_light(base_size = 14)
    
    p2 <- ggplot(all_data, aes(x = K, y = icl)) +
      geom_line(aes(color = model, group = model), size = 1) +
      geom_point(aes(color = model), size = 1.5) +
      facet_wrap(~model, scales = "free_y") +
      scale_x_continuous(limits = xrange) +
      labs(title = "Courbe ICL vs K par modèle", x = "K", y = "ICL") +
      theme_light(base_size = 12) +
      theme(legend.position = "none")
    

    
    if (!is.null(file)) {
      dirpath <- dirname(file)
      if (!dir.exists(dirpath)) dir.create(dirpath, recursive = TRUE)
      ggsave(filename = paste0(file, "each_model/_", mod, ".png"), plot = p, width = 8, height = 6)
      ggsave(filename = paste0(file, "_ICL_vs_K_par_model.png"), plot = p2, width = 8, height = 6)
      
    } else {
      print(p2)
    }
  }
  # Graphe 3 : moyenne ICL par modèle (barplot)
  best_icl <- aggregate(icl ~ model, data = all_data, mean, na.rm = TRUE) # la fonction peut etre changé par max, min ....
  p3 <- ggplot(best_icl, aes(x = reorder(model, icl), y = icl, fill = model)) +
    geom_bar(stat = "identity") +
    labs(title = "moyenne des ICL par modèle", y = "ICL", x = "Modèle") +
    theme_light(base_size = 18) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1))
  
  if (!is.null(file)) {
    dirpath <- dirname(file)
    if (!dir.exists(dirpath)) dir.create(dirpath, recursive = TRUE)
    ggsave(filename = paste0(file,"_ICL_vs_K_barplot.png"), plot = p3, width = 8, height = 6)
    
  } else {
    print(p3)
  }
} 
