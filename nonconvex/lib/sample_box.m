function samples = sample_box(B,N)
% Sample uniformly inside a hyperbox,
% INPUT: B is the upper and lower bound of the box. For example, for
% l1<x1<u1, l2<x2<u2, the input B is [l1,u1;l2,u2].
% OUTPUT: N samples within the box, return a Nxm matrix where m is the
% dimension of the box.

if nargin==1
    N = 1;
end

m = size(B,1);

samples = rand(N,m);

T1 = ones(N,1)*B(:,1)';
T2 = ones(N,1)*(B(:,2) - B(:,1))';

% map samples to the range given by B.
samples = T1 + samples.*T2;

end