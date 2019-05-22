load lk_inv_T1_H1
W1 = W;

load lk_inv_T5_H1
W2 = W;

load lk_inv_T0_H1
W3 = W;

dim = [1 2 4];
fig=figure;
for i = 1:1
    hold on;
%     visual(W2{i},dim,fig,'g',1);
    view(-90.5,40)
end

W_new = Polyhedron('A',W1{1}.A,'b',W1{1}.b+0.1*1e-4);
visual(W_new,dim,fig,'c',1);

% W_new = Polyhedron('A',W3{1}.A,'b',W3{1}.b+0.5*1e-4);
% visual(W_new,dim,fig,'c',1);


W_new = Polyhedron('A',W_all.A,'b',W_all.b+1e-4);
visual(W_new,dim,fig,'r',1);