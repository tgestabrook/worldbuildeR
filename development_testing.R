devtools::load_all()

sample_dem <- terra::rast(file.path('F:', 'LANDIS_Input_Data_Prep', 'Data', 'DEM_90m_OkaMet.tif'))
terra::plot(sample_dem)

terra::plot(worldbuildeR::add_percent_noise(sample_dem, 10))
