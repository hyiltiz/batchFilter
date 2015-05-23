function handle = statFun(funType, dim, args)
% use function(x, dim) for all statistics functions

switch lower(funType)
    case {'mean', 'nanmean'}
        handle = @(x) nanmean(x, dim);
    case {'trimmean', 'trimmedmean'}
        if ~exist('args', 'var')
            percent = 10; % percent
        else
            percent = args;
        end
        handle = @(x) trimmean(x, percent, 'round', dim);
    case {'median', 'nanmedian'}
        handle = @(x) nanmedian(x, dim);
    case {'std', 'nanstd'}
        handle = @(x) nanstd(x, 1, dim);
    otherwise
        error('statFun:undefined', 'Undefined statistics function!');
end