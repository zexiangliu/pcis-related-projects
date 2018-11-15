v = V.Set(1).V;

alpha = rand(1,size(v,1));
alpha = alpha/sum(alpha);

u_range = preXU.slice([1,2,3,4],(alpha*v(:,1:4))');
plot(u_range)