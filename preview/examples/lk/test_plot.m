% fig1 = figure('Position',  [100, 100, 600, 400]);
% 
% plot(t_list,X_list(:,1)); hold on;
% plot(t_list,X_list(:,2));
% plot(t_list,X_list(:,3));
% plot(t_list,X_list(:,4));
% xlabel("time","interpreter","latex");
% ylabel("states","interpreter","latex");
% h= legend(["$y$","$v$","$\Delta \Phi$", "$r$"],"interpreter","latex");
% rect = [0.77, 0.18, .1, .25];
% set(h, 'Position', rect);
% 
% set(gca,'fontsize',15)
% axis([0,50,-1.5,1.5]);

    car_angle = -10;
    im_car = imrotate(im1,-90+car_angle*180/pi,'bilinear','loose');
    Mrot = ~imrotate(true(size(im1)),-90+car_angle*180/pi);
    im_car(Mrot&~imclearborder(Mrot)) = 255;
    
    alphachannel = ~(im_car(:,:,1)==255 & im_car(:,:,2)==255 & im_car(:,:,3)==255);
    p1 = 0.4*cos(abs(car_angle)) + 0.5*sin(abs(car_angle));
    p2 = 0.4*sin(abs(car_angle)) + 0.5*cos(abs(car_angle));
  
    car1 = imagesc([x-p1,x+p1], [y+p2,y-p2],im_car,'AlphaData', alphachannel);hold on;
    plot(car_x_new,car_y_new,'.r','markersize',15);