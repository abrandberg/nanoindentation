function plotEachPoint(results)



indexOfRHs = unique([results.relativeHumidity]);
indexOfSets = unique([results.fiberInSet]);
colorTemp = lines(numel(indexOfSets));
indexOfIndenters = unique({results.indenterType});
markerTemp = {'o','s'};


figure;
for yLoop = 1:numel(results)
    
   % X-coordinate: RH
   % Marker: Indenter
   % Color: Set
   % Y-coordinate: ER
   
   xTemp = results(yLoop).relativeHumidity;%h_dot_tot;%relativeHumidity;
   yTemp = results(yLoop).Er;
   
   mTemp = markerTemp{(strcmp({results(yLoop).indenterType},indexOfIndenters))};
   cTemp = colorTemp(([results(yLoop).fiberInSet]==indexOfSets),:);
   
   xJitter = 1*(results(yLoop).fiberInSet-4.5)^-1;
   
   
   if strcmp(results(yLoop).indentationNormal,'L')
      subplot(1,2,1) 
   elseif strcmp(results(yLoop).indentationNormal,'T')
       subplot(1,2,2)
   else
       disp(stop)
   end
   
   plot(xTemp+xJitter,yTemp,'MarkerEdgeColor',cTemp,'marker',mTemp);%,'MarkerFaceColor',cTemp);
   hold on
   xlim([0 100])
   xlabel('RH')
   ylabel('Er')
   pause(0.5) 
end
subplot(1,2,1)
xticks([25 45 60 75])
ylim([0 50])
subplot(1,2,2)
xticks([25 45 60 75])
ylim([0 50])