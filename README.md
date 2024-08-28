# worldbuildeR
An R package with tools for creating speculative geographies.

## Installation

To install, run the following lines in R:

```{R}
library(devtools)
install_github("tgestabrook/worldbuildeR")
library(worldbuildeR)
```

## Overview
The aim of this package is to provide a suite of useful functions for creating plausible imaginary geographies. Unlike other guides and tools for making fantasy maps, `worldbuildeR` is intended to work with georeferenced data that can be readily loaded into other GIS platforms. 

## Key Features

- Handy wrappers for noise functions from the `ambient` package to generate random fractal terrain

- Simulated erosion

- Placement of simulated river and stream networks

## Background
GIS offers powerful tools for creating, exploring, and visualizing speculative geographies, but most tools and workflows presuppose real-world data as a starting point. Conversely, online hobbyist and game design communities have developed a variety of creative methods to generate and simulate fictional landscapes, but these are often in platforms that don't interface readily with GIS (e.g. game engines, image editors). This package ports some of those commonly-used techniques to R, using the `terra` package as a basis.

## Design Philosophy
`worldbuildeR` is more art than science. The algorithms are intended to produce results with a passable degree of verisimilitude, but should not be interpreted as scientifically valid simulations of real processes. 

Many `worldbuildeR` functions wrap or re-create functions available through `terra` or other packages. This was usually done in cases where a  

## Roadmap

### Top priority
[X] - Add functions to generate maps from noise

[ ] - Implement precipiton erosion algorithm

### Secondary priority
[ ] - Generate watersheds and rivers

[ ] - Generate random weather

[ ] - Assign biomes

## Resources



