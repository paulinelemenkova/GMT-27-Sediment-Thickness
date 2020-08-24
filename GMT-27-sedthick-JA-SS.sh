#!/bin/sh
# Purpose: Sediment thickness from GlobSed 5 arc minute grid version 3 (Straume et al. 2019) (here: Scotia Sea)
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

# Make raster image
grdcut GlobSed-v2.nc -R270/371/-72/-44 -Gss_sed.nc

# Generate a color palette table from grid
# makecpt --help
gdalinfo ss_sed.nc -stats
# Minimum=0.000, Maximum=7901.999
gmt makecpt -Cturbo.cpt -V -T0/7902 > sediments.cpt
# makecpt --help

# Generate a file
ps=SS_Sediments.ps
gmt grdimage ss_sed.nc -Csediments.cpt -R270/-65/340/-45r -JA318/-57/5.5i -P -I+a15+ne0.75 -Xc -K > $ps

# Add shorelines
gmt grdcontour ss_sed.nc -R -J -C200 -A600+f5p,Helvetica,black -Wthinnest,dimgray -O -K >> $ps

# Add grid
gmt psbasemap -R -J \
    -Bpx104f5a5 -Bpyg10f5a5 -Bsxg5 -Bsyg5 \
    --MAP_TITLE_OFFSET=1.5c \
    --MAP_ANNOT_OFFSET=0.1c \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,dimgray \
    --FONT_LABEL=7p,Helvetica,dimgray \
    -B+t"Sediment thickness on the Scotia Sea seafloor" \
    -Lx12.0c/-1.3c+c318/-57+w1000k+l"Scale (km) at 42\232W 57\232S"+f \
    -UBL/-5p/-40p -O -K >> $ps

# Texts
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Helvetica,white+jLB >> $ps << EOF
307 -69.0 W E D D E L L
311 -71.5 S E A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,Helvetica,white+jLB >> $ps << EOF
308 -57.0 S C O T I A   S E A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Times−Bold,white+jLB >> $ps << EOF
292 -69.0 Antarctic
291 -69.8 Peninsula
321.5 -52.5 South
321.5 -53.3 Georgia
EOF

#new
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Times−Bold,white+jLB >> $ps << EOF
315 -61.3 South
315 -62.1 Orkney
315 -62.8 Islands
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Times−Bold,white+jLB+a-315 >> $ps << EOF
302.0 -62.0 South
302.5 -62.8 Shetland
303.0 -63.6 Islands
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Times−Bold,white+jLB+a-340 >> $ps << EOF
299.5 -54.0 Burdwood
299.5 -54.7 Bank
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Times−Bold,white+jLB >> $ps << EOF
318 -48.5 A T L A N T I C  O C E A N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Times−Bold,white+jLB+a-330 >> $ps << EOF
279.5 -62.0 PACIFIC
279.5 -62.9 OCEAN
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Times−Bold,black+jLB+a-25 >> $ps << EOF
287 -53.5 Chile
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,Times−Bold,black+jLB+a-285  >> $ps << EOF
289.5 -50.5 Argentina
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Times−Bold,white+jLB >> $ps << EOF
300 -49.8 Falkland
300 -50.6 Islands
EOF

gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Times−Bold,white+jLB+a-340 >> $ps << EOF
305 -54.0 North
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Times−Bold,white+jLB+a-350 >> $ps << EOF
310 -53.5 Scotia
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Times−Bold,white+jLB+a-10 >> $ps << EOF
315 -53.5 Ridge
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Times−Bold,white+jLB+a-333 >> $ps << EOF
305 -60.5 South
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Times−Bold,white+jLB+a-10 >> $ps << EOF
313 -59.7 Scotia
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Times−Bold,white+jLB+a-332 >> $ps << EOF
322 -60.5 Ridge
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Times−Bold,white+jLB+a-93 >> $ps << EOF
328 -55.5 East Scotia Ridge
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,Times−Bold,white+jLB+a-320 >> $ps << EOF
298 -59.3 West Scotia Ridge
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Times−Bold,white+jLB+a-318 >> $ps << EOF
290.0 -59.0 DRAKE PASSAGE
EOF

# Add legend
gmt psscale -Dg260/-64+w10.0c/0.4c+v+o-7.0c/-5.3c+ml -R270/340/-65/-45 -J -Csediments.cpt \
    --FONT_LABEL=7p,Helvetica,dimgray \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    -Bg500f100a1000+l"Color scale: turbo (Google's Improved Rainbow Colormap for Visualization [C=RGB])" \
    -I0.2 -By+lm -O -K >> $ps

# Add GMT logo
gmt logo -Dx5.8/-2.2+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y6.7c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
2.0 7.4 GlobSed 5 arc minute grid version 3 (Straume et al. 2019)
0.0 6.8 Lambert Azimuthal Equal-Area projection. Central meridian 42\232W, parallel 57\232S
EOF

# Convert to image file using GhostScript
gmt psconvert SS_Sediments.ps -A0.5c -E720 -Tj -Z
