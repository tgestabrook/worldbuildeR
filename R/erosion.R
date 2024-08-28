#' @export
thermal_erode <- function(r, talus_angle=40, relax=0.25, iterations=1){  # https://www.fractal-landscapes.co.uk/maths.html
  talus <- tanpi(talus_angle/180)  # degrees
  dxy_card <- mean(terra::res(r))
  dxy_diag <- dxy_card*1.414214
  if(iterations>1){pb <- txtProgressBar(min = 0, max = iterations, style=3)}
  for (i in 1:iterations){
    # we filter out uphill slopes, then we get the sum of the gradients (rise over run) in each direction
    sum_of_downhill <- terra::focal(r, w=3,
                           fun=function(x, ...) sum(ifelse(x<x[5], x[5]-x, 0)/c(dxy_diag, dxy_card, dxy_diag, dxy_card, 1, dxy_card, dxy_diag, dxy_card, dxy_diag), na.rm=T))

    dhdt <- terra::ifel(sum_of_downhill/2 > talus, (talus-sum_of_downhill/2)*relax*dxy_card, 0)
    r <- r + dhdt
    if(iterations>1){setTxtProgressBar(pb, i)}
  }


  return(r + dhdt)
}


.cellrast <- function(r){
  df <- as.data.frame(r, xy=T, cells=T)
  df <- df[, c('x', 'y', 'cell')]

  return(terra::rast(df, type='xyz', crs=terra::crs(r), ext=terra::ext(r)))
}

.flow_downhill <- function(r, r_cells, startcell){

  cell <- startcell
  flow_path <- c()

  focals <- terra::focalValues(r)
  cellfocals <- terra::focalValues(r_cells)

  outlet=T
  while(outlet==T){
    flow_path <- c(flow_path, cell)  # this will record the downslope path
    adjcells <- cellfocals[cell,]

    elev_window <- focals[cell,]

    if(min(elev_window, na.rm=T)==elev_window[5]){outlet<-F; break}  # if the cell is a local minimum, flow ends

    downhill_dir <- which.min(elev_window)
    cell <- adjcells[downhill_dir]
    #cat(paste('..', cell))
  }

  return(flow_path)
}


#' @export
rainfall_erode <- function(r, precipitons=as.integer(terra::ncell(r)/10), frac=0.33, rainfall=terra::rast(r, vals=1)){  # https://www.sciencedirect.com/science/article/pii/S0098300400001679

  r_cells <- .cellrast(r)
  precip_sites <- terra::spatSample(rainfall, precipitons, method='weights', replace=T, cells=T)
  all_flow_paths <- c()

  pb <- txtProgressBar(min = 0, max = precipitons, style=3)
  for (i in 1:precipitons){

    precip_site <- precip_sites[i, 'cell']

    flow_path <- .flow_downhill(r, r_cells, precip_site)
    all_flow_paths <- c(all_flow_paths, flow_path)
    path_length <- length(flow_path)
    if(path_length<3){next}

    elevations <- r[flow_path][,1]

    dh <- elevations[1:(path_length-1),1] - elevations[2:path_length, 1]

    # sediment_moved <- frac * (elevations[1:(path_length-1),1] - elevations[2:path_length, 1])  # the fraction times the height difference between each cell
    #
    # elevations[1:(path_length-1),1] <- elevations[1:(path_length-1),1] - sediment_moved  # pull the amount from the upper slopes
    # elevations[2:path_length, 1] <- elevations[2:path_length, 1] + sediment_moved  # and add it to the lower slopes

    # for(j in 2:path_length){
    #   sediment_moved <- frac*(elevations[j-1] - elevations[j])
    #   elevations[j-1] <- elevations[j-1] - sediment_moved
    #   elevations[j] <- elevations[j] + sediment_moved
    # }

    r[flow_path] <- elevations

    setTxtProgressBar(pb, i)
  }

  pathvis <- terra::rast(r, vals=NA); pathvis[all_flow_paths] <- 1
  render_terrain(r); terra::plot(pathvis, add=T)

  return(r)
}











