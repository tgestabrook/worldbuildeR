topo_lookup <- c('#71ABD8', '#79B2DE', '#84B9E3', '#8DC1EA', '#96C9F0', '#A1D2F7', '#ACDBFB', '#B9E3FF', '#C6ECFF', '#D8F2FE',
            '#ACD0A5', '#94BF8B', '#A8C68F', '#BDCC96', '#D1D7AB', '#E1E4B5', '#EFEBC0', '#E8E1B6',
            '#DED6A3', '#D3CA9D', '#CAB982', '#C3A76B', '#B9985A', '#AA8753', '#AC9A7C', '#BAAE9A',
            '#CAC3B8', '#E0DED8', '#F5F4F2')

land_cols <- c('#ACD0A5', '#94BF8B', '#A8C68F', '#BDCC96', '#D1D7AB', '#E1E4B5', '#EFEBC0', '#E8E1B6',
               '#DED6A3', '#D3CA9D', '#CAB982', '#C3A76B', '#B9985A', '#AA8753', '#AC9A7C', '#BAAE9A',
               '#CAC3B8', '#E0DED8', '#F5F4F2')
water_cols <- c('#71ABD8', '#79B2DE', '#84B9E3', '#8DC1EA', '#96C9F0', '#A1D2F7', '#ACDBFB', '#B9E3FF', '#C6ECFF', '#D8F2FE')

#' @export
render_terrain <- function(r, shaded=T, flat_water=F){

  above_sl <- terra::ifel(r>0, r, NA)
  below_sl <- terra::ifel(r<=0, r, NA)

  terra::plot(above_sl, type='continuous', range=c(0,4500), fill_range=T, col=colorRampPalette(land_cols)(100))

  if(flat_water==T){
    terra::plot(below_sl, col='#84B9E3', add=T, legend=F)
  } else(
    terra::plot(below_sl, type='continuous', range=c(-3000, 0), fill_range=T, col=colorRampPalette(water_cols)(100), add=T, legend=F)
  )

  if(shaded==T){
    hillshade = terra::shade(terra::terrain(above_sl, v='slope', unit='radians'), terra::terrain(r, v='aspect', unit='radians'))
    terra::plot(hillshade, col=grey(0:100/100), range=c(0,1), alpha=0.25, add=T, legend=F)
  }
}








