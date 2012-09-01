FUNCTION READ_UKIDSS_ALL
basedir='$BOSSTARGET_DATA/ukidss/bycamcol/'
files= file_search(basedir+'*.fits',/test_regular)
return, mrdfits_multi(files,/silent)
END
