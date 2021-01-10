clc;clear all;close all;
constant_4d
[dyn,A,B,E,D,XU] = overtake_4d();

S0 = Polyhedron('lb',[-inf,-inf,v_min,y_min,u_min,vy_min],'ub',[inf,inf,v_max,y_max,u_max,vy_max]);
S1 = Polyhedron('H',[-1 0 0 0 0 0 -h_min
                      0 0 0 1 0 0 y_mid
                      0 0 0 -1 0 0 -y_min]);
S2 = Polyhedron('H',[1 0 0 0 0 0 -h_min
                      0 0 0 1 0 0 y_mid
                      0 0 0 -1 0 0 -y_min]);
S3 = Polyhedron('H',[ 0 -1 0 0  0 0 -h_min
                      0 0 0 1 0 0 y_max
                      0 0 0 -1 0 0 -y_mid]);
S4 = Polyhedron('H',[0 1 0 0 0 0 -h_min
                     0 0 0 1 0 0 y_max
                      0 0 0 -1 0 0 -y_mid]);
S5 = Polyhedron('H',[-1 0 0 0 0 0 -h_min
                      0 -1 0 0 0 0 -h_min
                      0 0 0 1 0 0 y_max
                      0 0 0 -1 0 0 -y_min]);
S6 = Polyhedron('H',[-1 0 0 0 0 0 -h_min
                      0 1 0 0 0 0 -h_min
                      0 0 0 1 0 0 y_max
                      0 0 0 -1 0 0 -y_min]);
S7 = Polyhedron('H',[1 0 0 0 0 0 -h_min
                      0 -1 0 0 0 0 -h_min
                      0 0 0 1 0 0 y_max
                      0 0 0 -1 0 0 -y_min]);
S8 = Polyhedron('H',[1 0 0 0 0 0 -h_min
                      0 1 0 0 0 0 -h_min
                      0 0 0 1 0 0 y_max
                      0 0 0 -1 0 0 -y_min]);
S1 = S0.intersect(S1);
S1.minHRep;
S2 = S0.intersect(S2);
S2.minHRep;
S3 = S0.intersect(S3);
S3.minHRep;
S4 = S0.intersect(S4);
S4.minHRep;
S5 = S0.intersect(S5);
S5.minHRep;
S6 = S0.intersect(S6);
S6.minHRep;
S7 = S0.intersect(S7);
S7.minHRep;
S8 = S0.intersect(S8);
S8.minHRep;


S = [S1,S2,S3,S4,S5,S6,S7,S8];

L = 40;
C2_test = get_lifted_set(A,B,E,D,S,L,'alg2');
C3_test = get_lifted_set(A,B,E,D,S,L,'alg3');

save overtake_4d_40.mat