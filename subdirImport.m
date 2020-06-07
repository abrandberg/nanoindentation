function folderNames = subdirImport(workDir,importScope,expressToMatch)
%subdirImport(workDir) goes through the workDir and returns all the
%folders. Hidden folders are not returned.
%
% INPUT:    - workDir : The directory where the search is to be performed.
%
% OUTPUT:   - folderNames: A structure of size [N x 1], where N is the
%                          number of folders found.
%
% REMARKS:
%
% TO DO:
%
% created by: August Brandberg
% DATE: 19-01-2018

currDir = cd;

if nargin == 1
    importScope = 'dir';
end

if strcmp(importScope,'dir')
    d = dir(workDir);
    isub = [d.isdir]; % returns logical vector
    folderNames = {d(isub).name}';
    folderNames(ismember(folderNames,{'.','..'})) = []; % Remove hidden folders from results (windows)
elseif strcmp(importScope,'regex')
    cd(workDir)
%     d = dir(horzcat(expressToMatch,'*.*'));
    d = dir(horzcat('*',expressToMatch,'*'));
    folderNames = {d.name};
%     for yLoop = 1:numel(folderNames)
%         folderNames{yLoop} = folderNames{yLoop}(1:end-4);
%     end
    cd(currDir)
end


end

