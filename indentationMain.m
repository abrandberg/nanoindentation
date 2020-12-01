%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% AFM-Nanoindentation
%
% ABOUT:
%
% created by: August Brandberg augustbr at kth . se
% date: 2020-06-04
%
%

% Meta-instructions
clear; close all; clc
format compact



% Check whether we are in MATLAB or in OCTAVE
execEngine = exist ('OCTAVE_VERSION', 'builtin');

if execEngine == 5
  pkg load optim
  cd('C:/Users/augus/Documents/softwareProjects/nanoindentation/')
end


% Output controls
% Outputs are handled by a STRUCT called ctrl. ctrl has only 1 entry, with fields corresponding to 
% the different run conditions
%
% The fields of ctrl are:
%
%   .verbose
ctrl.verbose = 0;

% Analysis controls
% Some parameters cannot be determined by the algoritm and need to be supplied by the analyst.
% Those parameters are input in a STRUCT called hyperParameters. This struct should only contain
% parameters which are the same for every input.
%
% The fields of hyperParameters are:
%
%   .epsilon                : [-] Tip factor.
%   .sampleRate             : [Hz] Sample rate.
%   .thermpnt               : [-] Measurement points before thermal hold.
%   .unloadingFitRange      : [-] Vector samples lengths (measured from start of
%                                 unloading) to be included in unload fit.
%   .unloadingFitFunction   : [string] Function to use when fitting. Currently
%                                      supports 'Ganser', 'Feng' &
%                                      'Oliver-Pharr'.
%   .compensateCreep        : [Bool] Decides whether stiffness should be
%                             compensated for creep or not.
hyperParameters.epsilon                 = 0.75;
hyperParameters.sampleRate              = 2000;
hyperParameters.thermpnt                = 2000;     % Change this
hyperParameters.unloadingFitRange       = 1400;
hyperParameters.unloadingFitFunction    = 'Feng';
hyperParameters.compensateCreep         = 1;
hyperParameters.constrainHead = 0;
hyperParameters.constrainTail = 0;




indentationSet(1).designatedName        = 'S2_pyr_25';
indentationSet(1).relativeHumidity      = 25;
indentationSet(1).indenterType          = 'pyramidal';
indentationSet(1).indentationNormal     = 'L';
indentationSet(1).springConstant        = 66.65;
indentationSet(1).areaFile              = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\S2_pyr_k_66.65_RH25\NI_08_check_0003_arfun.txt';
indentationSet(1).targetDir             = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\S2_pyr_k_66.65_RH25\S2_data_pyr_NI08_k_66.65\';

indentationSet(2).designatedName        = 'S2_pyr_60';
indentationSet(2).relativeHumidity      = 60;
indentationSet(2).indenterType          = 'pyramidal';
indentationSet(2).indentationNormal     = 'L';
indentationSet(2).springConstant        = 98.52;
indentationSet(2).areaFile              = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\S2_pyr_k_98.52_RH60\NI_05_clean_0001_arfun.txt';
indentationSet(2).targetDir             = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\S2_pyr_k_98.52_RH60\190730\';

indentationSet(3).designatedName        = 'S2_pyr_45';
indentationSet(3).relativeHumidity      = 45;
indentationSet(3).indenterType          = 'pyramidal';
indentationSet(3).indentationNormal     = 'L';
indentationSet(3).springConstant        = 100.97;
indentationSet(3).areaFile              = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\S2_pyr_k_100.97_RH45\NI_05_clean_0001_arfun.txt';
indentationSet(3).targetDir             = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\S2_pyr_k_100.97_RH45\k_100.97_RH45\';

indentationSet(4).designatedName        = 'S2_pyr_75';
indentationSet(4).relativeHumidity      = 75;
indentationSet(4).indenterType          = 'pyramidal';
indentationSet(4).indentationNormal     = 'L';
indentationSet(4).springConstant        = 100.97;
indentationSet(4).areaFile              = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\S2_pyr_k_100.97_RH75\NI_05_clean_0001_arfun.txt';
indentationSet(4).targetDir             = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\S2_pyr_k_100.97_RH75\k_100.97_RH75\';

