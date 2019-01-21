clc;clear all;close all;
path(pathdef);

% set up mosek
addpath(genpath('../../mosek/8/toolbox/'))
javaaddpath ../../mosek/8/tools/platform/linux64x86/bin/mosekmatlab.jar

% set up gurobi
cd '/home/zexiang/PROG/gurobi8.1.0_linux64/gurobi810/linux64/matlab'
gurobi_setup

cd '/home/zexiang/PROG/PCIS/pcis_projects'

addpath(genpath('pcis/lib/'))
% addpath(genpath('cps-inv/library'));

cd tbxmanager/
startup
clc;

cd ..
mpt_init

addpath(genpath('preview'))
cd preview
% addpath(genpath('int_estim'))
% cd int_estim
% addpath(genpath('acc_disturb'))
% cd acc_disturb
