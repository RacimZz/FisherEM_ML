##Imports

library(gdata, include.only = "mv")
library(FisherEM)
library(parallel)

##Input

#find back the args
args = commandArgs(trailingOnly=TRUE)

#path args
data_pretreated_path = args[[1]]

#Kborder
Kborder_1 = as.numeric(args[[2]])
Kborder_2 = as.numeric(args[[3]])

#save_path
save_path= args[[4]]

#DLM model
Model= args[[5]]
compt=5

while(compt!=length(args)){
  compt = compt+1
  Model = c(Model,args[[compt]])
}


#Method

Method='svd'

Kborder_init=c(as.numeric(Kborder_1), as.numeric(Kborder_2))

# Chargement automatique selon l'extension
if (grepl("\\.RData$", data_pretreated_path)) {
  obj_name <- load(data_pretreated_path)        # Charge le .RData et renvoie le nom de l’objet
  flux_pretreated_df <- get(obj_name)           # Récupère l’objet chargé
} else {
  flux_pretreated_df <- readRDS(data_pretreated_path)  # Lecture normale d’un .rds
}

flux_pretreated_df <- flux_pretreated_df[,-1]    # Suppression de la première colonne si nécessaire
flux_pretreated_mat <- as.matrix(flux_pretreated_df)




##Functions

fem_exe <- function(data, K, Model, Method, repetition=1, compt_repet=0){
  tryCatch(
    {
    print(paste0("start repetition number ", as.character(compt_repet)))
    print(paste0("start fem command with : ", as.character(length(data)), " ", as.character(K), " ", as.character(Model), " ", as.character(Method)))
    result = fem(data, K=K, model=Model, method=Method, nstart=25, init='random', maxit=25, mc.cores = 1)
    
    return(result)
    },
    error=function(e){
      message(paste0('An error occurred in fem_exe for '), as.character(Model))
      compt_repet = compt_repet +1
      if (compt_repet < repetition){
        fem_exe(data, K, Model, Method, repetition, compt_repet)
      }
      print(e)
      return(0)
    },
    warning=function(w){
      print('A Warning Occurred')
      compt_repet = compt_repet +1
      if (compt_repet < repetition){
        fem_exe(data, K, Model, Method, repetition, compt_repet)
      }
      print(w)
      return(0)
    }
  )
}

automatic_fem_max <- function(data, Kborder, Model, Method, repetition=1){
  #Param init
  max_reached <- 0 #param to know when the optimum has been reached
  error_min <- 0 #param to know if the min classification has failed
  error_max <- 0 #param to know if the max classification has failed
  next_fem <- 0 #param to know which is the next border to classify
  while (max_reached==0){
    print(paste0("Kborder ", Kborder))
    print(paste0("Kborder[1] ", Kborder[1]))
    print(paste0("Kborder[[1]] ", Kborder[[1]]))
    print(paste0("length(data)", length(data)))
    
    #Try executing fem on the min border and change the error min value if there is a problem
    if((next_fem==1) | (next_fem==0)){
    res_min <- fem_exe(data, K=Kborder[[1]], Model=Model, Method=Method, repetition = repetition)
    saveRDS(res_min, paste0(save_path,'AutomaticFem',Model,'K',Kborder[[1]],'.RDS'))
    print("res_min")
    print(res_min)
    }
    if (is.numeric(res_min)==TRUE) {
      error_min <- 1
    }
    else {
      error_min <- 0
    }
    
    
    #Try executing fem on the min border and change the error min value if there is a problem
    if((next_fem==2) | (next_fem==0)){
    res_max <- fem_exe(data, K=Kborder[[2]], Model=Model, Method=Method, repetition = repetition)
    saveRDS(res_max, paste0(save_path,'AutomaticFem',Model,'K',Kborder[[2]],'.RDS'))
    print("res_max")
    print(res_max)
    }
    
    if (is.numeric(res_max)==TRUE) {
      error_max <- 1
    }
    else {
      error_max <- 0
    }
    
    print("error_max")
    print(error_max)
    print("error_min")
    print(error_min)
    
    if (error_min == 0){
      if (error_max == 0){
        print(res_max[["critValue"]])
        print(res_min[["critValue"]])
        if (Kborder[[2]]-Kborder[[1]]<2) {
          print("max reached !")
          print("Kborder[[1]]")
          print(Kborder[[1]])
          print("Kborder[[2]]")
          print(Kborder[[2]])
          max_reached <- 1
          print("start return")
          return(res_final)
        }
        if (res_max[["critValue"]]>res_min[["critValue"]] ){
          Kborder[[1]] <- as.integer(Kborder[[1]]+((Kborder[[2]]-Kborder[[1]])/2))
          next_fem <- 1
          res_final <- res_max
        }
        else{
          Kborder[[2]] <- as.integer((Kborder[[2]]-Kborder[[1]])/2)
          next_fem <- 2
          res_final <- res_min
        }  
      }
      else{
        if (Kborder[[2]]-Kborder[[1]]<2) {
        print("max reached !")
        print("Kborder[[1]]")
        print(Kborder[[1]])
        print("Kborder[[2]]")
        print(Kborder[[2]])
        max_reached <- 1
        print("start return")
        return(res_final)
        }
        else {
          Kborder[[2]] <- Kborder[[2]]-1
          next_fem <- 2
          res_final <- res_min
        }  
      }
      
    }
    else {
      if (Kborder[[2]]-Kborder[[1]]<2) {
        print("max reached !")
        print("Kborder[[1]]")
        print(Kborder[[1]])
        print("Kborder[[2]]")
        print(Kborder[[2]])
        max_reached <- 1
        print("start return")
        return(res_final)
      }
      if (error_max == 0){
        Kborder[[1]] <-  Kborder[[1]]+1
        next_fem <- 1
        res_final <- res_max
      }
      else{
        if (Kborder[[2]]-Kborder[[1]]<2) {
          print("max reached !")
          print("Kborder[[1]]")
          print(Kborder[[1]])
          print("Kborder[[2]]")
          print(Kborder[[2]])
          max_reached <- 1
          print("start return")
          return(res_final)
        }
        Kborder[[1]] <- Kborder[[1]]+1
        Kborder[[2]] <- Kborder[[2]]-1
        next_fem <- 0
      }
    }
    
    
  }
}


