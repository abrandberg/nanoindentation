function [Er,H,Cidx,thermIdx,diagnostics] = modulusFitter(indentationSet,ctrl,hyperParameters,resultFile)
%function [Er,H,Cidx,thermIdx,diagnostics] = ...
%          modulusFitter(indentationSet,ctrl,hyperParameters,resultFile)
% 
% takes as inputs a set of references to NI-AFM output files and attempts
% to determine the indentation modulus Er. It takes as input 4 formatted
% arguments, described below.
%
% It provides as output 5 formatted outputs, as well as a diagnostic figure
% writen to a local directory if the variable ctrl.verbose is set to 1
%
% INPUTS:
%   indentationSet.PROPERTY     {STRUCT},
%   where PROPERTY =
%   .designatedName         : A user-defined string to identify the set.
%   .relativeHumidity       : [%] Scalar indicating the relative humidity during the measurement.
%   .indenterType           : [string] Currently supports "pyramidal" and "hemispherical".
%   .indentationNormal      : [string] Indicates along which axis the indentation was performed (L,T,...).
%   .springConstant         : [N/m] The indenter spring constant.
%   .areaFile               : [string] File path to the file specifying area as a function of indentation, A(z).
%   .targetDir              : [string] File path to the directory where the experiments are located. Experiments 
%                             are assumed to be reported in the form of *.ibw files.
%
%   ctrl.PROPERTY               {STRUCT},
%   where PROPERTY =
%   .verbose                : Boolean controlling the output of diagnostic plots.
%                             Can be set to 0 (fast, no plots) or 1 (plots)
%
%
%   hyperParameters.PROPERTY    {STRUCT},
%   where PROPERTY =
%   .epsilon                : [-] Tip factor.
%   .sampleRate             : [Hz] Sample rate.
%   .thermred               : [-] Factor reduction in force relative peak load.
%   .thermpnt               : [-] Measurement points before thermal hold.
%   .unloadingFitRange      : [-] Vector samples lengths (measured from start of
%                                 unloading) to be included in unload fit.
%   .unloadingFitFunction   : [string] Function to use when fitting. Currently
%                                      only 'Ganser' is supported.
%
%   
%   resultFile              : [string] The name of the specific file to analyse,
%                                      must be located in the targetDir.
%
%
% OUTPUTS:
%   Er                      : [GPa] Indentation modulus
%   H                       : [GPa] Hardness
%   Cidx                    : [-] C in Equation (22) of [1]
%   thermIdx                : [-] Equation (23) of [1]
%   diagnostics             : {STRUCT} Structure containing detailed diagnostic
%                              data of each process. Should not be used for 
%                              for debugging, but can be useful for filtering
%                              according to quality criterion.
%
%   
%
% ABOUT:
%
% created by: August Brandberg augustbr at kth . se
% date: 2020-06-07
%
%

% Check whether we are in MATLAB or in OCTAVE
execEngine = exist ('OCTAVE_VERSION', 'builtin');
% Save verbose-mode plots     
if ctrl.verbose
    if execEngine == 0
    	plotDir = 'plotsMATLAB';    
    elseif execEngine == 5
        plotDir = 'plotsOCTAVE';
    end
    if not(exist(plotDir ,'dir'))
        mkdir(plotDir)
    end
end
    
xy = dataPreProcessing(horzcat(indentationSet.targetDir,resultFile));
% Import signal from instrument


if ctrl.verbose
    figure
    %subplot(subplotSize(1),subplotSize(2),1)
    plot(xy(:,1),xy(:,2),'DisplayName','Raw signal')
    hold on
    xlabel('Column 1')
    ylabel('Column 2')
end
    
    
[xy,basefit,offsetPolynom,rampStartIdx,x_zero] = offsetAndDriftCompensation(xy, ...
                                                                            hyperParameters.endRangeBaseFit, ...
                                                                            hyperParameters.contactDetectionNoiseFactor);
