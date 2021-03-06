% load lk_inv_T1_H1
% W1 = W;
% 
% load lk_inv_T5_H1
% W2 = W;
% 
% load lk_inv_T0_H1
% W3 = W;
% 
% dim = [1 2 4];
% fig=figure;
% for i = 1:1
%     hold on;
% %     visual(W2{i},dim,fig,'g',1);
%     view(-90.5,40)
% end
% 
% W_new = Polyhedron('A',W1{1}.A,'b',W1{1}.b+0.1*1e-4);
% visual(W_new,dim,fig,'c',1);
% 
% % W_new = Polyhedron('A',W3{1}.A,'b',W3{1}.b+0.5*1e-4);
% % visual(W_new,dim,fig,'c',1);
% 
% 
% W_new = Polyhedron('A',W_all.A,'b',W_all.b+1e-4);
% visual(W_new,dim,fig,'r',1);

clc;clear all;
load lk_inv_new_rd_5.mat
% load lk_inv_new_rd_T1_H5.mat
% load res_T1_H2.mat
% load lk_inv_T1_H1.mat
load res_T1_H2.mat
W1 = W;
clear W;
% load lk_inv_new_rd_T5_H5.mat
% load res_T2_H2.mat
% load lk_inv_T5_H1.mat
load lk_inv_new_rd_T1_H5.mat
W2 = W;
%%
axisnames = ["y","v","\Delta\Psi","r"];
idx = 4;
dim = [1 2 4];
fig=figure;
hold on;

W_new = Polyhedron('A',W2{idx}.A,'b',W2{idx}.b+0*1e-4);
visual(W_new,dim,fig,'g',1,axisnames);

W_new = Polyhedron('A',W1{idx}.A,'b',W1{idx}.b+0.1*1e-4);
visual(W_new,dim,fig,'b',1,axisnames);

W_new = Polyhedron('A',W_all.A,'b',W_all.b+0.2*1e-4);
visual(W_new,dim,fig,'r',1,axisnames);
set(gca,'fontsize',15);
view(165.5,10)


dim = [1 2 3];
fig2=figure;
hold on;

W_new = Polyhedron('A',W2{idx}.A,'b',W2{idx}.b+0*1e-4);
visual(W_new,dim,fig2,'g',1,axisnames);

W_new = Polyhedron('A',W1{idx}.A,'b',W1{idx}.b+0.1*1e-4);
visual(W_new,dim,fig2,'b',1,axisnames);

W_new = Polyhedron('A',W_all.A,'b',W_all.b+0.2*1e-4);
visual(W_new,dim,fig2,'r',1,axisnames);
set(gca,'fontsize',15);
view(-45.5,10)

%%
% fig2 = figure
% dim = [1,2,3];
% hold on;
% W_new = Polyhedron('A',Ctest4.A,'b',Ctest4.b+0.0*1e-4);
% visual(W_new,dim,fig2,'b',1);
% 
% W_new = Polyhedron('A',Ctest2.A,'b',Ctest2.b+0.01*1e-4);
% visual(W_new,dim,fig2,'r',1);
% set(gca,'fontsize',15);
% view(-45.5,10)