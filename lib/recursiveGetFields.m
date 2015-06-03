function [x, xStr] = recursiveGetFields(str)
% return the nested field value of a structure
% str is a string of the structure index

varPart = regexprep(str, '^([a-zA-Z]+\w*)\..*', '$1');
var = evalin('caller', varPart);

if isstruct(var)% the value could be struct, but not this one
% >> regexprep('ss(2).ss.dd(1).cc','\.([a-zA-Z]+[0-9_]*)$?','.(''$1'')')
% ans =
% ss(2).('ss').('dd')(1).('cc')
xStr = regexprep(str, '\.([a-zA-Z]+\w*)$?', '.(''$1'')');

x = evalin('caller', xStr);
else
warning('recursiveGetFields:notStructInput',...
'The indexed variable is not a valid struct.');
end
end
