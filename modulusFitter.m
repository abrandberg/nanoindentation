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
%                                      Must be located in the targetDir.
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
%   diagnostics.PROPERTY    {STRUCT},
%   where PROPERTY =
%   .
%   
%
% ABOUT:
%
% created by: August Brandberg augustbr at kth . se
% date: 2020-06-07
%
%
    % Preprocessing
    xy = dataPreProcessing(horzcat(indentationSet.targetDir,resultFile));
    
    
    if ctrl.verbose
        subplot(3,2,1)
        plot(xy(:,1),xy(:,2),'DisplayName','Raw signal')
        hold on
        xlabel('Column 1')
        ylabel('Column 2')
    end
    
    % Fit a line to the beginning of the data recording to adjust for mean offset and linear drift
    % in the signal. 
%     [xy,basefit,offsetPolynom] = offsetAndDriftCompensation(xy);
    [xy,basefit,offsetPolynom,rampStartIdx,x_zero] = offsetAndDriftCompensation(xy);
    if ctrl.verbose
        subplot(3,2,1)
        plot(xy(:,1),xy(:,2),'DisplayName',['Offset and drift corr., O = ' num2str(offsetPolynom(2)), ', D = ' num2str(offsetPolynom(1))])
        legend('location','best')
        
    end
    
    

    if ctrl.verbose
        subplot(3,2,1)
        plot(xy(rampStartIdx,1),xy(rampStartIdx,2),'ko','DisplayName','Start of ramp')
        plot(xy(:,1),xy(:,2),'DisplayName','Calibrated to start of ramp')
    end
    
    % Convert displacement-deflection matrix to displacement-force matrix
    xy(:,1) = xy(:,1)-xy(:,2);                                      % Subtract deflection from distance to get indentation.
    xy(:,2) = xy(:,2)*indentationSet.springConstant;                % [10^-9*m]*[N/m] = nN Multiply deflection with spring constant to get the force.
    
    
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
    vecLengthTemp = round(500*sensorRange/200);
    [histTemp,edgesOfHist] = histcounts(xy(:,2),vecLengthTemp);
    
    tailVecStart = round(0.9*vecLengthTemp);
    [~,peakIdx] = max(histTemp(tailVecStart:end));
    peakIdx = peakIdx + tailVecStart-1;

    meanOfPlateau = mean(xy(xy(:,2)>edgesOfHist(peakIdx),2));
    holdStartIdx = find(xy(:,2)> meanOfPlateau,1,'first');

    if ctrl.verbose
        subplot(3,2,2)
        plot(xy(:,1),xy(:,2),'DisplayName','Centered signal')
        hold on
        plot(xy(rampStartIdx,1),xy(rampStartIdx,2),'ok','DisplayName','Start of ramp')
        plot(xy(holdStartIdx,1),xy(holdStartIdx,2),'ob','DisplayName','Start of hold')
        legend('location','best')
        xlabel('Indentor position [nm]')
        ylabel('Force [nN]')
    end
    
 
    % Split into loading and unloading.
    xy_load = xy(1:holdStartIdx,:);
	xy_unld1 = xy(holdStartIdx:end,:);
    
    if ctrl.verbose
        subplot(3,2,2)
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
    vecLengthTemp = round(500*sensorRange/1e4);
    [histTemp,edgesOfHist] = histcounts(xy_unld1(:,2),vecLengthTemp);
    
    
