function xy = dataPreProcessing(resultFile)
    

    % Check whether we are in MATLAB or in OCTAVE
    execEngine = exist ('OCTAVE_VERSION', 'builtin');

    xy0 = IBWtoTXT(resultFile);                     % Load the .ibw file, convert to text.

    xy0 = xy0 * 1e9;                                % Convert to nano-meter

    if execEngine == 0
%         if  contains(resultFile,'hemi')                 % If a hemispherical probe, the load schedule is different and so the relevant data is isolated in this step
%             xy0 = cleanAndIsolate(xy0);
%         end
    elseif execEngine == 5
        if  size(strfind(resultFile,'hemi'),1) > 0                 % If a hemispherical probe, the load schedule is different and so the relevant data is isolated in this step
            xy0 = cleanAndIsolate(xy0);
        end
    end
    
    xy = xy0;


    
