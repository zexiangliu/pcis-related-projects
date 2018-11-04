clc;clear all;close all;
% add piecewise behavior of the v_ey

% Parameters used in the intention estimation model (see the doc related
% to the model used in the intention estimation

param.f1 = 0.1;
param.KC1 = 0.01;
param.KC2 = -1.5;
param.KC3 = 0.05;
param.vdes = 25;
param.dC = [-0.3, 0.3];
param.KA = 0.05;
param.dA = [-0.3, 0.3];
param.a_ex = [-3, 3];
param.v_ey = [-0.9, 0.9];
param.v_ex = [16,30];
param.y_e = [-0.9,4.5];
param.h = [-300,300];
param.v_lx = [0,25];
param.w_ex = [0,0];
param.w_ey = [0,0];
param.w_Lx = [0,0];
param.beta = 0.135;
param.v_ex_db = 20;

% input sequence
u = [0 0 0 0;
     0.7064 0.0636 0 -0.01];

% sampling time
dt = 0.25;

[list_d1, list_d2, d1, d2] = get_pwadyn(u, dt, param);

% safe set: h in [-300, -10]U[10, 300]
H_S = [eye(4);-eye(4)];
h_S1 = [30;2.5;300;25;-16;0.9;-10;0];
h_S2 = [30;2.5;-10;25;-16;0.9;300;0];

% target set V
H_V = [eye(4);-eye(4)];
h_V1 = [25;1.5;20;25;-20;0.9;-10;0];
h_V2 = [25;1.5;-10;25;-20;0.9;20;0];

inv_caut = load("inv_caut.mat");
V1 = PolyUnion([inv_caut.Xr{1},inv_caut.Xr{2}]);
V1.reduce;

S = inv_caut.S.Set(1);
inv_ann = load("inv_ann.mat");
V2 = PolyUnion([inv_ann.Xr{1},inv_ann.Xr{2}]);
V2.reduce;
% 
% V is the intersection of two invariant sets
V = IntersectPolyUnion(V1,V2);
Va_fix = V;
Va_bnd = V;
Vc_fix = V;
Vc_bnd = V;

%% T step backward reachability computation

for i = 1:size(u,2)
    
    disp("The iteration with "+num2str(i)+"th input.");
    
    tmpVa = list_d1{i}.pre(Va_fix,1e-6);
    tmpVa.reduce;
    Va_fix = IntersectPolyUnion(tmpVa,S);
    tmpVa_bnd = d1.preUnion(Va_bnd,1e-6);
	tmpVa_bnd.reduce;
    Va_bnd = IntersectPolyUnion(tmpVa_bnd,S);
    
    tmpVc = list_d2{i}.pre(Vc_fix,1e-6);
    tmpVc.reduce;
    Vc_fix = IntersectPolyUnion(tmpVc,S);
    tmpVc_bnd = d2.preUnion(Vc_bnd,1e-6);
    tmpVc_bnd.reduce;
    Vc_bnd = IntersectPolyUnion(tmpVc_bnd,S);
end
%% computing winning sets

% Winning set with fixed input sequences

Win = IntersectPolyUnion(Va_fix,Vc_fix,50);

% Winning set with bounded inputs
Win_cnv = IntersectPolyUnion(Va_bnd,Vc_bnd);

%% Approximation

assert(ApproxContains(Va_fix,Va_bnd));
assert(ApproxContains(Vc_fix,Vc_bnd));
assert(ApproxContains(Win,Win_cnv));

%% Visualization
proj_Win = projectionPolyUnion(Win,[1,2,3]);
proj_Win_cnv = projectionPolyUnion(Win_cnv,[1,2,3]);

figure(1);
proj_Win.plot;

figure(2);
proj_Win_cnv.plot;