% sensorRange = range(xy_unld1(:,2));
% vecLengthTemp = round(500*sensorRange/1e4);
% 
% edges = linspace(min(xy_unld1(:,2)) , max(xy_unld1(:,2)),vecLengthTemp);
% 
% n = histc (xy_unld1(:,2), edges);
% 
% histTemp = n;
% edgesOfHist = edges;

    
    
    
    
    
    
    tailVecStart = round(0.9*vecLengthTemp);
    [~,peakIdx] = max(histTemp(tailVecStart:end));

    peakIdx = peakIdx + tailVecStart - 1;
    meanOfPlateau = mean(xy_unld1(xy_unld1(:,2)>edgesOfHist(peakIdx),2));
    unloadStartIdx = find(xy_unld1(:,2) > meanOfPlateau,1,'last');


    % Split into two new pieces
    xy_hold = xy_unld1(1:unloadStartIdx-1,:);             % Classified as pre m
    xy_unld = xy_unld1(unloadStartIdx:end,:);              % Classified as post m
    
    if ctrl.verbose
        subplot(3,2,2)
        plot(xy_hold(:,1),xy_hold(:,2),'DisplayName','Hold')
        plot(xy_unld(1,1),xy_unld(1,2),'o','DisplayName','Start of unload')
        plot(xy_unld(:,1),xy_unld(:,2),'DisplayName','Unload')
        
        
        subplot(3,2,5)
        plot(xy(holdStartIdx,1),xy(holdStartIdx,2),'o','DisplayName','Start of hold')
        hold on
        plot(xy_hold(:,1),xy_hold(:,2),'DisplayName','Hold')
        plot(xy_unld1(unloadStartIdx,1),xy_unld1(unloadStartIdx,2),'o','DisplayName','End of hold')
        legend('location','best')
        xlabel('Indenter position [nm]')
        ylabel('Force [nN]')
    end    
    
    if xy(holdStartIdx,1) < xy_unld1(unloadStartIdx,1)
    
    xy_unld5 = xy_unld(1:hyperParameters.thermpnt,:);    % Change this
    
    Fmax = median(xy_unld5(1,2));


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Estimate thermal drift over experiment.
    % 
    % Pretty weird that we do both this and the linear drift compensation
    %
    % 1. Find the thermal hold station
    % 2. Isolate the first step
    %
    % 3. Generate
    %       h(t) across the hold
    thermalHoldStartIdx = find(xy(:,2) > 1.6*(1-hyperParameters.thermred)*Fmax ,1,'last') ; % used to be 1.3
    thermalHoldEndIdx = find(xy(:,2) > (1-hyperParameters.thermred)*Fmax ,1,'last');
    
    
    thermalHoldStartIdx = thermalHoldStartIdx + hyperParameters.sampleRate; % throw away 2 seconds, 1 on each side
    thermalHoldEndIdx = thermalHoldEndIdx - hyperParameters.sampleRate;
    
    thermalHoldDisplacement = xy(thermalHoldStartIdx:thermalHoldEndIdx,1);
    thermalHoldTime = [1:length(thermalHoldDisplacement)]'./hyperParameters.sampleRate;
    
    thermalCreepFun = @(x) x(1) + x(2) * (thermalHoldTime ).^(x(3));
    thermalHoldminFcn = @(x) sum(sqrt((   (thermalCreepFun(x) - thermalHoldDisplacement)./thermalHoldDisplacement    ).^2));
    
    
    opts = optimset('Display','off');
    thermal_p = fminunc(thermalHoldminFcn,[40 1.5 1/3],opts);
    
    dhtdt = median(thermal_p(2) * thermal_p(3)*thermalHoldTime.^(thermal_p(3) - 1));
    if ctrl.verbose
        subplot(3,2,2)
        plot(xy(thermalHoldStartIdx:thermalHoldEndIdx,1),xy(thermalHoldStartIdx:thermalHoldEndIdx,2),'DisplayName','Thermal hold')
        plot(xy(thermalHoldStartIdx,1),xy(thermalHoldStartIdx,2),'s','DisplayName','Start of thermal hold')
        plot(xy(thermalHoldEndIdx,1),xy(thermalHoldEndIdx,2),'s','DisplayName','End of thermal hold')
        
        subplot(3,2,6)
        plot(xy(thermalHoldStartIdx:thermalHoldEndIdx,1),xy(thermalHoldStartIdx:thermalHoldEndIdx,2),'DisplayName','Thermal hold')
        hold on
        plot(xy(thermalHoldStartIdx,1),xy(thermalHoldStartIdx,2),'s','DisplayName','Start of thermal hold')
        plot(xy(thermalHoldEndIdx,1),xy(thermalHoldEndIdx,2),'s','DisplayName','End of thermal hold')
        xlabel('Indenter position [nm]')
        ylabel('Force [nN]')
        legend('location','best')
    end
    
    
    
    xy(:,1) = xy(:,1) - dhtdt*[1:length(xy(:,1))]'./hyperParameters.sampleRate;
    
      
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Here comes the fitting
    Fmax = median(xy_unld5(1,2));
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
            % h(P) = x(1) + x(2)^0.5 + x(3)^0.25 + x(4)^0.125
            %
            % Define a loss function as the fitted polynom minus the recorded displacement
            % values.
            unloadFitFun = @(dispVals,forceVals,fitCoefs) [ones(size(forceVals,1),1) forceVals.^0.5 forceVals.^0.25 forceVals.^0.125]*fitCoefs - dispVals ;
            
            % Sums the normalized losses 
            unloadFitMinFun = @(x) 1/length(xy_unld5(1:hyperParameters.uld_fit_nr,1))* ... 
                                    sum(  ...
                                        sqrt( ...
                                                ( ...
                                                    unloadFitFun(xy_unld5(1:hyperParameters.uld_fit_nr,1),xy_unld5(1:hyperParameters.uld_fit_nr,2),x) ...
                                                    ./xy_unld5(1:hyperParameters.uld_fit_nr,1) ... 
                                                    ).^2 ...
                                                 ) ...
                                    );
            
                                
            unloadFitConstraintFun =  @(x) deal(-((1/2)*x(2)*Fmax^(-1/2) + (1/4)*x(3)*Fmax^(-3/4) + (1/8)*x(4)*Fmax^(-7/8)), ...
                                                0);                  
            
            [uld_p,fval,exitflag,output] =  fmincon(unloadFitMinFun,        ... % Minimization function
                                                    [1, 1, 1, 1]',          ... % Starting guess
                                                    [],[],[],[],[],[],      ... % Linear equality and inequality constraints
                                                    unloadFitConstraintFun, ... % Non-linear inequality an equality constraints
                                                    opts);                  ... % Solver options

            
            stiffness_fitS(xLoop) = ([0.5*Fmax^-0.5 0.25*Fmax^-0.75 0.125*Fmax^-0.875]*uld_p(2:4))^-1;   
        
        elseif strcmp(hyperParameters.unloadingFitFunction,'Feng')
            
            % Equation (17b) in [1] used for the fit. Gives similar results.
            unloadFitFun = @(dispVals,forceVals,fitCoefs) (fitCoefs(1)+fitCoefs(2).*forceVals.^0.5 + fitCoefs(3).*forceVals.^fitCoefs(4)) - dispVals ;
            
            
            unloadFitMinFun = @(x) 1/length(xy_unld5(1:hyperParameters.uld_fit_nr,1))* ... 
                                    sum(  ...
                                        sqrt( ...
                                                ( ...
                                                    unloadFitFun(xy_unld5(1:hyperParameters.uld_fit_nr,1),xy_unld5(1:hyperParameters.uld_fit_nr,2),x) ...
                                                    ./xy_unld5(1:hyperParameters.uld_fit_nr,1) ... 
                                                    ).^2 ...
                                                 ) ...
                                    );
            
            unloadFitConstraintFun =  @(x) deal(-( 0.5*x(2).*Fmax.^-0.5 + x(4)*x(3).*Fmax.^(x(4) - 1) ), ...
                                                0);
            
            [uld_p,fval,exitflag,output] =  fmincon(unloadFitMinFun,        ... % Minimization function
                                                    [1, 1, 1, 1]',          ... % Starting guess
                                                    [],[],[],[],[],[],      ... % Linear equality and inequality constraints
                                                    unloadFitConstraintFun, ... % Non-linear inequality an equality constraints
                                                    opts);                  ... % Solver options
            
            
            stiffness_fitS(xLoop) = inv(( 0.5*uld_p(2).*Fmax.^-0.5 + uld_p(4)*uld_p(3).*Fmax.^(uld_p(4) - 1) ));
            
            
            
