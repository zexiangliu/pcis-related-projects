function visual(W,dim,fig)
if nargin == 2
    fig = figure();
end
PW = W.projection(dim);
plot(PW)
xlabel("y",'interpreter','latex');
ylabel("v",'interpreter','latex');
zlabel("r",'interpreter','latex');
set(gca,'fontsize',12);
end