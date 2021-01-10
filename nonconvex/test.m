clc;clear all;close all;
constant_3d
[dyn,A,B,E,D,XU] = overtake_3d();

S0 = Polyhedron('lb',[-inf,v_min,y_min,u_min,vy_min],'ub',[inf,v_max,y_max,u_max,vy_max]);
S1 = S0.intersect(Polyhedron('lb',[h_min,-inf,-inf,-inf,-inf],'ub',[inf,inf,inf,inf,inf]));
S2 = S0.intersect(Polyhedron('lb',[-inf,-inf,y_mid,-inf,-inf],'ub',[inf,inf,inf,inf,inf]));
S3 = S0.intersect(Polyhedron('lb',[-inf,-inf,-inf,-inf,-inf],'ub',[-h_min,inf,inf,inf,inf]));
S1.minHRep;
S2.minHRep;
S3.minHRep;
S = [S1,S2,S3];
[A_new,B_new,E_new,D_new,S_new,K] = nilpotent_lift(A,B,E,D,S);

