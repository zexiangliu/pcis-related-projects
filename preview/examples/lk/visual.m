function visual(W,dim,fig)
if nargin == 2
    fig = figure();
end
PW = W.projection(dim);
plot(PW)
xlabel("y");
ylabel("v");
zlabel("r");
end