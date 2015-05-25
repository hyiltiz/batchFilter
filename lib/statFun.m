function handle = statFun(funType, dim, args)
% use function(x, dim) for all statistics functions

% register valid functions that are to be defined below
statFunctions = struct(...
  'mean', {{'mean', 'nanmean'}},...
  'trimmean',  {{'trimmean', 'trimmedmean'}},...
  'median', {{'median', 'nanmedian'}},...
  'std', {{'std', 'nanstd'}}...
  );

if exist('dim', 'var') ~= 1
  dim = 1; % default to column-wise operation
end


if nargin == 0
  % display all possible cases
  disp(fieldnames(statFunctions));

else

  switch lower(funType)
    case statFunctions.mean
      handle = @(x) nanmean(x, dim);
    case statFunctions.trimmean
      if ~exist('args', 'var')
        percent = 10; % percent
      else
        percent = args;
      end
      handle = @(x) trimmean(x, percent, 'round', dim);
    case statFunctions.median
      handle = @(x) nanmedian(x, dim);
    case statFunctions.std
      handle = @(x) nanstd(x, 1, dim);
    otherwise
      error('statFun:undefined', 'Undefined statistics function!');
  end % switch
end

end
