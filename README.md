# worldbuildeR
An R package with tools for creating speculative geographies.

## Installation

To install, run the following lines in R:

```
library(devtools)
install_github("tgestabrook/worldbuildeR")
library(worldbuildeR)
```

## Overview
The aim of this package is to provide a suite of useful functions for creating imaginary geographies, including:

- Terrain generation through layered fractal noise
- Simulated erosion
- Placement of simulated river and stream networks

Unlike other guides and tools for making fantasy maps, `worldbuildeR` is intended to work with georeferenced data that can be readily loaded into other GIS platforms. To that end, it relies on the `terra` package for most of its raster and vector operations. Note that it currently assumes all data are in projected coordinate systems with 

## Roadmap

### Top priority
[X] - Add functions to generate maps from noise

[ ] - Implement precipiton erosion algorithm

### Secondary priority
[ ] - Generate watersheds and rivers

[ ] - Generate random weather

[ ] - Assign biomes

## Resources



