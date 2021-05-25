%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This code generate the figures of the manuscript
% Estimation of the in-situ elastic constants of wood pulp fibers in freely
% dried paper via AFM experiments
%
% C. Czibula, A. Brandberg, M. J. Cordill, A. Matković, O. Glushko, 
% Ch. Czibula, A. Kulachenko, C. Teichert, U. Hirn
%
% In prep. 2020.
%
% created by: August Brandberg augustbr at kth dot se
% date: 2020-12-01
%
clear; close all; clc
format compact
% addpath('gramm')

ctrl.workDir = cd;
% ctrl.interpreter = 'latex';
ctrl.fontSize = 12;
ctrl.c1 = [1,0.367323240931323,0.413223681757493];
ctrl.c2 = [0,0.737539425402267,0.834439366978244];

% load('results_23-Nov-2020.mat') 
% Replace this file with the one you generated yourself by running indentationMain.m

% load('results_10-Mar-2021.mat') 
% load('results_24-Mar-2021.mat') % Current gold
load('results_13-Apr-2021.mat')
nanoIndenterER = [3.352628
                    3.05104
                    3.373571
                    4.220259
                    3.287069
                    3.295697
                    2.886823
                    3.41113
                    3.372976
                    2.987791
                    3.181228
                    3.173616
                    3.107426
                    3.00002
                    3.085809
                    3.21454
                    3.227962
                    7.385569
                    7.012103
                    8.49995
                    7.276801
                    7.469342
                    8.387493
                    7.610101
                    8.348344
                    7.96452
                    8.71578
                    7.467436
                    7.576169
                    7.520031
                    6.696277
                    6.019133
                    7.583747
                    7.972977
                    8.358567
                    7.76398
                    5.414374
                    6.294132
                    5.212615
                    5.848676
                    6.783273
                    6.09468
                    6.162165
                    6.048677
                    6.138095
                    6.757279
                    6.713278
                    6.137045
                    6.371493
                    5.474469
                    6.225952
                    6.591342];

% results([([results.Er] > 50 | [results.Er] < 0 ) & strcmp({results.indentationNormal},'L')]) = [];
results([([results.Er] > 50 | [results.Er] < 0.75 )]) = [];


format compact
formatString = '     %20s %10.4f %20s %10.4f %20s %10.4f %20s %10.4f \n';


indentationDirections = {'L','T'};


selIdx = strcmp({results.indentationNormal},'L');
yTemp = [results(selIdx).Er]';

% xTemp = categorical({results(selIdx).indenterType});
xTemp = {results(selIdx).indenterType};
xTemp = strrep(xTemp,'hemispherical','2');
xTemp = strrep(xTemp,'pyramidal','1');
xTemp = str2double(xTemp);

selPyr = xTemp == 1;
selHemi = xTemp == 2;

selTrans = strcmp({results.indentationNormal},'T');
transER = [results(selTrans).Er];

figure('units','centimeters','OuterPosition',[10 10 15 10+2.5]);
tiledlayout(5,4,'padding','none','tilespacing','none');
nexttile(5,[4 4]);
% boxchart(xTemp,yTemp)



plot([mean(xTemp(1,selHemi))-0.35; mean(xTemp(1,selHemi)) + 0.35], repmat(mean(yTemp(selHemi), 1), 2, 1),'-k','linewidth',1,'displayname','Mean')
hold on
plot([mean(xTemp(1,selHemi))-0.35; mean(xTemp(1,selHemi)) + 0.35], repmat(median(yTemp(selHemi), 1), 2, 1),':k','linewidth',1,'displayname','Median')
scatter(xTemp(selHemi), yTemp(selHemi),40,'MarkerEdgeColor','w','MarkerFaceColor',ctrl.c1,'jitter','on','jitterAmount',0.15,'handlevisibility','off')

