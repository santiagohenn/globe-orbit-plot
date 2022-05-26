# globe-orbit-plot

Scripts to plot constellations in a 3D user interface. 

### Usage:

Input the constellation satellites via a .csv file, one for each line, grouped
by planes. This is: if you have N planes with M satellites, the M 
satellites from the first plane should come first, then the M satellites 
for the second plane, and so on until the N^th^ plane.

CSV's columns are as follows:

|  time  | a (Sem-Maj axis)  | ecc | inc | RAAN  | \omega  | v~0~  |
|---|---|---|---|---|---|---|

Where time is the Greenwich Hour angle, a is in meters, v~0~ is the true anomaly and all angles are in degrees. E.G.:

```csv
36.406,6978135,0,98,0,0,0
36.406,6978135,0,98,0,0,45
36.406,6978135,0,98,0,0,90
36.406,6978135,0,98,0,0,135
36.406,6978135,0,98,0,0,180
36.406,6978135,0,98,0,0,225
...
```

Then modify these lines in the orbit_plotter.m script:

```Matlab
% Read CSV file containing the constellation parameters
con = csvread('PATH/TO/CONSTELLATION/CSV');

% Set the number of planes and sats per plane
nPlanes = 1;        % < ----- N. of planes
nSatsInPlane = 8;   % < ----- N. of sats
```

And run the block of code that suits your needs:

* Plot ground tracks in 2D: Plots ground tracks
* Plot in 3D globe: Plots into a user-interactive 3D plot. [Other types of basemaps](https://la.mathworks.com/help/map/ref/geoglobe.html)
  are supported besides the provided default: _darkwater_[^1].
* Export globe-3D current view as file: Exports the current view of the UI 3D plot 
to a path/file.pdf indicated in the argument of this function[^2]:

```Matlab
exportapp(uif,'snaps/snap.pdf');
```

[^1]: Many of them require internet connection.
[^2]: Only pdf type of output is supported.

