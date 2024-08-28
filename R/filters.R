#' @export
dilate <- function(r, w=3){
  return(terra::focal(r, w=w, fun='max'))
}

#' @export
pinch <- function(r,w=3){
  return(terra::focal(r, w=w, fun='min'))
}

