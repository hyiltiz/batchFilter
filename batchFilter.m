function stat = batchFilter(matfiles, batchFun, varList, indexList, outFiles)
%BATCHFILTER applies batchFun as a filter to multiple mat-files then combines output into statistics-friendly tables.
%
% SYNOPSIS: stat = batchFilter(matfiles, batchFun, varList, indexList, outFiles)
%
% INPUT matfiles
%		batchFun
%		varList
%		indexList
%		outFiles
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

if nargin < 1
    dir = 'AVRtoj6AV/';
end
files = cellstr(ls([dir '*.mat']));


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