indentationSet(5).designatedName        = 'S2_pyr_45';
indentationSet(5).relativeHumidity      = 45;
indentationSet(5).indenterType          = 'pyramidal';
indentationSet(5).indentationNormal     = 'L';
indentationSet(5).springConstant        = 62.32;
indentationSet(5).areaFile              = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\S2_pyr_k_62.32_RH45\NI_05_clean_0001_arfun.txt';
indentationSet(5).targetDir             = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\S2_pyr_k_62.32_RH45\S2_pyr_k_62.32_RH45\';

indentationSet(6).designatedName        = 'S2_pyr_75';
indentationSet(6).relativeHumidity      = 75;
indentationSet(6).indenterType          = 'pyramidal';
indentationSet(6).indentationNormal     = 'L';
indentationSet(6).springConstant        = 62.32;
indentationSet(6).areaFile              = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\S2_pyr_k_62.32_RH75\NI_05_clean_0001_arfun.txt';
indentationSet(6).targetDir             = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\S2_pyr_k_62.32_RH75\S2_pyr_k_62.32_RH75\';

indentationSet(7).designatedName        = 'S2_hemi_75';
indentationSet(7).relativeHumidity      = 75;
indentationSet(7).indenterType          = 'hemispherical';
indentationSet(7).indentationNormal     = 'L';
indentationSet(7).springConstant        = 346.73;
indentationSet(7).areaFile              = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\S2_hemi_k_346.73_RH75\calib_05_0002_arfun.txt';
indentationSet(7).targetDir             = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\S2_hemi_k_346.73_RH75\RH75\';

indentationSet(8).designatedName        = 'S2_hemi_60';
indentationSet(8).relativeHumidity      = 60;
indentationSet(8).indenterType          = 'hemispherical';
indentationSet(8).indentationNormal     = 'L';
indentationSet(8).springConstant        = 335.99;
indentationSet(8).areaFile              = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\S2_hemi_k_335.99_RH60\calib_05_0002_arfun.txt';
indentationSet(8).targetDir             = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\S2_hemi_k_335.99_RH60\RH60\';

indentationSet(9).designatedName        = 'S2_hemi_60';
indentationSet(9).relativeHumidity      = 60;
indentationSet(9).indenterType          = 'hemispherical';
indentationSet(9).indentationNormal     = 'L';
indentationSet(9).springConstant        = 255.49;
indentationSet(9).areaFile              = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\S2_hemi_k_255.49_RH60\lrh_04_0001_arfun.txt';
indentationSet(9).targetDir             = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\S2_hemi_k_255.49_RH60\RH60\';

indentationSet(10).designatedName        = 'S2_hemi_25'; % FLAG THIS SET
indentationSet(10).relativeHumidity      = 25;
indentationSet(10).indenterType          = 'hemispherical';
indentationSet(10).indentationNormal     = 'L';
indentationSet(10).springConstant        = 242.35;
indentationSet(10).areaFile              = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\S2_hemi_k_242.35_RH25\calib_05_0002_arfun.txt';
indentationSet(10).targetDir             = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\S2_hemi_k_242.35_RH25\RH25\';

indentationSet(11).designatedName        = 'S2_hemi_45'; % FLAG THIS SET
indentationSet(11).relativeHumidity      = 45;
indentationSet(11).indenterType          = 'hemispherical';
indentationSet(11).indentationNormal     = 'L';
indentationSet(11).springConstant        = 242.35;
indentationSet(11).areaFile              = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\S2_hemi_k_242.35_RH45\calib_05_0002_arfun.txt';
indentationSet(11).targetDir             = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\S2_hemi_k_242.35_RH45\RH45\';

indentationSet(12).designatedName        = 'S2_hemi_25'; 
indentationSet(12).relativeHumidity      = 25;
indentationSet(12).indenterType          = 'hemispherical';
indentationSet(12).indentationNormal     = 'L';
indentationSet(12).springConstant        = 235.82;
indentationSet(12).areaFile              = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\S2_hemi_k_235.82_RH25\LRH250_4_0002_arfun.txt';
indentationSet(12).targetDir             = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\S2_hemi_k_235.82_RH25\RH25\';

indentationSet(13).designatedName        = 'S2_hemi_45'; 
indentationSet(13).relativeHumidity      = 45;
indentationSet(13).indenterType          = 'hemispherical';
indentationSet(13).indentationNormal     = 'L';
indentationSet(13).springConstant        = 235.82;
indentationSet(13).areaFile              = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\S2_hemi_k_235.82_RH45\LRH250_4_0002_arfun.txt';
indentationSet(13).targetDir             = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\S2_hemi_k_235.82_RH45\RH45\';

