# fragmentation_index

## Introduction 
Calculate fragmentation index over large areas/fine-scale raster can prove challenging due to memory constraints. One way to deal with this is to cut the raster into multiples tiles, process them in parrallel on a cluster and merge the results into a final raster. This repository aim to provide you the different scripts and folder structure required to go from a land use map to a map with one of the aggregation index compute by the landscapemetrics packages. 


## Worklow 
starting from the input file, you'll need to: 
  + use the tiling.R script to split your raster into several tiles, saved in the tilled_raster packages
  + run in parrallel the tiles_processing.R script on all of your tiles to save the output into the tiles_fragmentation folder 
  + run the merging.R script to merge all of your raster into a final output 

## Caution 
There is a couple of point than can prove tricky when calculating these index: 
 + be carefull about the projection system, it need to have meters as units and to be a projected coordinate system 
 + Even cut in tiles, the processing of one raster to derive fragmentation index is time consuming 

## Aknowledgement 
This script have been developed based on landscapemetrics package. 
