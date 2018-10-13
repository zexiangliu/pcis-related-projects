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
%%
% X = Polyhedron('A', [1; -1], 'b', [32;-16]);

% Xinv1 = win_always(dyn{1}, X, 0.00, false, 1);

% Pre1 = d1.pre(X,0);

% Pre2 = d2.pre(X,0);

%%
% plot(Xinv, 'alpha', 0.75)
% xlabel('$x$', 'interpreter', 'latex')
% ylabel('$\dot x$', 'interpreter', 'latex')
% zlabel('$\ddot x$', 'interpreter', 'latex')