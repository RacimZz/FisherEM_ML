#!/bin/bash
source /soft/env.bash
module load R
R CMD BATCH R/[fichier].R R/[fichier].Rout
