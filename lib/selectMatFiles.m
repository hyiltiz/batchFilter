function [matFilesList status] = selectMatFiles(matFiles, suffix, regexStartDir, options)
% % select the mat files
% ##### matFiles
%
% `matFiles` specifies the pathname of the data files to be opened as mat-files.
% The pathname could either be relative pathname to the current directory, or
% absolute pathname. When empty, batchFilter searches by defaultfor mat-files with
% .mat suffix first under an ./data directory (if one exists under current
%   directory), then under current directory.
%
% The data files could be specified with one of the following synatx:
%
% 1. A directory string. In this case, all mat-files under this directory is
% processed. For example:
% ```matlab
% % setting the value of `matFiles` to
% 'exp1/data/' % searches under exp1/data/
% ```
%
% 2. A glob pattern string consisting one or more wildcard `*` sign which
% represents zero or more of any characters. The glob pattern will be expanded by
% MATLAB's native `ls` command whenever possible, which in turn, relies upon the
% `ls` or `dir` utilities that the operating system provides. In other cases (e.g.
% when more than one wildcard are present under different directories,
% `data/*/*.mat`), the glob pattern is automatically transformed to a regex. For
% example:
% ```matlab
% % setting the value of `matFiles` to
% 'exp*/data/' % searches through data under exp1, exp2 etc.
% ```
%
% 3. A regular expressions pattern (regexp) string inside `'s/<pattern>/'`. If a
% regexp is provided, the pattern is matched against the relative full path under
% current directory. Setting options.isMatchFullPath to 0 can change this matching
% mode so that the pattern is matched against each file (e.g. `'a.mat'`) and
% folder names (e.g. `'exp1'`, `'data'`) instead of relative full path names (e.g.
% `'./exp1/data/a.mat'`). The regexp matching is processed by MATLAB's native
% `regexp` command. see `DOC REGEXP` for more information. For example:
% ```matlab
% % setting the value of `matFiles` to
% 's/.*john.*\.mat/' % searches for all .mat files whose name contains `'john'`.
% ```
%
% 4. A list of cell strings where each elements of the cell string is a single
% mat-file to be treated as the data-file to be processed. For example:
% ```matlab
% % setting the value of `matFiles` to
% {'data/a.mat', 'data/b.mat'} % processes all data files as mat-files.
% ```matlab

if exist('suffix', 'var') ~= 1 || isempty(suffix)
  suffix = '.mat';
  userDefinedSuffix = 0;
else
  userDefinedSuffix = 1; % add in the dot
  % cut out the accidental ..mat suffix
  suffix = regexprep(['.' suffix], '^\.*','.');
end

if exist('regexStartDir', 'var') ~= 1 || isempty(regexStartDir)
  regexStartDir = '.';
end

checkNextDir = 0;
if exist('matFiles', 'var') ~= 1 || isempty(matFiles)
  % You really should have provided this! Be explicit!

  for iDir = 1:numel(options.defaultDirs)
    thisDir = options.defaultDirs{iDir};
    if exist(thisDir, 'dir') == 7
      if isempty(ls([thisDir '*' suffix]))
        % Found no mat-file under data. Go search for current directory
        checkNextDir = 1;
      else
        warning('selectMatFiles:matFiles', ...
          'Auto-selecting all %s files under `%s`', suffix, thisDir);
        matFiles = thisDir;
        break
      end
    else
      checkNextDir = 1;
    end
  end
end

if ischar(matFiles) % char: could be 1) dir, 2) glob, 3) regex
  % decide if this is regexp
  if ~isempty(regexp(matFiles, '^s/.*/$', 'once')) && exist(matFiles, 'dir') == 7
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
      allFiles = regexprep(allFiles, '\\', '/');

      if options.isMatchFullPath
        matchstart = regexp(allFiles, matFiles);
        matFiles = allFiles(~cellfun(@isempty, matchstart));
      end


    elseif ~isempty(regexp(matFiles, '\*', 'once'))
      % found a glob pattern
      status.isGlob = 1;
      originalMatFiles = matFiles;
      if userDefinedSuffix % the user explicitly specified a suffix
        % repititive suffix
        matFiles = regexprep(matFiles, ['\' suffix '$'], '');
        % the user specified the suffix as the input
        % the user might also specified the suffix thinking uniformity
        % in that case, leave all the other suffix out
        matFiles = [matFiles suffix];
      end
      % a simple sanity check
      %       if isempty(regexp(requestedVar, '[^/\\\w\.\*]', 'once'))
      %         % we are clean

      matFiles = regexprep(matFiles, '[/\\]\', '/'); % use / for dirsep
      matFiles = regexprep(['./' matFiles], '^(\./)*', './'); % single ./
      % data/*/.mat will not match anyting => data/*/*.mat
      matFiles = regexprep(matFiles, ['[/\\]\' suffix], ['/*' suffix]);
      if ~isempty(regexp(matFiles, '^.*\*.*[/\\].*\*.*$', 'once'))
        % data/*/*.mat
        % use regexp for this
        matFiles = regexprep(matFiles, '\.', '\\.');
        matFiles = regexprep(matFiles, '\*', '.*');

        if ~strcmp(originalMatFiles, matFiles)
          warning('selectMatFiles:InputModified', ...
            'Your wildcard glob pattern `%s` is modified to a regex `%s`.\nStart with `./` for current directory, use `/` as directory seperators, and only use a single wildcard `*` if you did not want to see this warning message, or simply use a regex similiar to the one provided above.', originalMatFiles, matFiles);
        end


        allFiles = getAllFiles(regexStartDir, matFiles, options.isMatchFullPath);
        allFiles = regexprep(allFiles, '\\', '/');
        if options.isMatchFullPath
          matchstart = regexp(allFiles, matFiles);
          matFiles = allFiles(~cellfun(@isempty, matchstart));
        end

      else
        matFiles = cellstr(ls(matFiles));
      end
      %       else
      %         warning('selectMatFiles:invalidPattern', ...
      %           'Possible glob pattern `%s` found, but is invalid!', requestedVar);
      %       end


    else
      % could only be a dir
      status.isDir = 1;
      matFiles = [matFiles '/']; % append an /
      matFiles = regexprep(matFiles, '\\', '/'); % always use unix style path
      matFiles = regexprep(matFiles, '/*$', '/');
    end
  end
else
  % not char!
  if iscellstr(matFiles); status.userDefined = 1;end
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

matFiles = matFiles(~ismember(matFiles, {'.', '..'}));
validFiles = cellfun(@(x) exist(x, 'file')==2, matFiles);
if ~all(validFiles)
  warning('selectMatFiles:FileNotExist', ...
    '\nOmitting some non-existing files: (Are you using cell strings?)\n%s', matFiles{~validFiles});
  matFiles = matFiles(validFiles);
end

if isempty(matFiles)
  error('selectMatFiles:emptyOutput', 'No valid files matched!');
end
end
