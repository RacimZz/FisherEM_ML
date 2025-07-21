# ==============================================================================
# Script : mspsplit_sous_classification.R
# Auteurs : Racim ZENATI
# Date de création : Juin 2025
# Dernière modification : Juillet 2025
# Objet : 
# Génération automatique de courbes de moyennes spectraux pour les sous-classes
# d’un clustering FisherEM appliqué aux spectres SDSS. Le script :
#   - extrait les meilleures classifications FEM par classe principale,
#   - génère des visualisations `mspsplit_paper` avec bandes de dispersion,
#   - enregistre les graphiques dans des fichiers PDF par classe.
# ==============================================================================

library(FisherEM)
extract_all_rdata_rds <- function(root_dir) {
  all_files <- list.files(root_dir, pattern = "\\.(rds|RDS|rdata|RData)$", recursive = TRUE, full.names = TRUE)
  result_list <- list()
  
  for (file_path in all_files) {
    ext <- tools::file_ext(file_path)

    #cat("📂 Traitement de :", file_path, "\n")
    
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
      #cat("❌ Erreur lors du chargement de", file_path, ":", conditionMessage(e), "\n")
    })
  }
  
  #cat("✅ Terminé. Objets chargés :", length(result_list), "\n")
  return(result_list)
}

# dispersion = quantiles or std

# dispersion = quantiles or std

mspsplit_paper <- function(FEMout,spec=spectra,Xlambdas=lambdas,gpord=c(1:FEMout$K),nameclass=c(1:FEMout$K),arrang=NULL,disp="quantiles",yrange=NULL,legcex=0.8,legwidth=NULL) {
  #mspsplit <- function(FEMout,spec=spectra,Xlambdas=lambdas,gpord=c(1:length(table(FEMout$cls))),arrang=NULL,yrange=NULL,legcex=0.8,legwidth=legcex) {
  #    if(length(FEMout$my)==0) specmeans <- FEMout$mean else specmeans <- FEMout$my #  if version==151 else version=14  
  #    K <- FEMout$K
  ynull <- F
  if (is.null(yrange)) ynull=T
  #if (is.null(arrang)) arrang <- c(ceiling(sqrt(length(gpord))),floor(sqrt(length(gpord))))  
  if (is.null(arrang)) {
    nK <- min(length(gpord),length(table(FEMout$cls)))
    is.wholenumber <- function(x, tol = .Machine$double.eps^0.5)  abs(x - round(x)) < tol
    if(is.wholenumber(sqrt(nK))) arrang <- c(sqrt(nK),sqrt(nK)) else {
      a <- ceiling(sqrt(nK))
      arrang <- c(a,ceiling(nK/a))
    }
    # {
    # cof <- function(a,K) a*a+a-K
    # tmp <- function(a,K) min(a[which(min(cof(a,K)) & cof(a,K)>=0)])
    # 
    # arrang <- c(tmp(1:nK,nK)+1,tmp(1:nK,nK))      }
  }
  
  library(FisherEM)
  library(scales) # pour la fonction alpha() de la transparence
  #  op <- par(mfrow=arrang,mar=c(3,3,1,1),mgp=c(1.5,0.5,0),oma=c(3,0,2,0)) # ou mar=c(3,3,0.5,0.5),mgp=c(1.5,0,0)
  op <- par(mfrow=arrang,mar=c(0,0,0,0),mgp=c(1.5,0.5,0),oma=c(5,4,1,1),cex=1)
  j <- 0
  for (icls in gpord) {
    i <- which(as.numeric(names(table(FEMout$cls)))==icls) ; if (length(i)==0) {next}
    #    cof <- cbind(Xlambdas,specmeans[icls,])
    #    colnames(cof) = c("lambda","flux")
    #      plot(cof,type="l",ylim=yrange)    
    if (table(FEMout$cls)[i] != 1) { # pour éliminer les groupes avec un seul objet
      cof1 <- as.matrix(spec)[which(FEMout$cls==icls),]
      realmeans <- cbind(Xlambdas,colMeans(cof1))
      colnames(realmeans) = c("lambda","flux")
      #realmedian <-  cbind(Xlambdas,apply(cof1,2,median))
      if (disp == "quantiles") {
        stdmin <- cbind(Xlambdas,apply(cof1,2,function(x) quantile(x,probs=0.1)))
        stdmax <- cbind(Xlambdas,apply(cof1,2,function(x) quantile(x,probs=0.9))) 
      }
      if (disp == "std") {
        cof1std <- cbind(Xlambdas,apply(cof1,2,sd)) 
        cof <- realmeans
        stdmin <- cof ; stdmin[,2] <- cof[,2]-cof1std[,2]
        stdmax <- cof ; stdmax[,2] <- cof[,2]+cof1std[,2]
      }
      colnames(stdmin) = c("lambda","flux")
      colnames(stdmax) = c("lambda","flux")
      if (ynull) yrange=c(min(stdmin[,2]),max(stdmax[,2]))
      #      plot(cof,type="l",ylim=yrange)    
      #      plot(cof,type="l",ylim=yrange,xlab="",ylab="",axes=F)   
      plot(realmeans,type="l",ylim=yrange,xlab="",ylab="",axes=F)   
      #      lines(realmedian,col="blue")
      #      lines(realmeans,col="red")
      lines(stdmin,col=alpha("gray",0.6)) 
      lines(stdmax,col=alpha("gray",0.6)) 
      #title(main=paste0("Group ",i))
      #      if (is.null(legwidth)) legwidth=min(1,2000/strwidth("Class N  N=100000 "))
      #      if (disp == "quantiles") {legend("topleft",legend=c(paste("Class",nameclass[j+1],"  N=",table(FEMout$cls)[i])),col="black",lty=1,bty="n",cex=legwidth) }
      #      if (disp == "std") {legend("topleft",legend=c(paste("Class",nameclass[j+1],"  N=",table(FEMout$cls)[i]),"Standard deviation"),col=c("black",alpha("gray",0.6)),lty=1,bty="n",cex=legwidth) }
      title(main=paste(nameclass[j+1],"  N=",table(FEMout$cls)[i]),line=-0.5,cex.main=legcex*1.2)
      polygon(c(Xlambdas,rev(Xlambdas)),c(stdmax[,2],rev(stdmin[,2])),col=alpha("gray",0.3),border=NA,ylim=c(0.3,2))
    }
    if (table(FEMout$cls)[i] == 1) {     
      cof <- cbind(Xlambdas,spec[which(FEMout$cls==icls),])
      colnames(cof) = c("lambda","flux")
      
      #     plot(cof,type="l",ylim=yrange)   
      plot(cof,type="l",ylim=yrange,xlab="",ylab="",axes=F)   
      #      if (is.null(legwidth)) legwidth=min(1,2000/strwidth("mean Class N  N=100000 "))
      #      if (is.null(legwidth)) legwidth=min(1,2000/strwidth(" Class N  N=100000 "))
      #      legend("topleft",legend=paste("mean Class",nameclass[j+1],"  N=",table(FEMout$cls)[i]),col="black",lty=1,bty="n",cex=legwidth)
      title(main=paste(nameclass[j+1],"  N=",table(FEMout$cls)[i]),line=-0.5,cex.main=legcex*1.2)
    }
    box(which = "plot", bty = "o") 

    if (j +1 > length(gpord)-arrang[2]) axis(side = 1, cex.axis = legcex, las = 2)
    if (j%%arrang[2] == 0) axis(side = 2, cex.axis = legcex, las = 2)

    j <- j+1
  }
  par(op)
}