indentationSet(14).designatedName        = 'S2_hemi_60'; % Flag this set!
indentationSet(14).relativeHumidity      = 60;
indentationSet(14).indenterType          = 'hemispherical';
indentationSet(14).indentationNormal     = 'L';
indentationSet(14).springConstant        = 235.82;
indentationSet(14).areaFile              = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\S2_hemi_k_235.82_RH60\LRH250_4_0002_arfun.txt';
indentationSet(14).targetDir             = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\S2_hemi_k_235.82_RH60\RH60\';

indentationSet(15).designatedName        = 'S2_hemi_75'; % Flag this set!
indentationSet(15).relativeHumidity      = 75;
indentationSet(15).indenterType          = 'hemispherical';
indentationSet(15).indentationNormal     = 'L';
indentationSet(15).springConstant        = 235.82;
indentationSet(15).areaFile              = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\S2_hemi_k_235.82_RH75\LRH250_4_0002_arfun.txt';
indentationSet(15).targetDir             = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\S2_hemi_k_235.82_RH75\RH75\';



indentationSet(16).designatedName        = 'trans_hemi_25';
indentationSet(16).relativeHumidity      = 25;
indentationSet(16).indenterType          = 'hemispherical';
indentationSet(16).indentationNormal     = 'T';
indentationSet(16).springConstant        = 269.12;
indentationSet(16).areaFile              = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\trans_hemi_k_269.12_RH25\LRH250_03_0002_arfun.txt';
indentationSet(16).targetDir             = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\trans_hemi_k_269.12_RH25\RH25\';

indentationSet(17).designatedName        = 'trans_hemi_45';
indentationSet(17).relativeHumidity      = 45;
indentationSet(17).indenterType          = 'hemispherical';
indentationSet(17).indentationNormal     = 'T';
indentationSet(17).springConstant        = 268.15;
indentationSet(17).areaFile              = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\trans_hemi_k_268.15_RH45\LRH250_03_0002_arfun.txt';
indentationSet(17).targetDir             = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\trans_hemi_k_268.15_RH45\RH45\';

indentationSet(18).designatedName        = 'trans_hemi_25';
indentationSet(18).relativeHumidity      = 25;
indentationSet(18).indenterType          = 'hemispherical';
indentationSet(18).indentationNormal     = 'T';
indentationSet(18).springConstant        = 272.80;
indentationSet(18).areaFile              = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\trans_hemi_k_272.80_RH25\4th_LRH250_3_0001_arfun.txt';
indentationSet(18).targetDir             = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\trans_hemi_k_272.80_RH25\RH25\';

indentationSet(19).designatedName        = 'trans_hemi_60';
indentationSet(19).relativeHumidity      = 60;
indentationSet(19).indenterType          = 'hemispherical';
indentationSet(19).indentationNormal     = 'T';
indentationSet(19).springConstant        = 272.80;
indentationSet(19).areaFile              = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\trans_hemi_k_272.80_RH60\4th_LRH250_3_0001_arfun.txt';
indentationSet(19).targetDir             = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\trans_hemi_k_272.80_RH60\RH60\';

indentationSet(20).designatedName        = 'trans_hemi_75';
indentationSet(20).relativeHumidity      = 75;
indentationSet(20).indenterType          = 'hemispherical';
indentationSet(20).indentationNormal     = 'T';
indentationSet(20).springConstant        = 272.80;
indentationSet(20).areaFile              = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\trans_hemi_k_272.80_RH75\4th_LRH250_3_0001_arfun.txt';
indentationSet(20).targetDir             = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\trans_hemi_k_272.80_RH75\RH75\';

indentationSet(21).designatedName        = 'trans_hemi_45';
indentationSet(21).relativeHumidity      = 45;
indentationSet(21).indenterType          = 'hemispherical';
indentationSet(21).indentationNormal     = 'T';
indentationSet(21).springConstant        = 288.25;
indentationSet(21).areaFile              = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\trans_hemi_k_288.25_RH45\LRH250_4th_5_0001_arfun.txt';
indentationSet(21).targetDir             = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\trans_hemi_k_288.25_RH45\RH45\';

