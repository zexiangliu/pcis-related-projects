clc;close all;clear all;
load data_rho_simple.mat

figure('position',[100 100 350 250]);
plot(1:length(log1.time)+1,[0,log1.time],'linewidth',2);
hold on;
plot(1:length(log2.time)+1,[0,log2.time],'linewidth',2);
% plot(1:num_iter+2,[0,log3.time]);
axis([0,56,0,35])
L = get(gca,'XLim');
set(gca,'XTick',linspace(L(1),L(2),5));
L = get(gca,'YLim');
set(gca,'YTick',linspace(L(1),L(2),6));
xlabel('iteration');
ylabel('cumulative time [s]');
h = legend('new rho method','old rho method');
rect = [0.368, 0.793, .1, .1];
set(h, 'Position', rect);    set(gca,'fontsize',15)
set(gca,'fontsize',12)
%%
load data_rho_complicated.mat

figure('position',[100 100 350 250]);
plot(1:length(log1.time)+1,[0,log1.time],'linewidth',2);
hold on;
plot(1:length(log2.time)+1,[0,log2.time],'linewidth',2);
% plot(1:num_iter+2,[0,log3.time]);
% axis([0,25,0,800])
axis([0,24,0,810])
L = get(gca,'XLim');
set(gca,'XTick',linspace(L(1),L(2),5));
L = get(gca,'YLim');
set(gca,'YTick',linspace(L(1),L(2),6));
 
xlabel('iteration');
ylabel('cumulative time [s]');
%%
h=legend('new rho method','old rho method');
% rect = [0.43, 0.793, .1, .1];
rect = [0.368, 0.793, .1, .1];
set(h, 'Position', rect);    set(gca,'fontsize',15)
set(gca,'fontsize',12)
