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

#grdcut GlobSed-v2.nc -R180/270/50/80 -Gbs_sed.nc
grdcut GlobSed-v2.nc -R180/270/66/90 -Gbs_sed.nc
gdalinfo bs_sed.nc -stats
# {0,18064.5390625}

# Select a color palette
gmt makecpt -Cturbo.cpt -V -T0/18065/1000 > colors.cpt

# Generate a file
ps=BS_Sediments.ps
# Make raster image
#gmt grdimage bs_sed.nc -Ccolors.cpt -R220/50/270/80r -JA260/60/5.5i -P -I+a15+ne0.75 -Xc -K > $ps
gmt grdimage bs_sed.nc -Ccolors.cpt -R180/270/66/83 -JM5.5i -P -I+a15+ne0.75 -Xc -K > $ps

# Add grid
gmt psbasemap -R -J \
    -Bpxg10f5a10 -Bpyg10f5a5 -Bsxg5 -Bsyg5 \
    --MAP_TITLE_OFFSET=0.7c \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    --FONT_LABEL=6p,Helvetica,black \
    -B+t"Sediment thickness in the Beaufort Sea, Arctic Ocean" -O -K >> $ps
    
# Add shorelines
gmt grdcontour cs_sed.nc -R -J -C500 -Wthinnest,gray -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinnest,blue -Na -N1/thick,red -W0.2p -Df -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=8p,Palatino-Roman,black \
    --MAP_TITLE_OFFSET=0.3c \
    -Lx12.0c/-1.3c+c50+w2000k+l"Mercator projection. Scale: km"+f \
    -UBL/-5p/-40p -O -K >> $ps

# Add legend
gmt psscale -Dg169/66+w11.0c/0.4c+v+o0.3/0i+ml -R -J -Ccolors.cpt \
    --FONT_LABEL=6p,Helvetica,dimgray \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    -Baf+l"Color scale: turbo (Google's Improved Rainbow Colormap for Visualization [0/18128, C=RGB])" \
    -I0.2 -By+lm -O -K >> $ps

# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,Helvetica,white+jLB >> $ps << EOF
210.2 82.0 Arctic Ocean
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,Helvetica,blue+jLB >> $ps << EOF
214.6 76.5 Beaufort
216 75.5 Sea
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Palatino-Italic,blue+jLB+a-55 >> $ps << EOF
229.8 69.5 Mackenzie
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Palatino-Italic,blue+jLB+a-65 >> $ps << EOF
234.8 68.5 Anderson
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f7p,Palatino-Roman,white+jLB >> $ps << EOF
240.5 77.0 Queen
240.7 76.4 Elizabeth
240.9 75.7 Islands
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Palatino-Roman,white+jLB >> $ps << EOF
246 71.0 Victoria
246.5 70.3 Island
235.3 73.0 Banks
235.6 72.3 Island
EOF

# Add GMT logo
gmt logo -Dx6.0/-2.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y5.7c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
0.0 9.2 GlobSed 5 arc minute grid Version 3 by NOAA World Data Service for Geophysics
EOF

# Convert to image file using GhostScript
gmt psconvert BS_Sediments.ps -A0.5c -E720 -Tj -Z
