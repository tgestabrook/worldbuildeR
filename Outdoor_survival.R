library(tidyverse)
library(terra)
library(tidyterra)
library(flowdem)
devtools::load_all()
library(worldbuildeR)

os.shp <- vect('../Personal/Grid1.gpkg')

base_rast <- rast(ext=ext(os.shp), resolution=100, crs=crs(os.shp), vals=0)
north_tilt <- base_rast %>% as.data.frame(xy = T) %>%
  mutate(z = 3000 - (y/2500)) %>%
  select(x, y, z) %>%
  rast(type='xyz', crs = crs(os.shp), ext = ext(os.shp))
plot(north_tilt)

river_hexes <- os.shp %>% filter(River == T|Terrain=='Wetland') %>%
  rasterize(base_rast)
plot(river_hexes)

dist_river <- river_hexes %>%
  gridDist(target = NA, scale=1000) %>% log()
dist_river <- ifel(!is.na(river_hexes)|dist_river<0, 0, dist_river) * 150
plot(dist_river)

dist_river_interior <- ifel(is.na(river_hexes), 1, 0) %>%
  gridDist(target = 1, scale = 1000) %>% log()
dist_river_interior <- ifel(is.na(river_hexes)|dist_river_interior<0, 0, -55 * dist_river_interior)
plot(dist_river_interior)

mountain_hexes <- os.shp %>% filter(Terrain=='Mountain') %>%
  rasterize(base_rast)

mountain_interior_dist <- ifel(is.na(mountain_hexes), 1, 0) %>%
  gridDist(target = 1, scale = 1000) %>% sqrt() %>%
  focal(w=11, fun='max')
mountain_interior_dist <- ifel(is.na(mountain_interior_dist)|mountain_interior_dist<0.25, 0.25, mountain_interior_dist) %>%
  focal(w=13, fun='mean', na.rm=T) %>%
  focal(w=13, fun='mean', na.rm=T)
plot(mountain_interior_dist)
mountain_noise <- generate_fractal_noise(base_rast, fractal = 'rigid-multi', frequency=0.013, lacunarity = 1.75, octaves=7, gain=2) %>% rescale_heightmap(max = 750, min = -100)
mountain_noise <- mountain_noise * (mountain_interior_dist)
render_terrain(mountain_noise)

soft_noise <- generate_perlin_noise(base_rast, frequency = 0.0015) %>% rescale_heightmap(max = 250, min = 0)
plot(soft_noise)
render_terrain(soft_noise)

base_topo <- ((north_tilt*4 - 1000) + dist_river + dist_river_interior + mountain_noise + soft_noise) %>%
  flowdem::fill() %>%
  add_noise(amount=15) %>%
  flowdem::fill()
plot(base_topo)
render_terrain(base_topo)

rainfall_map <- data.frame("Terrain" = c("Open",  "Desert", "Forest", "Mountain", "Wetland"),
                           "Rainfall" = c(1, 0.1, 1.5, 2, 3))

rainfall.r <- os.shp %>% left_join(rainfall_map) %>%
  rasterize(base_rast, "Rainfall", background = 1)

eroded <- base_topo %>%
  incise_flow(rainfall=rainfall.r)%>%
  flowdem::fill() %>%
  incise_flow(rainfall=rainfall.r) %>%
  add_noise(amount=15) %>%
  flowdem::fill() %>%
  incise_flow(rainfall=rainfall.r) %>%
  incise_flow(rainfall=rainfall.r)

render_terrain(eroded)

eroded <- rainfall_erode(eroded, precipitons = 1000, rainfall = rainfall.r)

writeRaster(eroded, '../Personal/outdoor_dem.tif', overwrite=T)

eroded <- rast('../Personal/outdoor_dem.tif')
flowacc <- log(flowAccumulation(terra::terrain(eroded %>% fill(), v='flowdir')))

writeRaster(flowacc, '../Personal/outdoor_flowacc.tif', overwrite=T)


