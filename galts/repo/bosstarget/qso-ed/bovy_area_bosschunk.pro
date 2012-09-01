FUNCTION BOVY_AREA_BOSSCHUNK, chunk, boss_locations_file=boss_locations_file
IF ~keyword_set(boss_locations_file) THEN boss_locations_file= '~/tmp/boss_locations.fits'
;;Get plate list

plates= mrdfits('$BOSS_SPECTRO_REDUX/platelist.fits',1)
plates= plates[where(strcmp(strtrim(plates.chunk,2),$
                            'boss'+strtrim(string(chunk),2)))]
read_fits_polygons, boss_locations_file,locs
spherematch, plates.racen, plates.deccen, locs.ra, locs.dec, 2./3600.,pindx,lindx
plates= plates[pindx]
locs= locs[lindx]
print, strtrim(string(n_elements(pindx)),2)+" plates in this chunk"

;;balkanize
balkan_plot, locs, balkans=balkans,/noplot

area= 0.
for ii=0L, n_elements(balkans)-1 do area+= garea(balkans[ii])

RETURN, area*(180./!DPI)^2D0

END
