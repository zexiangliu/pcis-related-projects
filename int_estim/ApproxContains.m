function bool = ApproxContains(P1,P2)
% check if the convex hull of P1 contains that of P2

CH1 = P1.convexHull;
CH2 = P2.convexHull;

bool = CH1.contains(CH2);

end