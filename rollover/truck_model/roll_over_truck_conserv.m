clear all;
load DumpTruckModel_120_New.mat;
load DumpTruckModel_Uncertainty.mat;

dt = 0.03;

% set up random seed
seed = 1;
rng(seed)

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

P = Polyhedron('H', [eye(4) 0.1*xmax; -eye(4) 0.1*xmax]); % 1 works
XU = Polyhedron(); % 1 works

d = Dyn([Adt, Bdt; zeros(1,4), 1],[0;0;0;0;0],[], XU, {zeros(5),zeros(5),zeros(5),zeros(5)}, {delta_Adt(:,1),...
    delta_Adt(:,2),delta_Adt(:,3),delta_Adt(:,4)}, P);

tic;
Xinv = win_always_rho_inv(d, X, @rho_var3, 0, 1);
t = toc;

save data_0420_test.mat



