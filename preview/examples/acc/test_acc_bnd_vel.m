clc;clear all;close all;
mptopt('lpsolver', 'GUROBI', 'qpsolver', 'GUROBI');
%% Parameters
param.m = 1650;
param.f0 = 0.1;
param.f1 = 5;
param.f2 = 0.25;
param.g = 9.82;

% Bounds

param.vmin = 0;
param.vmax = 35;

param.v_l = [25,30];

% theta varying in several intervals
tmin = -10;
tmax = 10;
num_seg = 3;
param.thetamin = linspace(sind(tmin),sind(tmax-1),num_seg);
param.thetamax = linspace(sind(tmin+1),sind(tmax),num_seg);
param.umax = 0.2*param.m*param.g;
param.umin = -0.2*param.m*param.g;

% Time discretization
param.h = 0.01;

% theta varying in the full range
param2 = param;
param2.thetamin = sind(tmin);
param2.thetamax = sind(tmax);

dyn_list = get_acc_dyn_bnd_vel2(param);

dyn_all = get_acc_dyn_bnd_vel2(param2);
dyn_all = dyn_all{1};

ts = [0 1 0; 
      1 0 1;
      0 1 0];

t_prev = [0 5 0; 
          5 0 5;
          0 5 0];
t_hold = [20   20   20;
          inf inf inf];
  
pa = PrevAuto(num_seg,ts,dyn_list,t_prev,t_hold);

% safe sets: uphill, zero, downhill
X_up = Polyhedron('A', [1 0; -1 0;0 1;0 -1], ...
    'b', [32;-18;300;-5]);
X_zero = Polyhedron('A', [1 0; -1 0;0 1;0 -1],...
    'b', [32;-16;300;-5]);
X_down = Polyhedron('A', [1 0; -1 0;0 1;0 -1],...
    'b', [30;-16;300;-5]);

X = intersect(X_up,X_down);

X_list = {X_down,X_zero,X_up};

rho = 1e-6;
pre = @(dyn,X) dyn.pre(X,rho);
vol = @(X) X.volume;
inter = @(X1,X2) minHRep(X1.intersect(X2));
isEmpty = @(X) isEmptySet(X);

rho_ball = Polyhedron('A', [eye(dyn_list{1}.nx); -eye(dyn_list{1}.nx)], ...
                      'b', repmat(rho,4,1));
isContain = @(C1,C2) C1-rho_ball <= C2;

%%
W2 = dyn_all.win_always_rho_inv(X,@rho_var,1,1);
% W2 = dyn_all.win_always_rho(X, 0.0006,1,1);
% W2 = dyn_all.win_always(X,0.0006,1,1);

% [W,volume] = pa.win_always(X_list,pre,vol,inter,isEmpty,isContain,[],1);
