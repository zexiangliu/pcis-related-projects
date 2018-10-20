function P = expand(dyn, S, G, rhoPre)
% Find controlled invariant set (CIS) C \subseteq S
% G is CIS to be expanded 
plot_stuff = 1;
converged = zeros(S.Num,1);
P = cell(S.Num,1);
for i = 1:S.Num
    P{i} = G;
end
t = 0;
counter = 0;
while sum(converged) < S.Num   
    for i = 1:S.Num
        if converged(i) == 1
            continue
        end
        if plot_stuff
            subplot(221);hold on
            plot(P{i}(end).slice([1 4], [25 25]));
            set(gca,'Xdir','reverse','Ydir','reverse')
            axis([-1 5 -50 50]);
            xlabel('ye'); ylabel('h');
            title('vEgo = 25 m/s, vLead = 25 m/s')

            subplot(222);hold on
            plot(P{i}(end).slice([1 4], [30 20]));
            set(gca,'Xdir','reverse','Ydir','reverse')
            axis([-1 5 -50 50]);
            xlabel('ye'); ylabel('h');
            title('vEgo = 30 m/s, vLead = 20 m/s')

            subplot(223);hold on
            plot(P{i}(end).slice([1 4], [16 25]));
            set(gca,'Xdir','reverse','Ydir','reverse')
            axis([-1 5 -50 50]);
            xlabel('ye'); ylabel('h');
            title('vEgo = 16 m/s, vLead = 25 m/s')

            subplot(224);hold on
            plot(P{i}(end).slice([1 4], [25 0]));
            set(gca,'Xdir','reverse','Ydir','reverse')
            axis([-1 5 -50 50]);
            xlabel('ye'); ylabel('h');
            title('vEgo = 25 m/s, vLead = 0 m/s');
            drawnow;
        end
        disp(['Iteration ', num2str(t)]); t = t+1;
        P{i} = [P{i} intersect(pre(dyn, P{i}(end), rhoPre), S.Set(i))];
        if isEmptySet(mldivide(P{i}(end),P{i}(end-1)))
           converged(i) = 1;
           if sum(converged) == S.Num
               return
           end
        end
    end
    counter = counter + 1;
    if counter>10
        return
    end
end
        