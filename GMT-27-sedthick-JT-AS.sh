#!/bin/sh
# Purpose: Sediment thickness from the GlobSed 5 arc minute data set (here: Arabian Sea, Makran Trench)
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
gmt grdimage as_sed.nc -Csediments.cpt -R47/77/0/31 -JT62/15/6i -P -I+a15+ne0.75 -Xc -K > $ps
#gdalinfo as_sed.nc -stats
# Min=1.14 Max=8749

# Add grid
gmt psbasemap -R -J \
    -Bpx104f5a5 -Bpyg10f5a5 -Bsxg2.5 -Bsyg2.5 \
    --MAP_TITLE_OFFSET=1.1c \
    --FONT_TITLE=13p,Palatino-Roman,black \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    --FONT_LABEL=8p,Helvetica,black \
    -B+t"Sediment thickness on the Arabian Sea seafloor" -O -K >> $ps

# Add shorelines
gmt grdcontour as_sed.nc -R -J -C100 -W0.1p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P -Ia/thinnest,blue -N1/thinner,red -Wthinner -Df -O -K >> $ps

# Add legend
gmt psscale -Dg47/-2.7+w15.0c/0.4c+h+o0.3/0i+ml -R47/77/0/31 -J -Csediments.cpt \
    --FONT_LABEL=8p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=8p,Helvetica,black \
    -Baf+l"Color scale: turbo (Google's Improved Rainbow Colormap for Visualization [C=RGB])" \
    -I0.2 -By+lm -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=9p,Helvetica,black \
    --MAP_TITLE_OFFSET=0.3c \
    -Tdx12.6c/14.0c+w0.3i+f2+l+o0.15i \
    -Lx12.2c/-2.7c+c50+w800k+l"Transverse Mercator projection. Scale: km"+f \
    -UBL/-5p/-75p -O -K >> $ps

# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Times−Bold,brown+jLB >> $ps << EOF
60.0 23.5 Gulf of
60.1 23.0 Oman
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Times−Bold,black+jLB+a-335 -Gwhite@40 >> $ps << EOF
48.2 12.5 Gulf of Aden
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Times−Bold,black+jLB+a-53 >> $ps << EOF
49.5 29.0 P e r s i a n  G u l f
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Times−Bold,blue+jLB+a-320 -Gwhite@40 >> $ps << EOF
68.6 28.2 Indus
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Times−Bold,black+jLB -Gwhite@40 >> $ps << EOF
56.5 21.5 OMAN
62.4 28.6 P A K I S T A N
54.0 30.2 I R A N
73.8 22.0 I N D I A
49.0 22.0 SAUDI
49.0 21.3 ARABIA
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,Times-Roman,blue+jLB >> $ps << EOF
61.0 15.5 ARABIAN
62.2 14.0 SEA
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,Times-Roman,black+jLB+a-300 -Gwhite@50 >> $ps << EOF
48.0 6.0 S O M A L I
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Times-Roman,yellow+jLB+a-270 >> $ps << EOF
74.0 2.0 M  a  l  d  i  v  e  s
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Times−Bold,white+jLB >> $ps << EOF
53.0 11.7 Socotra
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Times-Roman,black+jLB+a-333 -Gwhite@50 >> $ps << EOF
48.5 15.1 Y E M E N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Helvetica,yellow+jLB+a-40 >> $ps << EOF
58.8 7.3 C a r l s b e r g  R i d g e
EOF

# Add GMT logo
gmt logo -Dx6.4/-3.5+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y6.7c -N -O \
    -F+f12p,Palatino-Roman,black+jLB >> $ps << EOF
4.3 15.3 GlobSed 5 arc minute grid version 3
0.8 14.6 Transverse Mercator prj. Central meridian: 62\232E Standard parallel: 15\232N
EOF

# Convert to image file using GhostScript
gmt psconvert AS_Sediments.ps -A1.0c -E720 -Tj -Z
