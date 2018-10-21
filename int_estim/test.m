clc;clear all;close all;

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

% input sequence
u = [0 0 0 0;
     0.7064 0.0636 0 -0.01];

% sampling time
dt = 0.25;

[list_d1, list_d2, d1, d2] = get_dyn(u, dt, param);

% safe set: h in [-300, -10]U[10, 300]
H_S = [eye(4);-eye(4)];
h_S1 = [30;2.5;300;25;-16;0.9;-10;0];
h_S2 = [30;2.5;-10;25;-16;0.9;300;0];

S1 = Polyhedron('A',H_S,'b',h_S1);
S2 = Polyhedron('A',H_S,'b',h_S2);

% S is the safe set that consists of two polytopes
S = PolyUnion([S1,S2]);

% target set V
H_V = [eye(4);-eye(4)];
h_V1 = [25;1.5;20;25;-20;0.9;-10;0];
h_V2 = [25;1.5;-10;25;-20;0.9;20;0];

V1 = Polyhedron('A',H_S,'b',h_S1);
V2 = Polyhedron('A',H_S,'b',h_S2);

% V is the intersection of two invariant sets
V = PolyUnion([V1,V2]);
Va_fix = V;
Va_bnd = V;
Vc_fix = V;
Vc_bnd = V;

for i = 1:size(u,2)
    tmpVa = list_d1{i}.pre(Va_fix,0);
    Va_fix = IntersectPolyUnion(tmpVa,S);
    tmpVa_bnd = d1.pre(Va_bnd,0);
    Va_bnd = IntersectPolyUnion(tmpVa_bnd,S);
    
    tmpVc = list_d2{i}.pre(Vc_fix,0);
    Vc_fix = IntersectPolyUnion(tmpVc,S);
    tmpVc_bnd = d2.pre(Vc_bnd,0);
    Vc_bnd = IntersectPolyUnion(tmpVc_bnd,S);
end
%% computing winning sets

% Winning set with fixed input sequences
Win = IntersectPolyUnion(Va_fix,Vc_fix,1000);

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