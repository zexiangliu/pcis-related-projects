clc;clear all;
load DumpTruckModel_120_New.mat;
load DumpTruckModel_Uncertainty.mat;

dt = 0.03; 

% System matrices: already discrete-time

sys = ss(Ac,Bc,eye(4),[]);
sysd = c2d(sys,dt);

Adt = sysd.A;

Bdt = sysd.B;

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
XU = Polyhedron(); % 1 works

d = Dyn([Adt, Bdt; zeros(1,4), 1],[0;0;0;0;0],[], XU, {delta_Adt}, {zeros(5,1)}, P);

Xinv = win_always_rho_inv(d, X, @rho_var3, false, 1);

save data_0420_test.mat