% Fit a line to the beginning of the data recording to adjust for mean offset and linear drift
% in the signal. 

    if ctrl.verbose
        %plot(xy(:,1),xy(:,2),'DisplayName',['Offset and drift corr., O = ' sprintf('%3.2e',offsetPolynom(2)), ', D = ' num2str(offsetPolynom(1))])
        legend('location','northwest')      
        plot(xy(rampStartIdx,1),xy(rampStartIdx,2),'ko','DisplayName','Start of ramp')
        plot(xy(:,1),xy(:,2),'DisplayName','Calibrated to start of ramp')
        
        print([indentationSet.targetDir filesep resultFile(1:end-4) '_F1.png'],'-dpng', '-r600')
        close;
    end
    
    % Convert displacement-deflection matrix to indentation-force matrix
    xy(:,1) = xy(:,1)-xy(:,2);                                      
    % Subtract deflection from distance to get indentation.
    xy(:,2) = xy(:,2)*indentationSet.springConstant;                
    % [10^-9*m]*[N/m] = nN Multiply deflection with spring constant to get the force.
    xy(:,1) = xy(:,1) - hyperParameters.machineCompliance*xy(:,2); 
    % OBS OBS OBS OBS OBS 
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Determine the start of the hold time at circa max force.
    % 
    % 1. Determine range of deflection values.
    % 2. Bin the values (heuristic bin size at the moment)
    % 3. Determine the most common deflection value at the highest load levels under the assumption that this bin will contain 
    %    the hold sequence.
    % 4. Determine the mean value of all values larger than this bin value.
    % 5. Find the first time the vector exceeds this value.
    % 6. This is taken as the first value in the hold sequence.
    sensorRange = range(xy(:,2));
    vecLengthTemp = round(800*sensorRange/200); 
    
    if execEngine == 0
      [histTemp,edgesOfHist] = histcounts(xy(:,2),vecLengthTemp);
    elseif execEngine == 5
      edges = linspace(min(xy(:,2)) , max(xy(:,2)),vecLengthTemp);
      n = histc(xy(:,2), edges);
      histTemp = n;
      edgesOfHist = edges;
    end
    
    
    tailVecStart = round(0.9*vecLengthTemp);
    [~,peakIdx] = max(histTemp(tailVecStart:end));
    peakIdx = peakIdx + tailVecStart-1;

    meanOfPlateau = mean(xy(xy(:,2)>edgesOfHist(peakIdx),2));
    holdStartIdx = find(xy(:,2)> meanOfPlateau,1,'first');

    if ctrl.verbose
        figure;
        plot(xy(:,1),xy(:,2),'DisplayName','Centered signal')
        hold on
        plot(xy(rampStartIdx,1),xy(rampStartIdx,2),'ok','DisplayName','Start of ramp')
        plot(xy(holdStartIdx,1),xy(holdStartIdx,2),'ob','DisplayName','Start of hold')
        legend('location','northwest')
        xlabel('Indenter position [nm]')
        ylabel('Force [nN]')
        xlim([xy(rampStartIdx,1)-100 max(xy(:,1))+100])       
    end
    
 
    % Split into loading and unloading.
    xy_load = xy(1:holdStartIdx,:);
	xy_unld1 = xy(holdStartIdx:end,:);
    
    if ctrl.verbose
        plot(xy_load(:,1),xy_load(:,2),'DisplayName','Loading')
    end

    % Determine the end of the hold time.
    %
    % 1. Determine range of force values.
    % 2. Bin the values (heuristic bin size at the moment)
    % 3. Determine the most common force value at the highest load levels under the assumption that this bin will contain 
    %    the hold sequence.
    % 4. Determine the mean value of all values larger than this bin value.
    % 5. Find the last time the vector exceeds this value.
    % 6. This is taken as the first value in the unload sequence.
    sensorRange = range(xy_unld1(:,2));
    vecLengthTemp = round(1500*sensorRange/1e4);
    
    if execEngine == 0
      [histTemp,edgesOfHist] = histcounts(xy_unld1(:,2),vecLengthTemp);
    elseif execEngine == 5
      edges = linspace(min(xy_unld1(:,2)) , max(xy_unld1(:,2)),vecLengthTemp);
      n = histc(xy_unld1(:,2), edges);
      histTemp = n;
      edgesOfHist = edges;
    end
         
    tailVecStart = round(0.9*vecLengthTemp);
    [~,peakIdx] = max(histTemp(tailVecStart:end));

    peakIdx = peakIdx + tailVecStart - 1;
    meanOfPlateau = mean(xy_unld1(xy_unld1(:,2)>edgesOfHist(peakIdx),2));
    unloadStartIdx = find(xy_unld1(:,2) > meanOfPlateau,1,'last');


    % Split into two new pieces
    xy_hold = xy_unld1(1:unloadStartIdx-1,:);
    xy_unld = xy_unld1(unloadStartIdx:end,:);
    
    if ctrl.verbose
        plot(xy_hold(:,1),xy_hold(:,2),'DisplayName','Hold')
        plot(xy_unld(1,1),xy_unld(1,2),'o','DisplayName','Start of unload')
        plot(xy_unld(:,1),xy_unld(:,2),'DisplayName','Unload')               
        print([indentationSet.targetDir filesep resultFile(1:end-4) '_F2.png'],'-dpng', '-r600')
        close;
        
        figure;
        plot(xy(holdStartIdx,1),xy(holdStartIdx,2),'o','DisplayName','Start of hold')
        hold on
        plot(xy_hold(:,1),xy_hold(:,2),'-k','DisplayName','Hold')
        plot(xy_unld1(unloadStartIdx,1),xy_unld1(unloadStartIdx,2),'o','DisplayName','End of hold')
        legend('location','southeast')
        xlabel('Indenter position [nm]')
        ylabel('Force [nN]')
        
        print([indentationSet.targetDir filesep resultFile(1:end-4) '_F3_driftDuringHold.png'],'-dpng', '-r600')
        close;
    end    
    

    

    % Accept only indentations that had positive creep. "Negative" creep (indenter moves outwards 
    % during hold sequence) can occur if the thermal drift is substantial, but this typically
    % indicates that the system was not in equilibrium (since the thermal drift dominates the creep)
    % and furthermore it messes up the mathematical framework if you accept such indentations (see
    % Cheng & Cheng articles.)
    condition1 = xy(holdStartIdx,1) < xy_unld1(unloadStartIdx,1); 

    % Accept only monotonously increasing load-displacement curves. A curve may show weird behaviour
    % and our solution is to simply drop the curve in that case. 
    condition2 = min(xy(rampStartIdx:holdStartIdx,1)) > -10;

    if condition1 && condition2
        
    % Make sure that the thermal hold sequence is not included in the unloading curve.
    xy_unld5 = xy_unld(1:round(hyperParameters.thermpnt*0.95),:); 

        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Estimate thermal drift over experiment.
    % 
    % 1. Find the thermal hold station
    % 2. Isolate the first step
    %
    % 3. Generate
    %       h(t) across the hold
    sensorRange = range(xy(:,2));
    vecLengthTemp = round(500*sensorRange/1e4);
    
    if execEngine == 0
      [histTemp,edgesOfHist] = histcounts(xy(:,2),vecLengthTemp);
    elseif execEngine == 5
      edges = linspace(min(xy(:,2)) , max(xy(:,2)),vecLengthTemp);
      n = histc(xy(:,2), edges);
      histTemp = n;
      edgesOfHist = edges;
    end
          
    [~,peakIdx] = max(histTemp(1:end));
    meanOfPlateau = mean(xy(xy(:,2)>edgesOfHist(peakIdx-1) & xy(:,2)<edgesOfHist(peakIdx+1),2));
    stdOfPlateau = std(xy(xy(:,2)>edgesOfHist(peakIdx-1) & xy(:,2)<edgesOfHist(peakIdx+1),2));
    
    noiseMultiplier = 5; % 15%
    thermalHoldStartIdx = find(xy(:,2) > meanOfPlateau+noiseMultiplier*stdOfPlateau,1,'last');
    thermalHoldEndIdx = find(xy(:,2) > meanOfPlateau-noiseMultiplier*stdOfPlateau,1,'last');
    
    thermalHoldStartIdx = thermalHoldStartIdx + hyperParameters.sampleRate; % throw away 2 seconds, 1 on each side
    thermalHoldEndIdx = thermalHoldEndIdx - hyperParameters.sampleRate;
    
    % Ensure that the thermal hold sequence contains at least 25 seconds (out of the 30 secounds
    % specified).
    if thermalHoldStartIdx > thermalHoldEndIdx
        disp('Missed thermal hold. Increasing search range.')
        
        if isfield(indentationSet,'thermalHoldTime')
            if numel(indentationSet.thermalHoldTime) > 0
                thermalHoldLength = round(indentationSet.thermalHoldTime * 0.8);
            else
                thermalHoldLength = 50000;
            end
        else
            thermalHoldLength = 50000;
        end
        
        while thermalHoldLength+thermalHoldStartIdx > thermalHoldEndIdx
            noiseMultiplier = noiseMultiplier + 1; %+2
            thermalHoldStartIdx = find(xy(:,2) > meanOfPlateau+noiseMultiplier*stdOfPlateau,1,'last');
            thermalHoldEndIdx = find(xy(:,2) > meanOfPlateau-noiseMultiplier*stdOfPlateau,1,'last');
            
            thermalHoldStartIdx = thermalHoldStartIdx + hyperParameters.sampleRate; % throw away 2 seconds, 1 on each side
            thermalHoldEndIdx = thermalHoldEndIdx - hyperParameters.sampleRate;
        end
        disp(['Thermal hold found using multiplier ' num2str(noiseMultiplier)])
    end 

    % Fit a function of displacement (due to thermal fluctuation)
    % h_thermal(time) = A1 + A2*time^A3 
    thermalHoldDisplacement = xy(thermalHoldStartIdx:thermalHoldEndIdx,1);
    thermalHoldTime = [1:length(thermalHoldDisplacement)]'./hyperParameters.sampleRate;
   
    thermalCreepFun = @(x)  x(1) * (thermalHoldTime ).^(x(2));
    thermalHoldminFcn = @(x) sum(sqrt((   (thermalCreepFun(x) - thermalHoldDisplacement)./thermalHoldDisplacement    ).^2));
    opts = optimset('Display','off');
    thermal_p = fminunc(thermalHoldminFcn,[1.5 1/3],opts);
    
    % Estimate the thermal drift rate by taking the median of the differentiated h_thermal
    % dhtdt = d(h_thermal(time))/d(time)
    % The functional form accounts for any viscous effects lingering from the unloading at the start
    % of the thermal hold, while the median provides a roboust average of the thermal drift rate.
    dhtdt = median(thermal_p(1) * thermal_p(2)*thermalHoldTime.^(thermal_p(2) - 1));

    if ctrl.verbose
        figure
        plot(xy(thermalHoldStartIdx:thermalHoldEndIdx,1),xy(thermalHoldStartIdx:thermalHoldEndIdx,2),'DisplayName','Thermal hold')
        hold on
        plot(xy(thermalHoldStartIdx,1),xy(thermalHoldStartIdx,2),'s','DisplayName','Start of thermal hold')
        plot(xy(thermalHoldEndIdx,1),xy(thermalHoldEndIdx,2),'s','DisplayName','End of thermal hold')
        xlabel('Indenter position [nm]')
        ylabel('Force [nN]')
        title(['dhtdt = ' num2str(round(dhtdt,2)) ' nm/s'])
        legend('location','northwest')
        
        print([indentationSet.targetDir filesep resultFile(1:end-4) '_F4_driftDuringThermalHold.png'],'-dpng', '-r600')
        close;
        
