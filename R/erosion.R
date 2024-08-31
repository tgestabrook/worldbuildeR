#' @export
thermal_erode <- function(r, talus_angle=40, relax=0.25, iterations=1){  # https://www.fractal-landscapes.co.uk/maths.html
  talus <- tanpi(talus_angle/180)  # degrees
  dxy_card <- mean(terra::res(r))
  dxy_diag <- dxy_card*1.414214
  if(iterations>1){pb <- utils::txtProgressBar(min = 0, max = iterations, style=3)}
  for (i in 1:iterations){
    # we filter out uphill slopes, then we get the sum of the gradients (rise over run) in each direction
    sum_of_downhill <- terra::focal(r, w=3,
                           fun=function(x, ...) sum(ifelse(x<x[5], x[5]-x, 0)/c(dxy_diag, dxy_card, dxy_diag, dxy_card, 1, dxy_card, dxy_diag, dxy_card, dxy_diag), na.rm=T))

    dhdt <- terra::ifel(sum_of_downhill/2 > talus, (talus-sum_of_downhill/2)*relax*dxy_card, 0)
    r <- r + dhdt
    if(iterations>1){utils::setTxtProgressBar(pb, i)}
  }


  return(r + dhdt)
}


.cellrast <- function(r){
  df <- as.data.frame(r, xy=T, cells=T)
  df <- df[, c('x', 'y', 'cell')]

  return(terra::rast(df, type='xyz', crs=terra::crs(r), ext=terra::ext(r)))
}

.flow_downhill <- function(r, cellfocals, startcell){

  cell <- startcell
  flow_path <- c()

  focals <- terra::focalValues(r)
  #cellfocals <- terra::focalValues(.cellrast(r))

  outlet=T
  while(outlet==T){
    flow_path <- c(flow_path, cell)  # this will record the downslope path

    adjcells <- cellfocals[cell,]

    elev_window <- focals[cell,]

    if(min(elev_window, na.rm=T)==elev_window[5]|is.na(elev_window[5])){outlet<-F; break}  # if the cell is a local minimum, flow ends

    downhill_dir <- which.min(elev_window)
    cell <- adjcells[downhill_dir]
    #cat(paste('..', cell))
  }

  return(flow_path)
}

# .flow_downhill2 <- function(r, cellfocals, startcell){
#   flowdir <- terra::terrain(r, v='flowdir')
#   #flowdir <- terra::classify(flowdir, rcl=data.frame('from'=c(32, 64, 128, 16, 1, 8, 4, 2, 0), 'to'=c(1, 2, 3, 4, 6, 7, 8, 9, 5)))
#
#   #names(cellfocals) <- c('X32', 'X64', 'X128', 'X16', 'X0', 'X1', 'X8', 'X4', 'X2')
#   dirmap <- data.frame('from'=c(32, 64, 128, 16, 1, 8, 4, 2, 0), 'to'=c(1, 2, 3, 4, 6, 7, 8, 9, 5))
#
#   flow_path <- c()
#   cell <- startcell
#   while(T){
#     flow_path <- c(flow_path, cell)
#     downdir <- flowdir[cell][[1]]
#     if(downdir==0){break} else{
#       cell<-cellfocals[cell, dirmap[dirmap$from==downdir,'to']]
#       if(cell%in%flow_path){break}
#     }
#   }
#   return(flow_path)
# }

#' Erode with simulated rainfall agents
#'
#' This function iteratively
#'
#' @details
#' The precipiton erosion algorithm randomly drops a simulated agent on the landscape (optionally weighted, e.g. by annual rainfall).
#' The agent moves down the path of steepest slope, transferring `frac*(upslope_elevation - downslope_elevation)` from the upslope cell to the
#' downslope cell.
#'
#' This method of simulating erosion is unfortunately much slower than `worldbuildeR::incise_flow()`. However,
#' it has the advantage of producing somewhat more organic-looking results and
#' not requiring filled drainage basins to function correctly.
#'
#' Note that even if a `rainfall` raster is provided, the odds of dropping an agent over negative elevations will be set to zero.
#'
#' @param r `terra::SpatRaster` object containing a digital elevation model.
#' @param precipitons Integer. Number of agents to simulate.
#' @param frac Numeric, in (0,0.5].
#' @param rainfall `terra::SpatRaster` object containing relative precipitation weights, used to weight the random start locations of the precipiton agents.
#'
#' @export
rainfall_erode <- function(r, precipitons=as.integer(terra::ncell(r)/10), frac=0.33, rainfall=terra::rast(r, vals=1)){  # https://www.sciencedirect.com/science/article/pii/S0098300400001679

  if(frac<=0|frac>0.5){warn(message='frac<=0 or > 0.5 may produce anomalous results.')}

  rainfall <- terra::ifel(r<0, NA, rainfall)  # don't bother dropping precipitons on submerged land

  cellfocals <- terra::focalValues(.cellrast(r))
  precip_sites <- terra::spatSample(rainfall, precipitons, method='weights', replace=T, cells=T)
  #all_flow_paths <- c()

  pb <- utils::txtProgressBar(min = 0, max = precipitons, style=3)
  for (i in 1:precipitons){

    precip_site <- precip_sites[i, 'cell']
    #print(precip_site)
    flow_path <- .flow_downhill(r, cellfocals, precip_site)
    #all_flow_paths <- c(all_flow_paths, flow_path)
    path_length <- length(flow_path)
    if(path_length<3){next}

    elevations <- r[flow_path][,1]

    # sediment_moved <- frac * (elevations[1:(path_length-1)] - elevations[2:path_length])  # the fraction times the height difference between each cell
    #
    # elevations[1:(path_length-1)] <- elevations[1:(path_length-1)] - sediment_moved  # pull the amount from the upper slopes
    # elevations[2:path_length] <- elevations[2:path_length] + sediment_moved  # and add it to the lower slopes

    for(j in 2:path_length){
      sediment_moved <- frac*(elevations[j-1] - elevations[j])
      elevations[j-1] <- elevations[j-1] - sediment_moved
      elevations[j] <- elevations[j] + sediment_moved
    }

    r[flow_path] <- elevations

    utils::setTxtProgressBar(pb, i)
  }

  #pathvis <- terra::rast(r, vals=NA); pathvis[all_flow_paths] <- 1
  #render_terrain(r); terra::plot(pathvis, add=T)

  return(r)
}



#' Carve out drainage channels
#'
#' Lower terrain according to the logarithm of flow accumulation.
#'
#' @details
#' This algorithm is very fast and works to create passable rills and canyons. However, it is prone to generating straight lines in flat areas and abruptly terminating canyons in basins with no outlet.
#' Both issues can be ameliorated by running one or more iterations of `worldbuildeR::add_noise()` followed by a basin-filling algorithm such as `flowdem::fill()`.
#'
#'
#' @param r `terra::SpatRaster` object containing a digital elevation model.
#' @param log_base
#' @param threshold integer, minimum number of upstream cells required to gouge a channel
#' @param blur TRUE (default) or FALSE. Indicates whether the flow accumulation map should be blurred with a mean filter
#'
#' @export
incise_flow <- function(r, log_base=1.5, threshold=100, blur=T){
  flowacc <- terra::flowAccumulation(terra::terrain(r, v='flowdir'))
  flowacc[flowacc<threshold] <- 1

  if(blur==T){flowacc <- terra::focal(flowacc, w=3, 'mean')}

  incision <- log(flowacc, log_base)

  return(r-incision)
}









