#!/bin/sh
# Purpose: shaded relief grid raster map from the ETOPO1/GEBCO datasets (here: Weddell Sea)
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

grdcut GlobSed-v2.nc -R290/360/-80/-40 -Gws_sed.nc
gdalinfo ws_sed.nc -stats
# Minimum=0.000, Maximum=13999.999

# Make color palette
gmt makecpt -Cturbo.cpt -V -T0/14000/200 > colors.cpt
#makecpt --help

# Generate a file
ps=WS_Sediments.ps
gmt grdimage ws_sed.nc -Ccolors.cpt -R290/360/-80/-60 -Js325/-90/5.5i/-60 -I+a15+ne0.75 -Xc -K > $ps

# Add grid
gmt psbasemap -R -J \
    -Bpx104f5a10 -Bpyg10f5a5 -Bsxg5 -Bsyg5 \
    --MAP_TITLE_OFFSET=1.4c \
    --MAP_ANNOT_OFFSET=0.1c \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    --FONT_LABEL=7p,Helvetica,black \
    -B+t"Sediment thickness in the Weddell Sea" \
    -Lx10.7c/-3.0c+c318/-57+w1000k+l"Polar stereographic projection"+f \
    -UBL/2.8c/-85p -O -K >> $ps

# Add shorelines
gmt grdcontour ws_sed.nc -R -J -C200 -W0.1p -O -K >> $ps

# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Helvetica,white+jLB >> $ps << EOF
318 -67.0 W E D D E L L
322 -68.5 S E A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Times−Bold,black+jLB -Gwhite@40 >> $ps << EOF
291 -67.0 Antarctic
290 -67.8 Peninsula
EOF

gmt psscale -R -J -Ccolors.cpt\
    -DjBC+o0.0c/-3.1c+w10c/0.5c+h\
    --FONT_LABEL=7p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,dimgray \
    --MAP_LABEL_OFFSET=0.1c \
    -Bg1000f200a2000+l"Color scale 'turbo': (Google's Improved Rainbow Colormap for Visualization [0/14000, C=RGB])" \
    -I0.2 -By+lm -O -K >> $ps

# Add GMT logo
gmt logo -Dx6.7/-1.2+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y4.7c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
2.0 10.0 GlobSed 5 arc minute grid Version 3 by NOAA World Data Service for Geophysics
1.5 9.2 Polar stereographic conformal projection. Central meridian 35\232W, standard parallel 60\232S
EOF

# Convert to image file using GhostScript
gmt psconvert WS_Sediments.ps -A1.0c -E720 -Tj -Z
