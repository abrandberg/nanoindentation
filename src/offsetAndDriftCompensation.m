function [xy,basefit,zeroLine,rampStartIdx,x_zero] = offsetAndDriftCompensation(xy, endRangeBaseFit, noiseFactor)
%function offsetAndDriftCompensation(xy)
% takes as input the instrument signal and returns the point where initial
% contact between the indenter tip and the surface of the material being
% tested is found.
%
% In the process, it resets the coordinate system so that this point is
% (0,0).
%
% INPUTS:
%   xy                      : {Matrix} [m*10^-9] Position of the indenter and the
%                             indenter tip
%   endRangeBaseFit         : {Int} The number of data points included in
%                              the first loop of the algorithm. 
%   noiseFactor             : {Double} The factor to trigger contact, i.e.
%                             if the force jumps above
%                             noiseFactor*std(forceSignal) then contact is
%                             considered to have occured.
%
% OUTPUTS:
%   xy                      : {Matrix} [m*10^-9] Position of the indenter and the
%                             indenter tip, now normalized so that the
%                             initial contact point is at (0,0).
%   basefit                 : {Int} Number of data points included in the
%                             calculations.
%   zeroLine                : {Matrix} Mean and drift of signal prior to
%                             contact.
%   rampStartIdx            : {Int} Entry (row) in the xy-matrix that is
%                             considered the point of intial contact with
%                             the underlying material.
%   x_zero                  : Applied offset along the x-axis.
%
%
% ABOUT:
% created by    : August Brandberg augustbr at kth . se
% date          : 2022-09-10
%
% endRangeBaseFit = 25;
breakForContact = 1;
aLoop = 0;

while breakForContact
    aLoop = aLoop + 1;
    sIdx = 10+endRangeBaseFit*(aLoop-1);
    % Start of time signal to consider.
    
    eIdx = 10+endRangeBaseFit*(aLoop);
    % End of time signal to consider.
    
    dPdt = 100*(xy(eIdx,2) - xy(sIdx,2)) / endRangeBaseFit;
    % Calculate \Delta Force / \Delta time to see if there is a jump in the
    % force value indicative of initial contact.


    if dPdt > 1.5  && aLoop > 3%dPdt > 3.3  && aLoop > 3
        % If jump is sufficiently large, break
       
        basefit = endRangeBaseFit*(aLoop-1);
        breakForContact = 0;
    elseif endRangeBaseFit*aLoop > 1000
        % If it appears that the jump has been missed, break.
        
        basefit = endRangeBaseFit*(8-1);
        breakForContact = 0;
        disp('Potential bug in finding the contact point!')
        
        figure
        plot(xy(sIdx:eIdx,1),xy(sIdx:eIdx,2),'-k+')  
        
        disp(stop)
    else
    end
end

zeroLineM = [ones(size(xy(10:basefit,1)))]\xy(10:basefit,2);
% Perform a linear regression to find the mean value of xy(:,2) before the
% contact.

%xy(:,2) = xy(:,2) - [ones(size(xy(:,1)))]*zeroLineM; 
xy(:,2) = xy(:,2) - zeroLineM; 
% Subtract this value to get the initial contact point to y-coordinate 0.

noise = max(0.1, std(xy(10:basefit,2)));
% Estimate the noise in the signal up to contact.

rampStartIdx = max(1, find( xy(:,2)> noiseFactor*noise ,1,'first') - 1);
% Locate the point where the ramp begins.

x_zero = xy(rampStartIdx,1);
% Find the x-coordinate at this point

xy(:,1) = xy(:,1) - x_zero;                                      
% Shift the curve by the value at the start of the ramp.

xy(:,2) = xy(:,2) - xy(rampStartIdx,2);
% Readjust the y-coordinate

zeroLineD = [xy(10:basefit,1) ]\xy(10:basefit,2);
% Provide diagnostic outputs: the best fitting curve on the form y = k*x

zeroLine = [zeroLineD zeroLineM];
% Provide the intercept and the slope as diagnostic output
    
    
    
    
    
    
    
    
