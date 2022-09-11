function xy = dataPreProcessing(resultFile)
%function dataPreProcessing(resultFile) takes as input a string path to an
% .IBW file and returns a two column matrix with the z-coordinate of the
% indenter and the tip, in nano-meters.
%
% INPUTS:
%   resultFile              : {string} The name of the specific file to analyse,
%                                      must be located in the targetDir.
%
% OUTPUTS:
%   xy                      : {Matrix} [m*10^-9] Position of the indenter and the
%                             indenter tip
%
% ABOUT:
% created by    : August Brandberg augustbr at kth . se
% date          : 2022-09-10
%

xy0 = IBWtoTXT(resultFile);
% Load the .ibw file, convert to text.
xy = xy0 * 1e9;
% Convert to nano-meter  



    