indentationSet(22).designatedName        = 'trans_hemi_45';
indentationSet(22).relativeHumidity      = 45;
indentationSet(22).indenterType          = 'hemispherical';
indentationSet(22).indentationNormal     = 'T';
indentationSet(22).springConstant        = 319.23;
indentationSet(22).areaFile              = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\trans_hemi_k_319.23_RH45\LRH250_05_0000_arfun.txt';
indentationSet(22).targetDir             = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\trans_hemi_k_319.23_RH45\RH45\';

indentationSet(23).designatedName        = 'trans_hemi_60';
indentationSet(23).relativeHumidity      = 60;
indentationSet(23).indenterType          = 'hemispherical';
indentationSet(23).indentationNormal     = 'T';
indentationSet(23).springConstant        = 319.23;
indentationSet(23).areaFile              = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\trans_hemi_k_319.23_RH60\LRH250_05_0000_arfun.txt';
indentationSet(23).targetDir             = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\trans_hemi_k_319.23_RH60\RH60\';
 
indentationSet(24).designatedName        = 'trans_hemi_75';
indentationSet(24).relativeHumidity      = 75;
indentationSet(24).indenterType          = 'hemispherical';
indentationSet(24).indentationNormal     = 'T';
indentationSet(24).springConstant        = 319.23;
indentationSet(24).areaFile              = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\trans_hemi_k_319.23_RH75\LRH250_05_0000_arfun.txt';
indentationSet(24).targetDir             = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\trans_hemi_k_319.23_RH75\RH75\';



indentationSet(25).designatedName        = 'trans_hemi_25';
indentationSet(25).relativeHumidity      = 25;
indentationSet(25).indenterType          = 'hemispherical';
indentationSet(25).indentationNormal     = 'T';
indentationSet(25).springConstant        = 301.02;
indentationSet(25).areaFile              = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\trans_hemi_k_301.02_RH25\LRH250_1_0001_arfun.txt';
indentationSet(25).targetDir             = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\trans_hemi_k_301.02_RH25\RH25\';

indentationSet(26).designatedName        = 'trans_hemi_60';
indentationSet(26).relativeHumidity      = 60;
indentationSet(26).indenterType          = 'hemispherical';
indentationSet(26).indentationNormal     = 'T';
indentationSet(26).springConstant        = 301.02;
indentationSet(26).areaFile              = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\trans_hemi_k_301.02_RH60\LRH250_1_0001_arfun.txt';
indentationSet(26).targetDir             = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\trans_hemi_k_301.02_RH60\RH60\';

indentationSet(27).designatedName        = 'trans_hemi_75';
indentationSet(27).relativeHumidity      = 75;
indentationSet(27).indenterType          = 'hemispherical';
indentationSet(27).indentationNormal     = 'T';
indentationSet(27).springConstant        = 301.02;
indentationSet(27).areaFile              = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\trans_hemi_k_301.02_RH75\LRH250_1_0001_arfun.txt';
indentationSet(27).targetDir             = 'C:\Users\augus\Desktop\tempCaterina\afmRepository\trans_hemi_k_301.02_RH75\RH75\';











if ctrl.verbose
    A =figure('PaperPositionMode','manual','PaperUnits','centimeters','PaperPosition',[20 20 30 20]);
    B =figure('PaperPositionMode','manual','PaperUnits','centimeters','PaperPosition',[20 20 30 20]);
    C =figure('PaperPositionMode','manual','PaperUnits','centimeters','PaperPosition',[20 20 30 20]);
    figure(A)
else
    B =figure('PaperPositionMode','manual','PaperUnits','centimeters','PaperPosition',[20 20 30 20]);
    
end

colorTemp = lines(20);

fprintf('%10s Start of calculations.\n','');
fprintf('%10s There are %2d set(s).\n','',numel(indentationSet));
for aLoop = 1:numel(indentationSet)         % For each row in indentationSet

    resultNames = subdirImport(indentationSet(aLoop).targetDir,'regex','.ibw');     % Find the .ibw files in targetDir
    indentationSet(aLoop).inputFiles = resultNames;
    
    fprintf('%10s %30s %10s\n','','The current set is: ',indentationSet(aLoop).designatedName);
    fprintf('%10s %30s %20d\n','','Result files in this set:',numel(resultNames));
    
    ErSave = nan(numel(resultNames),1);
    HSave = ErSave;
    CidxSave = ErSave;
    thermIdxSave = ErSave;
    for bLoop = 1:numel(resultNames)        % For each result file in targetDir
        
        
