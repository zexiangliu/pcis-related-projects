clc;clear all;close all;
%% fixed longitudinal speed.
mptopt('lpsolver', 'CDD', 'qpsolver', 'GUROBI');

vlong = 22.5;
dT = 0.01;

[A, B, C, D, Cplot, Dplot, Ay, by, H]  = rollovermodel(vlong, dT);


y_min = -0.95;
y_max = 0.95;

F = zeros(4,1);

XU = Polyhedron("lb",[-inf,-inf,-inf,-inf,-by(end)],...
    "ub",[inf,inf,inf,inf,by(end)]);
XU.minHRep;

dyn = Dyn(A,F,B,XU,[],[],[],[],[],[]);

Safe = Polyhedron('H',[C(1,:) by(1);
                       -C(1,:) by(1)]);
Safe2 = Polyhedron('lb',[-1e3,-1e3,-1e3,-1e3],'ub',[1e3,1e3,1e3,1e3]);

% Safe = Safe.intersect(Safe2);
Safe.minHRep;

rho = 1e-3;
C = dyn.win_always(Safe,rho,0,1);