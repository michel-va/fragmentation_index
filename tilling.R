### Library 
library(raster)
library(SpaDES)

###
lu<-raster("input.tif")
splitRaster(lu,3,3,buffer=0.05,fExt=".tif",path="tilled_raster")

# The second and third argument indicate how many time you want to divide the 
# raster horizontally and vertically 



