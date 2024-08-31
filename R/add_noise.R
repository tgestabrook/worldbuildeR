#' @export
add_noise <- function(r, type='absolute', amount=terra::res(r)[1]/2){

  if(type=='absolute'){
    noise_rast <- terra::rast(r, vals=0)
    sample_count <- length(terra::values(noise_rast))
    terra::values(noise_rast) <- sample((-1*ceiling(amount)):ceiling(amount), sample_count, replace=T)

    return(r+noise_rast)
  } else if (type=='percent'){
    range <- ceiling((max(terra::values(r, na.rm=T))-min(terra::values(r, na.rm=T)))*(amount/100))

    noise_rast <- terra::rast(r, vals=0)
    sample_count <- length(terra::values(noise_rast))
    terra::values(noise_rast) <- sample((-1*range:range), sample_count, replace=T)

    return(r+noise_rast)
  } else {
    stop("'type' must be 'absolute' or 'percent'.")
  }
}








