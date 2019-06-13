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
idx = 1;
dim = [1 2 4];
fig=figure;
hold on;

W_new = Polyhedron('A',Ctest2{idx}.A,'b',Ctest2{idx}.b+0*1e-4);
visual(W_new,dim,fig,'g',1);

W_new = Polyhedron('A',Ctest1{idx}.A,'b',Ctest1{idx}.b+0.0e-4);
visual(W_new,dim,fig,'b',1);

W_new = Polyhedron('A',Ctest_all.A,'b',Ctest_all.b+0.0*1e-4);
visual(W_new,dim,fig,'r',1);
set(gca,'fontsize',15);
view(165.5,10)


dim = [1 2 3];
fig2=figure;
hold on;

W_new = Polyhedron('A',Ctest2{idx}.A,'b',Ctest2{idx}.b+0*1e-4);
visual(W_new,dim,fig2,'g',1);

W_new = Polyhedron('A',Ctest1{idx}.A,'b',Ctest1{idx}.b+0.05e-4);
visual(W_new,dim,fig2,'b',1);

W_new = Polyhedron('A',W_all.A,'b',W_all.b+0.1*1e-4);
visual(W_new,dim,fig2,'r',1);
set(gca,'fontsize',15);
view(-45.5,10)

idx = 5;
dim = [1 2 4];
fig=figure;
hold on;

W_new = Polyhedron('A',Ctest2{idx}.A,'b',Ctest2{idx}.b);
visual(W_new,dim,fig,'g',1);

W_new = Polyhedron('A',Ctest1{idx}.A,'b',Ctest1{idx}.b);
visual(W_new,dim,fig,'b',1);

W_new = Polyhedron('A',Ctest_all.A,'b',Ctest_all.b+0.0*1e-4);
visual(W_new,dim,fig,'r',1);
set(gca,'fontsize',15);
view(165.5,10)

dim = [1 2 3];
fig2=figure;
hold on;

W_new = Polyhedron('A',Ctest2{idx}.A,'b',Ctest2{idx}.b+0*1e-4);
visual(W_new,dim,fig2,'g',1);

W_new = Polyhedron('A',Ctest1{idx}.A,'b',Ctest1{idx}.b+0.05e-4);
visual(W_new,dim,fig2,'b',1);

W_new = Polyhedron('A',W_all.A,'b',W_all.b+0.1*1e-4);
visual(W_new,dim,fig2,'r',1);
set(gca,'fontsize',15);
view(-45.5,10)


%%