%         figure
%         plot(thermalHoldTime,xy(thermalHoldStartIdx:thermalHoldEndIdx,1),'DisplayName','Thermal hold')
%         hold on
%         plot(thermalHoldTime,thermalCreepFun(thermalHoldTime) ,'s','DisplayName',sprintf('Fit, y(t) = %3.2f * t^{%3.2f}',thermal_p(1) , thermal_p(2)))
%         xlabel('Time [s]')
%         ylabel('Indenter position [nm]')
%         title(['dhtdt = ' num2str(round(dhtdt,2)) ' nm/s'])
%         legend('location','northwest')
%         print([indentationSet.targetDir filesep resultFile(1:end-4) '_F4b_driftDuringThermalHold.png'],'-dpng', '-r600')
%         close;
    end
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Fitting of the unloading curve.
    Fmax = median(xy_unld5(1,2));               % Maximum force during unloading
    Dmax = median(xy_unld5(1,1));               % Maximum indentation depth during unloading
    Fend = median(xy_unld5(1000,2));            % Force at half the unloading. Can be used to stabilize 
                                                % the fitting if the curve points the "wrong way".

    if hyperParameters.constrainHead && hyperParameters.constrainTail
        constrainedPoints = [Fmax Fend];
    elseif hyperParameters.constrainHead
        constrainedPoints = Fmax;
    elseif hyperParameters.constrainTail
        constrainedPoints = Fend;
    else
        constrainedPoints = nan;
    end
    
    % Pre-allocate
    opts = optimset('Algorithm','interior-point','Display','off');
    stiffness_fitS = nan(size(hyperParameters.unloadingFitRange));
    
    for xLoop = numel(hyperParameters.unloadingFitRange):-1:1
        hyperParameters.uld_fit_nr = hyperParameters.unloadingFitRange(xLoop);
        
        if strcmp(hyperParameters.unloadingFitFunction,'Ganser')
            % Previously used polynom fit
            %
            % Defines a function for the displacement as a function of force during the
            % unloading,
            %
            % h(F) = x(1) + x(2)*F^0.5 + x(3)*F^0.25 + x(4)*F^0.125
            %
            % Define a loss function as the fitted polynom minus the recorded displacement
            % values.
            unloadFitFun = @(dispVals,forceVals,fitCoefs) [ones(size(forceVals,1),1) forceVals.^0.5 forceVals.^0.25 forceVals.^0.125]*fitCoefs - dispVals ;
            
            % Sums the normalized losses 
            unloadFitMinFun = @(x) sqrt( ...
                                        1/length(xy_unld5(1:hyperParameters.uld_fit_nr,1))* ... 
                                            sum(  ...
                                                ( ...
                                                    unloadFitFun(xy_unld5(1:hyperParameters.uld_fit_nr,1),xy_unld5(1:hyperParameters.uld_fit_nr,2),x) ...
                                                    ./xy_unld5(1:hyperParameters.uld_fit_nr,1) ... 
                                                    ).^2 ...
                                                 ) ...
                                        );
            
                                
            unloadFitConstraintFun =  @(x) deal(-((1/2)*x(2)*[Fmax Fend].^(-1/2) + (1/4)*x(3).*[Fmax Fend].^(-3/4) + (1/8)*x(4).*[Fmax Fend].^(-7/8)), ...
                                                0);                  
            
            [uld_p,fval,exitflag,output] =  fmincon(unloadFitMinFun,        ... % Minimization function
                                                    [1, 1, 1, 1]',          ... % Starting guess
                                                    [],[],[],[],[],[],      ... % Linear equality and inequality constraints
                                                    [], ... % Non-linear inequality an equality constraints % OBS OBS OBS OBS OBS OBS 
                                                    opts);                  ... % Solver options

            
            stiffness_fitS(xLoop) = ([0.5*Fmax^-0.5 0.25*Fmax^-0.75 0.125*Fmax^-0.875]*uld_p(2:4))^-1;   
            
        elseif strcmp(hyperParameters.unloadingFitFunction,'Feng')
            
            % Equation (17b) in [1] used for the fit. Gives similar results.
            unloadFitFun = @(dispVals,forceVals,fitCoefs) (fitCoefs(1)+fitCoefs(2).*forceVals.^0.5 + fitCoefs(3).*forceVals.^fitCoefs(4)) - dispVals ;
            
            unloadFitMinFun = @(x) sqrt(  ...
                                        1/length(xy_unld5(1:hyperParameters.uld_fit_nr,1))* ... 
                                        sum( ...
                                                ( ...
                                                    unloadFitFun(xy_unld5(1:hyperParameters.uld_fit_nr,1),xy_unld5(1:hyperParameters.uld_fit_nr,2),x) ...
                                                    ./xy_unld5(1:hyperParameters.uld_fit_nr,1) ... 
                                                    ).^2 ...
                                                 ) ...
                                    );
            
            
            
            if execEngine == 0
                if sum(~isnan(constrainedPoints)) > 0
                    unloadFitConstraintFun =  {@(x) deal(-( 0.5*x(2).*constrainedPoints.^-0.5 + x(4)*x(3).*constrainedPoints.^(x(4) - 1) ) , ...
                                                    0)};
                else
                    unloadFitConstraintFun =  {[]};
                end
                                                
                [uld_p,fval,exitflag,output] =  fmincon(unloadFitMinFun,        ... % Minimization function
                                        [1, 1, 1, 1]',                          ... % Starting guess
                                        [],[],[],[],[],[],                      ... % Linear equality and inequality constraints
                                        unloadFitConstraintFun{1},                 ... % Non-linear inequality an equality constraints OBS OBS OBS OBS OBS OBS
                                        opts);                                  ... % Solver options
            elseif execEngine == 5
                if sum(~isnan(constrainedPoints)) > 0
                    unloadFitConstraintFun = {@(x) -( 0.5*x(2).*Fmax.^-0.5 + x(4)*x(3).*Fmax.^(x(4) - 1) )};
                else
                    unloadFitConstraintFun =  {[]};
                end
                
                [uld_p,fval,exitflag,output] = optiForOctave(unloadFitMinFun,unloadFitConstraintFun,Fmax);

            end
            
            % Collect apparent stiffness
            stiffness_fitS(xLoop) = inv(( 0.5*uld_p(2).*Fmax.^-0.5 + uld_p(4)*uld_p(3).*Fmax.^(uld_p(4) - 1) ));
            

        elseif strcmp(hyperParameters.unloadingFitFunction,'Oliver-Pharr')
            unloadFitFun = @(dispVals,forceVals,fitCoefs) fitCoefs(1)*(dispVals - fitCoefs(2)).^fitCoefs(3) - forceVals;
            unloadFitMinFun = @(x) sqrt(  ...
                                        1/length(xy_unld5(1:hyperParameters.uld_fit_nr,1))* ... 
                                        sum( ...
                                                ( ...
                                                    unloadFitFun(xy_unld5(1:hyperParameters.uld_fit_nr,1),xy_unld5(1:hyperParameters.uld_fit_nr,2),x) ...
                                                    ./xy_unld5(1:hyperParameters.uld_fit_nr,2) ... 
                                                    ).^2 ...
                                                 ) ...
                                    );             

            unloadFitConstraintFun =  @(x) deal(-( x(1)*x(3)*(Dmax - x(2)).^(x(3) - 1)) , ...
                                                0);

            [uld_p,fval,exitflag,output] =  fmincon(unloadFitMinFun,        ... % Minimization function
                                                [1, 1, 1]',             ... % Starting guess
                                                [],[],[],[],[],[],      ... % Linear equality and inequality constraints
                                                [],                     ... % Non-linear inequality an equality constraints OBS OBS OBS OBS OBS OBS
                                                opts);                  ... % Solver options

            stiffness_fitS(xLoop) = max(0,uld_p(1)*uld_p(3)*(Dmax - uld_p(2)).^(uld_p(3) - 1));
        else
            disp(['hyperParameters.unloadingFitFunction = ' hyperParameters.unloadingFitFunction ' is not implemented!'])
            disp(stop)
        end
        
        if ctrl.verbose
            xTemp = xy_unld5(1:hyperParameters.uld_fit_nr,1);
            yTemp = xy_unld5(1:hyperParameters.uld_fit_nr,2);
            
            figure;
            plot(xy_unld5(:,1),xy_unld5(:,2),'DisplayName','Signal')
            hold on
            plot(xTemp,yTemp,'DisplayName','Signal used in fit')
            
            if strcmp(hyperParameters.unloadingFitFunction,'Ganser')
                plot([ones(size(yTemp,1),1) ...
                      yTemp.^0.5            ...
                      yTemp.^0.25           ...
                      yTemp.^0.125]*uld_p,yTemp, ...
                      'k-', 'DisplayName', 'Fit (Ganser)') 
                  
            elseif strcmp(hyperParameters.unloadingFitFunction,'Feng')
                plot((uld_p(1)+uld_p(2).*xy_unld5(1:hyperParameters.uld_fit_nr,2).^0.5 + uld_p(3).*xy_unld5(1:hyperParameters.uld_fit_nr,2).^uld_p(4)), ...
                      xy_unld5(1:hyperParameters.uld_fit_nr,2),'k-', 'DisplayName', 'Fit (Feng)') 
            elseif strcmp(hyperParameters.unloadingFitFunction,'Oliver-Pharr')       
                plot(xTemp,uld_p(1)*(xTemp - uld_p(2)).^uld_p(3),'k-', 'DisplayName', 'Fit (Oliver & Pharr)')
            else
                disp('Not implemented!')
                disp(stop)
            end
            xlabel('Indenter position [nm]')
            ylabel('Force [nN]')
            legend('location','northwest')
            print([indentationSet.targetDir filesep resultFile(1:end-4) '_F5_unloadingWithFit.png'],'-dpng', '-r600')
            close;

