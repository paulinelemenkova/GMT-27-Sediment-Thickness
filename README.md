# GMT Sediment Thickness — Marine Sediment Isopach Mapping Scripts

A collection of GMT (Generic Mapping Tools) shell scripts for mapping total marine sediment thickness over ocean basins, seas and trenches from a global sediment-thickness grid. Thickness grids are colour-shaded and contoured as isopachs, with coastal and geographic context. The scripts have been used to generate map figures across the author's marine-geological and cartographic publications.

## What the scripts do

Each script builds a complete sediment-thickness map, typically chaining:

- grid clipping and subsetting (grdcut) over a study-area bounding box
- colour palette generation (makecpt, turbo scheme) scaled to the thickness range
- thickness grid rendering (grdimage), optionally with illumination
- isopach contours in metres (grdcontour)
- coastlines, borders and rivers (pscoast)
- colour scale bars (psscale), grids, frames, scale bars and roses (psbasemap)
- place labels and annotations (pstext), GMT logo (logo)
- export to raster (psconvert) at high resolution

## Data sources

Total sediment thickness from the NOAA/NGDC GlobSed grid (5 arc-minute global marine sediment thickness). Coastlines from GSHHG via GMT.

## File naming

Scripts follow GMT-27-sedthick-XX.sh, where XX is a feature tag for an ocean basin, sea or trench (e.g. CS = Caribbean Sea, RS = Red Sea, WS = Weddell Sea, NER = Ninetyeast Ridge, IO = Indian Ocean). Date suffixes mark revised versions.

## Requirements

- GMT 6.x (Generic Mapping Tools): https://www.generic-mapping-tools.org
- A POSIX shell (bash/sh)
- The GlobSed sediment-thickness grid available locally
- GDAL (optional) for grid statistics (gdalinfo)

## Usage

Place the GlobSed grid in the working directory, adjust the -R region and -J projection at the top of the chosen script, then run:

    bash GMT-27-sedthick-CS.sh

The script writes a PostScript file and converts it to a raster image (JPG/PNG) via psconvert.

## Author and citation

Polina Lemenkova
ORCID: https://orcid.org/0000-0002-5759-1089

These scripts accompany figures in the author's marine-geological and cartographic papers; please cite the specific article a given map appears in. The full publication list is available via the ORCID record above.

## License

See the LICENSE file in this repository.
