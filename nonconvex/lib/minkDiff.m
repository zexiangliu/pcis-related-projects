function P3 = minkDiff(P1,P2)
% compute P1-P2 (note that the minus operation provided by MPT3 is not
% stable

H = []; h=[];
P2.computeVRep;
for i = 1:size(P2.V,1)
    H = [H;P1.A];
    h = [h;P1.b-P1.A*P2.V(i,:)'];
end
P3 = Polyhedron('A',H,'b',h);
P3.minHRep;