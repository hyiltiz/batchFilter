function stat = batchFilter(matfiles, varList, indexList, batchFun, outFiles, options)
%BATCHFILTER applies batchFun as a filter to multiple mat-files then combines output into statistics-friendly tables.
%
% SYNOPSIS: stat = batchFilter(matfiles, batchFun, varList, indexList, outFiles)
%
% INPUT
% matFiles
%       matFiles specifies the pathname of the data files to be opened as mat-files.
%       The pathname could either be relative pathname to the current directory,
%       or absolute pathname. When empty, batchFilter searches for mat-files with
%       .mat suffix first under an ./data directory (if one exists under current
%       directory), then under current directory.
%       The data files could be specified with one of the following synatx:
%         1. A directory string. In this case, all mat-files under this directory is
%            processed.
%            For example: 'exp1/data/' searches under exp1/data/
%         2. A glob pattern string consisting one or more asterisks (*) sign which represents zero or more of any charachters. The glob
%            pattern will be expanded by MATLAB's native ls command, which in turn,
%            relies upon the `ls` or `dir` utilities in the operating system.
%            For example: 'exp*/data/' searches through data under exp1, exp2 etc.
%         3. A regular expressions patteen (regexp) string inside 's/<pattern>/'.
%          If a regexp is provided, the pattern is matched against the relative full path under
%            current directory. Setting options.isMatchFullPath to 0 can change
%            this matching mode so that the pattern is matched against each file
%            (e.g. 'a.mat') and folder names (e.g. 'exp1', 'data') instead of
%            relative full path names (e.g. './exp1/data/a.mat'). The regexp matching
%            is procecssed by MATLAB's native `regexp` command. see DOC REGEXP
%            for more information.
%            For example, 's/.*john.*\.mat/' searches for all .mat files whose name contains 'john'
%         4. A list of cell strings where each elements of the cell string is a
%            single mat-file to be treated as the data-file to be processed.
%            For expmple: {'data/a.mat', 'data/b.mat'} processes all data files as mat-files.
% 	varList
%		indexList
%		batchFun
%		outFiles
%   options
%
% OUTPUT stat
%

% created with MATLAB ver.: 8.0.0.783 (R2012b)
% on Microsoft Windows 7 Version 6.1 (Build 7601: Service Pack 1)
%
% Author: Hormetjan Yiltiz, 2015-05-23
% UPDATED: 2015-05-23 16:18:17
%
% HISTORY
% yyyy-dd-mm	whoami	log
% 2015-05-23	Hormetjan Yiltiz	Created it.
%
%
% Copyright 2015 by Hormetjan Yiltiz <hyiltiz@gmail.com>
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

options.defaultDirs = {'./data/', './'}; % always include the last
options.defaultSuffix = {'.mat'}; % for now, only checks for the first element
options.defaultRegexStartDir = '.';

%% Input processing
% select the mat files
% NOTE: maybe simply using the path mechanism would be easier, but it introduces
% potential bugs where unintended mat-files get processed.
checkNextDir = 0;
suffix = options.defaultSuffix{1};
regexStartDir = options.defaultRegexStartDir;
if exist('maFiles', 'var') ~= 1
  % You really should have provided this! Be explicit!
  
  for iDir = 1:options.defaultDirs
    thisDir = options.defaultDirs{iDir};
    if exist(thisDir, 'dir') ~= 7
      if isempty(ls([thisDir] '*' suffix]))
        % Found no mat-file under data. Go search for current directory
        checkNextDir = 1;
      else
        warning('batchFilter:matFiles', ['Auto-selecting all mat files under `' thisDir '`']);
        matFiles = thisDir;
      end
    else
      checkNextDir = 1;
    end
  end
  
  if ischar(matFiles) % char: could be 1) dir, 2) glob, 3) regex
    % decide is this is regexp
    if ~isempty(regexp(matFiles, '^s/.*/$'))
      % this could be regexp
      if exist(matFiles, 'dir') == 7
        % this could also be valid directory
        warning('batchFilter:matFiles', ['Auto-selecting all mat files under `' matFiles '`\n'...
          'Or did you mean a REGular EXpression by that!?'...
          'If so, please rename that directory first.']);
      else
        % this is a regexp
        matFiles = matFiles(3:end-1); % strip out s//
        allFiles = getAllFiles(regexStartDir, matFiles, options.isMatchFullPath);
        
        if options.isMatchFullPath
          matchstart = regexp(allFiles, matFiles);
          matFiles = allFiles(~cellfun(@isempty, matchstart));
        end
      end
      
    elseif ~isempty(regexp(matFiles, '\*'))
      % found a glob pattern
      matFiles = cellstr(ls(matFiles));
    else
      % could only be a dir
      matFiles = [matFiles '/']; % append an /
      matFiles = regexprep(matFiles, '\\', '/'); % always use unix style path
      matFiles = regexprep(matFiles, '/*$', '/');
    end
  end
  
  
  % parse them into the list format
  if iscellstr(matFiles)
    % good!
    matFilesList = matFiles; % treat AS IS
  elseif exist(matFiles, 'dir') == 7
    matFilesList = cellstr(ls([matFiles '*.mat']));
  elseif exist(matFiles, 'file') == 2
    matFilesList = {matFiles}; % this is a single mat file
  end
  nMatFiles = numel(matFilesList);
  
  
  
  
  getCenter = statFun('mean', 1); % or choose median
  getDispersion = statFun('std', 1); % or choose mad/irq
  
  data = [];
  for iSub = 1:numel(files)
    s = load([dir files{iSub}]);
    mC{iSub} = accumarray(s.Trial(:, [6 1 2]), s.Trial(:, 4), [2 2 3], getCenter, NaN);
    sdC{iSub} = accumarray(s.Trial(:, [6 1 2]), s.Trial(:, 4), [2 2 3], getDispersion, NaN);
    [typeAV, typeRegIrreg, avgInterval] = ind2sub(size(mC{iSub}), find(mC{iSub}));
    data = [data; [iSub*ones(size(typeAV)), typeAV, typeRegIrreg, avgInterval, mC{iSub}(:), sdC{iSub}(:)]];
  end
  
end
