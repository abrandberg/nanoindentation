%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Demo 1 for "nanoindentation"
%
%
% created by: August Brandberg augustbr at kth . se
% date: 2020-08-17

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
%   .verbose    - Decides whether to plot intermediate results.
%                 0 - no intermediate output
%                 1 - intermediate output
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
%   .constrainHead          : [Bool] Enforce that slope at Fmax > 0
%   .constrainTail          : [Bool] Enforce that slope at Fend > 0
%
% N.B. That constraining the function works better in MATLAB than in Octave (Octave fminunc
%      is comparatively poor). Constraining the slope is a non-conventional approach and
%      should be used with caution. Take care to verify that the scatter in results does not
%      increase too much.
hyperParameters.epsilon                 = 0.75;
hyperParameters.sampleRate              = 2000;
hyperParameters.thermpnt                = 2000;
hyperParameters.unloadingFitRange       = 1500;
hyperParameters.unloadingFitFunction    = 'Feng';
hyperParameters.compensateCreep         = 1;
hyperParameters.constrainHead           = 0;
hyperParameters.constrainTail           = 0;

% Inputs
% Inputs are formatted using a STRUCT called indentationSet. indentationSet may have any number of entries.
%
% The fields of each set are:
%
%   .designatedName         : A user-defined string to identify the set.
%   .relativeHumidity       : [%] Scalar indicating the relative humidity during the measurement.
%   .indenterType           : Currently supports "pyramidal" and "hemispherical".
%   .indentationNormal      : Indicates along which axis the indentation was performed (L,T,...).
%   .springConstant         : The indenter spring constant.
%   .areaFile               : File path to the file specifying area as a function of indentation, A(z).
%   .targetDir              : File path to the directory where the experiments are located. Experiments 
%                             are assumed to be reported in the form of *.ibw files.

indentationSet(1).designatedName        = 'Demo1';
indentationSet(1).relativeHumidity      = 25;
indentationSet(1).indenterType          = 'pyramidal';
indentationSet(1).indentationNormal     = 'L';
indentationSet(1).springConstant        = 66.65;
indentationSet(1).areaFile              = ['demoFiles' filesep 'NI_08_check_0003_arfun.txt'];
indentationSet(1).targetDir             = ['demoFiles' filesep];

if ctrl.verbose
    A =figure('PaperPositionMode','manual','PaperUnits','centimeters','PaperPosition',[20 20 30 20]);
    figure(A)
end

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
    end
    
    % Associate results with array
    indentationSet(aLoop).Er = (ErSave);
    indentationSet(aLoop).H = (HSave);
    indentationSet(aLoop).Cidx = (CidxSave);
    indentationSet(aLoop).thermIdx = (thermIdxSave);
    indentationSet(aLoop).diagnostics = (diagnosticsSave);
    
    clear ErSave HSave CidxSave thermIdxSave diagnosticsSave
end

% Save raw outputs in an array.
indentationSave = indentationSet;

% Clean entries that do not fulfill requirements
topLimitER = 100;                   % [GPa]
botLimitER = 0;                     % [GPa]
topLimitHardness = 1;               % [GPa]
botLimitHardness = 0;               % [GPa]

for cLoop = 1:numel(indentationSet)
    for dLoop = numel(indentationSet(cLoop).Er):-1:1
        conditionA = indentationSet(cLoop).Er(dLoop) > topLimitER;
        conditionB = indentationSet(cLoop).Er(dLoop) < botLimitER;
        conditionC = indentationSet(cLoop).H(dLoop) > topLimitHardness;
        conditionD = indentationSet(cLoop).H(dLoop) < botLimitHardness;

        if conditionA || conditionB || conditionC || conditionD
            indentationSet(cLoop).Er(dLoop) = [];
            indentationSet(cLoop).H(dLoop) = [];
            indentationSet(cLoop).Cidx(dLoop) = [];
            indentationSet(cLoop).thermIdx(dLoop) = [];
            indentationSet(cLoop).inputFiles(dLoop)  = [];
        end
    end   
end




% Explicitly write the output of this demo.
fprintf('%10s %30s %10s %10s\n','','Indentation modulus ER: ',indentationSet.Er,' GPa');
fprintf('%10s %30s %10s %10s\n','','Hardness H: ',indentationSet.H,' GPa');