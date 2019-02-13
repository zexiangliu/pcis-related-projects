function main
%
% -- Constraint enforcement for vehicle rollover dynamics to prevent
%    rollover
%
%    References:
%   
%    [1] Rollover LPV model from the article by Solmaz, Corless and Shorten
%    titled "A methodology for the design of robust rollover prevention
%    controllers for automotive vehicles: Part 2 - Active steering"
%    Proceedings of the 2007 American Control Conference, July 11-13, 2007
%    pp. 1606-1611;
%
%    [2] Kolmanovsky, I.V., Gilbert, E.G., and Tseng, E., "Constrained 
%    control of vehicle steering," Proceedings  of 2009 IEEE Multiconference 
%    on Systems and Control, St. Petersburg, Russia, May, 2009, pp. 576-581.      
%
%    Example implemented by I. Kolmanovsky, Last updated: Oct. 5,2014


close all; clear all;
dT    = 0.01;    % discrete-time sampling period
vlong = 22.5;    % longitudinal velocity 
[A, B, C, D, Cplot, Dplot, Ay, by, H]  = rollovermodel(vlong, dT); % discrete time model

% ---  Construct O-infinity (brute force)  ----
tstar = 100; % horizon
AOi = []; bOi = [];
n = size(A,1);
I = eye(n,n);
for t=0:1:tstar,
    AOi = [AOi; Ay*(C*inv(I-A)*(I-A^t)*B+D), Ay*(C*A^t)];
    bOi = [bOi; by];
end;

% --- Augment tightened steady-state constraints ----
epsi = 0.01;
H    = C*inv(I-A)*B+D;
AOi  = [AOi; Ay*H,Ay*C*zeros(n,n)];  
bOi  = [bOi; by*(1-epsi)];

% --- Eliminate redundant inequalities ---
if exist('lp.m','file')>0,
    [AOi,bOi] = elimm1(AOi, bOi,1e-12);
end;

% --- Define reference command profile ---
Rhist = []; % fishhook-like maneuver
tf     = 5.5;
indmax = floor(tf/dT);  % number of samples/final time
% T1level = 110;  % at 35
% T1level = 150;    % at 22.5
T1level = 140;  % level where steady-state is admissible at 22.5
Rhist   = [];
t0      = T1level/720; % initial steer
T1      = 0.61;        % at T1level
t1      = t0 + T1;
%  t2      = 2*T1level/720+t1;
t2      = 2*T1level/720/2+t1;
T2      = 2.0;
t3      = t2 + T2;
T3      = 1.0;
t4      = t3 + T3;
for (i=1:1:indmax+1),
    tc = dT*(i-1);
    if tc<=t0,
        Rhist = [Rhist;T1level/t0*tc];
    elseif tc > t0 & tc <= t1,
        Rhist = [Rhist;T1level];
    elseif tc > t1 & tc<=t2,
        Rhist = [Rhist;T1level-(tc-t1)/(t2-t1)*(2*T1level)];
    elseif tc > t2 & tc<=t3,
        Rhist = [Rhist;-T1level];
    elseif tc >t3 & tc<=t4,
        Rhist = [Rhist;-T1level+(tc-t3)/T3*T1level];
    elseif tc>t4,
        Rhist = [Rhist;0];
    end
end

% --- Perform simulations ---
x0 = [0, 0, 0, 0]'; v0 = [0];
[Thist, Vhist, Xhist, Kphist, Rhist,Xhist0] = flow(v0, x0, Rhist, A, B, AOi, bOi);

% --- Compute constraints history ---
Chist  = [ ]; % with RG
Chist0 = [ ]; % without RG
Yhist  = [ ];
for (k = 1:1:length(Thist)),
    
    y  = (C*Xhist(k,:)' + D*Vhist(k,:)');
    Chist(k,:) = (Ay*y - by)';
    Yhist(k,:) = y(:)';
    
    y0  = (C*Xhist0(k,:)' + D*Rhist(k,:)');
    Chist0(k,:) = (Ay*y0 - by)'; 
    
end;

% -- Compute "plot" outputs history ---
if ~isempty(Cplot), 
    yplothist = [];
    for (k = 1:1:length(Thist)),
        yplothist(k,:) = (Cplot*Xhist(k,:)' + Dplot*Vhist(k,:)');
    end;
end;

clr = ['k','b','m','r','g','y'];

for (cfg = 1:1:size(Rhist,2)),
    figure(cfg); pl = plot(Thist*dT,Vhist(:,cfg),[clr(1),'--']);
    set(pl,'linewidth',3)
    hold on;
    pl = plot(Thist*dT,Rhist(:,cfg),[clr(1),'-']);
    set(pl,'linewidth',3)
    if ~isempty(Cplot),    pl = plot(Thist*dT,yplothist(:,cfg),[clr(1)]);
        set(pl,'linewidth',3); end;
    xlabel('Time (sec)','fontsize',16);
    ylabel('r, v, y','fontsize',16);
    set(gca,'fontsize',16)
end;
cfgc = cfg + 1;

for ( k = 1:1:size(Chist,2) ),
    kc = (k + 1 - floor(k/length(clr))*length(clr));
    figure(cfgc); pl = plot(Thist*dT,Chist(:,k),[clr(kc),'-']);
    set(pl,'linewidth',3)
    hold on;
    xlabel('Time (sec)','fontsize',16);
    ylabel('Constraints','fontsize',16);
    set(gca,'fontsize',16)
