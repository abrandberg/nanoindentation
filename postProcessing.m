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
addpath('gramm')
load('results_23-Nov-2020.mat') 
% Replace this file with the one you generated yourself by running indentationMain.m

format compact
formatString = '     %20s %10.4f %20s %10.4f %20s %10.4f %20s %10.4f \n';


indentationDirections = {'L','T'};


% Real images for the manuscript
selIdx = strcmp({results.indentationNormal},'L') ;
f2 = gramm('x',[results.relativeHumidity]','y',[results.Er]','color',{results.indenterType},...
            'subset',selIdx);
f2.stat_boxplot();
f2.axe_property('xlim',[20 80],'ylim',[0 20],'xtick',[25 45 60 75]);
f2.set_names('x','Relative humidity [\%]', ...
             'y','Indentation modulus $M$ [GPa]' , ...
             'color','Indenter','marker','Indenter');
f2.set_text_options('interpreter','latex','base_size',14,'font','Arial');

f2.set_point_options('base_size',8);
f2.set_layout_options('legend',false);
f2.geom_hline('yintercept',0,'style','k-');
figure;
f2.draw();
f2.export('file_name','densityLongitudinal','file_type','png','width',8,'height',8,'units','cm');


rTemp = {results.indentationNormal};
rTemp = strrep(rTemp,'L','Longitudinal');
rTemp = strrep(rTemp,'T','Transverse');
selIdx = strcmp({results.indenterType},'hemispherical') ;
f2 = gramm('x',[results.relativeHumidity]','y',[results.Er]','color',rTemp,...
            'subset',selIdx);
f2.stat_boxplot();
f2.axe_property('xlim',[20 80],'ylim',[0 20],'xtick',[25 45 60 75]);
f2.set_names('x','Relative humidity [\%]', ...
             'y','Indentation modulus $M$ [GPa]' , ...
             'color','');
f2.set_text_options('interpreter','latex','base_size',14,'font','Arial');
f2.set_point_options('base_size',8);
f2.set_color_options('map','d3_10');
f2.set_layout_options('legend',false);
f2.geom_hline('yintercept',0,'style','k-');
figure;
f2.draw();
f2.export('file_name','densityTransverse','file_type','png','width',8,'height',8,'units','cm');



% Calculate the means \pm CI
indentationSel = strcmp({results.indentationNormal},'L') & strcmp({results.indenterType},'pyramidal');

selIdx = indentationSel & [results.relativeHumidity] == 25;
[ErMeanLP25,ErStdLP25,ErNumelLP25,ErCILP25,HMeanLP25,HStdLP25,HNumelLP25,HCILP25] = summaryStatisticsOfResults(results(selIdx));
fprintf(formatString,'ErMeanLP25 = ',ErMeanLP25,'ErStdLP25 = ',ErStdLP25,'ErNumelLP25 = ',ErNumelLP25,'ErCILP25 = ',ErCILP25)
fprintf(formatString,'HMeanLP25 = ',HMeanLP25,'HStdLP25 = ',HStdLP25,'HNumelLP25 = ',HNumelLP25,'HCILP25 = ',HCILP25)

selIdx = indentationSel & [results.relativeHumidity] == 45;
[ErMeanLP45,ErStdLP45,ErNumelLP45,ErCILP45,HMeanLP45,HStdLP45,HNumelLP45,HCILP45] = summaryStatisticsOfResults(results(selIdx));
fprintf(formatString,'ErMeanLP45 = ',ErMeanLP45,'ErStdLP45 = ',ErStdLP45,'ErNumelLP45 = ',ErNumelLP45,'ErCILP45 = ',ErCILP45)
fprintf(formatString,'HMeanLP45 = ',HMeanLP45,'HStdLP45 = ',HStdLP45,'HNumelLP45 = ',HNumelLP45,'HCILP45 = ',HCILP45)


selIdx = indentationSel & [results.relativeHumidity] == 60;
[ErMeanLP60,ErStdLP60,ErNumelLP60,ErCILP60,HMeanLP60,HStdLP60,HNumelLP60,HCILP60] = summaryStatisticsOfResults(results(selIdx));
fprintf(formatString,'ErMeanLP60 = ',ErMeanLP60,'ErStdLP60 = ',ErStdLP60,'ErNumelLP60 = ',ErNumelLP60,'ErCILP60 = ',ErCILP60)
fprintf(formatString,'HMeanLP60 = ',HMeanLP60,'HStdLP60 = ',HStdLP60,'HNumelLP60 = ',HNumelLP60,'HCILP60 = ',HCILP60)

selIdx = indentationSel & [results.relativeHumidity] == 75;
[ErMeanLP75,ErStdLP75,ErNumelLP75,ErCILP75,HMeanLP75,HStdLP75,HNumelLP75,HCILP75] = summaryStatisticsOfResults(results(selIdx));
fprintf(formatString,'ErMeanLP75 = ',ErMeanLP75,'ErStdLP75 = ',ErStdLP75,'ErNumelLP75 = ',ErNumelLP75,'ErCILP75 = ',ErCILP75)
fprintf(formatString,'HMeanLP75 = ',HMeanLP75,'HStdLP75 = ',HStdLP75,'HNumelLP75 = ',HNumelLP75,'HCILP75 = ',HCILP75)


