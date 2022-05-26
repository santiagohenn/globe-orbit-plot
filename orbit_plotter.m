%% Modify here VVVVVVVV

% Read CSV file containing the constellation parameters
con = csvread('constellation.csv');

% Set the number of planes and sats per plane
nPlanes = 1;        % < ----- N. of planes
nSatsInPlane = 8;   % < ----- N. of sats

% Modify here ^^^^^^^^^

clc
format('shortG')

% N of sats in constellation
nSats = nPlanes * nSatsInPlane;

%% Plot ground tracks in 2D

lla = elements2lla(con);

for n = 1 : nSatsInPlane : nSats
   
    latsToPlot = lla(n:n+(nSatsInPlane-1),1);
    latsToPlot(nPlanes + 1) = latsToPlot(1);
    longsToPlot = lla(n:n+(nSatsInPlane-1),2);
    longsToPlot(nPlanes + 1) = longsToPlot(1);
    [latI,lonI] = interpm(latsToPlot,longsToPlot,0.1,'gc');
    geoplot(latI,lonI,'-','MarkerSize',12,'LineWidth',1,'Color',[1 0 1]); hold on;
    geoplot(lla(:,1),lla(:,2),'p','MarkerSize',5,'Color',[1 0 0]); hold on;
    
end

%% Plot in 3D globe

lla = elements2lla(con);

uif = uifigure;
g = geoglobe(uif,'Basemap','darkwater');
satHeight = lla(n,3)*1e3;

for n = 1 : nSatsInPlane : nSats
    
    % Plot great circle
    latsToPlot = lla(n:n+(nSatsInPlane - 1),1);
    latsToPlot(nSatsInPlane + 1) = latsToPlot(1);
    longsToPlot = lla(n:n+(nSatsInPlane - 1),2);
    longsToPlot(nSatsInPlane + 1) = longsToPlot(1);
    [latI,lonI] = interpm(latsToPlot,longsToPlot,0.1,'gc');
    alts = satHeight*ones(size(latI,1),1);
    p = geoplot3(g,latI,lonI,alts,'r','LineWidth',0.8);
    p.HeightReference = 'ellipsoid';
    hold(g,'on');
    % Plot satellite positions
    alts = satHeight*ones(size(longs,1) + 1,1);
    p = geoplot3(g,latsToPlot,longsToPlot,alts,'ro','LineWidth',3,'MarkerSize',1);
    hold(g,'on');
    
end

geobasemap(g,'darkwater')

%% Export globe-3D current view as file
exportapp(uif,'snaps/snap.pdf');

%% Function that obtains the lla matrix for the constellation from the .csv
function lla = elements2lla(con)

    nSats = size(con, 1);
    lla = zeros(nSats,3);

    for sat = 1 : nSats
        time = con(sat,1);
        a = con(sat,2) / 1000;
        e = con(sat,3);
        i = con(sat,4);
        W = con(sat,5);
        w = con(sat,6);
        v0 = con(sat,7);
        [lat, lon, alt] = compute_LLA(time,a,e,i,W,w,v0);
        lla(sat,:) = [lat, lon, alt];
    end
    
end