end;

figure(cfgc+2);
pl = plot(Thist*dT,Kphist,['k','-']);
set(pl,'linewidth',3)
hold on;
xlabel('Time (sec)','fontsize',16);
ylabel('\kappa','fontsize',16);
set(gca,'fontsize',16)

% --- Compute vehicle trajectory on X-Y plane ----
psi = 0;
psi0 =0;
X   = 0;
Y   = 0;
X0  = 0;
Y0  = 0;
PosHist  = [];
PosHist0 = [];
cnrViolated0 =[];
for (k=1:1:length(Thist)),
    posHist(k,:)=[X,Y];
    psidot = Xhist(k,2);
    bt     = atan(Xhist(k,1)/sqrt(vlong^2 - Xhist(k,1)^2)); % sideslip angle
    Xdot   = vlong*cos(psi + bt);
    Ydot   = vlong*sin(psi + bt);
    psi = psi + psidot*dT;
    X   = X   + Xdot*dT;
    Y   = Y    + Ydot*dT;
    
    posHist0(k,:)=[X0,Y0];
    psidot0 = Xhist0(k,2);
    bt0     = atan(Xhist0(k,1)/sqrt(vlong^2-Xhist0(k,1)^2));
    Xdot0   = vlong*cos(psi0 + bt0);
    Ydot0   = vlong*sin(psi0 + bt0);
    psi0    = psi0 + psidot0*dT;
    X0      = X0   + Xdot0*dT;
    Y0      = Y0    + Ydot0*dT;
    if max(Chist0(k,:)>0), cnrViolated0(k)=1; else, cnrViolated0(k)=0; end;
end;
figure(cfgc+3);pl=plot(posHist(:,1),posHist(:,2));
set(pl,'linewidth',3)
hold on;pl=plot(posHist0(:,1),posHist0(:,2),'r--');
set(pl,'linewidth',3)
inds = find(cnrViolated0>0.5);
plot(posHist0(inds,1),posHist0(inds,2),'g*');
xlabel('X[m]','fontsize',16);
ylabel('Y[m]','fontsize',16);
set(gca,'fontsize',16)

return


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


% --- Compute K ---
function K = findK(v, x, r,  A, Bv, APd, bPd)

toll = 1e-6;

r_minus_v = r - v;
xGG       = [v(:); x(:)];  

szr = length(r);
szP = size(APd,1);

KL = 0;
KU = 1;

for (i = 1:1:szP),
 
    Aco = APd(i, 1:szr)*r_minus_v;    %compute Aco
    bco = bPd(i) - APd(i,:)*xGG;      %compute bco
    
    if (bco >= 0), 
        if (Aco <= 0),
        ;
        else,
            KU = min([KU;bco/Aco]);
        end
    else,
        if (Aco>bco + toll),
            KU = 0;     
        else,
            KL = max([KL; bco/Aco]);
        end;
    end;
end;

if (KL > KU),
    K = 0;
else,
    K = KU;
end;

return;


% --- Simulate reference governor ---
function [Thist, Vhist, Xhist, Kphist, Rhistout, Xhist0] = flow(v0, x0, Rhist, A, B, APd, bPd)

Vhist   = [];
Xhist   = [];
Xhist0   = [];
Kphist  = [];
Rhistout =[];
Thist   = [];

xcurr   = x0;
vcurr   = v0;
tcurr   = 0;
xcurr0  = x0;

szRhist = size(Rhist,1);

for (i=1:1:(szRhist-1)),
    rcurr =  Rhist(i,:)';
    Thist = [Thist; tcurr];
    Xhist = [Xhist; xcurr(:)'];
    Xhist0 = [Xhist0; xcurr0(:)'];
    Vhist = [Vhist; vcurr(:)'];
    Rhistout = [Rhistout; rcurr(:)'];
    Kp    =  findK(vcurr, xcurr, rcurr,  A,  B, APd, bPd);
    Kphist = [Kphist;Kp];
    vcurr =  vcurr   + Kp*(rcurr - vcurr);
    xcurr =  A*xcurr + B*vcurr;
    xcurr0=  A*xcurr0+ B*rcurr;
    tcurr =  tcurr + 1.0;
end
return;

% --- Eliminate redundant constraints -----

function [A1,b1] = elimm1(A,b,toll)

%   Eliminate redundant constraints in Ax<=b
%   The output set is A1<=b1

if (nargin==2),
    toll = 1e-6;
end

A1      = A;
b1      = b;
sizeA   = size(A);
n       = sizeA(1);
options = optimset('Display','off');

for (i = 1:1:n),
    f  = -A1(1,:);
    Aa = A1(2:n,:);
    ba = b1(2:n);
    hx = lp(f,Aa,ba,[],[],[],[],-1);
       % hx = linprog(f,Aa,ba,[],[],[],[],[],options);
    hxval = -f*hx;
    if (hxval<b(i)+toll),
        A1 = Aa;
        b1 = ba; n = n-1;
    else,
        A1 = [Aa;-f];
        b1 = [ba;b1(1)];
    end
    if (n==1),
        break; disp('Warning: only one active constraint remains');
    end;
end;

return;