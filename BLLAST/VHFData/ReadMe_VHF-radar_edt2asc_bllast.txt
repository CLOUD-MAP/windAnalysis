VHF RADAR operated by Laboratoire d'Aerologie
PI: F. SAID


Structure of "*.edt2asc" files:



22 lines for HEADER


----------------------------
DATA BLOCKS DESCRIPTION

first line:
DATE (YYMMDD): YYMMDD  HOUR TU (hhmmss): hhmmss  NLEV:   nn  MEAN NOISE DENSITY (DB):         V      N      S      E      W
    ---> for example:
    DATE (yymmdd): 110601  HOUR TU (hhmmss):   1006  NLEV:   39  MEAN NOISE DENSITY (DB):   -6.4   -6.6   -5.6   -6.2   -6.5
    DATE (yymmdd): 110710  HOUR TU (hhmmss): 191023  NLEV:   39  MEAN NOISE DENSITY (DB):   -6.9   -6.8   -6.2   -6.6   -7.0

second line:
ALT Z1(m/msl):   2474    9999    9999  ALT Zt(m/msl):  11662   13943    9999
    - Z1 = estimate of boundary layer height, when appropriate (detected from local maximum of reflectivity and complementary criteria)
    - Zt = estimate of tropopause height (detected from local maximum of reflectivity and complementary criteria)
	   --> 3 estimates from different criteria
    for Z1 and Zt, contact PI for more information

third line:
ALT m/msl U(WE)ms-1 V(SN)ms-1 W(VT)ms-1  CN2 m-2/3 ASPT db 2STDw ms-1 SKEW W ( ) unused      unused      unused      unused      unused

 ---> header of following data table
	01. altitude (m ASL)
	02. u wind component, from west to east direction (m/s)
	03. v wind component, from north to south direction (m/s)
	04. w wind component, vertical velocity (m/s)
	05. turbulence indicator cn2 (m-2/3)
	06. aspect ratio (dB)
	07. 2 * standard deviation of w (m/s)
	08. skewness of V beam
	09. unused
	10. unused
	11. unused
	12. unused
	13. unused

next 39 lines:
data

last line is empty

END DATA BLOCKS
----------------------------