-- Create the table we want to stuff in

create table "spall_dr9"  (
PLATE INT ,
MJD  INT,
FIBER SMALLINT, 
CLASS VARCHAR(20),              
SUBCLASS VARCHAR(30),           
Z REAL,       
Z_ERR REAL, 
ZWARNING SMALLINT,      
PLUG_RA DOUBLE,      
PLUG_DEC DOUBLE, 
IPRIMARY SMALLINT,  
CHUNK VARCHAR(10),   
PLATESN2  REAL,   
DEREDSN2 REAL,         
OBJTYPE VARCHAR(20),         
BOSS_TARGET1 BIGINT,           
ANCILLARY_TARGET1 BIGINT, 
TILEID INT, 
OBJC_TYPE VARCHAR(20),  
MODELFLUX0 REAL,   
MODELFLUX1 REAL,   
MODELFLUX2 REAL,   
MODELFLUX3 REAL,   
MODELFLUX4 REAL,     
Z_PERSON REAL,  
CLASS_PERSON SMALLINT, 
Z_CONF_PERSON SMALLINT);

-- The text file needs to be prepared by removing double spaces
-- and the starting space of each line
-- as well as the header line

-- Also, some of the bigints with the final bit set need to be switched to 
-- NULL
copy 831000 records into spall_dr9 
from '/Users/npadmana/data/mymonetdb/sdss/spAll-v5_4_45.dat'
using delimiters ' ','\n','"' locked;
