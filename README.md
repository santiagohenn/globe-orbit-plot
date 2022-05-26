# globe-orbit-plot

Scripts to plot constellations, both in 2D as ground tracks or in 
3D with user interface. 

### Usage:

Set the constellation satellites via a .csv file, one for each line, grouped
by planes: if you have N planes with M satellites, the M 
satellites from the first plane should come first, then the M satellites 
for the second plane, and so on until the N^th^ plane.

CSV's columns are as follows:

|  time  | a (sem-maj axis)  | ecc | inc | RAAN  | 	ω  | vo  |
|---|---|---|---|---|---|---|

Where time is the Greenwich Hour angle, a is in meters, vo is the true anomaly, and all angles are in degrees. E.G.:

_constellation.csv_
```csv
36.406,6978135,0,98,0,0,0
36.406,6978135,0,98,0,0,45
36.406,6978135,0,98,0,0,90
36.406,6978135,0,98,0,0,135
36.406,6978135,0,98,0,0,180
36.406,6978135,0,98,0,0,225
[...]
```

Then modify the following lines in the _orbit_plotter.m_ script, and run the block 
the .csv file:

```Matlab
% Read CSV file containing the constellation parameters
con = csvread('PATH/TO/CONSTELLATION/CSV'); % <--- Path to .csv file

% Set the number of planes and sats per plane
nPlanes = 8;        % < ----- N. of planes
nSatsInPlane = 8;   % < ----- N. of sats
```

Finally, run the script, or the block of code that suits your needs:

* **Plot ground tracks in 2D**: Plots ground tracks
* **Plot in 3D globe**: Plots into a user-interactive 3D plot. [Other types of basemaps](https://la.mathworks.com/help/map/ref/geoglobe.html)
  are supported besides the provided default: _darkwater_[^1].
* **Export globe-3D current view as file**: Exports the current view of the UI 3D plot 
to a path/file.pdf indicated in the argument of this function[^2]:

```Matlab
%% Export globe-3D current view as file
exportapp(uif,'PATH/TO/OUTPUT/PDF');
```

[^1]: Many of them require internet connection.
[^2]: Only pdf type of output is supported.

---

## Snapshots

<img src="https://drive.google.com/uc?id=1Cj91exn6sbVGJ_JrylTaKQ2ZyyRLwxpR" alt="MarineGEO circle logo" style="height: 100%; width:80%;"/>
<img src="https://drive.google.com/uc?id=1GVqb8aVROxglmYCqYtEKiKCPPRtQotNY" alt="MarineGEO circle logo" style="height: 100%; width:80%;"/>
<img src="https://drive.google.com/uc?id=180GPgVIZrI9ntrcVYQrT2tLLPGNrbooQ" alt="MarineGEO circle logo" style="height: 100%; width:80%;"/>
<img src="https://drive.google.com/uc?id=1IJUl1j72bFVdCUN2BYlImcTdNMkactKf" alt="MarineGEO circle logo" style="height: 100%; width:80%;"/>

---

## Requirements and restrictions

**Matlab 2022a** or later is required to obtain the 3D plots.

The functions used do not appear to be intended to plot orbits, rather to be used to plot 
lines, great circles, and overall regions over the surface of the Earth. To achieve the 
obtained results, great circles are interpolated in between sub-satellite points, which 
are then elevated to the plane's approximate height (based on the orbit's Semi-Major axis)
and Earth's equatorial radius. Small constellations or trailing satellite formations
could yield strange results in the visualizations.

No orbit propagation is performed in this tool, this is yet to be implemented, which will
allow for more freedom, mainly in non-symmetric constellations.

---

## Disclaimer

**This is a visualization only tool**. These scripts are not intended to be used as a propagator, obtain access 
intervals, or to obtain any estimation in any way about the behaviour and/or 
operation of a satellite constellation. No metrics should be obtained using this tool.