%             subplot(subplotSize(1),subplotSize(2),6)
%             plot(hyperParameters.unloadingFitRange(xLoop),stiffness_fitS(xLoop),'ob','HandleVisibility','off')
%             hold on
%             xlabel('Number of points in fit')
%             ylabel('Apparent stiffness S_u [N/m]')
        end
        
        % Collect diagnostic data
        diagnostics.fval(xLoop) = fval;
        diagnostics.exitFlags(xLoop) = exitflag;
        diagnostics.output(xLoop) = output;
        
        diagnostics.rmsValue(xLoop) = unloadFitMinFun(uld_p);
        diagnostics.uld_p(xLoop,:) = uld_p;
        
    end
    diagnostics.stiffnessFitS = stiffness_fitS;
    stiffness_fitS(isnan(stiffness_fitS)) = [];
    diagnostics.geometricMeanOfSu = 0;
    diagnostics.medianOfSu = median(stiffness_fitS);
    stiffness_fit = median(stiffness_fitS);
    
       
    
    if ctrl.verbose
       figure;
       plot([hyperParameters.unloadingFitRange],100*[diagnostics.rmsValue],'o-')
       xlabel('Number of points in fit')
       ylabel('Root Mean Square Percentage Error [%]')       
       print([indentationSet.targetDir filesep resultFile(1:end-4) '_F7_RMSofFit.png'],'-dpng', '-r600')
       close;
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % Fit the creep during the hold time at maximum load to a linear spring-dashpot model
    %
    % Equation (17c) - not labeled in [1]
    % 
    % h(t) = h_i + \beta * t.^(1/3)
    %
    %   h(t)    - Displacement as a function of time during hold sequence.
    %   h_i     - Fitting constant
    %   \beta   - Fitting constant
    %   t       - Time

    % Generate time signal
    holdTimeVals = [1:size(xy_hold,1)]'/hyperParameters.sampleRate;

    % Depreciated fitting with three fitting parameters
