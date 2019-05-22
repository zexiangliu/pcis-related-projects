close all;clc;
load lk_simu_data.mat
step = 3;

road_x = zeros(N,1);
road_y = zeros(N,1);

x = 0;
y = 0;
theta = 0;
u=30;
dt = 0.1;

theta_list = zeros(N,1);

for i = 2:N
    
    % rd = u/R
    R = u/rd_list(i-1);
    % R = s/dtheta
    s = u*dt*cos(X_list(i-1,3));
    theta = theta + s/R;
    
    x = x + s*sin(theta);
    y = y + s*cos(theta);
    
    road_x(i) = x;
    road_y(i) = y;
    theta_list(i-1) = theta;
end
theta_list(end) = theta;

plot(road_x(1:end),road_y(1:end),'--k','linewidth',0.5); hold on;
lanewidth = 0.9;
plot(road_x(1:end)-lanewidth*cos(theta_list),road_y(1:end)+lanewidth*sin(theta_list),'r','linewidth',0.1);
plot(road_x(1:end)+lanewidth*cos(theta_list),road_y(1:end)-lanewidth*sin(theta_list),'r','linewidth',0.1);
lanewidth = 2;
plot(road_x(1:end)-lanewidth*cos(theta_list),road_y(1:end)+lanewidth*sin(theta_list),'-k','linewidth',0.5);
plot(road_x(1:end)+lanewidth*cos(theta_list),road_y(1:end)-lanewidth*sin(theta_list),'-k','linewidth',0.5);

axis equal;

x = 0;
y = 0;
car_x = zeros(N,1);
car_y = zeros(N,1);
car_t = zeros(N,1);
for i = 2:N
    theta = theta_list(i-1);
%     car_angle = theta + X_list(i-1,3);
%     v = X_list(i-1,2);
%     x = x - u*dt*sin(car_angle) - v*dt*sin(car_angle+90);
%     y = y + u*dt*cos(car_angle) + v*dt*cos(car_angle+90);
    dy = X_list(i,1);
    car_angle = theta + X_list(i-1,3);

    x = road_x(i) + dy*cos(theta);
    y = road_y(i) - dy*sin(theta);

    car_x(i) = x;
    car_y(i) = y;
    car_t(i) = car_angle;
end


%% visualize
fig = figure('position',[100 100 500 800]);
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];
    
fig1 = figure('Position',  [100, 100, 600, 400]);

fig2 = figure('Position',  [100, 100, 600, 400]);

im1 = imread('car_green.png');

tstep = 1/33;
t = 0;

car_x_new = [];
car_y_new = [];
t_list_new = [];


