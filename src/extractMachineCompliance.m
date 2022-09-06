function [complianceSave,areaOut] = extractMachineCompliance(compliance,ctrl,hyperParameters)


% The idea here is that we have several indentations at different depths
% done on a material which is well known and where there are no hidden problems.
%
% Now we form the following function, from O&P:
%
% C_tot = C_f + \sqrt(\pi)/(2*Er) * 1/(sqrt(A))
%
%   Here, C_tot needs to be calculated, and the square root of the area needs to be
%   extracted
%

resultNames = subdirImport(compliance.targetDir,'regex','.ibw');     % Find the .ibw files in targetDir
compliance.inputFiles = resultNames;
    
fprintf('%10s %30s %20d\n','','Result files in this set:',numel(resultNames));

for bLoop = 1:numel(resultNames)        % For each result file in targetDir

    [complianceSave(bLoop),areaSave(bLoop)] = extractCalibrationData(compliance,ctrl,hyperParameters,resultNames{bLoop});
    hold off

    fprintf('%20s %20s %20.4f %4s\n','','C_tot = ',complianceSave(bLoop),' m/N');      
    fprintf('%20s %20s %20.4f %4s\n','','A_unload = ',areaSave(bLoop),'[nm]^2');      
end
areaOut = 1./sqrt(areaSave);


