%     hOftFun = @(x) x(1) + x(2) * holdTimeVals.^(x(3));
%     minFcn = @(x) sqrt(sum((   (hOftFun(x) - xy_hold(:,1))./xy_hold(:,1)    ).^2));
%     crp_p = fminunc(minFcn,[40 1.5 1/3],opts);
%     h_dot_tot = crp_p(2)*crp_p(3)*holdTimeVals(end)^(crp_p(3) - 1);
    
    hOftFun = @(x) xy_hold(1,1) + x(1) * holdTimeVals.^(x(2));
    minFcn = @(x) sqrt(sum((   (hOftFun(x) - xy_hold(:,1))./xy_hold(:,1)    ).^2));
    crp_p = fminunc(minFcn,[1.5 1/3],opts);

    h_dot_tot = crp_p(1)*crp_p(2)*holdTimeVals(end)^(crp_p(2) - 1);

    dPdt = [hyperParameters.sampleRate^-1*[0:(length(xy_unld5(:,1))-1)]' ones(length(xy_unld5(:,1)),1)]\xy_unld5(:,2);  
    
    
    if (h_dot_tot-dhtdt) < 0 && hyperParameters.allowNegativeCreep ~= 1
        h_dot_tot = dhtdt;
    end
    
    % Equation (3) in [1]
    if hyperParameters.compensateCreep
        stiffness = inv(1/stiffness_fit + h_dot_tot/(abs(dPdt(1)))); 
    else
        stiffness = stiffness_fit;
    end
    
    if ctrl.verbose
        figure;
        bar(categorical({'Apparent stiffness','Creep contribution','Stiffness'}), ...
                        [stiffness_fit (h_dot_tot/(abs(dPdt(1))))^-1 stiffness])
        ylabel('Equivalent stiffness [N/m]')
        print([indentationSet.targetDir filesep resultFile(1:end-4) '_F8_RelativeImportanceOfCreep.png'],'-dpng', '-r600')
        close;
        
        figure
        plot(holdTimeVals,xy_hold(:,1), 'DisplayName','Signal')
        hold on
%         plot(holdTimeVals,hOftFun(crp_p),'DisplayName',sprintf('Fit, y(t) = %3.1f + %3.1f * t^{%3.1f}',crp_p(1) , crp_p(2) , crp_p(3) ))
        plot(holdTimeVals,hOftFun(crp_p),'DisplayName',sprintf('Fit, y(t) = %3.1f + %3.2f * t^{%3.2f}',xy_hold(1,1) , crp_p(1) , crp_p(2) ))
        xlabel('Time [s]')
        ylabel('Indenter displacement [nm]')
        legend('location','southeast')
        title(['End creep rate = ' num2str(round(h_dot_tot,2)) ' nm/s'])
        print([indentationSet.targetDir filesep resultFile(1:end-4) '_F9_creepDuringHold.png'],'-dpng', '-r600')
        close;
    end
    
    % Equation (22) in [1]
    Cidx = (h_dot_tot-dhtdt)*stiffness_fit/abs(dPdt(1));  
   
    
    % Equation (2) in [1]
    maxIndentation = xy_unld5(1,1) - dhtdt*(size(xy(rampStartIdx:holdStartIdx,1),1)+size(xy_hold,1))/hyperParameters.sampleRate;
    
    if contains(resultFile,'pyr')
        x0 = maxIndentation - 0.72*Fmax/stiffness;
    else
        x0 = maxIndentation - 0.75*Fmax/stiffness;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Calculate second key index (sensitivity to miss-specification of thermal drift)
    % Equation (23) in [1]
    %
    % th \approx S/abs(dPdt) *hc
    %
    %   th      - [s] Hold time
    %   S       - [N/m] Stiffness calculated according to Equation (3)
    %   dPdt    - [nm/s] Derivative of force with respect to time
    %   h_c     - [nm] Contact depth
    th = length(xy(rampStartIdx:unloadStartIdx,1))/hyperParameters.sampleRate;
    thermIdx = 1 - th*abs(dPdt(1)) /(x0*stiffness);
    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Determine the area by loading the calibration data and fitting a polynom to the data.
    area_xy = load(indentationSet.areaFile);
    

    if (x0 >= 100)
        area_fit_end = size(area_xy,1);
    elseif (x0 < 100)
        area_fit_end = find(area_xy(:,1) > 100,1,'first');
    end
    
    p_area = [area_xy(1:area_fit_end,1).^2 area_xy(1:area_fit_end,1).^1 area_xy(1:area_fit_end,1).^0.5 area_xy(1:area_fit_end,1).^0.25 area_xy(1:area_fit_end,1).^0.125] \ area_xy(1:area_fit_end,2);
    UnloadArea = [x0^2 x0 x0^0.5 x0^0.25 x0^0.125]*p_area;
    
    
    

    if UnloadArea < max(area_xy(:,2)) || x0 > 15 || x0 < 300  % 25
        % Equation (1) in [1]
        Er = sqrt(pi)/(2)/sqrt(UnloadArea) / (1/stiffness );%- hyperParameters.machineCompliance
        
        if contains(resultFile,'pyr')
            Er = Er/1.05;
        end
        
        H = Fmax/UnloadArea;

        % Collect diagnostic output
        diagnostics.constantOffset = offsetPolynom(2);
        diagnostics.linearDrift = offsetPolynom(1);
        diagnostics.basefit = basefit;
        diagnostics.unloadArea = UnloadArea;
        diagnostics.maxIndentation = maxIndentation;
        diagnostics.x0 = x0;
        diagnostics.dPdt = dPdt;
        diagnostics.h_dot_tot = h_dot_tot;
        diagnostics.hf = xy_unld5(end,1);
        diagnostics.area_xy = area_xy;
        diagnostics.hc = (h_dot_tot-dhtdt);
        diagnostics.xy = xy;
        diagnostics.comment = '';

    else
        % Criterion is that if indentation is too shallow or too deep it is better to drop the indentation.
        Er = nan;
        H = nan;
        Cidx = nan;
        thermIdx = nan;
        
        
        diagnostics.constantOffset = offsetPolynom(2);
        diagnostics.linearDrift = offsetPolynom(1);
        diagnostics.basefit = basefit;
        diagnostics.fval = [];
        diagnostics.exitFlags= [];
        diagnostics.output = [];
        diagnostics.geometricMeanOfSu = [];
        diagnostics.medianOfSu = [];
        diagnostics.stiffnessFitS = [];
        diagnostics.rmsValue = [];
        diagnostics.unloadArea = [];
        diagnostics.maxIndentation =  [];
        diagnostics.x0 = [];
        diagnostics.dPdt = [];
        diagnostics.h_dot_tot = [];
        diagnostics.hf = [];
        diagnostics.area_xy = [];
        diagnostics.hc = [];
        diagnostics.uld_p(xLoop,:) = [];
        diagnostics.xy = [];
        diagnostics.comment = 'Missed start.';
    
    end
    
    % For some of the functions, the Er may end up imaginary if something goes wrong. 
    if imag(Er) ~= 0
        disp('Fit unsuccessful. This sample will be dropped.')
        diagnostics.comment = 'Fit unsuccessful.';
        Er = nan;
        H = nan;
        Cidx = nan;
        thermIdx = nan;
    end
    
    else
        % If the code did not pass condition1 and condition2 above, we drop the indentation.
        Er = nan;
        H = nan;
        Cidx = nan;
        thermIdx = nan;
        
        
        diagnostics.constantOffset = offsetPolynom(2);
        diagnostics.linearDrift = offsetPolynom(1);
        diagnostics.basefit = basefit;
        diagnostics.fval = [];
        diagnostics.exitFlags= [];
        diagnostics.output = [];
        diagnostics.geometricMeanOfSu = [];
        diagnostics.medianOfSu = [];
        diagnostics.stiffnessFitS = [];
        diagnostics.rmsValue = [];
        diagnostics.unloadArea = [];
        diagnostics.maxIndentation =  [];
        diagnostics.x0 = [];
        diagnostics.dPdt = [];
        diagnostics.h_dot_tot = [];
        diagnostics.hf = [];
        diagnostics.area_xy = [];
        diagnostics.hc = [];
        diagnostics.uld_p = [];
        diagnostics.xy = [];
        diagnostics.comment = 'Thermal drift > creep.';
    end

    

end % End of function