# code pour extraire toutes les classification et en particulier la meilleure (DBk 15)
#results <- extract_all_rdata_rds("results/")
#results_fem_only <- Filter(function(x) class(x) == "fem", results)
#result <- results_fem_only[[35]]
#on peut génerer le mspsplit de cette classification en executant ce qui suit sur result 
#au lieu de la faire pour chaque sous classe ( exemple : l'image mise dans le README)

# Dossier racine
base_path <- "1068/sous_classif/"

# Charger les spectres et lambda
load("Data/lambdasbin.RData")
#load("Data/sppart4567fwbnnCZ.RData")  

# Boucle sur les 15 classes
for (i in 1:15) {
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
  result <- results_extract[[best_idx]]


  #  Affichage
  load(paste0("Data/class_", i, "DBk_15.Rdata"))
  class <- get(paste0("class", i))
  
  pdf(paste0("PDFs/class_", i, ".pdf"))
  mspsplit_paper(result, spec = class, Xlambdas = lambdasbin, yrange=c(0,2e+07))
  dev.off()
}
quit(save="no")


# Code pour extraire les classes de l'optimum de la premiere classification (DBK 15)
#load("Data/class_2DBk_15.Rdata")
#load("Data/sppart4567fwbnnCZ.RData")
#for (i in 1:15) {
  #class <- paste0("class",i)
  #spectra_class <- sppart4567fwbnnCZ[which(result$cls == i), ]
  #assign(class,spectra_class)
  #save(list = class, file = paste0("Data/class_", i, "DBk_15.Rdata"))
#}
