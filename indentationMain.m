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
addpath('src')


% Check whether we are in MATLAB or in OCTAVE
execEngine = exist ('OCTAVE_VERSION', 'builtin');

if execEngine == 5
  pkg load optim
  plotDir = 'plotsOCTAVE';
else
  plotDir = 'plotsMATLAB';
end


% Output controls
% Outputs are handled by a STRUCT called ctrl. ctrl has only 1 entry, with fields corresponding to 
% the different run conditions
%
% The fields of ctrl are:
%
%   .verbose
ctrl.verbose = 1;

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
hyperParameters.constrainHead           = 0;
hyperParameters.constrainTail           = 0;
hyperParameters.machineCompliance       = 0;

hyperParameters.endRangeBaseFit = 25;               % Should not be changed in general.
hyperParameters.contactDetectionNoiseFactor = 4;    % Should not be changed in general
hyperParameters.allowNegativeCreep = 0;             % Can be changed.


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

indentationSet = importMOFMeasurements();

[indentationSet , hyperParameters, ctrl] = inputValidation( indentationSet, hyperParameters, ctrl);


fprintf('%10s Start of calculations.\n','');
fprintf('%10s There are %2d set(s).\n','',numel(indentationSet));
for aLoop = 1:numel(indentationSet) % For each  indentationSet
    
    resultNames = subdirImport(indentationSet(aLoop).targetDir,'regex','.ibw');
    % Import all the .IBW files in the target directory.
    
    indentationSet(aLoop).inputFiles = resultNames;
    % Add the file names to the indentationSet structure for future use.
    
    fprintf('%10s %30s %10s\n','','The current set is: ',indentationSet(aLoop).designatedName);
    fprintf('%10s %30s %20d\n','','Result files in this set:',numel(resultNames));
    
    ErSave          = nan(numel(resultNames),1);
    HSave           = nan(numel(resultNames),1);
    CidxSave        = nan(numel(resultNames),1);
    thermIdxSave    = nan(numel(resultNames),1);
    
    for bLoop = 1:numel(resultNames)        % For each result file in targetDir       
        [ErSave(bLoop),HSave(bLoop),CidxSave(bLoop),thermIdxSave(bLoop),diagnosticsSave(bLoop)] = modulusFitter(indentationSet(aLoop),ctrl,hyperParameters,resultNames{bLoop});

        fprintf('%20s %20s %20.4f %4s\n','','ER = ',ErSave(bLoop),' GPa');
    end
 
        
    % Associate results with indentationSet for future use
    indentationSet(aLoop).Er = (ErSave);
    indentationSet(aLoop).H = (HSave);
    indentationSet(aLoop).Cidx = (CidxSave);
    indentationSet(aLoop).thermIdx = (thermIdxSave);
    indentationSet(aLoop).diagnostics = (diagnosticsSave);
    
    
    clear ErSave HSave CidxSave thermIdxSave diagnosticsSave
    % Clear the variables to ensure the sizes are correct on the next loop.
end


% Make one huge array
results = collectAllResults(indentationSet);

% Save a .MAT file for easy resume.
save(['results_' datestr(today) '.mat'],'results','indentationSet','hyperParameters','-v7.3')

% Save a excel file for easy further processing.
ColumnExport       = {results.inputFiles}';
ColumnExport(:,2)  = {results.indenterType}';
ColumnExport(:,3)  = {results.relativeHumidity}';
ColumnExport(:,4)  = {results.springConstant}';

ColumnExport(:,5)  = {results.Er}';
ColumnExport(:,6)  = {results.H}';
ColumnExport(:,7)  = {results.Cidx}';
ColumnExport(:,8)  = {results.thermIdx}';
ColumnExport(:,9)  = {results.indentationNormal}';
ColumnExport(:,10) = {results.designatedName}';

if execEngine == 0
    filename = 'testdataMATLAB.xlsx';
    writecell(ColumnExport,filename,'Sheet',1,'Range','B2')
elseif execEngine == 5
    filename = 'testdataOCTAVE.csv';
    cell2csv(filename,ColumnExport)
end

