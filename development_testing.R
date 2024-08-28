library(devtools)
devtools::check()
devtools::load_all()

sample_dem <- terra::rast(file.path('F:', 'LANDIS_Input_Data_Prep', 'Data', 'DEM_90m_OkaMet.tif'))
sample_dem <- terra::rast(file.path('F:', 'LANDIS_Input_Data_Prep', 'Data', 'DEM_90m_WenEnt.tif'))
sample_dem <- terra::rast(file.path('F:', 'LANDIS_Input_Data_Prep', 'Data', 'DEM_90m_Tripod.tif'))
terra::plot(sample_dem)
render_terrain(sample_dem)

terra::plot(worldbuildeR::add_noise(sample_dem))

terra::plot(generate_perlin_noise(sample_dem, frequency=0.005))

terra::plot(generate_fractal_noise(sample_dem, fractal = 'rigid-multi', lacunarity = 1.9, octaves=7, gain=2))

test <- generate_perlin_noise(sample_dem, frequency=0.005)
terra::plot(test)
test <- rescale_heightmap(test)
#terra::plot(test)
render_terrain(test)
render_terrain(add_noise(test))

test2 <- generate_fractal_noise(sample_dem, fractal = 'rigid-multi', frequency=0.001, lacunarity = 1.9, octaves=7, gain=2)
#terra::plot(test2, col=topo_lookup)
test2 <- rescale_heightmap(test2, 5000, -5000)
terra::plot(test2)
render_terrain(test2, flat_water = T)
render_terrain(pinch(test2, w=5), flat_water = T)

test3 <- thermal_erode(test, iterations = 20)
render_terrain(test3)

test4 <- rainfall_erode(test)
render_terrain(test4)

test5 <- rainfall_erode(add_noise(test2), precipitons=5000)
test5 <- rainfall_erode(test5, frac = 0.5, precipitons = 5000)
render_terrain(test5)

start <- Sys.time()
#.flow_downhill(r, terra::focalValues(.cellrast(r)), 222222)
idk <- rainfall_erode(test2, precipitons=2000)
print(Sys.time()-start)

start <- Sys.time()
.flow_downhill2(r, terra::focalValues(.cellrast(r)), 222222)
print(Sys.time()-start)


