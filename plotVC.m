function plotVC(pth,name,doi,stn)
% PlotVC
%
% This function takes the result of an exported Vista Clara surface NMR
% inversion and replots.  The *.fig file is required to be saved manually
% that his the FID vs. Pulse moment. Otherwise, the TXT file output from
% exporting the result is the only other thing needed. The figure and text
% files need to have the same filename except for the suffix. The result is
% a JPG printed to the folder with the same name as input file.
%
% ==========Parameters==========
%
% pth   = this is the path to the directory with the fig and TXT are
% name  = name of the fig and TXT
% doi   = user-defined DOI value. Usually interpreted from res matrix
% stn   = plot settings: [max CAxis, ("-")max depth to display, max VWC ]
%
% ==============================
%
% pth  = pth_{ii};
% name = name_{ii};
% doi  = doi_(ii);
%% Plot the raw data from a saved "FID vs. pulse moment" figure from VC software
figure;
subplot(1,4,1:2);
d = load([pwd pth name '.fig'],'-mat'); %load the figure containing the data

cube =     d.hgS_070000.children(1).children(1).properties.CData; %extract from figure structure
time =     d.hgS_070000.children(1).children(1).properties.YData;
qmom = 10.^d.hgS_070000.children(1).children(1).properties.XData;

surface(time,qmom,cube','EdgeColor','none') %plot the raw QT data cube
box on;    grid on
set(gca,'ydir','reverse','ytick',[.1 .5 1 5 10],'layer','top','yscale','log') %plot settings to look good
ylim([min(qmom) max(qmom)]) %fix the limits of the plot
xlim([min(time) max(time)])
%colorbar
xlabel('time [s]')
ylabel('pulse moment [A s]')
caxis([0 stn(1)])
% fix the plotting
pos = get(gca, 'Position');
set(gca, 'Position', [pos(1) pos(2)+0.05 pos(3) pos(4)-0.05]);
%% Plot the inverted VWC
subplot(1,4,3)

r = load([pwd pth name '/' name '_1d_inversion.txt']); % load the results
sz = size(r);
tops = r(:,1); % top of each layer
btms = r(:,2); % bottom of each layer
pos  = [0 0 0]; %position vector, not in use
vw   = r(:,11); % total water content from multiexponentail inversion

for j = 1:sz(1)-1 %loop through to plot the vertical parts
    line([vw(j) vw(j)],[-tops(j)+pos(3) -btms(j)+pos(3)],'color',[0 0 0],'linewidth',1,'linestyle',':');
    %patch([Rho-Rhostd Rho+Rhostd Rho+Rhostd Rho-Rhostd],[-tops(j)+pos(3) -tops(j)+pos(3) -btms(j)+pos(3) -btms(j)+pos(3)],[.5 .5 .5],'EdgeColor','none','FaceAlpha',.5);
end
for j = 1:sz(1)-2 %loop through to plot the horizontal parts
    VW  = vw(j);    VW2 = vw(j+1);
    line([VW VW2],[-btms(j)+pos(3) -btms(j)+pos(3)],'color',[0 0 0])
end

% plot the single exponential VWC
vw = r(:,4);
for j = 1:sz(1)-1 %loop through to plot the vertical parts
    line([vw(j) vw(j)],[-tops(j)+pos(3) -btms(j)+pos(3)],'color',[0 0 0],'linewidth',1);
    %patch([Rho-Rhostd Rho+Rhostd Rho+Rhostd Rho-Rhostd],[-tops(j)+pos(3) -tops(j)+pos(3) -btms(j)+pos(3) -btms(j)+pos(3)],[.5 .5 .5],'EdgeColor','none','FaceAlpha',.5);
end
for j = 1:sz(1)-2 %loop through to plot the horizontal parts
    VW  = vw(j);    VW2 = vw(j+1);
    line([VW VW2],[-btms(j)+pos(3) -btms(j)+pos(3)],'color',[.2 .2 .2],'linewidth',1)
end

line([0 stn(3)],[-doi -doi],'color','r') % plot the DOI

ylim([stn(2) 0]) %fix the limits of the plot
xlim([0 stn(3)])
xlabel('VWC [-]')
ylabel('depth [m]')

%% Plot the inverted T2*
subplot(1,4,4)

t2s = r(:,5); %T2* relaxation time

for j = 1:sz(1)-1 %loop through to plot the vertical parts
    line([t2s(j) t2s(j)],[-tops(j)+pos(3) -btms(j)+pos(3)],'color',[0 0 0],'linewidth',1);
    %patch([Rho-Rhostd Rho+Rhostd Rho+Rhostd Rho-Rhostd],[-tops(j)+pos(3) -tops(j)+pos(3) -btms(j)+pos(3) -btms(j)+pos(3)],[.5 .5 .5],'EdgeColor','none','FaceAlpha',.5);
end
for j = 1:sz(1)-2 %loop through to plot the horizontal parts
    VW  = t2s(j);    VW2 = t2s(j+1);
    line([VW VW2],[-btms(j)+pos(3) -btms(j)+pos(3)],'color',[0 0 0])
end

line([10^-3 10^2],[-doi -doi],'color','r') % plot the DOI

set(gca,'xscale','log','xtick',[.01 .1 1])
xlim([10^-2.5 10^1])
xlabel('T_2^* [s]')
ylim([stn(2) 0]) %fix the limits of the plot

%% finish the figure
% set all of the fonts
set(findall(gcf,'-property','FontSize'),'FontSize',10.5 )
set(findall(gcf,'-property','FontName'),'FontName','Avenir' )

% set the figure size
set(gcf,'PaperUnits','centimeters','PaperPosition',[0 0 20 8])

% print to graphic
print([name '_plot.jpg'],'-djpeg','-r600')
close all
