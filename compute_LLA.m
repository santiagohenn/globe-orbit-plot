% This function obtains approximated Sub-Satellite Points based upon
% orbital elements and the Greenwich hour angle. 
% Parameters and units:
% time = Greenwich Hour Angle [degrees]
% a    = Semi-Major Axis [Km]
% e    = Eccentricity
% i    = Inclination [degrees]
% W    = RAAN [degrees]
% w    = Argument of perigee [degrees]
% v0   = True Anomaly [degrees]
%
% This snippet is based upon Ennio Condoleo's 2013 orbit tracker.

function [lat, lon, alt] = compute_LLA(time,a,e,i,RAAN,w,v0)

% -------------------------------- CONST ---------------------------------%
RE = 6378;          % Earth's radius                            [km]
muE = 398600.44;    % Earth gravitational parameter             [km^3/sec^2]
wE = (2*pi/86164);  % Earth rotation velocity aorund z-axis     [rad/sec]
% --------------------------------- CONV ---------------------------------%
RAAN  = RAAN*pi/180;        % RAAN                          [rad]
w     = w*pi/180;           % Argument of perigee           [rad]
v0    = v0*pi/180;          % True anomaly at the departure [rad]
i     = i*pi/180;           % inclination                   [rad]
% ------------------------------------------------------------------------%
%% ORBIT COMPUTATION
rp = a*(1-e);               % radius of perigee             [km]
ra = a*(1+e);               % radius of apogee              [km]
Vp = sqrt(muE*(2/rp-1/a));  % velocity at the perigee       [km/s]
Va = sqrt(muE*(2/ra-1/a));  % velocity at the  apogee       [km/s]
n  = sqrt(muE./a^3);        % mean motion                   [rad/s]
p  = a*(1-e^2);             % semi-latus rectus             [km]
T  = 2*pi/n;                % period                        [s]
h  = sqrt(p*muE);           % moment of the momentum        [km^2/s]
h1 = sin(i)*sin(RAAN);      % x-component of unit vector h
h2 = -sin(i)*cos(RAAN);     % y-component of unit vector h
h3 = cos(i);                % z-component of unit vector h
n1 = -h2/(sqrt(h1^2+h2^2)); % x-component of nodes' line
n2 =  h1/(sqrt(h1^2+h2^2)); % y-component of nodes' line
n3 = 0;                     % z-component of nodes' line
N  = [n1,n2,n3];            % nodes' line (unit vector)

%% TIME
norb = 0;                                        % number of orbits
t0   = 0;                                        % initial time          [s]
tf   = norb*T;                                   % final   time          [s]  
step = 10;                                       % time step             [s]
t    = t0:step:tf+step;                          % vector of time        [s]

%% DETERMINATION OF THE DYNAMICS
cosE0 = (e+cos(v0))./(1+e.*cos(v0));               % cosine of initial eccentric anomaly
sinE0 = (sqrt(1-e^2).*sin(v0))./(1+e.*cos(v0));    %   sine of initial eccentric anomaly
E0 = atan2(sinE0,cosE0);                           % initial eccentric anomaly              [rad]
if (E0<0)                                          % E0�[0,2pi]
    E0=E0+2*pi;
end
tp = (-E0+e.*sin(E0))./n+t0;                       % pass time at the perigee               [s]
M  = n.*(t-tp);                                    % mean anomaly                           [rad]
%% Mk = Ek - e*sin(Ek);
% Eccentric anomaly (must be solved iteratively for Ek)
E = zeros(size(t,2),1);
for j=1:size(t,2)
    E(j) = anom_ecc(M(j),e);                     % eccentric anomaly         [rad]
