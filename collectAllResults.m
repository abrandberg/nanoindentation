function results = collectAllResults(indentationSet)


counter = 0;
for cLoop = 1:numel(indentationSet)
    counterSave = counter+1;
    
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

    %         results(counter).geometricMean = indentationSet(cLoop).diagnostics.geometricMeanOfSu(dLoop);
            indexPrecursor = strfind(results(counter).inputFiles,'_');


            if strfind(results(counter).inputFiles,'MX') > 0

                results(counter).fiberInSet = str2double(results(counter).inputFiles(3));
                results(counter).indentationInSet = str2double(results(counter).inputFiles(indexPrecursor(2)+1:indexPrecursor(3)-1));
                results(counter).machineIndex = str2double(strtok(results(counter).inputFiles(indexPrecursor(3)+1:end),'.'));

            else
            if length(indexPrecursor) > 3
                indexPrecursor(1:end-3) = [];
            end

            results(counter).fiberInSet = str2double(results(counter).inputFiles(indexPrecursor(1)+1:indexPrecursor(2)-1));
            results(counter).indentationInSet = str2double(results(counter).inputFiles(indexPrecursor(2)+1:indexPrecursor(3)-1));
            results(counter).machineIndex = str2double(strtok(results(counter).inputFiles(indexPrecursor(3)+1:end),'.'));

            end

            if isnan(results(counter).fiberInSet)
                disp(stop) % debug
            end
        
        else
%             disp('Deleted')
        end

        
    end

    uniqueFibersInSet = unique([results([counterSave:counter]).fiberInSet]);
    for fLoop = 1:numel(uniqueFibersInSet)
        selIdx = [results.fiberInSet] == uniqueFibersInSet(fLoop) & ...
                 strcmp({results.indenterType},indentationSet(cLoop).indenterType) & ...
                 [results.relativeHumidity] == indentationSet(cLoop).relativeHumidity & ...
                 strcmp({results.indentationNormal},indentationSet(cLoop).indentationNormal);
        for eLoop = counterSave:counter
            if selIdx(eLoop)
                results(eLoop).medianOfSet = median([results(selIdx).Er],'omitnan');    % Set here is RH+Fiber+Indenter+Direction
                results(eLoop).meanOfSet = mean([results(selIdx).Er],'omitnan');    % Set here is RH+Fiber+Indenter+Direction
                results(eLoop).stdOfSet = std([results(selIdx).Er],'omitnan');    % Set here is RH+Fiber+Indenter+Direction
                
            end
        end
    end   
end



        
        





