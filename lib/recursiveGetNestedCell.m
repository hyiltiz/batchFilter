function [x, xStr] = recursiveGetNestedCell(str)
% return the nested cell content of a cell
% str is of format '{1}{3}'

if iscell(str) % the value could be cell, but not this one
% >> regexprep('{1}{3}(1:end)', '^(\{.*\})*(\(.*\))?$', '$1')
% ans =
% {1}{3}
xStr = regexprep(indexStr, '^(\{.*\})*(\(.*\))?$', '$1');

x = eval(xStr);
else
warning('recursiveGetNestedCell:notCellInput',...
'The indexed variable is not a valid cell.');
end
end
