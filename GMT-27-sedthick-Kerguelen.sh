#!/bin/sh
# Purpose: sediment thickness (here: Kergelen)
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

exec bash

#gmt grdcut GlobSed-v2.nc -R-25/-65/101/-10r -Gker_sed.nc
gmt grdcut GlobSed-v2.nc -R-40/150/-70/-10 -Gker_sed.nc

gdalinfo ker_sed.nc -stats
# Minimum=0.000, Maximum=8116.000, Mean=530.333, StdDev=728.622

# Make color palette
# gmt makecpt -Cno_green.cpt -V -T0/6000 > myocean.cpt
# gmt makecpt -Crainbow.cpt -V -T0/6000 > myocean.cpt
# gmt makecpt -Csealand.cpt -V -T0/6000 > myocean.cpt
# gmt makecpt -Ccubhelix.cpt -V -T0/6000 > myocean.cpt
# gmt makecpt -Cbroc.cpt -V -T0/6000 > myocean.cpt
# gmt makecpt -Ccyclic.cpt -V -T0/6000 > myocean.cpt
# gmt makecpt -Clapaz.cpt -V -T0/6000 > myocean.cpt
# gmt makecpt -Cseis.cpt -V -T0/6000 > myocean.cpt
# gmt makecpt -Cseis.cpt -V -T0/6000 -Q > myocean.cpt
# gmt makecpt -Cturbo.cpt -V -T0/5000 > myocean.cpt
# gmt makecpt -CAbstract_2.cpt -V -T0/5000 -Ic > myocean.cpt
gmt makecpt -Cspectrum.cpt -V -T0/6000 -Ic -N > myocean.cpt
gmt makecpt -Cspringcolors.cpt.cpt -V -T0/6000 -Ic -N > myocean.cpt
# gmt makecpt --help


# gmt makecpt --help

# Generate a file
ps=SedThick_Kgl.ps
gmt grdimage ker_sed.nc -Cmyocean.cpt -R-25/-65/101/-10r -JA55/-50/7.5i -P -I+a15+ne0.75 -Xc -K > $ps

# Add shorelines
gmt grdcontour ker_sed.nc -R -J -C300 -A600+f10p,25,black -Wthinner,white -O -K >> $ps

# Add grid
gmt psbasemap -R -J \
    -Bpxg10f5a10 -Bpyg10f5a15 -Bsxg5 -Bsyg5 \
    --MAP_TITLE_OFFSET=1.5c \
    --MAP_ANNOT_OFFSET=0.1c \
    --MAP_FRAME_AXES=wESN \
    --FONT_ANNOT_PRIMARY=10p,0,dimgray \
    --FONT_TITLE=13p,0,black \
    --FONT_LABEL=10p,0,black \
    -B+t"Sediment thickness over East Antarctic, Kerguelen Plateau and SW Indian Ocean" \
    -Lx15.0c/-1.5c+c318/-57+w2000k+l"Scale (km) at 60\232E 50\232S"+f \
    -UBL/-5p/-40p -O -K >> $ps

# Texts

# Add legend
gmt psscale -Dg-33/-59+w15.4c/0.4c+v+ml+e -R -J -Cmyocean.cpt \
    --FONT_LABEL=10p,0,dimgray \
    --FONT_ANNOT_PRIMARY=10p,0,black \
    -Bg1000f50a1000+l"Color scale: 'springcolors' [R=0/6000, 0-100, continuous, RGB, 10 segments]" \
    -I0.2 -By+lm -O -K >> $ps

# Add GMT logo
gmt logo -Dx5.5/-2.2+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y13.0c -N -O \
    -F+f12p,0,black+jLB >> $ps << EOF
3.0 6.1 GlobSed: Total Sediment Thickness Version 3, 5 arc minute grid
EOF

# Convert to image file using GhostScript
gmt psconvert SedThick_Kgl.ps -A1.5c -E720 -Tj -Z