automatic_fem_Process_1Model <- function(DataList){

  print(as.character(length(DataList)))
  print(paste0("start to automatically find the optimum for ", DataList[[3]]))
  print(paste0("length(DataList[1])", as.character(length(DataList[[1]]))))
  print(paste0("Kborder",  DataList[[2]]))
  print(paste0("method", DataList[[4]]))
  print(paste0("AutomaticFem", as.character(DataList[[3]]), as.character(DataList[[2]][1]), as.character(DataList[[2]][2])))
  print(paste0("automatic fem model ", as.character(DataList[[3]]), " will start"))
  print(paste0("test of string : save of ", as.character(DataList[[3]]), "completed"))
  
  res_final <- automatic_fem_max(DataList[[1]], DataList[[2]], DataList[[3]], DataList[[4]])
  print("start mv")
  mv(from= "res_final", to = paste0("AutomaticFem", as.character(DataList[[3]]), as.character(DataList[[2]][1]), as.character(DataList[[2]][2])))
  print(paste0("automatic fem model ", as.character(DataList[[3]]), " ended"))
  save_path_res_final= paste0(save_path, "AutomaticFem", DataList[[3]], as.character(DataList[[2]][1]), as.character(DataList[[2]][2]), ".RData")
  print("try get")
  get(paste0("AutomaticFem", as.character(DataList[[3]]), as.character(DataList[[2]][1]), as.character(DataList[[2]][2])))
  print(paste0("start save at ", save_path_res_final))
  saveRDS(get(paste0("AutomaticFem", as.character(DataList[[3]]), as.character(DataList[[2]][1]), as.character(DataList[[2]][2]))), file=save_path_res_final)
  print(paste0("save of ", as.character(DataList[[3]]), "completed"))
  return(0)
}

##Code Execution

nb_model = length(Model)
compt_model=0

ListOfDataList = list()

print(paste0("length flux_pretreated_mat ", length(flux_pretreated_mat)))

while(compt_model<nb_model){
  print(paste0("model ",as.character(compt_model+1),"out of ", as.character(nb_model)))
  if (compt_model==0){
    list_model = list(flux_pretreated_mat, Kborder_init, Model[compt_model+1], Method)
    list_model_0 <- list_model
    compt_model = compt_model + 1
  }
  else {
    list_model = list(flux_pretreated_mat, Kborder_init, Model[compt_model+1], Method)
    mv(from = "list_model", to =paste0("list_model_",as.character(compt_model)))
    print(paste0("saved list_model into ", paste0("list_model_",as.character(nb_model) )))
    compt_model = compt_model + 1
  }
  
}

if(nb_model==1){
  ListOfDataList = list(list_model_0)
}

if(nb_model==2){
  ListOfDataList = list(list_model_0, list_model_1)
}

if(nb_model==3){
  ListOfDataList = list(list_model_0, list_model_1, list_model_2)
}

if(nb_model==4){
  ListOfDataList = list(list_model_0, list_model_1, list_model_2, list_model_3)
}

if(nb_model==5){
  ListOfDataList = list(list_model_0,  list_model_1, list_model_2, list_model_3, list_model_4)
}

if(nb_model==6){
  ListOfDataList = list(list_model_0, list_model_1, list_model_2, list_model_3, list_model_4, list_model_5)
}

if(nb_model==7){
  ListOfDataList = list(list_model_0, list_model_1, list_model_2, list_model_3, list_model_4, list_model_5, list_model_6)
}

if(nb_model==8){
  ListOfDataList = list(list_model_0, list_model_1, list_model_2, list_model_3, list_model_4, list_model_5, list_model_6, list_model_7)
}

if(nb_model==9){
  ListOfDataList = list(list_model_0, list_model_1, list_model_2, list_model_3, list_model_4, list_model_5, list_model_6, list_model_7, list_model_8)
}

if(nb_model==10){
  ListOfDataList = list(list_model_0, list_model_1, list_model_2, list_model_3, list_model_4, list_model_5, list_model_6, list_model_7, list_model_8, list_model_9)
}

if(nb_model==11){
  ListOfDataList = list(list_model_0, list_model_1, list_model_2, list_model_3, list_model_4, list_model_5, list_model_6, list_model_7, list_model_8, list_model_9, list_model_10)
}

if(nb_model==12){
  ListOfDataList = list(list_model_0, list_model_1, list_model_2, list_model_3, list_model_4, list_model_5, list_model_6, list_model_7, list_model_8, list_model_9, list_model_10, list_model_11)
}

print(paste0("Model is ", as.character(Model)))
print(paste0("length of ListOfDataList is ", as.character(length(ListOfDataList))))

AllResults <- mclapply(ListOfDataList, automatic_fem_Process_1Model, mc.cores=nb_model, mc.preschedule = FALSE, mc.cleanup = FALSE)


#plot(res_final)

