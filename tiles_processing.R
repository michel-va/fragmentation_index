#
library(raster)
library(sf)
library(sp)
library(raster)
library(dplyr)
library(lubridate)
library(ggplot2)
library(tidyr)
library(landscapemetrics)
library(rgeos)

################################################################################
################# Using one of the files as an input ########################### 
################################################################################

# The idea of this R project is to allow you to use array job for processing 
# multiples tiles in parrallel before fixing them 

# The current script have been written to use with a cluster using a PBS
# resources managers, this part might depend on the cluster resources manager
# use by your institution 

#jobID<-Sys.getenv("PBS_ARRAY_INDEX")



# We will process the tiles number 5 
jobID<-'5'


name_input<-paste0("tilled_raster/input_tile",jobID)
name_input<-paste(name_input,"tif",sep=".")

# Create the name of the output 
name_output<-paste0("output/output",jobID)
name_output<-paste(name_output_ed,"tif",sep=".")




################################################################################
###################### Processing of the files #################################


### load the data 
lu<-raster(name_input)


# The landscapemetrics need to use a crs with projected coordinate in meters, 
# Here we use an UTM projection for Brazil but you might need to change to a 
# projected system adapted to your study area 

proj<-"+proj=aea +lat_1=-5 +lat_2=-42 +lat_0=-32 +lon_0=-60 +x_0=0 +
  y_0=0 +ellps=aust_SA +units=m +no_defs"


lu2<-projectRaster(lu,crs=proj,method="ngb",progress="text")


# Determine the size of the pixels we want for our final raster 
res=10000


# Check if we have the land use of interest in our tiles, in our case we are 
# looking at the forest, represented by the code 4 in our input files 

if(4 %in% unique(lu2)){
  print ("we can go!")
}else{
  setValues(lu2,0)
  a<-2500/res(lu2)[[1]]
  lu2<-raster::aggregate(lu2,fact=a)
  writeRaster(lu2,name_output)
  print("no land use of interest there")
  stop()
}



#### Reclassification of the raster 
# We want to reclass our raster to avoid having too much categories and 
# make the ocmputation faster. I'll reclass only the land use of interest as 1,
# and all other land use as 2

reclass_df <- c(0, 0,
                3,1,
                4,2,
                5,2,
                9,2,
                11,2,
                12,2,
                14,2,
                15,2,
                19,2,
                20,2,
                21,2,
                22,2,
                23,2,
                24,2,
                25,2,
                26,2,
                27,2,
                29,2,
                30,2,
                31,2,
                32,2,
                33,2,
                36,2,
                39,2,
                40,2,
                41,2,
                47,2,
                48,2,
                49,2)

reclass_m <- matrix(reclass_df,
                    ncol = 2,
                    byrow = TRUE)

lu_classified<- reclassify(lu2, reclass_m)
plot(lu_classified)


### Create a gridpoint that the landscapemetrics will use 
a<-res/res(lu2)[[1]]

raster_template<-raster::aggregate(lu_classified,fact=a)
#pixels<-raster::crop(pixels,lu_classified)
pixels_output <- as(raster_template,'SpatialPixelsDataFrame')


#Extract the landscape metric of interest and insert in a new table  
v_ai<-sample_lsm(lu_classified,pixels_output,shape="square",what="lsm_c_ed",size=5000,progress = TRUE)
v_ai<-subset(v_ai,class==1)

# Use the value return by sample_lsm to our pixel dataframe
pixels_output@grid.index<-1:nrow(pixels_output)
for (i in 1:length(pixels_output)){
  
  if (any(v_ai$plot_id==pixels_output@grid.index[[i]])){
    pixels_output$layer[[i]]<-as.numeric(v_ai[v_ai$plot_id==i,6])
  }
  
  else{
    pixels_output$layer[[i]]<-NA
  }
}



#### Transform pixels dataframe into a raster  
pixels_output<-st_as_sf(pixels_output)
pixels_output$layer<-as.numeric(pixels_output$layer)
raster_ed<-rasterize(pixels_output,raster_template,field="layer",fun=mean)


#### check the output and save it
plot(raster_ed)
writeRaster(raster_ed,name_output,overwrite=TRUE)
