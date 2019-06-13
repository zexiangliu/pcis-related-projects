% sanity check
clear all;close all;clc;
load lk_inv_new_rd_5.mat
load res_T1_H2.mat
W1 = W;
clear W;
load res_T2_H2.mat
W2 = W;

Ctest1 = cell(5,1);
Ctest2 = cell(5,2);

Ctest1{1} = Polyhedron('A',W1{1}.A,'b',W1{1}.b);

Ctest1{2} = Polyhedron('A',W1{2}.A,'b',W1{2}.b);

Ctest1{4} = Polyhedron('A',W1{4}.A,'b',W1{4}.b);

Ctest1{5} = Polyhedron('A',W1{5}.A,'b',W1{5}.b);
% 
Ctest1{1} == Ctest1{5}
Ctest1{2} == Ctest1{4}

Ctest2{1} = Polyhedron('A',W2{1}.A,'b',W2{1}.b);

Ctest2{2} = Polyhedron('A',W2{2}.A,'b',W2{2}.b);

Ctest2{4} = Polyhedron('A',W2{4}.A,'b',W2{4}.b);

Ctest2{5} = Polyhedron('A',W2{5}.A,'b',W2{5}.b);

Ctest_all = Polyhedron('A',W_all.A,'b',W_all.b);
% 
Ctest2{1} == Ctest2{5}
Ctest2{2} == Ctest2{4}

%%
idx = 2
figure;
hold on;
plot(Ctest2{idx}.slice(3,0.05),'color','g');
plot(Ctest1{idx}.slice(3,0.05),'color','b');
plot(Ctest_all.slice(3,0.05),'color','r');

idx = 4
figure;
hold on
plot(Ctest2{idx}.slice(3,-0.05),'color','g');
plot(Ctest1{idx}.slice(3,-0.05),'color','b');
plot(Ctest_all.slice(3,-0.05),'color','r');
