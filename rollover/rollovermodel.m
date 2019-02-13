function [A, B, C, D, Cplot, Dplot, Ay, by, H]  = rollovermodel(vext, dT)
% Rollover LPV model from the article by Solmaz, Corless and Shorten
% titled "A methodology for the design of robust rollover prevention
% controllers for automotive vehicles: Part 2- Active steering"
% Proceedings of the 2007 American Control Conference, July 11-13, 2007
% pp. 1606-1611; 

% Model parameters: see Table II
g = 9.81;
m = 1224;
Jxx = 362.6;
Jzz = 1280;
lv  = 1.102;
lh  = 1.25;
T   = 1.51;
h   = 0.375;
c   = 4000;
k   = 36075;
Cv  = 90240;
Ch  = 180000;

% Definitions: see (1), (2)
Jxeq = Jxx+m*h^2;
sg   = Cv+Ch;
rho  = Ch*lh-Cv*lv;
kp   = Cv*lv^2+Ch*lh^2; % note kp (kappa) is different from k

% vehicle velocity is an external parameter
v    = vext; 
 
% Linearization: see (3), (4):
Ac=[-sg*Jxeq/m/v/Jxx,  rho*Jxeq/m/v/Jxx - v,  -h*c/Jxx,  h*(m*g*h-k)/Jxx;
   rho/Jzz/v,         -kp/Jzz/v,           0,         0;
   -h*sg/Jxx/v,       h*rho/v/Jxx,        -c/Jxx,     (m*g*h-k)/Jxx;
   0,                  0,                  1,           0];

% states: lateral velocity of the GC, yaw rate of the unsprung mass, roll
% rate of the sprung mass and roll angle of the sprung mass

Bc = [Cv*Jxeq/m/Jxx, Cv*lv/Jzz,h*Cv/Jxx,0]';  %steering angle in rad 
%  steering angle is modifiable by AFS

Bc = Bc*pi/180/17.5; % steering angle at driver wheel in deg

Cc   = [0, 0, -2*c/m/g/T, -2*k/m/g/T; 0, 0, 0, 0]; 
    % Load transfer ratio - should be within [-1,+1] interval
Dc   = [0; 1/180*pi]; % Steering angle in rad

syspc = ss(Ac, Bc, Cc, Dc); 
syspd = c2d(syspc, dT);
[A, B, C, D, Ts] = ssdata(syspd);

% dc gain from [steering angle] to ltr
n=size(A,1);
H  = C*inv(eye(n,n)-A)*B+D; 

thdmax = 0.95; % 0.05 margin from 1
dltmax = 360/180*pi;  % +/- 360 deg converted into rads 
Ay     = [1, 0;
         -1, 0; 
          0, 1; 
          0, -1];
by     = [thdmax;thdmax;dltmax;dltmax];

Cplot = [];
Dplot = [];
return;