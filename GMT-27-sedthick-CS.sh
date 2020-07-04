#!/bin/sh
# Purpose: geoid grid raster map from the EGM96 global data set (here: Caribbean Sea)
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
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

grdcut GlobSed-v2.nc -R270/305/7/24 -Gcs_sed.nc
gdalinfo cs_sed.nc -stats
# Minimum=0.000, Maximum=18128.000

# Select a color palette
gmt makecpt -Cturbo.cpt -V -T0/18128/1000 > colors.cpt

# Generate a file
ps=CS_Sediments.ps
# Make raster image
gmt grdimage cs_sed.nc -Ccolors.cpt -R270/305/7/24 -JM6i -P -I+a15+ne0.75 -Xc -K > $ps

# Add grid
gmt psbasemap -R -J \
    -Bpx104f2.5a5 -Bpyg10f2.5a5 -Bsxg5 -Bsyg5 \
    --MAP_TITLE_OFFSET=0.8c \
    -B+t"Sediment thickness on the Caribbean Sea seafloor" -O -K >> $ps
    
# Add shorelines
gmt grdcontour cs_sed.nc -R -J -C500 -Wthinnest,gray -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=8p,Palatino-Roman,black \
    --MAP_TITLE_OFFSET=0.3c \
    -Tdx13.8c/4.0c+w0.2i+f2+l+o0.1c \
    -Lx12.7c/-1.3c+c50+w700k+l"Mercator projection. Scale: km"+f \
    -UBL/-5p/-40p -O -K >> $ps

# Add legend
gmt psscale -Dg265.5/7+w7.7c/0.4c+v+o0.3/0i+ml -R270/305/7/24 -J -Ccolors.cpt \
    --FONT_LABEL=6p,Helvetica,dimgray \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    -Baf+l"Color scale: turbo (Google's Improved Rainbow Colormap for Visualization [0/18128, C=RGB])" \
    -I0.2 -By+lm -O -K >> $ps

# Add GMT logo
gmt logo -Dx6.2/-2.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y5.7c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
5.0 4.2 GlobSed 5 arc min grid V-3
EOF

# Convert to image file using GhostScript
gmt psconvert CS_Sediments.ps -A0.5c -E720 -Tj -Z
