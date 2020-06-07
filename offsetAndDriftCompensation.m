function [xy,basefit,zeroLine] = offsetAndDriftCompensation(xy)
    

   
    endRangeBaseFit = 100;
    breakForContact = 1;
    aLoop = 0;
    zeroMeanOld = 0; zeroStdOld = 0;

    while breakForContact
        aLoop = aLoop + 1;
        zeroMean = mean(xy(10:endRangeBaseFit*aLoop,2));
        zeroStd = std(xy(10:endRangeBaseFit*aLoop,2));
        
        if  0 % Debug module
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
        
        if zeroMean > (zeroMeanOld+0.5*zeroStdOld) & aLoop > 3
            basefit = endRangeBaseFit*(aLoop-1);
            breakForContact =0;
        else
            zeroMeanOld = zeroMean;
            zeroStdOld = zeroStd;
        end
    end

    zeroLine = [xy(10:basefit,1) ones(size(xy(10:basefit,1)))]\xy(10:basefit,2);
    xy(:,2) = xy(:,2) - [xy(:,1) ones(size(xy(:,1)))]*zeroLine; 
