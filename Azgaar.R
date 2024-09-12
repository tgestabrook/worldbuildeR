library(tidyverse)
library(terra)
library(tidyterra)
library(flowdem)
library(worldbuildeR)


Azgaar_data <- terra::vect(file.path('test_data', 'Azgaar_cells.geojson'))
terra::plot(Azgaar_data, 'height')


Azgaar_data_clean <- Azgaar_data %>%
  mutate(height_m = as.integer(height*0.3048)) %>%  # convert from ft to m
  filter(biome!=11) %>%  # eliminate ice
  project('EPSG:3857')

template <- rast(ext=ext(Azgaar_data_clean), resolution=500, crs=crs(Azgaar_data_clean), vals=0)
Azgaar.r <- terra::rasterize(Azgaar_data_clean, template, field='height_m')
render_terrain(Azgaar.r)

Rivers.r <- vect(file.path('test_data', 'Azgaar_rivers.geojson')) %>%
  project('EPSG:3857') %>%
  rasterize(template, background=0) %>%
  focal(., w=7, fun='mean')

plot(Rivers.r)

Azgaar.r <- Azgaar.r - (50*Rivers.r)


Azgaar.r <- ifel(Azgaar.r < 0, Azgaar.r-200, Azgaar.r)

Azgaar_eroded.r <- add_noise(Azgaar.r, type='absolute', amount=10)
render_terrain(Azgaar_eroded.r)

Azgaar_eroded.r <- flowdem::fill(Azgaar_eroded.r)
Azgaar_eroded.r <- incise_flow(Azgaar_eroded.r)
Azgaar_eroded.r <- incise_flow(Azgaar_eroded.r)
Azgaar_eroded.r <- incise_flow(Azgaar_eroded.r)
render_terrain(Azgaar_eroded.r)


Azgaar_eroded.r <- rainfall_erode(Azgaar_eroded.r, precipitons = 20000)
Azgaar_eroded.r <- rainfall_erode(Azgaar_eroded.r)
Azgaar_eroded.r <- rainfall_erode(Azgaar_eroded.r)


writeRaster(Azgaar_eroded.r, file.path('test_data', 'eroded.tif'), overwrite=T)















