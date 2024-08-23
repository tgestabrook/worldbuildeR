devtools::check()
devtools::load_all()

sample_dem <- terra::rast(file.path('F:', 'LANDIS_Input_Data_Prep', 'Data', 'DEM_90m_OkaMet.tif'))
terra::plot(sample_dem)

terra::plot(worldbuildeR::add_percent_noise(sample_dem, 10))

terra::plot(generate_perlin_noise(sample_dem, frequency=0.005))

terra::plot(generate_fractal_noise(sample_dem, fractal = 'rigid-multi', lacunarity = 1.9, octaves=7, gain=2))

test <- generate_perlin_noise(sample_dem, frequency=0.005)
terra::plot(test)
terra::plot(rescale_heightmap(test))


