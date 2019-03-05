% case study code for preview paper: cruise control 
clc;clear all;close all;
%% Parameters
param.m = 1650;
param.f0 = 0.1;
param.f1 = 5;
param.f2 = 0.25;
param.g = 9.82;

% Bounds

param.vmin = 0;
param.vmax = 35;

% theta varying in several intervals
tmin = 0;
tmax = 20;
param.thetamin = [sind(-0.5), sind(29.5), sind(-0.5)];
param.thetamax = [sind(0.5), sind(30.5), sind(0.5)];
param.umax = 0.66*param.m*param.g;
param.umin = -0.65*param.m*param.g;

% Time discretization
param.h = 0.01;

% theta varying in the full range
param2 = param;
% param2.thetamin = sind(-0.5);
% param2.thetamax = sind(20.5);

param2.thetamin = sind(-0.5);
param2.thetamax = sind(30.5);

dyn_list = get_cc_dyn(param);

dyn_all = get_cc_dyn(param2);
dyn_all = dyn_all{1};

ts = [0 1 0 ; 
      1 0 1 ;
      0 0 0 ;];

t_prev = [0 2 0 ; 
          2 0 2 ;
          0 0 0 ];
t_hold = [3 3 inf;
          inf inf inf];
  
pa = PrevAuto(3,ts,dyn_list,t_prev,t_hold);

X = Polyhedron('A', [1; -1], 'b', [32.0;-31.95]);

X_list = {X,X,X};

rho = 1e-6;
pre = @(dyn,X) dyn.pre(X,rho);
vol = @(X) X.volume;
inter = @(X1,X2) minHRep(X1.intersect(X2));
isEmpty = @(X) isEmptySet(X);

rho_ball = Polyhedron('A', [eye(dyn_list{1}.nx); -eye(dyn_list{1}.nx)], ...
                      'b', repmat(rho,2,1));
isContain = @(C1,C2) C1-rho_ball <= C2;
%%
[W,volume] =pa.win_always(X_list,pre,vol,inter,isEmpty,isContain,[],1);

W2 = dyn_all.win_always(X,rho,1,1);