plot([mean(xTemp(1,selPyr))-0.35; mean(xTemp(1,selPyr)) + 0.35], repmat(mean(yTemp(selPyr), 1) , 2, 1),'-k','linewidth',1,'handlevisibility','off')
plot([mean(xTemp(1,selPyr))-0.35; mean(xTemp(1,selPyr)) + 0.35], repmat(median(yTemp(selPyr), 1) , 2, 1),':k','linewidth',1,'handlevisibility','off')
scatter(xTemp(selPyr), yTemp(selPyr),40,'v','MarkerEdgeColor','w','MarkerFaceColor',ctrl.c1,'jitter','on','jitterAmount',0.15,'handlevisibility','off')

plot([0-0.35; 0 + 0.35], repmat(mean(transER', 1), 2, 1),'-k','linewidth',1,'handlevisibility','off')
plot([0-0.35; 0 + 0.35], repmat(median(transER', 1) , 2, 1),':k','linewidth',1,'handlevisibility','off')
scatter(0*ones(size(transER)) , transER,40,'MarkerEdgeColor','w','MarkerFaceColor',ctrl.c2,'jitter','on','jitterAmount',0.15,'handlevisibility','off')


plot([3-0.35; 3 + 0.35], repmat(mean(nanoIndenterER, 1), 2, 1),'-k','linewidth',1,'handlevisibility','off')
plot([3-0.35; 3 + 0.35], repmat(median(nanoIndenterER, 1) , 2, 1),':k','linewidth',1,'handlevisibility','off')
scatter(3.*ones(size(nanoIndenterER)), nanoIndenterER,40,'v','MarkerEdgeColor','w','MarkerFaceColor',ctrl.c1,'jitter','on','jitterAmount',0.15,'handlevisibility','off')


ylabel('Indentation modulus M [GPa]')
xlabel('Indenter, direction')
xticks([0 1 2 3])
xticklabels({'AFM-NI, T','AFM-NI, L','AFM-NI, L','NI, L'})
xlim([-0.5 3.5])
% ylim([0 50])
ylim([0 30])
legend('location','northeast')
set(gca,'fontsize',10,'FontName','Arial','Ygrid','on','YMinorGrid','off')
% set(gca,'Yscale','log')

%%%%%%%%%%%%%%
nexttile(1);
text(-0.35,0.2,sprintf('%s \n','Normal: ','Indenter: ','Max load: '),'FontWeight','bold')
hold on
text(0.5,0.2,sprintf('%s \n','Transverse','Hemisphere','20 \muN'),'HorizontalAlignment','center')
axis off 

nexttile(2);
text(0.5,0.2,sprintf('%s \n','Longitudinal','Pyramid','10 \muN'),'HorizontalAlignment','center')
axis off 

nexttile(3);
text(0.5,0.2,sprintf('%s \n','Longitudinal','Hemisphere','20 \muN'),'HorizontalAlignment','center')
axis off 

nexttile(4);
text(0.5,0.2,sprintf('%s \n','Longitudinal','Pyramid','100 \muN'),'HorizontalAlignment','center')
axis off 
% for aLoop = 1:10
% %     subplot(5,5,splotIdx(aLoop))
%     nexttile(splotIdx(aLoop))
%     text(0.5,0.5,sprintf('%3.2f',corrMatrix(corrIdx(aLoop,1),corrIdx(aLoop,2))),textInstructions{:})
%     axis off
% end
% set(findobj(gcf,'type','axes'),'TickLabelInterpreter',ctrl.interpreter);





%%%%%%%%%%%%%%
set(gcf,'PaperPositionMode','auto')
print('testOne','-dpng','-r400')




% micromechanicalTesting = 1e-9.*[32781534517.0828;9699759355.01919;8485046890.73298;5941635104.79263;11368275421.7228;NaN;NaN;7122743616.13227;10087870981.1859;NaN;NaN;8666309740.51272;5339759797.68220;7006929764.79919;15825514720.9594];
micromechanicalTesting = 1e-9.*[11458162778.5396;13001266174.8315;6777745356.55497;14063373415.9568;9154271778.89636;21777370056.9383;8564966670.52301;12837889570.2371;15581733478.1002;9090677651.06356;9631538446.25217;6122014366.13415;7773201014.92600;20812443920.4185;6660104686.94239;8391100905.92074;3112818663.67063];
% micromechanicalTesting(micromechanicalTesting > 100) = [];

micromechanicalTesting = 1e-9.*[NaN;11458162778.5396;13001266174.8315;6777745356.55497;14063373415.9568;NaN;NaN;8564966670.52301;12837889570.2371;15581733478.1002;9090677651.06356;9631538446.25217;6122014366.13415;7773201014.92600;20812443920.4185;6660104686.94239;8391100905.92074;NaN;3756606959.24702;5785177922.49888;6264922016.10833;NaN;NaN;4567910998.06839;15657413424.3751;6399666450.21508;NaN;NaN]
figure('units','centimeters','OuterPosition',[10 10 8 8]);
tiledlayout(1,1,'padding','none');
nexttile;


plot([1-0.15; 1 + 0.15], repmat(mean(micromechanicalTesting, 1,'omitnan'), 2, 1),'-k','linewidth',1,'displayname','Mean')
hold on
plot([1-0.15; 1 + 0.15], repmat(median(micromechanicalTesting, 1,'omitnan'), 2, 1),':k','linewidth',1,'displayname','Median')
scatter(ones(size(micromechanicalTesting)), micromechanicalTesting,40,'MarkerEdgeColor','w','MarkerFaceColor',ctrl.c1,'jitter','on','jitterAmount',0.15,'handlevisibility','off')


plot([1.25],repmat(11.12, 1, 1),'ok','linewidth',1,'handlevisibility','off')%'displayname','Seidlhofer et al. 2019')
plot([1.25],repmat(20.0, 1, 1),'sk','linewidth',1,'handlevisibility','off')%'displayname','Lorbach et al., 2014, a)')
plot([1.25],repmat(17.0, 1, 1),'dk','linewidth',1,'handlevisibility','off')%'displayname','Lorbach et al., 2014, b)')

text(1.3,11.12,'Seidlhofer et al., 2019','horizontalAlignment','left','fontname','Arial')
text(1.3,18.5,'Lorbach et al., 2014','horizontalAlignment','left','fontname','Arial')
% text(1.3,17,'Lorbach et al., 2014, b)','horizontalAlignment','left','fontname','Arial')
ylabel('Longitudinal modulus E_L [GPa]')
xticks([1 ])
xticklabels({'This work'})
xlim([0.75 2.25])
% ylim([0 50])
ylim([0 30])
legend('location','northeast')
set(gca,'fontsize',10,'FontName','Arial','Ygrid','on','YMinorGrid','off')
set(gcf,'PaperPositionMode','auto')
print('testTwo','-dpng','-r400')










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
plot(x1,f1Fcn(x1),lineInstructionsOne{:})
hold on
plot(x2,f2Fcn(x2),lineInstructionsOne{:},'handlevisibility','off')
plot(x3,f3Fcn(x3),lineInstructionsOne{:},'handlevisibility','off')
plot(x4,f4Fcn(x4),lineInstructionsOne{:},'handlevisibility','off')

plot(x1,f1Fcn(x1)/2,lineInstructionsTwo{:})
hold on
plot(x2,f2Fcn(x2)/2,lineInstructionsTwo{:},'handlevisibility','off')
plot(x3,f3Fcn(x3)/2,lineInstructionsTwo{:},'handlevisibility','off')
plot(x4,f4Fcn(x4)/2,lineInstructionsTwo{:},'handlevisibility','off')

xlabel('Time [s]')
ylabel('Force [\cdot 10^{-6} N]')
legend('Hemispherical','Pyramidal','location','northeast','fontname','Arial')

xlim([-2 45])
ylim([0 22.5])

% annotation('textarrow',[0.6 0.3],[0.5 0.5],'String','20 \cdot 10^{-6} N/s')
% text(6,17.5,'\leftarrow20\cdot10^{-6} N/s\rightarrow','horizontalalignment','center','fontname','Arial')
% text(6,7.5,'\leftarrow10\cdot10^{-6} N/s\rightarrow','horizontalalignment','center','fontname','Arial')

text(11.25,15,'\leftarrow20\cdot10^{-6} N/s','horizontalalignment','left','fontname','Arial')
text(11.65,7.5,'\leftarrow10\cdot10^{-6} N/s','horizontalalignment','left','fontname','Arial')

text(29,5.0,'Thermal drift est.','horizontalalignment','center','fontname','Arial')
text(29,2.5,'at 5% load \downarrow','horizontalalignment','center','fontname','Arial')

set(gca,'fontsize',10,'fontname','Arial')

set(gcf,'PaperPositionMode','auto')
print('loadSchedule','-dpng','-r400')



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






% 
% % Real images for the manuscript
% selIdx = strcmp({results.indentationNormal},'L') ;
% f2 = gramm('x',[results.relativeHumidity]','y',[results.Er]','color',{results.indenterType},...
%             'subset',selIdx);
% f2.stat_boxplot();
% f2.axe_property('xlim',[20 80],'ylim',[0 20],'xtick',[25 45 60 75]);
% f2.set_names('x','Relative humidity [\%]', ...
%              'y','Indentation modulus $M$ [GPa]' , ...
%              'color','Indenter','marker','Indenter');
% f2.set_text_options('interpreter','latex','base_size',14,'font','Arial');
% 
% f2.set_point_options('base_size',8);
% f2.set_layout_options('legend',false);
% f2.geom_hline('yintercept',0,'style','k-');
% figure;
% f2.draw();
% f2.export('file_name','densityLongitudinal','file_type','png','width',8,'height',8,'units','cm');
% 
% 
% rTemp = {results.indentationNormal};
% rTemp = strrep(rTemp,'L','Longitudinal');
% rTemp = strrep(rTemp,'T','Transverse');
% selIdx = strcmp({results.indenterType},'hemispherical') ;
% f2 = gramm('x',[results.relativeHumidity]','y',[results.Er]','color',rTemp,...
%             'subset',selIdx);
% f2.stat_boxplot();
% f2.axe_property('xlim',[20 80],'ylim',[0 20],'xtick',[25 45 60 75]);
% f2.set_names('x','Relative humidity [\%]', ...
%              'y','Indentation modulus $M$ [GPa]' , ...
%              'color','');
% f2.set_text_options('interpreter','latex','base_size',14,'font','Arial');
% f2.set_point_options('base_size',8);
% f2.set_color_options('map','d3_10');
% f2.set_layout_options('legend',false);
% f2.geom_hline('yintercept',0,'style','k-');
% figure;
% f2.draw();
% f2.export('file_name','densityTransverse','file_type','png','width',8,'height',8,'units','cm');
% 
% 
% 
% % Calculate the means \pm CI
% indentationSel = strcmp({results.indentationNormal},'L') & strcmp({results.indenterType},'pyramidal');
% 
% selIdx = indentationSel & [results.relativeHumidity] == 25;
% [ErMeanLP25,ErStdLP25,ErNumelLP25,ErCILP25,HMeanLP25,HStdLP25,HNumelLP25,HCILP25] = summaryStatisticsOfResults(results(selIdx));
% fprintf(formatString,'ErMeanLP25 = ',ErMeanLP25,'ErStdLP25 = ',ErStdLP25,'ErNumelLP25 = ',ErNumelLP25,'ErCILP25 = ',ErCILP25)
% fprintf(formatString,'HMeanLP25 = ',HMeanLP25,'HStdLP25 = ',HStdLP25,'HNumelLP25 = ',HNumelLP25,'HCILP25 = ',HCILP25)
% 
% selIdx = indentationSel & [results.relativeHumidity] == 45;
% [ErMeanLP45,ErStdLP45,ErNumelLP45,ErCILP45,HMeanLP45,HStdLP45,HNumelLP45,HCILP45] = summaryStatisticsOfResults(results(selIdx));
% fprintf(formatString,'ErMeanLP45 = ',ErMeanLP45,'ErStdLP45 = ',ErStdLP45,'ErNumelLP45 = ',ErNumelLP45,'ErCILP45 = ',ErCILP45)
% fprintf(formatString,'HMeanLP45 = ',HMeanLP45,'HStdLP45 = ',HStdLP45,'HNumelLP45 = ',HNumelLP45,'HCILP45 = ',HCILP45)
% 
% 
% selIdx = indentationSel & [results.relativeHumidity] == 60;
% [ErMeanLP60,ErStdLP60,ErNumelLP60,ErCILP60,HMeanLP60,HStdLP60,HNumelLP60,HCILP60] = summaryStatisticsOfResults(results(selIdx));
% fprintf(formatString,'ErMeanLP60 = ',ErMeanLP60,'ErStdLP60 = ',ErStdLP60,'ErNumelLP60 = ',ErNumelLP60,'ErCILP60 = ',ErCILP60)
% fprintf(formatString,'HMeanLP60 = ',HMeanLP60,'HStdLP60 = ',HStdLP60,'HNumelLP60 = ',HNumelLP60,'HCILP60 = ',HCILP60)
% 
% selIdx = indentationSel & [results.relativeHumidity] == 75;
% [ErMeanLP75,ErStdLP75,ErNumelLP75,ErCILP75,HMeanLP75,HStdLP75,HNumelLP75,HCILP75] = summaryStatisticsOfResults(results(selIdx));
% fprintf(formatString,'ErMeanLP75 = ',ErMeanLP75,'ErStdLP75 = ',ErStdLP75,'ErNumelLP75 = ',ErNumelLP75,'ErCILP75 = ',ErCILP75)
% fprintf(formatString,'HMeanLP75 = ',HMeanLP75,'HStdLP75 = ',HStdLP75,'HNumelLP75 = ',HNumelLP75,'HCILP75 = ',HCILP75)
% 
% 
% indentationSel = strcmp({results.indentationNormal},'L') & strcmp({results.indenterType},'hemispherical');
% 
% selIdx = indentationSel & [results.relativeHumidity] == 25;
% [ErMeanLH25,ErStdLH25,ErNumelLH25,ErCILH25,HMeanLH25,HStdLH25,HNumelLH25,HCILH25] = summaryStatisticsOfResults(results(selIdx));
% fprintf(formatString,'ErMeanLH25 = ',ErMeanLH25,'ErStdLH25 = ',ErStdLH25,'ErNumelLH25 = ',ErNumelLH25,'ErCILH25 = ',ErCILH25)
% fprintf(formatString,'HMeanLH25 = ',HMeanLH25,'HStdLH25 = ',HStdLH25,'HNumelLH25 = ',HNumelLH25,'HCILH25 = ',HCILH25)
% 
% 
% 
% selIdx = indentationSel & [results.relativeHumidity] == 45;
% [ErMeanLH45,ErStdLH45,ErNumelLH45,ErCILH45,HMeanLH45,HStdLH45,HNumelLH45,HCILH45] = summaryStatisticsOfResults(results(selIdx));
% fprintf(formatString,'ErMeanLH45 = ',ErMeanLH45,'ErStdLH45 = ',ErStdLH45,'ErNumelLH45 = ',ErNumelLH45,'ErCILH45 = ',ErCILH45)
% fprintf(formatString,'HMeanLH45 = ',HMeanLH45,'HStdLH45 = ',HStdLH45,'HNumelLH45 = ',HNumelLH45,'HCILH45 = ',HCILH45)
% 
% 
% 
% 
% selIdx = indentationSel & [results.relativeHumidity] == 60;
% [ErMeanLH60,ErStdLH60,ErNumelLH60,ErCILH60,HMeanLH60,HStdLH60,HNumelLH60,HCILH60] = summaryStatisticsOfResults(results(selIdx));
% fprintf(formatString,'ErMeanLH60 = ',ErMeanLH60,'ErStdLH60 = ',ErStdLH60,'ErNumelLH60 = ',ErNumelLH60,'ErCILH60 = ',ErCILH60)
% fprintf(formatString,'HMeanLH60 = ',HMeanLH60,'HStdLH60 = ',HStdLH60,'HNumelLH60 = ',HNumelLH60,'HCILH60 = ',HCILH60)
% 
% 
% 
% 
% selIdx = indentationSel & [results.relativeHumidity] == 75;
% [ErMeanLH75,ErStdLH75,ErNumelLH75,ErCILH75,HMeanLH75,HStdLH75,HNumelLH75,HCILH75] = summaryStatisticsOfResults(results(selIdx));
% fprintf(formatString,'ErMeanLH75 = ',ErMeanLH75,'ErStdLH75 = ',ErStdLH75,'ErNumelLH75 = ',ErNumelLH75,'ErCILH75 = ',ErCILH75)
% fprintf(formatString,'HMeanLH75 = ',HMeanLH75,'HStdLH75 = ',HStdLH75,'HNumelLH75 = ',HNumelLH75,'HCILH75 = ',HCILH75)
% 
% 
% 
% selIdx = strcmp({results.indentationNormal},'T') & [results.relativeHumidity] == 45;
% [ErMeanTH45,ErStdTH45,ErNumelTH45,ErCITH45,HMeanTH45,HStdTH45,HNumelTH45,HCITH45] = summaryStatisticsOfResults(results(selIdx));
% fprintf(formatString,'ErMeanTH45 = ',ErMeanTH45,'ErStdTH45 = ',ErStdTH45,'ErNumelTH45 = ',ErNumelTH45,'ErCITH45 = ',ErCITH45)
% fprintf(formatString,'HMeanTH45 = ',HMeanTH45,'HStdTH45 = ',HStdTH45,'HNumelTH45 = ',HNumelTH45,'HCITH45 = ',HCITH45)
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Hardness values
% selIdx = strcmp({results.indentationNormal},'L') ;
% f2 = gramm('x',[results.relativeHumidity]','y',[results.H]','color',{results.indenterType},...
%             'subset',selIdx);
% f2.stat_boxplot();
% f2.axe_property('xlim',[20 80],'ylim',[0 0.8],'xtick',[25 45 60 75]);
% f2.set_names('x','Relative humidity [\%]', ...
%              'y','Hardness $H$ [GPa]' , ...
%              'color','Indenter','marker','Indenter');
% f2.set_text_options('interpreter','latex','base_size',14,'font','Arial');
% f2.set_point_options('base_size',8);
% f2.set_layout_options('legend',false);
% f2.geom_hline('yintercept',0,'style','k-');
% figure;
% f2.draw();
% f2.export('file_name','densityLongitudinalHardness','file_type','png','width',8,'height',8,'units','cm');
% 
% 
% 
% 
% 
% 
% 
% 
% 
% 
% fprintf('%20s\n','KEY INPUTS')
% fprintf('%20s %10.4f %4s\n','ErMeanLH45 = ',ErMeanLH45,' GPa')
% fprintf('%20s %10.4f %4s\n','ErMeanLP45 = ',ErMeanLP45,' GPa')
% fprintf('%20s %10.4f %4s\n','ErMeanTH45 = ',ErMeanTH45,' GPa')
% 
% 
% 
% 
% 
% % Real images for the manuscript
% selIdx = strcmp({results.indentationNormal},'L') ;
% f2 = gramm('x',{results.indenterType},'y',[results.Er]','color',{results.indenterType},...
%             'subset',selIdx);
% % f2.stat_boxplot();
% % f2.stat_violin();
% f2.geom_point();
% f2.geom_jitter();
% % f2.axe_property('xlim',[20 80],'ylim',[0 20],'xtick',[25 45 60 75]);
% f2.set_names('x','Relative humidity [\%]', ...
%              'y','Indentation modulus $M$ [GPa]' , ...
%              'color','Indenter','marker','Indenter');
% f2.set_text_options('interpreter','latex','base_size',14,'font','Arial');
% 
% f2.set_point_options('base_size',8);
% f2.set_layout_options('legend',false);
% f2.geom_hline('yintercept',0,'style','k-');
% figure;
% f2.draw();



figure('units','centimeters','OuterPosition',[10 10 15 10+2.5*3]);
tiledlayout(9,4,'padding','none','tilespacing','none');
nexttile(5,[4 4]);
plot([mean(xTemp(1,selHemi))-0.35; mean(xTemp(1,selHemi)) + 0.35], repmat(mean(yTemp(selHemi), 1), 2, 1),'-k','linewidth',1,'displayname','Mean')
hold on
plot([mean(xTemp(1,selHemi))-0.35; mean(xTemp(1,selHemi)) + 0.35], repmat(median(yTemp(selHemi), 1), 2, 1),':k','linewidth',1,'displayname','Median')
scatter(xTemp(selHemi), yTemp(selHemi),40,'MarkerEdgeColor','w','MarkerFaceColor',ctrl.c1,'jitter','on','jitterAmount',0.15,'handlevisibility','off')

plot([mean(xTemp(1,selPyr))-0.35; mean(xTemp(1,selPyr)) + 0.35], repmat(mean(yTemp(selPyr), 1) , 2, 1),'-k','linewidth',1,'handlevisibility','off')
plot([mean(xTemp(1,selPyr))-0.35; mean(xTemp(1,selPyr)) + 0.35], repmat(median(yTemp(selPyr), 1) , 2, 1),':k','linewidth',1,'handlevisibility','off')
scatter(xTemp(selPyr), yTemp(selPyr),40,'v','MarkerEdgeColor','w','MarkerFaceColor',ctrl.c1,'jitter','on','jitterAmount',0.15,'handlevisibility','off')

plot([0-0.35; 0 + 0.35], repmat(mean(transER', 1), 2, 1),'-k','linewidth',1,'handlevisibility','off')
plot([0-0.35; 0 + 0.35], repmat(median(transER', 1) , 2, 1),':k','linewidth',1,'handlevisibility','off')
scatter(0*ones(size(transER)) , transER,40,'MarkerEdgeColor','w','MarkerFaceColor',ctrl.c2,'jitter','on','jitterAmount',0.15,'handlevisibility','off')


plot([3-0.35; 3 + 0.35], repmat(mean(nanoIndenterER, 1), 2, 1),'-k','linewidth',1,'handlevisibility','off')
plot([3-0.35; 3 + 0.35], repmat(median(nanoIndenterER, 1) , 2, 1),':k','linewidth',1,'handlevisibility','off')
scatter(3.*ones(size(nanoIndenterER)), nanoIndenterER,40,'v','MarkerEdgeColor','w','MarkerFaceColor',ctrl.c1,'jitter','on','jitterAmount',0.15,'handlevisibility','off')


% patch([-0.5 3.5 3.5 -0.5 -0.5],[0 0 10 10 0],[0 0 0],'edgecolor','none','linewidth',2, ...
%       'facecolor',[0.5 0.5 0.5],'facealpha',0.2,'HandleVisibility','off')


ylabel('Indentation modulus M [GPa]')
% xlabel('Indenter, direction')
xticks([0 1 2 3])
xticklabels({'AFM-NI, T','AFM-NI, L','AFM-NI, L','NI, L'})
xlim([-0.5 3.5])
ylim([0 50])
% ylim([0 30])
legend('location','northwest')
set(gca,'fontsize',10,'FontName','Arial','Ygrid','on','YMinorGrid','off')
% set(gca,'Yscale','log')

%%%%%%%%%%%%%%
nexttile(1);
text(-0.35,0.2,sprintf('%s \n','Normal: ','Indenter: ','Max load: '),'FontWeight','bold')
hold on
text(0.5,0.2,sprintf('%s \n','Transverse','Hemisphere','20 \muN'),'HorizontalAlignment','center')
axis off 

nexttile(2);
text(0.5,0.2,sprintf('%s \n','Longitudinal','Pyramid','10 \muN'),'HorizontalAlignment','center')
axis off 

nexttile(3);
text(0.5,0.2,sprintf('%s \n','Longitudinal','Hemisphere','20 \muN'),'HorizontalAlignment','center')
axis off 

nexttile(4);
text(0.5,0.2,sprintf('%s \n','Longitudinal','Cube corner','100 \muN'),'HorizontalAlignment','center')
axis off 



nexttile(21,[4 4]);
plot([mean(xTemp(1,selHemi))-0.35; mean(xTemp(1,selHemi)) + 0.35], repmat(mean(yTemp(selHemi), 1), 2, 1),'-k','linewidth',1,'displayname','Mean')
hold on
plot([mean(xTemp(1,selHemi))-0.35; mean(xTemp(1,selHemi)) + 0.35], repmat(median(yTemp(selHemi), 1), 2, 1),':k','linewidth',1,'displayname','Median')
scatter(xTemp(selHemi), yTemp(selHemi),40,'MarkerEdgeColor','w','MarkerFaceColor',ctrl.c1,'jitter','on','jitterAmount',0.15,'handlevisibility','off')

plot([mean(xTemp(1,selPyr))-0.35; mean(xTemp(1,selPyr)) + 0.35], repmat(mean(yTemp(selPyr), 1) , 2, 1),'-k','linewidth',1,'handlevisibility','off')
plot([mean(xTemp(1,selPyr))-0.35; mean(xTemp(1,selPyr)) + 0.35], repmat(median(yTemp(selPyr), 1) , 2, 1),':k','linewidth',1,'handlevisibility','off')
scatter(xTemp(selPyr), yTemp(selPyr),40,'v','MarkerEdgeColor','w','MarkerFaceColor',ctrl.c1,'jitter','on','jitterAmount',0.15,'handlevisibility','off')

plot([0-0.35; 0 + 0.35], repmat(mean(transER', 1), 2, 1),'-k','linewidth',1,'handlevisibility','off')
plot([0-0.35; 0 + 0.35], repmat(median(transER', 1) , 2, 1),':k','linewidth',1,'handlevisibility','off')
scatter(0*ones(size(transER)) , transER,40,'MarkerEdgeColor','w','MarkerFaceColor',ctrl.c2,'jitter','on','jitterAmount',0.15,'handlevisibility','off')


plot([3-0.35; 3 + 0.35], repmat(mean(nanoIndenterER, 1), 2, 1),'-k','linewidth',1,'handlevisibility','off')
plot([3-0.35; 3 + 0.35], repmat(median(nanoIndenterER, 1) , 2, 1),':k','linewidth',1,'handlevisibility','off')
scatter(3.*ones(size(nanoIndenterER)), nanoIndenterER,40,'v','MarkerEdgeColor','w','MarkerFaceColor',ctrl.c1,'jitter','on','jitterAmount',0.15,'handlevisibility','off')


ylabel('Indentation modulus M [GPa]')
xlabel('Indenter, direction')
xticks([0 1 2 3])
xticklabels({'AFM-NI, T','AFM-NI, L','AFM-NI, L','NI, L'})
xlim([-0.5 3.5])
ylim([0 10])
% ylim([0 30])
legend('location','northwest')
set(gca,'fontsize',10,'FontName','Arial','Ygrid','on','YMinorGrid','off')




set(gca,'fontsize',10,'fontname','Arial','Ygrid','on')

set(gcf,'PaperPositionMode','auto')
print('testThree','-dpng','-r400')










% pts = linspace(0,20,200);
% 
% [f1,~] = ksdensity(yTemp(selHemi),pts,'support','positive','BoundaryCorrection','reflection');
% 
% [f2,~] = ksdensity(yTemp(selPyr),pts,'support','positive','BoundaryCorrection','reflection');
% [f3,~] = ksdensity(nanoIndenterER,pts,'support','positive','BoundaryCorrection','reflection');
% [f4,~] = ksdensity(transER,pts,'support','positive','BoundaryCorrection','reflection');
% 
% lineInstructions = {'linewidth',1};
% figure;
% plot(pts,f1,lineInstructions{:})
% hold on
% plot(pts,f2,lineInstructions{:})
% plot(pts,f3,lineInstructions{:})
% plot(pts,f4,lineInstructions{:})
% 
% legend('Hemispherical L','Pyramidal L','NI, L','Hemispherical, T','location','northeast')








