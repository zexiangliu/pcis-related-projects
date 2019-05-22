load lk_simu_data.mat

w = VideoWriter('test.avi','Motion JPEG AVI');
w.Quality = 100;
open(w);

t0 = 50-1460/33-1.7;
idx0 = round(t0/0.1);
t= t0;
idx=idx0;
fig1 = figure(1);
set(gcf, 'Position',  [100, 100, 600, 400]);

fig2 = figure(2);
set(gcf, 'Position',  [100, 100, 600, 400]);

line = 2;
line2 = 1.3;
for i = 1:1460
    i
    t = 50 - (1460-i)/33;
    idx = round(t/0.1);
    A = imread(['video/Pictures',num2str(i),'.jpg']);
    
    
    %%
    figure(fig1);
    plot(t_list(1:idx-idx0+1),X_list(idx0:idx,1),'linewidth',line,'color',colorOrder(1,:));
        hold on;
        plot(t_list(1:idx-idx0+1),X_list(idx0:idx,2),'linewidth',line,'color',colorOrder(2,:));
        plot(t_list(1:idx-idx0+1),X_list(idx0:idx,3),'linewidth',line,'color',colorOrder(3,:));
        plot(t_list(1:idx-idx0+1),X_list(idx0:idx,4),'linewidth',line,'color',colorOrder(4,:));
    xlabel("time","interpreter","latex");
    ylabel("states","interpreter","latex");
    legend(["$y$","$v$","$\Delta \Phi$", "$r$"],"interpreter","latex");
    set(gca,'fontsize',15)
    axis([0,50,-1.5,1.5]);
    hold on;
    plot([0,t-t0],[y_max,y_max],'-.','linewidth',line2,'color',colorOrder(1,:),'HandleVisibility','off');
    plot([0,t-t0],[y_min,y_min],'-.','linewidth',line2,'color',colorOrder(1,:),'HandleVisibility','off');
    plot([0,t-t0],[v_max,v_max],'-.','linewidth',line2,'color',colorOrder(2,:),'HandleVisibility','off');
    plot([0,t-t0],[v_min,v_min],'-.','linewidth',line2,'color',colorOrder(2,:),'HandleVisibility','off');
    plot([0,t-t0],[Phi_max,Phi_max],'-.','linewidth',line2,'color',colorOrder(3,:),'HandleVisibility','off');
    plot([0,t-t0],[Phi_min,Phi_min],'-.','linewidth',line2,'color',colorOrder(3,:),'HandleVisibility','off');
    plot([0,t-t0],[dPhi_max,dPhi_max],'-.','linewidth',line2,'color',colorOrder(4,:),'HandleVisibility','off');
    plot([0,t-t0],[dPhi_min,dPhi_min],'-.','linewidth',line2,'color',colorOrder(4,:),'HandleVisibility','off');
    hold off;
    print(fig1,['video/','frame_1_',num2str(i)],'-dpng');
%     M1 = getframe(fig1);
%%
    figure(fig2);
    plot(t_list(1:idx-idx0+1),m_list(idx0:idx),'linewidth',line)
    axis([0,50,0,5]);
    xlabel("time","interpreter","latex");
    ylabel("mode","interpreter","latex");

    hold on;
    for k = idx0:idx
        if pt_list(k)==1
            plot([t_list(k)-t0,t_list(k)-t0],[0,5],'--','linewidth',line,'color',colorOrder(end,:));
        end
    end
    set(gca,'fontsize',15)
    hold off;
%     M2 = getframe(fig2);
    print(fig2,['video/','frame_2_',num2str(i)],'-dpng');
    
    M1 = imread(['video/','frame_1_',num2str(i),'.png']);
    M2 = imread(['video/','frame_2_',num2str(i),'.png']);
%%    
    sizA = size(A);
    siz1 = size(M1);
    siz2 = size(M2);

    B = 255+zeros(sizA(1)+max(siz1(1),siz2(1)),sizA(2),3,'uint8');
    B(1:sizA(1),1:sizA(2),1:3) = A;
    B(sizA(1)+1:sizA(1)+siz1(1),1:siz1(2),1:3) = M1;
    B(sizA(1)+1:sizA(1)+siz2(1),end-siz2(2)+1:end,1:3) = M2;
    writeVideo(w,B);
end

close(w);


