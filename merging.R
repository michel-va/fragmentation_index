### Merging 

library(raster)
library(SpaDES)
library(stringr)
library(sf)
library(tmap)
library(meteo)

### Create a list of raster 


current.list <- list.files(path="output", 
                           pattern =".tif")


current.list<-paste('output',current.list,sep="/")
current.list<-str_subset(current.list,pattern = 'tif.aux.xml',negate=TRUE)
current.list<-str_sort(current.list, numeric = TRUE)

list_raster<-list()

for (i in 1:length(current.list)){
  list_raster[[i]]<-raster(current.list[[i]])
  print(i)
}



for (i in 1:length(current.list)){
  rast_temp<-raster(current.list[[i]])
  if (is.na(unique(values(rast_temp)))==TRUE&
      length(unique(values(rast_temp)))==1){
    print("no")
  }else{
  print('yes')
}}



ibis=1
for (i in 1:length(current.list)){
  rast_temp<-raster(current.list[[i]])
  val<-unique(values(rast_temp))
  
  if (is.na(val)==TRUE&
      length(val)==1){
    print("no")
  }else{
    list_raster[ibis]<-rast_temp
    ibis=ibis+1
  }}




list_raster$tolerance<-3

m0<-do.call(raster::merge,list_raster)


tm_shape(m0)+
  tm_raster(palette="YlOrRd",style="cont")+
  tm_layout(main.title="Edges density",legend.show = F)


m0<-writeRaster(m0,"fragmentation_index.tif")



