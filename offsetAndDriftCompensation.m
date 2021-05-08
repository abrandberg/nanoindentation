function [xy,basefit,zeroLine,rampStartIdx,x_zero] = offsetAndDriftCompensation(xy)
    
% figure;
   
    endRangeBaseFit = 25; % 100 previously
    breakForContact = 1;
    aLoop = 0;
    zeroMeanOld = 0; zeroStdOld = 0;

    while breakForContact
        aLoop = aLoop + 1;
        zeroMean = mean(xy(10:endRangeBaseFit*aLoop,2));
        zeroStd = std(xy(10:endRangeBaseFit*aLoop,2));
        
        sIdx = 10+endRangeBaseFit*(aLoop-1);
        eIdx = 10+endRangeBaseFit*(aLoop);
        
%         
        dPdt = 100*(xy(eIdx,2) - xy(sIdx,2)) / endRangeBaseFit;
        
        
%         dPdt = [2000^-1 * [0:(length(xy(10:endRangeBaseFit*aLoop,2))-1)]' ones(length(xy(10:endRangeBaseFit*aLoop,2)),1)]\xy(10:endRangeBaseFit*aLoop,2);  
        
%         plot(aLoop,dPdt(1),'o'); hold on
%         plot(aLoop,dPdt(2),'s')
        
        if  0% Debug module
%             if aLoop == 1
%                 figure;
%                 subplot(1,2,1)
%                 plot(xy(:,2))
%                 subplot(1,2,2)
%             end
            
            plot(aLoop,zeroMean,'ob')
            hold on
            plot(aLoop,zeroMean-zeroStd,'k+')
            plot(aLoop,zeroMean+zeroStd,'k+')
            plot(aLoop,zeroMean-2*zeroStd,'rs')
            plot(aLoop,zeroMean+2*zeroStd,'rs')
            pause(2)
        end
        
        if dPdt > 3.3  && aLoop > 3%zeroMean > (zeroMeanOld+0.5*zeroStdOld) && aLoop > 1
            basefit = endRangeBaseFit*(aLoop-1);
            breakForContact =0;
        elseif endRangeBaseFit*aLoop > 1000
            basefit = endRangeBaseFit*(8-1);
            breakForContact =0;
        else
            zeroMeanOld = zeroMean;
            zeroStdOld = zeroStd;
        end
    end

%     zeroLine = [xy(10:basefit,1) ones(size(xy(10:basefit,1)))]\xy(10:basefit,2);
%     xy(:,2) = xy(:,2) - [xy(:,1) ones(size(xy(:,1)))]*zeroLine; 
    
    
    zeroLineM = [ones(size(xy(10:basefit,1)))]\xy(10:basefit,2);
    xy(:,2) = xy(:,2) - [ones(size(xy(:,1)))]*zeroLineM; 
    
    % Locate the point where the ramp begins.
    noise = max(0.1,std(xy(10:basefit,2)));
    rampStartIdx = max(1,find( xy(:,2)>4*noise ,1,'first') - 1);
    x_zero = xy(rampStartIdx,1);
    xy(:,1) = xy(:,1) - x_zero;                                       % Shift the curve by the value at the start of the ramp.
    xy(:,2) = xy(:,2) - xy(rampStartIdx,2);
    
    
    
    
    zeroLineD = [xy(10:basefit,1) ]\xy(10:basefit,2);
%     xy(:,2) = xy(:,2) - [xy(:,1) ]*zeroLineD; 
    
    zeroLine = [zeroLineD zeroLineM];
    
    
    
    
    
    
    
    
