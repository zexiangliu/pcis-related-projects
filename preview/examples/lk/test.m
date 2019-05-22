  fig = figure('position',[100 100 500 800]);
ax = gca;
outerpos = ax.OuterPosition;
ti = ax.TightInset; 
left = outerpos(1) + ti(1);
bottom = outerpos(2) + ti(2);
ax_width = outerpos(3) - ti(1) - ti(3);
ax_height = outerpos(4) - ti(2) - ti(4);
ax.Position = [left bottom ax_width ax_height];

%%
    figure(fig);
    hold off;
    plot(road_x(1:end),road_y(1:end),'--k','linewidth',1); hold on;
    lanewidth = 0.9;
    plot(road_x(1:end)-lanewidth*cos(theta_list),road_y(1:end)-lanewidth*sin(theta_list),'-.r','linewidth',1);
    plot(road_x(1:end)+lanewidth*cos(theta_list),road_y(1:end)+lanewidth*sin(theta_list),'-.r','linewidth',1);
    lanewidth = 2;
    plot(road_x(1:end)-lanewidth*cos(theta_list),road_y(1:end)-lanewidth*sin(theta_list),'-k','linewidth',2);
    plot(road_x(1:end)+lanewidth*cos(theta_list),road_y(1:end)+lanewidth*sin(theta_list),'-k','linewidth',2);

    im_car = imrotate(im1,90+car_angle*180/pi,'bilinear','loose');
    Mrot = ~imrotate(true(size(im1)),90+car_angle*180/pi);
    im_car(Mrot&~imclearborder(Mrot)) = 255;
    
    alphachannel = ~(im_car(:,:,1)==255 & im_car(:,:,2)==255 & im_car(:,:,3)==255);
    p1 = 0.4*cos(abs(car_angle)) + 0.5*sin(abs(car_angle));
    p2 = 0.4*sin(abs(car_angle)) + 0.5*cos(abs(car_angle));
    p1= p1*cos(car_angle);
    p2 = p2*cos(car_angle);
    car1 = imagesc([x-p1,x+p1], [y+p2,y-p2],im_car,'AlphaData', alphachannel);hold on;
    plot(car_x_new,car_y_new,'.r','markersize',15)
    x_range = 4*0.9;
    y_range = 5*0.9;
    axis([x-x_range,x+x_range,y-y_range,y+y_range]);
    
    print(fig,['video2/','frame_1_',num2str(i)],'-dpng','-r300');
    