indentationSel = strcmp({results.indentationNormal},'L') & strcmp({results.indenterType},'hemispherical');

selIdx = indentationSel & [results.relativeHumidity] == 25;
[ErMeanLH25,ErStdLH25,ErNumelLH25,ErCILH25,HMeanLH25,HStdLH25,HNumelLH25,HCILH25] = summaryStatisticsOfResults(results(selIdx));
fprintf(formatString,'ErMeanLH25 = ',ErMeanLH25,'ErStdLH25 = ',ErStdLH25,'ErNumelLH25 = ',ErNumelLH25,'ErCILH25 = ',ErCILH25)
fprintf(formatString,'HMeanLH25 = ',HMeanLH25,'HStdLH25 = ',HStdLH25,'HNumelLH25 = ',HNumelLH25,'HCILH25 = ',HCILH25)



selIdx = indentationSel & [results.relativeHumidity] == 45;
[ErMeanLH45,ErStdLH45,ErNumelLH45,ErCILH45,HMeanLH45,HStdLH45,HNumelLH45,HCILH45] = summaryStatisticsOfResults(results(selIdx));
fprintf(formatString,'ErMeanLH45 = ',ErMeanLH45,'ErStdLH45 = ',ErStdLH45,'ErNumelLH45 = ',ErNumelLH45,'ErCILH45 = ',ErCILH45)
fprintf(formatString,'HMeanLH45 = ',HMeanLH45,'HStdLH45 = ',HStdLH45,'HNumelLH45 = ',HNumelLH45,'HCILH45 = ',HCILH45)




selIdx = indentationSel & [results.relativeHumidity] == 60;
[ErMeanLH60,ErStdLH60,ErNumelLH60,ErCILH60,HMeanLH60,HStdLH60,HNumelLH60,HCILH60] = summaryStatisticsOfResults(results(selIdx));
fprintf(formatString,'ErMeanLH60 = ',ErMeanLH60,'ErStdLH60 = ',ErStdLH60,'ErNumelLH60 = ',ErNumelLH60,'ErCILH60 = ',ErCILH60)
fprintf(formatString,'HMeanLH60 = ',HMeanLH60,'HStdLH60 = ',HStdLH60,'HNumelLH60 = ',HNumelLH60,'HCILH60 = ',HCILH60)




selIdx = indentationSel & [results.relativeHumidity] == 75;
[ErMeanLH75,ErStdLH75,ErNumelLH75,ErCILH75,HMeanLH75,HStdLH75,HNumelLH75,HCILH75] = summaryStatisticsOfResults(results(selIdx));
fprintf(formatString,'ErMeanLH75 = ',ErMeanLH75,'ErStdLH75 = ',ErStdLH75,'ErNumelLH75 = ',ErNumelLH75,'ErCILH75 = ',ErCILH75)
fprintf(formatString,'HMeanLH75 = ',HMeanLH75,'HStdLH75 = ',HStdLH75,'HNumelLH75 = ',HNumelLH75,'HCILH75 = ',HCILH75)



selIdx = strcmp({results.indentationNormal},'T') & [results.relativeHumidity] == 45;
[ErMeanTH45,ErStdTH45,ErNumelTH45,ErCITH45,HMeanTH45,HStdTH45,HNumelTH45,HCITH45] = summaryStatisticsOfResults(results(selIdx));
fprintf(formatString,'ErMeanTH45 = ',ErMeanTH45,'ErStdTH45 = ',ErStdTH45,'ErNumelTH45 = ',ErNumelTH45,'ErCITH45 = ',ErCITH45)
fprintf(formatString,'HMeanTH45 = ',HMeanTH45,'HStdTH45 = ',HStdTH45,'HNumelTH45 = ',HNumelTH45,'HCITH45 = ',HCITH45)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hardness values
selIdx = strcmp({results.indentationNormal},'L') ;
f2 = gramm('x',[results.relativeHumidity]','y',[results.H]','color',{results.indenterType},...
            'subset',selIdx);
f2.stat_boxplot();
f2.axe_property('xlim',[20 80],'ylim',[0 0.8],'xtick',[25 45 60 75]);
f2.set_names('x','Relative humidity [\%]', ...
             'y','Hardness $H$ [GPa]' , ...
             'color','Indenter','marker','Indenter');
f2.set_text_options('interpreter','latex','base_size',14,'font','Arial');
f2.set_point_options('base_size',8);
f2.set_layout_options('legend',false);
f2.geom_hline('yintercept',0,'style','k-');
figure;
f2.draw();
f2.export('file_name','densityLongitudinalHardness','file_type','png','width',8,'height',8,'units','cm');










fprintf('%20s\n','KEY INPUTS')
fprintf('%20s %10.4f %4s\n','ErMeanLH45 = ',ErMeanLH45,' GPa')
fprintf('%20s %10.4f %4s\n','ErMeanLP45 = ',ErMeanLP45,' GPa')
fprintf('%20s %10.4f %4s\n','ErMeanTH45 = ',ErMeanTH45,' GPa')





