function visual(W,dim,fig,color,alpha,axisnames)
if nargin == 2
    fig = figure();
    color = 'r';
    alpha = 1;
    axisnames = ["x_1","x_2","x_3","x_4"];
end
figure(fig);
PW = projection2(W,dim);
plot(PW,'alpha',alpha,'color',color)
xlabel("$"+axisnames(dim(1))+"$",'interpreter','latex');
ylabel("$"+axisnames(dim(2))+"$",'interpreter','latex');
% zlabel("$r$",'interpreter','latex');
zlabel("$"+axisnames(dim(3))+"$",'interpreter','latex');
set(gca,'fontsize',12);
end
