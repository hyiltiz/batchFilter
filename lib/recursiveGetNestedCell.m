function [x, xStr] = recursiveGetNestedCell(str)
% return the nested cell content of a cell
% str is of format 'x{1}{3}'

varPart = regexprep(str, '^([a-zA-Z]+\w*)\{.*', '$1');
var = evalin('caller', varPart);

if iscell(var) % the value could be cell, but not this one
% >> regexprep('{1}{3}(1:end)', '^(\{.*\})*(\(.*\))?$', '$1')
% ans =
% {1}{3}
xStr = regexprep(str, '^(\{.*\})*(\(.*\))?$', '$1');

x = evalin('caller', xStr);
else
warning('recursiveGetNestedCell:notCellInput',...
'The indexed variable is not a valid cell.');
end
end
