function xy = dataPreProcessing(resultFile)


    xy0 = IBWtoTXT(resultFile);                     % Load the .ibw file, convert to text.

    xy0 = xy0 * 1e9;                                % Convert to nano-meter


    if  contains(resultFile,'hemi')                 % If a hemispherical probe, the load schedule is different and so the relevant data is isolated in this step
        xy0 = cleanAndIsolate(xy0);
    end

    xy = xy0;


    
