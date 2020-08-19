#!/bin/sh
# Purpose: sediment thickness grid raster map (here: Ross Sea)
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

grdcut GlobSed-v2.nc -R160/220/-81/-40 -Grs_sed.nc

gdalinfo rs_sed.nc -stats
# Minimum=0.000, Maximum=8042.000

# Make color palette
gmt makecpt -Cturbo.cpt -V -T0/8042/500 > colors.cpt
#makecpt --help

# Generate a file
ps=RS_Sediments.ps
gmt grdimage rs_sed.nc -Ccolors.cpt -R160/220/-81/-60 -Js190/-90/5.5i/-60 -P -I+a15+ne0.75 -Xc -K > $ps

# Add grid
gmt psbasemap -R -J \
    -Bpx104f5a10 -Bpyg10f5a5 -Bsxg5 -Bsyg5 \
    --MAP_TITLE_OFFSET=1.4c \
    --MAP_ANNOT_OFFSET=0.1c \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    --FONT_LABEL=7p,Helvetica,black \
    -B+t"Sediment thickness  of the Ross Sea region" \
    -Lx9.7c/-3.1c+c318/-57+w1000k+l"Polar stereographic projection"+f \
    -UBL/2.8c/-85p -O -K >> $ps

# Add shorelines
#gmt grdcontour rs_sed.nc -R -J -C200 -Wthinnest,gray -O -K >> $ps

# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Helvetica,white+jLB >> $ps << EOF
185.5 -67.0 R O S S
186.5 -68.5 S E A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Helvetica,black+jLB >> $ps << EOF
175.5 -76.0 Ross
176.5 -77.2 Ice
177.5 -78.4 Shelf
EOF

gmt psscale -R -J -Ccolors.cpt\
    -DjBC+o0.0c/-3.0c+w9c/0.5c+h\
    --FONT_LABEL=7p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,dimgray \
    --MAP_LABEL_OFFSET=0.1c \
    -Bg1000f200a1000+l"Color scale: turbo (Google's Improved Rainbow Colormap for Visualization [0/18128, C=RGB])" \
    -I0.2 -By+lm -O -K >> $ps

# Add GMT logo
gmt logo -Dx5.7/-1.3+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y4.7c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
0.7 10.3 GlobSed 5 arc minute grid Version 3 by NOAA World Data Service for Geophysics
0.0 9.6 Polar stereographic conformal projection. Central meridian 170\232W, standard parallel 60\232S
EOF

# Convert to image file using GhostScript
gmt psconvert RS_Sediments.ps -A1.0c -E720 -Tj -Z
