MODEM Radiosoundings operated by Laboratoire d'Aerologie - Centre de Recherches Atmospheriques (CRA)
PI: M. Lothon

Three types of files supplied:
- ".ref" files are informations files on each radiosounding
- ".cor" files are raw data (no filter with height)
- ".fil" files contain data filetered with height (over 100 m for PTU data, and 200 m for wind data).

-----------------------------------------------------------------------------------------------------------------
Structure of files names
----------------------------------------------------------------------------
RS_YYYYMMDD_hhmm_siteNb_system_owner.ext

RS = radiosounding
YYYY = year
MM = month
DD = day
hh = hour
mm = minute
siteNb = site1 or site3
system = graw or modem
owner = Bonn or Davis or CRA
ext = 'ref', 'cor' or 'fil' (see explanations above)

-----------------------------------------------------------------------------------------------------------------

Structure of ".ref" files:
23 lines

1.	 'Exec date' 	 	 	 	reprocessing date
2.	 'dd/mm/yyyy' 	 	 	 	launch date
3.	 'Sonde TYPE' 	 	 	 	radiosonde type
4.	 'Version logiciel station' 	 	software version
5.	 'N° Identification Sonde' 	 	radiosonde identification number
6.	 'Latitude' 	 	 	 	latitude
7.	 'Longitude' 	 	 	 	longitude
8.	 'Altitude Référence' 	 	 	reference altitude
9.	 'Altitude Laché' 	 	 	launch altitude
10.	 'AltStation' 	 	 	 	station altitude
11.	 'Altitude moyenne GPS' 	 	mean GPS altitude
12.	 'Pression Sol' 	 	 	ground pressure
13.	 'Direction Vent Sol' 	 	 	wind direction
14.	 'Force Vent Sol' 	 	 	wind velocity
15.	 'Température Sol' 	 	 	ground temperature
16.	 'Humidité Sol' 	 	 	ground humidity
17.	 'nuages' 	 	 	 	cloud codification
18.	 '7wwW1W2' 	 	 	 	
19.	 'Calibration Température' 	  	calibration temperature
20.	 'Calibration Humidité' 	 	calibration humidity
21.	 'Observations' 	 	 	Observations
22.	 'Pump time' 	 	 	 	pump time (for ozone) --> not used
23.	 'Zero courant' 	 	 	zero current (for ozone) --> not used
-----------------------------------------------------------------------------------------------------------------

Structure of ".cor" files:
17 columns, separator = 'TAB'

1.	 'Temps' 	GPS time of the day (s)
2.	 'Altitude'     Geopotential altitude (m)
3.	 'Latitude'     Latitude (rad)
4.	 'Longitude'    Longitude (rad)
5.	 'VE'           East component of the probe velocity (m/s)
6.	 'VN'           North component of the probe velocity (m/s)
7.	 'VVert'        Vertical component of the probe velocity (m/s)
8.	 'VHor'         Horizontal wind velocity (m/s)
9.	 'VDir'         Horizontal wind direction (degrees)
10.	 'Cor'          Differential GPS correction status (+00: full, +10: none, other: partial)
11.	 'TaNCal'       Air temperature, uncalibrated (deg Celsius)
12.	 'TaCal'        Air temperature, calibrated (deg Celsius)
13.	 'TaRad'        Air temperature, calibrated, and corrected for radiative effect (deg Celsius)
14.	 'UNCal'        Relative humidity, uncalibrated (%)
15.	 'UCal'         Relative humidity, calibrated (%)
16.	 'Press'        Pressure (hPa)
17.	 'GPSAlt'       Raw GPS altitude (m)

We advise to use 'TaRad' and 'UCal'.
-----------------------------------------------------------------------------------------------------------------

Structure of ".fil" files:
16 columns, separator = 'TAB'

1.	'TempF'		GPS time of the day (s)
2.	'AltitudF'	Geopotential altitude (m)	
3.	'LatitudeF'	Latitude (rad)
4.	'LongitudeF'	Longitude (rad)
5.	'VEstF'		East component of the probe velocity (m/s)
6.	'VNordF'	North component of the probe velocity (m/s)
7.	'VVertF'	Vertical component of the probe velocity (m/s)
8.	'VHorF'		Horizontal wind velocity (m/s)
9.	'VDirF'		Horizontal wind direction (degrees)
10. 	'TaNCalF'	Air temperature, uncalibrated (deg Celsius)
11.	'TaCalF'	Air temperature, calibrated (deg Celsius)
12.	'TaRadF'	Air temperature, calibrated, and corrected for radiative effect (deg Celsius)
13.	'UNCaF'		Relative humidity, uncalibrated (%)
14.	'UCalF'		Relative humidity, calibrated (%)
15.	'PressF'	Pressure (hPa)
16.	'GPSAltF'	Raw GPS altitude (m)

We advise to use 'TaRadF' and 'UCalF'.
