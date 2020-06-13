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

# Generate a file
ps=PO_Sediments.ps
# Make raster image
grdcut GlobSed-v2.nc -R110/295/-70/70 -Gpo_sed.nc
gmt grdimage po_sed.nc -Csediments.cpt -R -JY180/0/6.5i -P -I+a15+ne0.75 -Xc -K > $ps

# Add grid
gmt psbasemap -R -J \
    -Bxg20f10a10 -Byg20f10a10 \
    --MAP_TITLE_OFFSET=0.8c \
    -B+t"Sediment thickness on the Pacific Ocean seafloor" -O -K >> $ps
    
# Add legend
gmt psscale -Dg85/-70+w9.5c/0.4c+v+o0.3/0i+ml \
    -Rpo_relief.nc -J -Csediments.cpt \
    --FONT_LABEL=8p,Helvetica,dimgray \
    --FONT_ANNOT_PRIMARY=5p,Helvetica,dimgray \
    -Baf+l"Color scale: turbo (Google's Improved Rainbow Colormap for Visualization [C=RGB])" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=8p,Palatino-Roman,black \
    --MAP_TITLE_OFFSET=0.3c \
    -Lx14c/-1.2c+c50+w3000k+l"Behrman cylindrical equal-area prj. Scale: km"+f \
    -UBL/0.0c/-1.5c -O -K >> $ps

# Add GMT logo
gmt logo -Dx6.5/-2.2+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X1.0c -Y4.5c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
3.7 9.0 GlobSed five arc minute grid version three
EOF

# Convert to image file using GhostScript
gmt psconvert PO_Sediments.ps -A1.0c -E720 -Tj -Z
