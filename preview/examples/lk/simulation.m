close all;clear all;clc;
load lk_inv_T1_H1.mat
load lk_inv_T1_H1_cont.mat
% W_hier_XU = compute_xu(pa, W_hier, T_min);

% initial mode, initial state
m0 = 3;
x0 = W{m0}.V(1,:)';


t_step = param.dt;

t_span = 50;

t_list = 0:t_step:t_span;
N = length(t_list);
X_list = zeros(N,4);
u_list = zeros(N,1);
m_list = zeros(N,1);
u_list = zeros(N,1);
rd_list = zeros(N,1);
pt_list = zeros(N,1);

X_list(1,:) = x0;
m_list(1,:) = m0;
x = x0;
m = m0;

c_h = pa.t_hold(1,m);
c_T = inf;

figure(1);
colorOrder = get(gca, 'ColorOrder');
for i = 2:N
    t = t_list(i)
    % decide if a preview at time t-1
    if isinf(c_T) && rand(1) > 0.99
       post = find(pa.ts_array(m,:));
       order = randperm(length(post));
       m_next = post(order(1));
       if pa.t_prev(m,m_next) >= c_h
           c_T = pa.t_prev(m,m_next);
           pt_list(i-1) = 1;
       end
    end
    
    % update c_T, c_h at time t
    c_T = c_T - 1;
    c_h = max(max(c_h-1,T_min(m)),1);
    
    % pick u at t-1
    if isinf(c_T) % if no preview at t-1
        u = mean(W_hier_XU{m}{1}{c_h}.slice([1,2,3,4],x).V);
    elseif c_T > 0 % if preview time is not 0
        u = mean(W_hier_XU{m}{2}{c_T}.slice([1,2,3,4],x).V);
    else
        u = mean(W_hier_XU{m_next}{1}{pa.t_hold(1,m_next)}.slice([1,2,3,4],x).V);
    end
    
    % pick r_d at t-1
    rd = pa.dyn{m}.D.V(2) + rand*(pa.dyn{m}.D.V(1)-pa.dyn{m}.D.V(2));
    
    % compute x at t, envolve from the mode at t-1
    x = pa.dyn{m}.A*x + pa.dyn{m}.B*u+pa.dyn{m}.Fd{1}*rd;
    
    % if c_T == 0, means that the mode at t is m_next
    if c_T == 0
        m = m_next;
        c_T = inf;
        c_h = pa.t_hold(1,m);
    end
    
    X_list(i,:) = x;
    m_list(i,:) = m;
    u_list(i-1,:) = u;
    rd_list(i-1,:) = rd;
    
    plot(t_list,X_list(:,1),'linewidth',1,'color',colorOrder(1,:));
    hold on;
    plot(t_list,X_list(:,2),'linewidth',1,'color',colorOrder(2,:));
    plot(t_list,X_list(:,3),'linewidth',1,'color',colorOrder(3,:));
    plot(t_list,X_list(:,4),'linewidth',1,'color',colorOrder(4,:));
    drawnow;
    hold off;
end
%%
figure(1);
plot(t_list,X_list(:,1),'linewidth',1,'color',colorOrder(1,:));
    hold on;
    plot(t_list,X_list(:,2),'linewidth',1,'color',colorOrder(2,:));
    plot(t_list,X_list(:,3),'linewidth',1,'color',colorOrder(3,:));
    plot(t_list,X_list(:,4),'linewidth',1,'color',colorOrder(4,:));
xlabel("time","interpreter","latex");
ylabel("states","interpreter","latex");
legend(["$y$","$v$","$\Delta \Phi$", "$r$"],"interpreter","latex");
set(gca,'fontsize',12)
hold on;
plot([0,t_span],[y_max,y_max],'-.','color',colorOrder(1,:),'HandleVisibility','off');
plot([0,t_span],[y_min,y_min],'-.','color',colorOrder(1,:),'HandleVisibility','off');
plot([0,t_span],[v_max,v_max],'-.','color',colorOrder(2,:),'HandleVisibility','off');
plot([0,t_span],[v_min,v_min],'-.','color',colorOrder(2,:),'HandleVisibility','off');
plot([0,t_span],[Phi_max,Phi_max],'-.','color',colorOrder(3,:),'HandleVisibility','off');
plot([0,t_span],[Phi_min,Phi_min],'-.','color',colorOrder(3,:),'HandleVisibility','off');
plot([0,t_span],[dPhi_max,dPhi_max],'-.','color',colorOrder(4,:),'HandleVisibility','off');
plot([0,t_span],[dPhi_min,dPhi_min],'-.','color',colorOrder(4,:),'HandleVisibility','off');
%%


figure(2);
plot(t_list,m_list,'linewidth',1)
axis([0,t_span,0,5]);
xlabel("time","interpreter","latex");
ylabel("mode","interpreter","latex");

hold on;
for i = 1:N
    if pt_list(i)==1
        plot([t_list(i),t_list(i)],[0,5],'--','linewidth',1,'color',colorOrder(end,:));
    end
end
set(gca,'fontsize',12)