line = 2;
line2 = 1.3;
i = 1;
while t<=50
    x = interp1(t_list,car_x,t);
    y = interp1(t_list,car_y,t);
    car_angle = interp1(t_list,car_t,t);
    
    car_x_new = [car_x_new,x];
    car_y_new = [car_y_new,y];
    t_list_new = [t_list_new,t];
    
    figure(fig);
    hold off;
    plot(road_x(1:end),road_y(1:end),'--k','linewidth',1); hold on;
    lanewidth = 0.9;
    plot(road_x(1:end)-lanewidth*cos(theta_list),road_y(1:end)+lanewidth*sin(theta_list),'-.r','linewidth',1);
    plot(road_x(1:end)+lanewidth*cos(theta_list),road_y(1:end)-lanewidth*sin(theta_list),'-.r','linewidth',1);
    lanewidth = 2;
    plot(road_x(1:end)-lanewidth*cos(theta_list),road_y(1:end)+lanewidth*sin(theta_list),'-k','linewidth',2);
    plot(road_x(1:end)+lanewidth*cos(theta_list),road_y(1:end)-lanewidth*sin(theta_list),'-k','linewidth',2);

    im_car = imrotate(im1,90-car_angle*180/pi,'bilinear','loose');
    Mrot = ~imrotate(true(size(im1)),90-car_angle*180/pi);
    im_car(Mrot&~imclearborder(Mrot)) = 255;
    
    alphachannel = ~(im_car(:,:,1)==255 & im_car(:,:,2)==255 & im_car(:,:,3)==255);
    p1 = 0.4*cos(abs(car_angle)) + 0.5*sin(abs(car_angle));
    p2 = 0.4*sin(abs(car_angle)) + 0.5*cos(abs(car_angle));
  
    car1 = imagesc([x-p1,x+p1], [y+p2,y-p2],im_car,'AlphaData', alphachannel);hold on;
    plot(car_x_new,car_y_new,'.r','markersize',15);
    x_range = 4*min([1,0.5+t*1])*(1+sin(abs(car_angle)));
    y_range = 5*min([1,0.5+t*1])*(1+sin(abs(car_angle)));
    axis([x-x_range,x+x_range,y-y_range,y+y_range]);
    
    print(fig,['video2/','frame_1_',num2str(i)],'-dpng','-r300');
    
     %%
    figure(fig1);
    X_list_new = interp1(t_list,X_list,t_list_new);
    
    plot(t_list_new,X_list_new(:,1),'linewidth',line,'color',colorOrder(1,:));
        hold on;
        plot(t_list_new,X_list_new(:,2),'linewidth',line,'color',colorOrder(2,:));
        plot(t_list_new,X_list_new(:,3),'linewidth',line,'color',colorOrder(3,:));
        plot(t_list_new,X_list_new(:,4),'linewidth',line,'color',colorOrder(4,:));
    xlabel("time","interpreter","latex");
    ylabel("states","interpreter","latex");
    h= legend(["$y$","$v$","$\Delta \Phi$", "$r$"],"interpreter","latex");
    rect = [0.77, 0.18, .1, .25];
    set(h, 'Position', rect);    set(gca,'fontsize',15)
    axis([0,50,-1.5,1.5]);
    hold on;
    plot([0,t],[y_max,y_max],'-.','linewidth',line2,'color',colorOrder(1,:),'HandleVisibility','off');
    plot([0,t],[y_min,y_min],'-.','linewidth',line2,'color',colorOrder(1,:),'HandleVisibility','off');
    plot([0,t],[v_max,v_max],'-.','linewidth',line2,'color',colorOrder(2,:),'HandleVisibility','off');
    plot([0,t],[v_min,v_min],'-.','linewidth',line2,'color',colorOrder(2,:),'HandleVisibility','off');
    plot([0,t],[Phi_max,Phi_max],'-.','linewidth',line2,'color',colorOrder(3,:),'HandleVisibility','off');
    plot([0,t],[Phi_min,Phi_min],'-.','linewidth',line2,'color',colorOrder(3,:),'HandleVisibility','off');
    plot([0,t],[dPhi_max,dPhi_max],'-.','linewidth',line2,'color',colorOrder(4,:),'HandleVisibility','off');
    plot([0,t],[dPhi_min,dPhi_min],'-.','linewidth',line2,'color',colorOrder(4,:),'HandleVisibility','off');
    hold off;
    print(fig1,['video2/','frame_2_',num2str(i)],'-dpng','-r300');
    %%
    figure(fig2);
    m_list_new = interp1(t_list,m_list,t_list_new);
    plot(t_list_new,m_list_new,'linewidth',line)
    axis([0,50,0,5]);
    xlabel("time","interpreter","latex");
    ylabel("mode","interpreter","latex");

    hold on;
    for k = 1:N
        if t_list(k) > t 
            break;
        end
        if pt_list(k)==1
            plot([t_list(k),t_list(k)],[0,5],'--','linewidth',line,'color',colorOrder(end,:));
        end
    end
    set(gca,'fontsize',15)
    hold off;
%     M2 = getframe(fig2);
    print(fig2,['video2/','frame_3_',num2str(i)],'-dpng','-r300');
    %%
%     axis equal
%     drawnow; 
    t = t+tstep
    i = i +1;
end


%% generate video
w = VideoWriter('test4.avi','Motion JPEG AVI');
w.Quality = 100;
open(w);


for j = 1:i-1
    j
    M1 = imread(['video2/','frame_1_',num2str(j),'.png']);
    M2 = imread(['video2/','frame_2_',num2str(j),'.png']);
    M3 = imread(['video2/','frame_3_',num2str(j),'.png']);
    
    siz1 = size(M1);
    siz2 = size(M2);
    siz3 = size(M3);

    B = 255+zeros(siz1(1)+1,siz1(2)+max(siz2(2)+1,siz3(2)),3,'uint8');
    B(1:siz1(1),1:siz1(2),1:3) = M1;
    B(1:siz2(1),siz1(2)+1:siz1(2)+siz2(2),1:3) = M2;
    B(end-siz2(1)+1:end,siz1(2)+1:siz1(2)+siz3(2),1:3) = M3;
    writeVideo(w,B);
%     imshow(B)
    
end

close(w);

