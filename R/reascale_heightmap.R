#' @export
rescale_heightmap <- function(r, max=5000, min=-5000){
  vals <- terra::values(r)
  inmax <- max(vals)
  inmin <- min(vals)

  r_out <- terra::as.int((r-inmin)/(inmax-inmin)*(max-min)+min)

  return(r_out)
}
