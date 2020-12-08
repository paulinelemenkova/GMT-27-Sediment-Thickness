#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO dataset (here: Indian Ocean, Sunda Trench)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert

# GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=1c \
    MAP_ANNOT_OFFSET=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thin,white \
    MAP_GRID_PEN_SECONDARY=thinnest,white \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    FONT_LABEL=7p,Helvetica,dimgray
# Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

# Make raster image
grdcut GlobSed-v2.nc -R90/130/-20/10 -Gst_sed.nc
gdalinfo st_sed.nc -stats
# 1.635289669036865,12598

# Make color palette
# gmt makecpt --help
gmt makecpt -Cwysiwyg.cpt -V -T1/12598/250 -Ic > colors.cpt
# cubhelix drywet vik

# Generate a file
ps=ST_Sediments.ps

# Make raster image
gmt grdimage st_sed.nc -Ccolors.cpt -R90/130/-20/10 -JPoly/6i -P -I+a15+ne0.75 -Xc -K > $ps
    
# Add grid
gmt psbasemap -R -J \
    -Bpx10f5a5 -Bpyg10f5a5 -Bsxg5 -Bsyg5 \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    --FONT_LABEL=7p,Helvetica,black \
    --MAP_FRAME_AXES=WEsN \
    -B+t"Sediment thickness around the Sunda Trench, Java and Sumatra" \
    -Lx12.7c/-2.2c+c318/-57+w800k+l"Polyconic projection. Scale: km"+f \
    -UBL/5p/-65p -O -K >> $ps

# Add legend
gmt psscale -Dg92.0/-22+w12.0c/0.4c+h+o0.3/0i+ml -R -J -Ccolors.cpt \
    --FONT_LABEL=6p,Helvetica,dimgray \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    -Ba1000f100+l"Color scale 'wysiwyg': 20 well-separated RGB colors [C=RGB, 1/12598]" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add isolines
gmt grdcontour st_sed.nc -R -J -C500 -Wthinnest,white -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P -Ia/thinnest,blue -Na -N1/thinner,red -Wthinner -Df -O -K >> $ps

# Add GMT logo
gmt logo -Dx6.3/-2.9+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y5.7c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
4.5 10.0 GlobSed 5 arc min grid V-3
EOF

# Convert to image file using GhostScript
gmt psconvert ST_Sediments.ps -A0.5c -E720 -Tj -Z
