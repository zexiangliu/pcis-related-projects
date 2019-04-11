function visual(W,dim,fig,color)
if nargin == 2
    fig = figure();
    color = 'r';
end
PW = W.projection(dim);
plot(PW,'alpha',1,'color',color)
xlabel("$y$",'interpreter','latex');
ylabel("$v$",'interpreter','latex');
zlabel("$r$",'interpreter','latex');
% zlabel("$\Delta \Phi$",'interpreter','latex');
set(gca,'fontsize',12);
end