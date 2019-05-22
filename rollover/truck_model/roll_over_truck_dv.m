clc;clear all;
load DumpTruckModel_120_New.mat;
load DumpTruckModel_Uncertainty.mat;

dt = 0.03; 

% System matrices: already discrete-time
Adt = expm(Ac*dt);

Bdt = Bc*dt;

C = Cc;

delta_Adt = blkdiag(DAc*dt,0);

% Bounds

xmax = [80; 200; 200; 100];
ymax = 1; 
umax = 160; 

% QQ = diag(1./xmax);
% Adt = QQ*Adt/QQ;
% Bdt = QQ*Bdt;
% C = C/QQ;
% delta_Adt = QQ*delta_Adt/QQ;
% xmax = [1; 1; 1; 1];

X = Polyhedron('A', [eye(5); -eye(5); [C, 0]; [-C, 0]], 'b', [xmax; umax; xmax; umax; ymax; ymax]);

P = Polyhedron('H', [eye(1) 1; -eye(1) 1]); % 1 works
XU = Polyhedron('H', [0 0 0 0 0 1 umax; 0 0 0 0 0 -1 umax]); % 1 works

d = Dyn([Adt, Bdt; zeros(1,4), 1],[0;0;0;0;0],[0;0;0;0;0], XU, {delta_Adt}, {zeros(5,1)}, P);

profile on
Xinv = win_always(d, X, 0, false, 1,10);
profile viewer

save data_0413.mat



