#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO dataset (here: Ninety East Ridge, Indian Ocean)
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

grdcut GlobSed-v2.nc -R74/100/2/23 -Gbb_sed.nc
gdalinfo bb_sed.nc -stats
# Minimum=0.000, Maximum=16172.000

# Select a color palette
gmt makecpt -Cturbo.cpt -V -T0/16200/200 > colors.cpt

# Generate a file
ps=BB_Sediments.ps
# Make raster image
gmt grdimage bb_sed.nc -Ccolors.cpt -R74/100/2/23 -JM6.0i -P -I+a15+ne0.75 -Xc -K > $ps

# Add grid
gmt psbasemap -R -J \
    -Bpxg5f5a5 -Bpyg5f5a5 -Bsxg5 -Bsyg5 \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_TITLE=12p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    -B+t"Sediment thickness in the Bay of Bengal and Andaman Sea region" -O -K >> $ps
    
# Add shorelines
gmt grdcontour bb_sed.nc -R -J -C200 -W0.1p -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=8p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=9p,Helvetica,black \
    --MAP_LABEL_OFFSET=0.1c \
    -Lx13.0c/-2.5c+c50+w600k+l"Mercator projection. Scale: km"+f \
    -UBL/-5p/-75p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinnest,blue -Na -N1/thinner,red -W0.1p -Df -O -K >> $ps

# Add color scale
gmt psscale -Dg74/-0.5+w15.2c/0.4c+h+o0.0/0i+ml -R -J -Ccolors.cpt \
    --FONT_LABEL=8p,Helvetica,black \
    --MAP_LABEL_OFFSET=0.1c \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    -Bg1000f200a1000+l"Color scale 'geo': turbo (Google's Improved Rainbow Colormap for Visualization [0/16200, C=RGB])" \
    -I0.2 -By+lm -O -K >> $ps

# Texts
#gmt pstext -R -J -N -O -K \
#-F+jTL+f13p,Helvetica,blue+jLB >> $ps << EOF
#87.0 16.5 Bay of
#87.0 14.5 Bengal
#EOF

gmt pstext -R -J -N -O -K \
-F+jTL+f14p,Helvetica,white+jLB >> $ps << EOF
75.0 17.0 I  n  d  i  a
EOF
#gmt pstext -R -J -N -O -K \
#-F+jTL+f12p,Helvetica,white+jLB+a-75 >> $ps << EOF
#98.5 19.0 Thailand
#EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Helvetica,white+jLB >> $ps << EOF
97.5 18.0 Thailand
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Helvetica,white+jLB >> $ps << EOF
94.0 21 Myanmar
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Helvetica,white+jLB >> $ps << EOF
89.0 22.5 Bangladesh
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Helvetica,white+jLB >> $ps << EOF
80.2 8.0 Sri
80.2 7.3 Lanka
EOF
#

# Add GMT logo
gmt logo -Dx6.2/-3.3+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y2.0c -N -O \
    -F+f11p,Helvetica,black+jLB >> $ps << EOF
0.5 17.0 GlobSed 5 arc minute grid Version 3 by NOAA World Data Service for Geophysics
EOF

# Convert to image file using GhostScript
gmt psconvert BB_Sediments.ps -A0.8c -E720 -Tj -Z
