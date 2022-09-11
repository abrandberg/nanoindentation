function [indentationSet , hyperParameters, ctrl] = inputValidation(indentationSet , hyperParameters, ctrl)

% Make sure there is a trailing file separator on the targetDir
for aLoop = 1:numel(indentationSet)
    if not(strcmp(indentationSet(aLoop).targetDir(end) ,filesep))
            fprintf('          Added a trailing file separator to %s\n', indentationSet(aLoop).targetDir)
            indentationSet(aLoop).targetDir = [indentationSet(aLoop).targetDir filesep];
    end
end