%             t3 = @(pt,x) x(1)+x(2).*pt.^0.5 + x(3).*pt.^x(4);
%             tFun3 = @(pt,y,x) sum(sqrt(( t3(pt,x) - y).^2) );
%             tempFun3 = @(x) tFun3(xy_unld5(1:hyperParameters.uld_fit_nr,2),xy_unld5(1:hyperParameters.uld_fit_nr,1),x);
%             [dtempFun3] = @(x) deal(-(0.5.*x(2).*Fmax.^-0.5 + x(4).*x(3).*Fmax.^(x(4)-1) ), 0);

%             uld_p = fmincon(tempFun3,[1, 1, 1, 1]',[],[],[],[],[],[],dtempFun3,opts);
            
        else
            disp(['hyperParameters.unloadingFitFunction = ' hyperParameters.unloadingFitFunction ' is not implemented!'])
            disp(stop)
        end
        
        if ctrl.verbose
            subplot(3,2,3) 
            plot(xy_unld5(1:hyperParameters.uld_fit_nr,1),xy_unld5(1:hyperParameters.uld_fit_nr,2))
            hold on
            if strcmp(hyperParameters.unloadingFitFunction,'Ganser')
                plot([ones(size(xy_unld5(1:hyperParameters.uld_fit_nr,2),1),1) ...
                      xy_unld5(1:hyperParameters.uld_fit_nr,2).^0.5            ...
                      xy_unld5(1:hyperParameters.uld_fit_nr,2).^0.25           ...
                      xy_unld5(1:hyperParameters.uld_fit_nr,2).^0.125]*uld_p,xy_unld5(1:hyperParameters.uld_fit_nr,2),'k-') 
                  
            elseif strcmp(hyperParameters.unloadingFitFunction,'Feng')
                plot((uld_p(1)+uld_p(2).*xy_unld5(1:hyperParameters.uld_fit_nr,2).^0.5 + uld_p(3).*xy_unld5(1:hyperParameters.uld_fit_nr,2).^uld_p(4)), ...
                      xy_unld5(1:hyperParameters.uld_fit_nr,2),'k-') 
            else
                disp('Not implemented!')
                disp(stop)
            end
            
            
            subplot(3,2,4)
            plot(hyperParameters.unloadingFitRange(xLoop),stiffness_fitS(xLoop),'ob','HandleVisibility','off')
            hold on
            xlabel('Number of points in fit')
            ylabel('Apparent stiffness S_u [N/m]')
        end
        
        % Collect diagnostic data
        diagnostics.fval(xLoop) = fval;
        diagnostics.exitFlags(xLoop) = exitflag;
        diagnostics.output(xLoop) = output;
        
    end
    diagnostics.geometricMeanOfSu = geomean(stiffness_fitS);
    diagnostics.medianOfSu = median(stiffness_fitS);
    
    stiffness_fit = median(stiffness_fitS);
    
    if ctrl.verbose
        subplot(3,2,3)
        legend('Data in fit','Fit','location','best')
        xlabel('Indenter position [nm]')
        ylabel('Force [nN]')
            
       subplot(3,2,4)
       plot([hyperParameters.unloadingFitRange(1) hyperParameters.unloadingFitRange(end)], ...
             stiffness_fit.*[1 1],'linewidth',2,'DisplayName','Median fit')
       ylim([0 2*stiffness_fit])
       legend('location','best')
    end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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

    % Generate anonymous function
    % x = [h_i ; \beta ]
    hOftFun = @(x) x(1) + x(2) * holdTimeVals.^(x(3));
    minFcn = @(x) sum(sqrt((   (hOftFun(x) - xy_hold(:,1))./xy_hold(:,1)    ).^2));
    opts = optimset('Display','off');
    crp_p = fminunc(minFcn,[40 1.5 1/3],opts);

    h_dot_tot = crp_p(2)*crp_p(3)*holdTimeVals(end)^(crp_p(3) - 1);

    dPdt = [hyperParameters.sampleRate^-1 * [0:(length(xy_unld5(:,1))-1)]' ones(length(xy_unld5(:,1)),1)]\xy_unld5(:,2);  
   
    % Equation (3) in [1]
    stiffness = inv(1/stiffness_fit + h_dot_tot/(abs(dPdt(1))));
    
       
    % Equation (22) in [1]
    Cidx = (h_dot_tot-dhtdt) * stiffness_fit / abs(dPdt(1));
    
    maxIndentation = median(xy_unld5(1,1));
    
    % Equation (2) in [1]
	x0 = maxIndentation - hyperParameters.epsilon*Fmax/stiffness;

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Calculate second key index
    % Equation (23) in [1]
    %
    % th \approx S/abs(dPdt) *hc
    %
    %   th      - [s] Hold time
    %   S       - [N/m] Stiffness calculated according to Equation (3)
    %   dPdt    - [nm/s] Derivative of force with respect to time
    %   h_c     - [nm] Contact depth

    th = length(xy(holdStartIdx:unloadStartIdx,1))/hyperParameters.sampleRate;
    rhs = stiffness / abs(dPdt(1)) * x0;
    thermIdx = ( th - rhs )./ rhs;
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
	% Determine the area
	area_xy = load(indentationSet.areaFile);
	
    if (x0 >= 100)
        area_fit_end = size(area_xy,1);
    elseif (x0 <100)
        area_fit_end = find(area_xy(:,1) > 100,1,'first');
    end
    
    p_area = [area_xy(1:area_fit_end,1) area_xy(1:area_fit_end,1).^2 area_xy(1:area_fit_end,1).^3] \ area_xy(1:area_fit_end,2);
    UnloadArea = [x0 x0.^2 x0.^3]*p_area;

	% Equation (1) in [1]
	Er = sqrt(pi)/2*(stiffness/sqrt(UnloadArea));
    H = Fmax/UnloadArea;
    
    
    % Collect diagnostic output
    diagnostics.constantOffset = offsetPolynom(2);
    diagnostics.linearDrift = offsetPolynom(1);
    diagnostics.basefit = basefit;

    
    else
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
    

    end

    
    
if ctrl.verbose
    mkdir('plots')
    
    folders = subdirImport(['plots' filesep],'regex','_');

    print(horzcat(['plots' filesep],resultFile(1:end-4)),'-dpng')


    for tLoop = 1:6
        subplot(3,2,tLoop)
        hold off
    end
end
end % End of function
% References
%	[1]  G. Feng et al.: Effects of creep and thermal drift on modulus measurement using 
%       depth-sensing indentation. J. Mater. Res., 17, 2002

    
    
