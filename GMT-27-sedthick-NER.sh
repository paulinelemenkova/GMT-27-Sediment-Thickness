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

grdcut GlobSed-v2.nc -R65/107/-35/21 -Gner_sed.nc

gdalinfo ner_sed.nc -stats
# Minimum=0.000, Maximum=16172.000
# Make color palette
# makecpt --help
#gmt makecpt -Cseis.cpt -V -T0/16172/5000 > colors.cpt
gmt makecpt -Cturbo.cpt -V  -T0/16172/1000+n100 -Z > colors.cpt

# Generate a file
ps=NER_Sediments.ps
# Make raster image
gmt grdimage ner_sed.nc -Ccolors.cpt -R65/107/-35/21 -JM6i -P -I+a15+ne0.75 -Xc -K > $ps
#gmt grdimage gravNER.grd -Ccolors.cpt -R65/107/-35/21 -JPoly/6i -P -I+a15+ne0.75 -Xc -K > $ps

# Add grid
gmt psbasemap -R -J \
    -Bpx10f5a5 -Bpyg10f5a5 -Bsxg5 -Bsyg5 \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_TITLE=14p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    -B+t"Marine free-air gravity anomaly: Ninety East Ridge region, Indian Ocean" -O -K >> $ps
    
# Add shorelines
gmt grdcontour ner_sed.nc -R -J -C30 -W0.1p -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT_LABEL=9p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=8p,Helvetica,black \
    --MAP_LABEL_OFFSET=0.1c \
    -Lx12.7c/-2.5c+c50+w1000k+l"Mercator projection. Scale: km"+f \
    -UBL/-5p/-75p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinnest,blue -Na -N1/thinner,red -W0.1p -Df -O -K >> $ps

# Add legend
gmt psscale -Dg65/-38+w15.2c/0.4c+h+o0.0/0i+ml -R -J -Ccolors.cpt \
    --FONT_LABEL=9p,Helvetica,black \
    --MAP_LABEL_OFFSET=0.1c \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    -Bg1000f500a1000+l"Color scale 'haxby': Haxby: Bill Haxby's color scheme for geoid & gravity [C=RGB]" \
    -I0.2 -By+lmGal -O -K >> $ps

# Add GMT logo
gmt logo -Dx6.2/-3.3+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y13.0c -N -O \
    -F+f12p,Helvetica,black+jLB >> $ps << EOF
2.0 13.5 Global gravity grid from CryoSat-2 and Jason-1 satellite missions
EOF

# Convert to image file using GhostScript
gmt psconvert NER_Sediments.ps -A1.0c -E720 -Tj -Z
