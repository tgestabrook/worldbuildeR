library(devtools)
devtools::check()
devtools::load_all()
library(flowdem)

sample_dem <- terra::rast(file.path('F:', 'LANDIS_Input_Data_Prep', 'Data', 'DEM_90m_OkaMet.tif'))
sample_dem <- terra::rast(file.path('F:', 'LANDIS_Input_Data_Prep', 'Data', 'DEM_90m_WenEnt.tif'))
sample_dem <- terra::rast(file.path('F:', 'LANDIS_Input_Data_Prep', 'Data', 'DEM_90m_Tripod.tif'))
terra::plot(sample_dem)
render_terrain(sample_dem, streams = 150)

test2 <- generate_fractal_noise(sample_dem, fractal = 'rigid-multi', frequency=0.004, lacunarity = 1.9, octaves=7, gain=2)
#terra::plot(test2, col=topo_lookup)
test2 <- rescale_heightmap(test2, 5000, -5000)
test2 <- add_noise(test2)
test2 <- fill(test2)
test2 <- add_noise(test2)
test2 <- fill(test2)
#terra::plot(test2)
render_terrain(test2, flat_water = T, streams = 150)
test2 <- incise_flow(test2)
test2 <- incise_flow(test2)
test2 <- incise_flow(test2)
test2 <- incise_flow(test2)
test2 <- incise_flow(test2)
render_terrain(test2, flat_water = T, streams = 150)
test2 <- rainfall_erode(test2, frac = 0.5, precipitons = 5000)

render_terrain(test2, streams = 200)

#test2 <- rainfall_erode(add_noise(test2), precipitons=5000)

start <- Sys.time()
#.flow_downhill(r, terra::focalValues(.cellrast(r)), 222222)
idk <- rainfall_erode(test2, precipitons=2000)
print(Sys.time()-start)

start <- Sys.time()
.flow_downhill2(r, terra::focalValues(.cellrast(r)), 222222)
print(Sys.time()-start)


test <- generate_perlin_noise(sample_dem)
test <- rescale_heightmap(test, 5000,-5000)
render_terrain(test)
test <- add_noise(test, amount=30)
test <- fill(test)
test <- incise_flow(test)
render_terrain(test)
test <- pinch(test)
test <- rainfall_erode(test)

test4 <- incise_flow(sample_dem)
test4 <- incise_flow(test4)
render_terrain(test4)
