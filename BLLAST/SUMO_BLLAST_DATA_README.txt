These are the most important SUMO variables:


WS: wind speed
WD: wind direction
SHT_T: temperature
SHT_RH: relative humidity
SCP_P: pressure
time: time (in "matlab format")
lon: longitude
lat: latitude
GPS_alt_fixed: altitude above ground
GPS_alt: altitude above sea level
W_alt: altitude above ground for wind variables
zvec: altitude vector for 20m bins

add: _asc to get the ascent
e.g. sumo(1).SHT_T_asc gives you the ascent part of the temperature profile

add int_asc to get the ascent data averaged over 20m intervals
e.g. sumo(1).SHT_T_int_asc gives you the ascent part of the temperature profile averaged in 20m bins

similarly for descent data


The profile flights are marked as e.g. sumo(100).a_type ='profile', the others are marked as 'survey'




