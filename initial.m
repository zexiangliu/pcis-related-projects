clc;clear all;close all;
path(pathdef);

% set up mosek
addpath(genpath('../../mosek/8/toolbox/'))
javaaddpath ../../mosek/8/tools/platform/linux64x86/bin/mosekmatlab.jar


addpath(genpath('pcis/lib/'))
% addpath(genpath('cps-inv/library'));

cd tbxmanager/
startup
clc;

cd ..

% addpath(genpath('preview'))
% cd preview
% addpath(genpath('int_estim'))
% cd int_estim
% addpath(genpath('acc_disturb'))
% cd acc_disturb
