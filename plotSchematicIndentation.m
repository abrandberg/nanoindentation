function plotSchematicIndentation()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Schematic force displacement curve

CFcn1 = @(x) 0.5.*x.^1.8 + 20.6.*x ;
CFcn2 = @(x) 0.5.*100.^1.8 + 20.6.*100.*ones(size(x));
CFcn3 = @(x)  0.5.*(x).^2 - (0.5.*100.^1.8 + 20.6.*100.*ones(size(x))) + 850.5 + 50;

% DFcn3 = @(x) x;

y1 = linspace(0,100,100);
y2 = linspace(100,120,100);
y3 = linspace(78,120,100);


lineInstructions = {'marker','none','markerfacecolor','k','markersize',4,'color','k', ...
                       'linewidth',1,'linestyle','-'};
figure('units','centimeters','OuterPosition',[10 10 8 8]);

plot(y1, CFcn1(y1),lineInstructions{:})
hold on
plot(y2, CFcn2(y2),lineInstructions{:})
plot(y3, CFcn3(y3),lineInstructions{:})

% plot([90 120] , [0 4051],'--','color','k','linewidth',1)

plot(4+[116 125],-2.4*4051+115.*[116 125],'color','k','linewidth',1,'linestyle',':')

% plot([100 110],4051/30.*[100 100]-12200,'color','k')
% plot([110 110],4051/30.*[100 110]-12200,'color','k')

plot(4+[116 125],-2.4*4051+115.*[116 116],'color','k','linewidth',1)
plot(4+[125 125],-2.4*4051+115.*[116 125],'color','k','linewidth',1)


xlim([0 160])
ylim([0 5000])

xlabel('Indentation z [m]')
ylabel('Force F [N]')

yticks([0 4051])
yticklabels({'0','F_{max}'})

xticks([0 120])
xticklabels({'0','z_{max}'})

% text(45,1950,'\rightarrow','horizontalalignment','left','fontname','Arial','rotation',45)
% text(50,2000,'\rightarrow','horizontalalignment','left','fontname','Arial','rotation',45)
% text(55,2050,'\rightarrow','horizontalalignment','left','fontname','Arial','rotation',45)

text(48,2000,'Loading \rightarrow','horizontalalignment','center','fontname','Arial','rotation',45)
text(93,2000,'\leftarrow Unloading','horizontalalignment','center','fontname','Arial','rotation',68)

% text(112,1800,'S_u','horizontalAlignment','left','fontname','Arial')
% text(105,1000,'1','horizontalAlignment','center','fontname','Arial')

text(124,3200,'1','horizontalAlignment','center','fontname','Arial')
text(135,4000,'S_u','horizontalAlignment','left','fontname','Arial')

set(gca,'fontsize',10,'fontname','Arial','Xgrid','on','Ygrid','on')

set(gcf,'PaperPositionMode','auto')
print('schematicIndentation','-dpng','-r400')