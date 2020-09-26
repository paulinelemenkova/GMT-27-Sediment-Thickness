#!/bin/sh
# Purpose: shaded relief grid raster map from the ETOPO1 from 1 arc minute global data set (here: Cascadia Trench)
# GMT modules: gmtset, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert

# GMT set up
gmt set FORMAT_GEO_MAP=dddF \
MAP_FRAME_PEN=black \
MAP_FRAME_WIDTH=0.1c \
MAP_TITLE_OFFSET=1c \
MAP_ANNOT_OFFSET=0.1c \
MAP_TICK_PEN_PRIMARY=thinner,black \
MAP_GRID_PEN_PRIMARY=thin,white \
MAP_GRID_PEN_SECONDARY=thinnest,white \
FONT_TITLE=12p,Helvetica,black \
FONT_ANNOT_PRIMARY=7p,Helvetica,black \
FONT_LABEL=7p,Helvetica,black \

# Make raster image
grdcut GlobSed-v2.nc -R224/240/35/55 -Gct_sed.nc
gdalinfo ct_sed.nc -stats
# Minimum=0.000, Maximum=2338.964

# Generate a file
ps=CT_Sediments.ps

# Make color palette
gmt makecpt -Cturbo.cpt -V -T0/2339/10 > colors.cpt

# Make raster image
gmt grdimage ct_sed.nc -Ccolors.cpt -R224/240/35/55 -JM6i -P -I+a15+ne0.75 -Xc -K > $ps

# Add grid
gmt psbasemap -R -J \
    -Bpxg8f2a4 -Bpyg6f2a2 -Bsxg4 -Bsyg2 \
    --MAP_TITLE_OFFSET=1.0c \
    --FONT_ANNOT_PRIMARY=8p,Helvetica,black \
    --MAP_ANNOT_OFFSET=0.1c \
    -B+t"Sediment thickness around Cascadia Trench seafloor, west Canada" -O -K >> $ps
    
# Add legend
gmt psscale -Dg217/35+w15.0c/0.4c+h+o7.0/-1.5c+ml -R -J -Ccolors.cpt \
    --FONT_LABEL=8p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=8p,Helvetica,black \
    -Bg200f40a200+l"Color scale: turbo (Google's Improved Rainbow Colormap for Visualization [0/2339, C=RGB])" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add shorelines
gmt grdcontour ct_sed.nc -R -J -C100 -A300 -Wthinnest,white -O -K >> $ps

# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=8p,Helvetica,black \
    --MAP_TITLE_OFFSET=0.3c \
    -Lx13.4c/-2.8c+c50+w300k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-80p -O -K >> $ps
    
# Add GMT logo
gmt logo -Dx6.4/-3.5+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/14 -X0.5c -Y7.1c -N -O \
    -F+f10p,Helvetica,black+jLB >> $ps << EOF
5.0 22.7 GlobSed 5 arc min grid V-3
EOF

# Convert to image file using GhostScript
gmt psconvert CT_Sediments.ps -A2.5c -E720 -Tj -Z
