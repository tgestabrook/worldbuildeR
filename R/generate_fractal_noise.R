
#' @export
generate_perlin_noise <- function(r, frequency=0.005){

  noise <- ambient::noise_perlin(c(terra::nrow(r), terra::ncol(r)), frequency=frequency, fractal='none')
  return(terra::rast(noise, crs=terra::crs(r), ext=terra::ext(r)))
}


generate_fractal_noise <- function(r, frequency=0.005, fractal='fbm', octaves=4, lacunarity=2, gain=0.5, pertubation='none', pertubation_amplitude=1){
  noise <- ambient::noise_perlin(c(terra::nrow(r), terra::ncol(r)), frequency=frequency, fractal=fractal, octaves=octaves, lacunarity=lacunarity, gain=gain, pertubation=pertubation, pertubation_amplitude=pertubation_amplitude)
  return(terra::rast(noise, crs=terra::crs(r), ext=terra::ext(r)))
}
