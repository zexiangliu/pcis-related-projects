clc;clear all;close all;
constant_3d
param.vL_min = 0;
param.vL_max = 0;
[dyn,A,B,E,D,XU] = avoid_3d(param);

h1 = 50;
h2 = 60;
h3 = 80;

S0 = Polyhedron('lb',[0,v_min,y_min,u_min,vy_min],'ub',[inf,v_max,y_max,u_max,vy_max]);
S1 = Polyhedron('lb',[-inf,-inf,-inf,-inf,-inf],'ub',[h1,inf,inf,inf,inf]);
S2 = Polyhedron('lb',[-inf,-inf,y_mid,-inf,-inf],'ub',[h3,inf,inf,inf,inf]);
S3 = Polyhedron('lb',[h2,-inf,-inf,-inf,-inf],'ub',[h3,inf,inf,inf,inf]);
S4 = Polyhedron('lb',[h2,0,y_min,u_min,vy_min],'ub',[inf,v_max,y_mid,u_max,vy_max]);
S1 = S1.intersect(S0);
S2 = S2.intersect(S0);
S3 = S3.intersect(S0);
S1.minHRep;
S2.minHRep;
S3.minHRep;
S4.minHRep;

S = [S1,S2,S3,S4];

L = 100;
x0 = [80;0;0;8000;0];
[C2,h] = get_lifted_set(A,B,E,D,S,L,'alg2');
C3 = get_lifted_set(A,B,E,D,S,L,'alg3',10);

save avoid_40.mat