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
#gmt makecpt -Celevation.cpt -V -T0/18171 -Iz > sediments.cpt
gmt makecpt -Celevation.cpt -V -T0/18171 > sediments.cpt
# makecpt --help

# Generate a file
ps=AO_Sediments.ps
# Make raster image
grdcut GlobSed-v2.nc -R-90/25/-65/65 -Gao_sed.nc
gdalinfo ao_sed.nc -stats
#gmt grdimage ao_sed.nc -Csediments.cpt -R-90/25/-65/65 -JPoly/4i -P -I+a15+ne0.75 -Xc -K > $ps
gmt grdimage ao_sed.nc -Csediments.cpt -R-90/25/-65/65 -JPoly/4i -P -I+a15+ne0.75 -Xc -K > $ps
    
# Add isolines
gmt grdcontour ao_sed.nc -R -J -C1000 -W0.1p -O -K >> $ps

# Add grid
gmt psbasemap -R -J \
    -Bpx20f10a20 -Bpyg20f10a10 -Bsxg10 -Bsyg10 \
    --MAP_TITLE_OFFSET=1.4c \
    -B+t"Sediment thickness of the Atlantic Ocean seafloor" -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=7p,Palatino-Roman,black \
    --MAP_TITLE_OFFSET=0.2c \
    -Lx7.8c/-3.7c+c50+w4000k+l"Polyconic prj. Scale: km"+f \
    -UBL/1.0c/-3.7c -O -K >> $ps
    
# Add color legend
gmt psscale -R -J -Csediments.cpt\
    -DjBC+o0.0c/-3.0c+w8c/0.5c+h\
    --FONT_LABEL=7p,Palatino-Roman,dimgray \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,dimgray \
    --MAP_LABEL_OFFSET=0.1c \
    -Baf+l"Color scale: lajolla [R=0/18171, H=0, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps

# Add GMT logo
gmt logo -Dx3.9/-2.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y6.7c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
3.0 9.3 GlobSed 5 arc min grid V-3
EOF

# Step-13. Convert to image file using GhostScript
gmt psconvert AO_Sediments.ps -A1.5c -E720 -Tj -Z
