library(magick)

# Chemin des fichiers PDF
files <- paste0("PDFs/sous_classif/class_", 1:15, ".pdf")

# Convertir chaque PDF en image et ajouter un titre
imgs <- lapply(seq_along(files), function(i) {
  img <- image_read_pdf(files[i], density = 150)[1]              # Lire la première page
  img <- image_flatten(img)                                      
  
  # Créer une étiquette (titre "Classe i")
  title <- image_blank(width = image_info(img)$width, height = 50, color = "white")
  title <- image_annotate(title, paste("Classe", i), color = "black",
                          size = 30, gravity = "center", weight = 700)
  
  # Empiler le titre au-dessus de l'image
  image_append(c(title, img), stack = TRUE)
})

# Créer la grille 5x3
img_montage <- image_montage(image_join(imgs), tile = "5x3", geometry = "x0+10+10", shadow = FALSE)

# Sauvegarder en PDF
image_write(img_montage, path = "sous_classification_finale.pdf", format = "pdf")