%         makeRepresentativeFDCurves(indentationSet(aLoop),ctrl,hyperParameters,resultNames{bLoop})

        [ErSave(bLoop),HSave(bLoop),CidxSave(bLoop),thermIdxSave(bLoop),diagnosticsSave(bLoop)] = modulusFitter(indentationSet(aLoop),ctrl,hyperParameters,resultNames{bLoop});

        fprintf('%20s %20s %20.4f %4s\n','','ER = ',ErSave(bLoop),' GPa');
       
    end
 
    
    if execEngine == 0
      mkdir('plotsMATLAB')
      folders = subdirImport([pwd filesep 'plotsMATLAB' filesep],'regex','_');
      print(horzcat([pwd filesep 'plotsMATLAB' filesep],indentationSet(aLoop).designatedName,num2str(aLoop)),'-dpng')
    elseif execEngine == 5
      mkdir('plotsOCTAVE')
      folders = subdirImport([pwd filesep 'plotsOCTAVE' filesep],'regex','_');
      print(horzcat([pwd filesep 'plotsOCTAVE' filesep],indentationSet(aLoop).designatedName,num2str(aLoop)),'-dpng')
    end
    
    
    % Associate results with array
    indentationSet(aLoop).Er = (ErSave);
    indentationSet(aLoop).H = (HSave);
    indentationSet(aLoop).Cidx = (CidxSave);
    indentationSet(aLoop).thermIdx = (thermIdxSave);
    indentationSet(aLoop).diagnostics = (diagnosticsSave);
    
    
    clear ErSave HSave CidxSave thermIdxSave diagnosticsSave

end


indentationSave = indentationSet;

for cLoop = 1:numel(indentationSet)
    for dLoop = numel(indentationSet(cLoop).Er):-1:1   
        if indentationSet(cLoop).Er(dLoop) > 100 || indentationSet(cLoop).Er(dLoop) < 0
            indentationSet(cLoop).Er(dLoop) = [];
            indentationSet(cLoop).H(dLoop) = [];
            indentationSet(cLoop).Cidx(dLoop) = [];
            indentationSet(cLoop).thermIdx(dLoop) = [];
            indentationSet(cLoop).inputFiles(dLoop)  = [];
        elseif indentationSet(cLoop).H(dLoop) > 1 || indentationSet(cLoop).H(dLoop) < 0
            indentationSet(cLoop).Er(dLoop) = [];
            indentationSet(cLoop).H(dLoop) = [];
            indentationSet(cLoop).Cidx(dLoop) = [];
            indentationSet(cLoop).thermIdx(dLoop) = [];
            indentationSet(cLoop).inputFiles(dLoop)  = [];
        end
    end   
end






% Make one huge array
results = collectAllResults(indentationSet);

save(['results_' datestr(today) '.mat'],'results','indentationSet','hyperParameters','-v7.3')


if execEngine == 0
    Row1export = {results.inputFiles}';
    Row1export(:,2) = {results.indenterType}';
    Row1export(:,3) = {results.relativeHumidity}';
    Row1export(:,4) = {results.springConstant}';


    Row1export(:,5) = {results.Er}';
    Row1export(:,6) = {results.H}';
    Row1export(:,7) = {results.Cidx}';
    Row1export(:,8) = {results.thermIdx}';
    Row1export(:,9) = {results.indentationNormal}';
    
    filename = 'testdataMATLAB.xlsx';
    writecell(Row1export,filename,'Sheet',1,'Range','B2')
elseif execEngine == 5
        Row1export = {results.inputFiles}';
    Row1export(:,2) = {results.indenterType}';
    Row1export(:,3) = {results.relativeHumidity}';
    Row1export(:,4) = {results.springConstant}';


    Row1export(:,5) = {results.Er}';
    Row1export(:,6) = {results.H}';
    Row1export(:,7) = {results.Cidx}';
    Row1export(:,8) = {results.thermIdx}';
    Row1export(:,9) = {results.indentationNormal}';

    filename = 'testdataOCTAVE.csv';
    cell2csv(filename,Row1export)

end



