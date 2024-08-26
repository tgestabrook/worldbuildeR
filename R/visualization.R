topo_lookup <- data.frame(
  from = c(-999999, seq(-2250, 4500, 250)),
  to = c(seq(-2251, 4501, 250), 9999),
  color = c('#71ABD8', '#79B2DE', '#84B9E3', '#8DC1EA', '#96C9F0', '#A1D2F7', '#ACDBFB', '#B9E3FF', '#C6ECFF', '#D8F2FE',
            '#ACD0A5', '#94BF8B', '#A8C68F', '#BDCC96', '#D1D7AB', '#E1E4B5', '#EFEBC0', '#E8E1B6',
            '#DED6A3', '#D3CA9D', '#CAB982', '#C3A76B', '#B9985A', '#AA8753', '#AC9A7C', '#BAAE9A',
            '#CAC3B8', '#E0DED8', '#F5F4F2')
)

#' @export
render_terrain <- function(r, shaded=T){
  terra::plot(r, col=topo_lookup)

  if(shaded=T){
    hillshade = terra::shade(terra::terrain(r, v='slope', unit='radians'), terra::terrain(r, v='aspect', unit='radians'))
    terra::plot(hillshade, col=grey(0:100/100), range=c(0,1), alpha=0.5, add=T, legend=F)
  }
}








