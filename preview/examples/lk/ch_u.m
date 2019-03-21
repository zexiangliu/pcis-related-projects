function V = ch_u(u_min,u_max)
% inputs: the range of forward speed
% outputs: the vertices of the convex hull of the graph [u,1/u]
    V = zeros(4,2);
    V(1,:) = [u_min,1/u_min];
    V(2,:) = [u_max,1/u_max];
    u_md = sqrt((u_max - u_min)/(1/u_min - 1/u_max));
    u_1 = 2/(1/u_md + 1/u_min);
    u_2 = 2/(1/u_md + 1/u_max);
    V(3,:) = [u_1, -1/u_min^2*u_1 + 2/u_min];
    V(4,:) = [u_2, -1/u_max^2*u_2 + 2/u_max];
end