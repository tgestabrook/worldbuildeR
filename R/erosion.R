#' @export
thermal_erosion <- function(r, talus_angle=40, relax=0.25, iterations=1){  # https://www.fractal-landscapes.co.uk/maths.html
  talus <- tanpi(talus_angle/180)  # degrees
  dxy_card <- mean(terra::res(r))
  dxy_diag <- dxy_card*1.414214

  for (i in 1:iterations){
    # we filter out uphill slopes, then we get the sum of the gradients (rise over run) in each direction
    sum_of_downhill <- terra::focal(r, w=3,
                           fun=function(x, ...) sum(ifelse(x<x[5], x[5]-x, 0)/c(dxy_diag, dxy_card, dxy_diag, dxy_card, 1, dxy_card, dxy_diag, dxy_card, dxy_diag), na.rm=T))

    dhdt <- terra::ifel(sum_of_downhill/2 > talus, (talus-sum_of_downhill/2)*relax*dxy_card, 0)
    r <- r + dhdt
    print(paste('Iteration', i, 'complete.'))
  }


  return(r + dhdt)
}

#' @export
rainfall_erosion <- function(r, rainfall=terra::rast(r, vals=1)){  # https://www.sciencedirect.com/science/article/pii/S0098300400001679

}











