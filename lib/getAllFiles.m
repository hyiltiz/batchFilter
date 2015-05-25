function fileList = getAllFiles(dirName, pattern, isMatchFullPath)

% Copyright 2010 , gnovice
% http://stackoverflow.com/users/52738/gnovice

if nargin < 3
    isMatchFullPath = 1; % change to 0 to match only file or folder names
end

dirData = dir(dirName);      %# Get the data for the current directory
dirIndex = [dirData.isdir];  %# Find the index for directories


fileList = {dirData(~dirIndex).name}';  %# Get a list of the files
if ~isempty(fileList)
    fileList = cellfun(@(x) fullfile(dirName,x),... %# Prepend path to files
        fileList,'UniformOutput',false);
    
    if ~isMatchFullPath % Match pattern to file or folder name; NORUN by default
        matchstart = regexp(fileList, pattern);
        fileList = fileList(~cellfun(@isempty, matchstart));
    end
end


subDirs = {dirData(dirIndex).name};  %# Get a list of the subdirectories
validIndex = ~ismember(subDirs,{'.','..'});  %# Find index of subdirectories
%#   that are not '.' or '..'
for iDir = find(validIndex)                  %# Loop over valid subdirectories
    nextDir = fullfile(dirName,subDirs{iDir});    %# Get the subdirectory path
    fileList = [fileList; getAllFiles(nextDir)];  %# Recursively call getAllFiles
end

end
