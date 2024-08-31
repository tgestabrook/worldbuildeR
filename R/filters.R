#' Dilate terrain
#'
#' Widen terrain features with a local maximum filter.
#'
#' @details
#' This simple function wraps a call to terra::focal with a maximum filter of the desired window size.
#' It can be used to quickly widen ridges and thin valleys. As a general rule, this function and its inverse `pinch()`
#' are best used early in a workflow prior to applying erosion algorithms.
#'
#' @param r `terra::SpatRaster` object containing a digital elevation model.
#'
#' @param w integer specifying the window size used to dilate the terrain. Larger values are slower but produce more dramatic effects.
#'
#' @export
#'
dilate <- function(r, w=3){
  return(terra::focal(r, w=w, fun='max'))
}

#' Pinch terrain
#'
#' Narrow terrain features with a local minimum filter.
#'
#' @details
#' This simple function wraps a call to terra::focal with a minimum filter of the desired window size.
#' It can be used to quickly thin ridges and widen valleys. As a general rule, this function and its inverse `dilate()`
#' are best used early in a workflow prior to applying erosion algorithms.
#'
#'
#' @param r `terra::SpatRaster` object containing a digital elevation model.
#'
#' @param w integer specifying the window size used to pinch the terrain. Larger values are slower but produce more dramatic effects.
#'
#' @export
pinch <- function(r,w=3){
  return(terra::focal(r, w=w, fun='min'))
}

