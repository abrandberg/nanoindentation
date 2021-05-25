function plotLoadSchedule()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tauL = 1;
tauH = 10;
tauU = tauL + tauH;
tauTH = 30;
f1Fcn = @(x) 20.*x;
f2Fcn = @(x) 20.*ones(size(x));
f3Fcn = @(x) 20.*(1+tauU-x);
f4Fcn = @(x) 20.*0.05.*ones(size(x));



x1 = linspace(0,tauL,2);
x2 = linspace(tauL,tauU,2);
x3 = linspace(tauU,tauU+tauL*0.95,2);
x4 = linspace(tauU+tauL,tauU+tauL+tauTH,2);

lineInstructionsOne = {'marker','none','markerfacecolor','k','markersize',4,'color','k','linewidth',1,'linestyle','--'};
lineInstructionsTwo = {'marker','none','markerfacecolor','k','markersize',4,'color','k','linewidth',1,'linestyle','-'};

figure('units','centimeters','OuterPosition',[10 10 8 8]);
% plot(x1,f1Fcn(x1),lineInstructionsOne{:},'displayname','Hemispherical')
% hold on
% plot(x2,f2Fcn(x2),lineInstructionsOne{:},'handlevisibility','off')
% plot(x3,f3Fcn(x3),lineInstructionsOne{:},'handlevisibility','off')
% plot(x4,f4Fcn(x4),lineInstructionsOne{:},'handlevisibility','off')

plot(x1,f1Fcn(x1)/2,lineInstructionsTwo{:},'displayname','Pyramidal')
hold on
plot(x2,f2Fcn(x2)/2,lineInstructionsTwo{:},'handlevisibility','off')
plot(x3,f3Fcn(x3)/2,lineInstructionsTwo{:},'handlevisibility','off')
plot(x4,f4Fcn(x4)/2,lineInstructionsTwo{:},'handlevisibility','off')

xlabel('Time [s]')
ylabel('Force [\cdot 10^{-6} N]')
legend('location','northeast','fontname','Arial')

xlim([-2 45])
ylim([0 22.5])


%text(11.25,15,'\leftarrow20\cdot10^{-6} N/s','horizontalalignment','left','fontname','Arial')
text(11.65,7.5,'\leftarrow10\cdot10^{-6} N/s','horizontalalignment','left','fontname','Arial')

text(29,5.0,'Thermal drift est.','horizontalalignment','center','fontname','Arial')
text(29,2.5,'at 5% load \downarrow','horizontalalignment','center','fontname','Arial')

set(gca,'fontsize',10,'fontname','Arial')

set(gcf,'PaperPositionMode','auto')
print('loadSchedule','-dpng','-r400')