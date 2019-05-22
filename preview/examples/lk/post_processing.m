x_list = zeros(N,1);

x = 0;
for i = 2:N
   
    x = x + param.u*cos(X_list(i-1,3))*param.dt;
    
    x_list(i) = x;
    
end