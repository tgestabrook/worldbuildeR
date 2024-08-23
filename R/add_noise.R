#' @export
add_percent_noise <- function(r, pct){
  # get range
  range <- ceiling((max(terra::values(r, na.rm=T))-min(terra::values(r, na.rm=T)))*(pct/100))

  noise_rast <- terra::rast(r, vals=0)
  sample_count <- length(terra::values(noise_rast))
  terra::values(noise_rast) <- sample(1:range, sample_count, replace=T)

  return(r+noise_rast)
}

#' @export
add_absolute_noise <- function(r, noise){
  noise_rast <- terra::rast(r, vals=0)
  sample_count <- length(terra::values(noise_rast))
  terra::values(noise_rast) <- sample(1:ceiling(noise), sample_count, replace=T)

  return(r+noise_rast)
}







