function [matFilesList status] = selectMatFiles(matFiles, suffix, regexStartDir)
% select the mat files
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

if exist('suffix', 'var') ~= 1
  suffix = '.mat';
end

if exist('regexStartDir', 'var') ~= 1
  regexStartDir = '.';
end

checkNextDir = 0;
if exist('maFiles', 'var') ~= 1
  % You really should have provided this! Be explicit!

  for iDir = 1:options.defaultDirs
    thisDir = options.defaultDirs{iDir};
    if exist(thisDir, 'dir') ~= 7
      if isempty(ls([thisDir '*' suffix]))
        % Found no mat-file under data. Go search for current directory
        checkNextDir = 1;
      else
        warning('selectMatFiles:matFiles', ['Auto-selecting all mat files under `' thisDir '`']);
        matFiles = thisDir;
      end
    else
      checkNextDir = 1;
    end
  end

if ischar(matFiles) % char: could be 1) dir, 2) glob, 3) regex
% decide if this is regexp
if ~isempty(regexp(matFiles, '^s/.*/$', 'once')) & exist(matFiles, 'dir') == 7
  % this could be regexp
  % this could also be valid directory that looks like: s/abc/
  status.isAmbiguousPatternOrDir = 1;
  warning('selectMatFiles:matFiles', ['Auto-selecting all mat files under `' matFiles '`\n'...
    'Or did you mean a REGular EXpression by that!?'...
    'If so, please rename that directory first.']);
else
    % found no hilarious dir or no regexp at all!
    if ~isempty(regexp(matFiles, '^s/.*/$', 'once'))
        % this is a regexp
        status.isRegexp = 1;
        matFiles = matFiles(3:end-1); % strip out s//
        allFiles = getAllFiles(regexStartDir, matFiles, options.isMatchFullPath);

        if options.isMatchFullPath
          matchstart = regexp(allFiles, matFiles);
          matFiles = allFiles(~cellfun(@isempty, matchstart));
        end


    elseif ~isempty(regexp(matFiles, '\*', 'once'))
      % found a glob pattern
      status.isGlob = 1;
      matFiles = cellstr(ls(matFiles));
    else
      if exist(matFiles, 'file') == 2
        % just a file, do nothing
        
      else
        if exist(matFile, 'dir') == 7
      % could only be a dir
      status.isDir = 1;
      matFiles = [matFiles '/']; % append an /
      matFiles = regexprep(matFiles, '\\', '/'); % always use unix style path
      matFiles = regexprep(matFiles, '/*$', '/');
        else
          error('selectMatFiles:DirectoryNotFound',...
            'Directory `%s` not found!', matFiles);
        end
      end
    end
end
% not char!
end




  % parse them into the list format
  if iscellstr(matFiles)
    % good!
    matFilesList = matFiles(:); % treat AS IS
  elseif exist(matFiles, 'dir') == 7
    matFilesList = cellstr(ls([matFiles '*' suffix]));
  elseif exist(matFiles, 'file') == 2
    status.isSingleFile = 1;
    matFilesList = {matFiles}; % this is a single mat file
  end
end
end