end
%% True anomaly, Argument of latitude, Radius
sin_v = (sqrt(1-e.^2).*sin(E))./(1-e.*cos(E));   % sine of true anomaly
cos_v = (cos(E)-e)./(1-e.*cos(E));               % cosine of true anomaly
v     = atan2(sin_v,cos_v);                      % true anomaly              [rad]
theta = v + w;                                   % argument of latitude      [rad]
r     = (a.*(1-e.^2))./(1+e.*cos(v));            % radius                    [km]
%% Satellite coordinates
% "Inertial" reference system ECI (Earth Centered Inertial)
xp = r.*cos(theta);                          % In-plane x position (node direction)             [km]
yp = r.*sin(theta);                          % In-plane y position (perpendicular node direct.) [km]
xs = xp.*cos(RAAN)-yp.*cos(i).*sin(RAAN);    % ECI x-coordinate SAT                             [km]
ys = xp.*sin(RAAN)+yp.*cos(i).*cos(RAAN);    % ECI y-coordinate SAT                             [km]
zs = yp.*sin(i);                             % ECI z-coordinate SAT                             [km]
rs = p./(1+e.*cos(theta-w));                 % norm of radius SAT                               [km]
  
%% GREENWICH HOUR ANGLE

greenwich0 = time;

%% SUB-SATELLITE-POINT
greenwich0 = greenwich0*pi/180;                 % Greenwich hour angle at the initial time    [rad]
rot_earth  = wE.*(t-t0)+greenwich0;             % Greenwich hour angle at the time t          [rad]
for j=1:size(t,2)
    if rot_earth(j) < (-pi)
        nn = ceil(rot_earth(j)/(-2*pi));
        rot_earth(j) = rot_earth(j) + nn*2*pi;
    elseif rot_earth(j) > (pi)
        nn = fix(rot_earth(j)/(2*pi));
        rot_earth(j) = rot_earth(j) - nn*2*pi;
    end
end

LatSSP     = asin(sin(i).*sin(theta));          % Latitude  of Sub-Satellite-Point            [rad]
LongSSP    = atan2(ys./rs,xs./rs)-rot_earth';   % Longitude of Sub-Satellite-Point            [rad]
   
% xSSP = RE.*cos(LatSSP).*cos(LongSSP)+1;         % x-component of  Sub-Satellite-Point         [km]
% ySSP = RE.*cos(LatSSP).*sin(LongSSP)+1;         % y-component of  Sub-Satellite-Point         [km]
% zSSP = RE.*sin(LatSSP)+0.1;                     % z-component of  Sub-Satellite-Point         [km]

lat = rad2deg(LatSSP(1));
lon = rad2deg(LongSSP(1));
alt = a - RE;

end

function [E] = anom_ecc(M,e)
    % function [E] = anom_ecc(M,e) 
    % Risoluzione numerica dell'equazione: E-e*sin(E)=M
    % E = anomalia eccentrica [rad]
    % e = eccentricità
    % M = anomalia media [rad]
    % Si devono dare in input alla funzione due valori scalari,
    % rispettivamente M in rad ed e.
    % Il programma restituisce E [rad] con un errore di 1e-10
    % N.B. Per migliorare l'accuratezza accedere all'editor e modificare il
    % valore della variabile err, che rappresenta l'errore commesso.
    
    format long
%     x = 0;
%     sx = 1;
%     dymax = -1;
%     trovato = true;
%     while (trovato)
%         if (sx<0.2)
%             sx = 0.1 - (x/1000);
%         else
%             sx  = M-x;
%             dx  = M+x;
%             dy  = abs(cos(dx));
%             dy2 = abs(cos(sx));
%         end
%         if (dymax<dy || dymax<dy2)
%             if (dy<dy2)
%                 dymax = dy2;
%             else
%                 dymax = dy;
%                 dy = dymax;
%             end
%         end 
%         f0 = sx-e.*sin(sx)-M;
%         f1 = dx-e.*sin(dx)-M;
%         trovato = ((f0.*f1)>0);
%         x = x + 0.1;
%     end
    E = M;
    k = 1;
    err = 1e-10;
    % stabilito intervallo di ricerca (sx,dx) e max valore derivata dymax;
    while (k>err)
        y = e*sin(E)+M;
        k = abs(abs(E)-abs(y));
        E = y;
    end
    % trovato E con un errore inferiore a 0.1*10^(-4);
    %fprintf(' La soluzione E è stata trovata nell''intervallo [%2.5f,%2.5f]',sx,dx);
    %fprintf(' \n errore inferiore a %1.2e: [rad] E = %3.5f',err,E);
end
