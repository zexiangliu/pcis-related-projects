clc;clear all;close all;

load res_pre_int.mat

pre_V = pre_int_xu(dyn_a, dyn_c, V, rho, [], [], true);


%%

v = V.Set(1).V;

alpha = rand(1,size(v,1));
alpha = alpha/sum(alpha);

u_range = pre_V.slice([1,2,3,4],(alpha*v(:,1:4))');
plot(u_range)