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
tmin = -10;
tmax = 12;
num_seg = 5;
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

dyn_list = get_acc_dyn(param);

dyn_all = get_acc_dyn(param2);
dyn_all = dyn_all{1};

ts = [0 1 0 0 0; 
      0 0 1 0 0;
      0 0 0 1 0;
      0 0 0 0 1;
      1 0 0 0 0];

t_prev = [0 2 0 0 0; 
      0 0 2 0 0;
      0 0 0 2 0;
      0 0 0 0 2;
      2 0 0 0 0];
t_hold = [3 3 3 3 30;
          inf inf inf inf 100];
  
pa = PrevAuto(num_seg,ts,dyn_list,t_prev,t_hold);

X = Polyhedron('A', [1; -1], 'b', [32;-16]);

X_list = {X,X,X,X,X};

pre = @(dyn,X) dyn.pre(X,0);
vol = @(X) X.volume;
inter = @(X1,X2) minHRep(X1.intersect(X2));
%%
[W,volume] = pa.win_always(X_list,pre,vol,inter,[],1);

% W2 = dyn_all.win_always(X,0,0,1);