function [x, xStr] = recursiveGetFields(str)
% return the nested field value of a structure
% str is a string of the structure index

if isstruct(str)% the value could be struct, but not this one
% >> regexprep('ss(2).ss.dd(1).cc','\.([a-zA-Z]+[0-9_]*)$?','.(''$1'')')
% ans =
% ss(2).('ss').('dd')(1).('cc')
xStr = regexprep(str, '\.([a-zA-Z]+[0-9_]*)$?', '.(''$1'')');

x = eval(xStr);
else
warning('recursiveGetFields:notStructInput',...
'The indexed variable is not a valid struct.');
end
end
