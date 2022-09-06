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
addpath('gramm')


% Check whether we are in MATLAB or in OCTAVE
execEngine = exist ('OCTAVE_VERSION', 'builtin');

if execEngine == 5
  pkg load optim
  %cd('')
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
hyperParameters.thermpnt                = 2000;
hyperParameters.unloadingFitRange       = 1400;
hyperParameters.unloadingFitFunction    = 'Oliver-Pharr';
hyperParameters.compensateCreep         = 0;
hyperParameters.constrainHead = 0;
hyperParameters.constrainTail = 0;


% compliance.targetDir        = ''
% compliance.areaFile         = ''
% compliance.springConstant   = 260.12;
% compliance.Er               = 3;
% [complianceTot, areaSave]   = extractMachineCompliance(compliance,ctrl,hyperParameters);
% selInf = isinf(areaSave);
% complianceTot(selInf) = [];
% areaSave(selInf) = [];
% effectiveCompliance = [areaSave ; ones(size(complianceTot))]'\complianceTot';
% effectiveCompliance = effectiveCompliance(2);
% 
% hyperParameters.unloadingFitFunction    = 'Oliver-Pharr';
% hyperParameters.machineCompliance = 0;
% hyperParameters.compensateCreep = 0;



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
    Row1export(:,10) = {results.designatedName}';
    
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
    Row1export(:,10) = {results.designatedName}';

    filename = 'testdataOCTAVE.csv';
    cell2csv(filename,Row1export)

end

