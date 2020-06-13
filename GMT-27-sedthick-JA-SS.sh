#!/bin/sh
# Purpose: shaded relief grid raster map from the ETOPO1 from 1 arc minute global data set (here: Scotia Sea)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert

# Step-2. GMT set up
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
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

# Make raster image
grdcut GlobSed-v2.nc -R270/371/-72/-44 -Gss_sed.nc

# Generate a color palette table from grid
# makecpt --help
gdalinfo ss_sed.nc -stats
gmt makecpt -Cturbo.cpt -V -T0/7902 > sediments.cpt
# makecpt --help

# Generate a file
ps=SS_Sediments.ps
gmt grdimage ss_sed.nc -Csediments.cpt -R270/-65/340/-45r -JA318/-57/5.5i -P -I+a15+ne0.75 -Xc -K > $ps

# Add shorelines
gmt grdcontour ss_sed.nc -R -J -C200 -A5 -Wthinnest,dimgray -O -K >> $ps

# Add grid
gmt psbasemap -R -J \
    -Bpx104f5a5 -Bpyg10f5a5 -Bsxg5 -Bsyg5 \
    --MAP_TITLE_OFFSET=1.5c \
    --MAP_ANNOT_OFFSET=0.1c \
    -B+t"Sediment thickness on the Scotia Sea seafloor" \
    -Lx12.0c/-1.3c+c318/-57+w1000k+l"Scale (km) at 42\232W 57\232S"+f \
    -UBL/-5p/-40p -O -K >> $ps

# Add legend
gmt psscale -Dg260/-64+w10.0c/0.4c+v+o-7.0c/-5.3c+ml -R270/340/-65/-45 -J -Csediments.cpt \
    --FONT_LABEL=7p,Helvetica,dimgray \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    -Baf+l"Color scale: turbo (Google's Improved Rainbow Colormap for Visualization [C=RGB])" \
    -I0.2 -By+lm -O -K >> $ps

# Add GMT logo
gmt logo -Dx5.8/-2.2+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y6.7c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
3.6 7.4 GlobSed 5 arc minute grid version 3
0.0 6.8 Lambert Azimuthal Equal-Area projection. Central meridian 42\232W, parallel 57\232S
EOF

# Convert to image file using GhostScript
gmt psconvert SS_Sediments.ps -A0.5c -E720 -Tj -Z
