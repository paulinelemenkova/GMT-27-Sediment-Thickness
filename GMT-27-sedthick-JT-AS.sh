#!/bin/sh
# Purpose: shaded relief grid raster map from the ETOPO1 from 1 arc minute global data set (here: Ryukyu Trench)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert

# GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=0.5c \
    MAP_ANNOT_OFFSET=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thin,white \
    MAP_GRID_PEN_SECONDARY=thinnest,white \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    FONT_LABEL=7p,Helvetica,dimgray
#
Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults
# Step-5. Make color palette
gmt makecpt -Cturbo.cpt -V -T0/6000 > sediments.cpt
# makecpt --help

# Make raster image
grdcut GlobSed-v2.nc -R47/77/0/31 -Gas_sed.nc

# Generate a file
ps=AS_Sediments.ps
#gmt grdimage as_sed.nc -Csediments.cpt -R47/77/0/31 -JM6i -P -I+a15+ne0.75 -Xc -K > $ps
gmt grdimage as_sed.nc -Csediments.cpt -R47/77/0/31 -JT62/15/6i -P -I+a15+ne0.75 -Xc -K > $ps
#gdalinfo as_sed.nc -stats
# Min=1.14 Max=8749

# Add grid
gmt psbasemap -R -J \
    -Bpx104f5a5 -Bpyg10f5a5 -Bsxg2.5 -Bsyg2.5 \
    --MAP_TITLE_OFFSET=0.8c \
    -B+t"Sediment thickness on the Arabian Sea seafloor" -O -K >> $ps

# Add shorelines
gmt grdcontour as_sed.nc -R -J -C100 -W0.1p -O -K >> $ps

# Add legend
gmt psscale -Dg47/-2.5+w15.0c/0.4c+h+o0.3/0i+ml -R47/77/0/31 -J -Csediments.cpt \
    --FONT_LABEL=7p,Helvetica,dimgray \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    -Baf+l"Color scale: turbo (Google's Improved Rainbow Colormap for Visualization [C=RGB])" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=8p,Palatino-Roman,black \
    --MAP_TITLE_OFFSET=0.3c \
    -Tdx12.6c/14.0c+w0.3i+f2+l+o0.15i \
    -Lx12c/-2.5c+c50+w800k+l"Transverse Mercator projection. Scale: km"+f \
    -UBL/-5p/-70p -O -K >> $ps

# Add GMT logo
gmt logo -Dx6.2/-3.2+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y6.7c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
4.3 15.1 GlobSed 5 arc minute grid version 3
1.7 14.6 Transverse Mercator prj. Central meridian: 62\232E Standard parallel: 15\232N
EOF

# Convert to image file using GhostScript
gmt psconvert AS_Sediments.ps -A1.0c -E720 -Tj -Z
