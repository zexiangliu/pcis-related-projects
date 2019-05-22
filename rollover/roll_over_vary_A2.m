clc;clear all;close all;
% Compute an invariant set for a triple integrator system
mptopt('lpsolver', 'GUROBI', 'qpsolver', 'GUROBI');
load LinearizeModel.mat
dt = 0.01; 

% System matrices: already discrete-time
Adt0 = eye(4) + A0*dt; 
Adt1 = A1*dt;

% 
Bdt = B0*dt;

C = C0;


% Bounds
xmax = [100; 10; 20; 2];
ymax = 0.95; 
umax = 1e-3*142.73; % see above Fig. 1,  https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=5280801
umin = -umax;

QQ = diag(1./xmax);
Adt0 = QQ*Adt0/QQ;
Adt1 = QQ*Adt1/QQ;
Bdt = QQ*Bdt;
xmax = [1; 1; 1; 1];
C = C/QQ;

X = Polyhedron('A', [eye(4); -eye(4); C; -C], 'b', [xmax; xmax; ymax; ymax]);
%  X = Polyhedron('A', [C; -C], 'b', [ymax; ymax]);

XU = Polyhedron('H', [0 0 0 0 1 umax;
		      0 0 0 0 -1 umax]);
                  
P = Polyhedron('lb',-1, 'ub', 1);
% rho_var = @(n) 1e-4;
% profile on;
d = Dyn(Adt0, Bdt*umax, zeros(4,1), XU,  {Adt1}, {zeros(4,1)}, P);
Xinv_max = win_always_rho_var(d, X, @rho_var, false, 1);
% save('Xinv_max.mat','Xinv_max');
% profile viewer;

d = Dyn(Adt0, Bdt*umin, [], XU,  {Adt1}, {zeros(4,1)}, P);
Xinv_min = win_always_rho_var(d, X, @rho_var, false, 1);
% save('Xinv_min.mat','Xinv_min');



