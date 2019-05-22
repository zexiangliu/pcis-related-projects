function visual(W,dim,fig,color,alpha)
if nargin == 2
    fig = figure();
    color = 'r';
    alpha = 1;
end
PW = W.projection(dim);
plot(PW,'alpha',alpha,'color',color)
xlabel("$y$",'interpreter','latex');
ylabel("$v$",'interpreter','latex');
zlabel("$r$",'interpreter','latex');
% zlabel("$\Delta \Phi$",'interpreter','latex');
set(gca,'fontsize',12);
end
