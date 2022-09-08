function results = collectAllResults(indentationSet)


counter = 0;
for cLoop = 1:numel(indentationSet)
   
    for dLoop = numel(indentationSet(cLoop).Er):-1:1
        
        
        geometricMean = indentationSet(cLoop).diagnostics(dLoop).geometricMeanOfSu;
        medianOfSu = indentationSet(cLoop).diagnostics(dLoop).medianOfSu;
        
        if sum(size(geometricMean)) > 0
            condition1 = inf > abs((geometricMean - medianOfSu)./medianOfSu);
        else
             condition1 = 0;
        end
        
        C2 =   isreal(indentationSet(cLoop).Er(dLoop)) ...
             & not(isnan(indentationSet(cLoop).Er(dLoop))) ...
             & not(isempty(indentationSet(cLoop).Er(dLoop)));
        
        
        if condition1 && C2
            counter = counter + 1;
            results(counter).Er = real(indentationSet(cLoop).Er(dLoop));
            results(counter).H = indentationSet(cLoop).H(dLoop);
            results(counter).Cidx = indentationSet(cLoop).Cidx(dLoop);
            results(counter).thermIdx = indentationSet(cLoop).thermIdx(dLoop);
            results(counter).inputFiles = indentationSet(cLoop).inputFiles{dLoop};

            results(counter).springConstant = indentationSet(cLoop).springConstant;
            results(counter).designatedName = indentationSet(cLoop).designatedName;
            results(counter).relativeHumidity = indentationSet(cLoop).relativeHumidity;
            results(counter).indenterType = indentationSet(cLoop).indenterType;
            results(counter).indentationNormal = indentationSet(cLoop).indentationNormal;

            results(counter).maxIndentation = indentationSet(cLoop).diagnostics(dLoop).maxIndentation;
            results(counter).x0 = indentationSet(cLoop).diagnostics(dLoop).x0;
            results(counter).h_dot_tot = indentationSet(cLoop).diagnostics(dLoop).h_dot_tot;
            results(counter).geometricMeanOfSu = indentationSet(cLoop).diagnostics(dLoop).geometricMeanOfSu;
            results(counter).medianOfSu = indentationSet(cLoop).diagnostics(dLoop).medianOfSu;
            
            results(counter).hc = indentationSet(cLoop).diagnostics(dLoop).hc;
            
            results(counter).hf = indentationSet(cLoop).diagnostics(dLoop).hf;
            results(counter).unloadArea = indentationSet(cLoop).diagnostics(dLoop).unloadArea;
            results(counter).area_xy = indentationSet(cLoop).diagnostics(dLoop).area_xy;

            results(counter).uld_p = indentationSet(cLoop).diagnostics(dLoop).uld_p;
            results(counter).xy = indentationSet(cLoop).diagnostics(dLoop).xy;

        else
        end
    end  
end



        
        





