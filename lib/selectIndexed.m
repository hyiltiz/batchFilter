function [targetColumnList status] = selectIndexed(index, srcTable, structData, isGroup)
% ##### indexList, groupVar
%
% indexList specifies the target COLUMN(S) of the variables specified by varList
% to be processed. This column(s) could also be further grouped using groupVar.
% The indexed (indexList) column(s) in each variable (varList) will be grouped
% based on the values of the column(s) specified by groupVar of that variable
% (varList). Integers in indexList should be no greater than the column numbers of
% the variables. Length of groupVar should be equal to the length of the variable
% to be processed, with the same number of rows in each of them.
%
% Both indexList and groupVar are specified using the same rules. They can be: A
% single integer or an 1 x n array of integers that specifies the COLUMN indexes
% of each variables in varList to be (grouped and then) processed. Use m x n array
% of integers to respectively specify the COLUMNS indexes for each of the
% variables. m should be equal to the number of variables in varList.
%
% Could also be a string that satisfies one of the following cases:
%
% 1. `'T(rowIndex)'`. This first `transpose`s the variable, and then uses the
% original row index as the column index for the transposed variable.
%
% 2. `'P(dimIndex, ORDER)'`. This permutes the variable using `permute(x, order)`,
% and then uses dimIndex as the column index (second dimention) for the transposed
% variable.
%
% 3. `'eye()'` specifies ALL the columns as target columns or all rows as a single
% group. This is equivalent to '1:end' for indexList, or a single vector of all
% ones with the same length of the variable(s) to be processed for groupVar.
% Could be provided as the first argument to index transpose function T() and
% index permutation function P().
%
% 4. `'file()'` gets the indexes from the variable that shares the same name with the data file
% to be used. Could be provided as the first argument to index transpose function T() and index permutation function P().
%
% 5. A valid numeric MATLAB index or a string representation of a valid MATLAB
% index which could be evaluated as a literal matrix or cell index (Use varList to
% specify a structure indexing instead), e.g. `1:4`, `1`, '`1:end'`, `'3:6'`, `'[2
% 4 end-1]'`, `'{[1 2]}'` etc. Do NOT include any brackets `()` in this string
% expression, which is reserved for the special functions mentioned above. Use
% square brackets `[]` for grouping parts of the expression when necessary.
% 6. `'indexVarName'` specifies the variable `indexVarName` in the data file whose
% values are to be treated as the index array (should be one dimentional vector)
% or the grouping variables (should be m x n matrix where groups are divided based
% on the value of each column).
%
% In addition, use cell strings of size m x 1 to specify respectively for each of
% the m variables. For example:
% ```matlab
% % use the following syntax for setting values for `indexList` or `groupVar`
% % for all mat-files under ./data/, group Trials(:,4) based on Trials(:,[2 3])
% % and then return the mean for each group (6 groups in total)
% batchFilter('data', 'Trials', 4, [2 3], 'mean');
%
% % for all mat-files under ./data/, group Trials(:,targetIndex) based on
% % Trials(:,condition) and then return the mean for each group (results in 6
% % groups in total)
% batchFilter('data', 'Trials', 'targetIndex', 'condition', 'mean');
% ```

isDebug = 1;

targetColumnList = {};
targetColumns = {};

% we got a lot of parsing to do...
% first get the variable names out of varList, then get the values

% decoded varList cell string
% can be used directly for dynamic structure inexing: s.(fieldName)

if iscellstr(index)
  % parse each element separately
  for iCol = 1 : numel(index)
    if ischar(index{iCol})
      [targetColList{iVar} status] = parseColString(index{iCol}, srcTable,  structData);
    end
  end

elseif ischar(index)
  % function() or pattern?
  [targetColList{1} status] = parseColString(index{iCol}, srcTable,  structData);
end % cellstr or a single string


% Hurrah! No more enigmas now!
for iCol = 1 : numel(targetColList)
  try
    %targetVars{iVar} = structData.(targetVarList{iVar});
    % NOTE: Allow for structure indexing
    % we could have still use recursiveGetFields (an overkill with eval)
    targetColumns{iCol} = recursiveGetFields(['structData.' targetColList{iCol}]);
  catch
    error('selectIndex:InvalidIndex',...
      'Index: %f requested!', targetColList{iCol});
  end
end

end % function

function [indexedVarValue, table, status] = parseVarString(indexStr, table, wrkspc)
status.succeed = 0;
% requestedVar is an encoded string
% return the decoded cell string
if ischar(indexStr)
  indexStr = strtrim(indexStr);

  allVariables = fieldnames(wrkspc);

  % file__Name__ was not part of original data
  allVariables(strcmp(allVariables, 'file__Name__')) = [];

  if strcmp(indexStr, 'file()')
    % use the file name
    status.isFromFileName = 1;
    indexStr = cellstr(wrkspc.file__Name__); % use it as the index to the variable

  elseif strcmp(indexStr, 'eye()')
    % use all variables
    status.isAllVariables = 1;
    indexStr = sprintf('1:%d', size(table,2));

  elseif ~isempty(indexStr, '^([a-zA-Z]*\(.*\)){2,}$', 'once'))
    % a string of format: a(x)b(y) or more
    status.isConsecutiveFunctions = 1;
    nestedFormat = indexStr;
    while ~isempty(nestedFormat, '^([a-zA-Z]*\(.*\)){2,}$', 'once'))
      % a()b()c(hello) => a()b(c(hello))
      % a()b()c() => a()b(c())
      nestedFormat = regexprep(nestedFormat, '^(.*)(.*)\(\)(.*\(.*\))$', '$1$2($3)');
    end

    warning('selectIndexed:InvalidFunctionSpecifier',...
      'Consecutive functions of form a()b() is found, which effectively means absolutely nothing as far as indexing goes! We are nice to support a nested syntax, though, such as: a(b()). \nDid you mean something like this: \n%s', nestedFormat);

  elseif ~isempty(regexp(indexStr, '^T\((.*)\)$', 'tokens'))
    % do a transpose
    status.isTranspose = 1;
    matchedTokensCell = regexp(indexStr, '^T\((.*)\)$', 'tokens');
    indexStr = matchedTokensCell{1}{1};
    table = transpose(table);

  elseif ~isempty(regexp(indexStr, '^P\((.*),(.*)\)$', 'tokens')
    % do a permutation
    status.isPermute = 1;
    matchedTokensCell = regexp(indexStr,'^P\((.*),(.*)\)$', 'tokens');
    indexStr = matchedTokensCell{1}{1};
    permuteOrder = matchedTokensCell{1}{2};
    try
      eval(sprintf('table = permute(table, [%s]);', permuteOrder));
    catch
      warning('selectIndexed:InvalidPermuteOrder', 'Could not permute with: %s', permuteOrder);
      rethrow(lasterror);
    end

  else
    status.isUnknownIndex = 1;
    warning('selectIndexed:UnknownIndexSpecifier', 'Index specifier `%s` is not recognized.\nSee HELP batchFilter to see the description for all valid index specifiers.', indexStr)
    if isDebug; keyboard; end
  end % parse

else
  status.isNotStringIndex = 1;
  % warning('selectIndexed:NotAString', 'An index of type `string` is required!');
  % if isDebug; keyboard; end
end % ischar


if ischar(indexStr) & ~isempty(regexp(indexStr, '^\{(.*)\}(\(.*\))?$', 'tokens'))
  % cell indexing found
  status.isCellIndex = 1;
  matchedTokensCell =  regexp(indexStr, '^\{(.*)\}(\(.*\))?$', 'tokens');
  eval(sprintf('table = table{[%s]};', matchedTokensCell{1}{1}));
  indexStr = matchedTokensCell{1}{2};
  if isempty(indexStr)
    indexStr = 'eye()';
  end
end

if status.isTranspose | status.isPermute | status.isCellIndex
  status.isTableTransformation = 1;
else
  status.isTableTransformation = 0;
end

if status.isTableTransformation
  % we updated the table this time; get the indexed variable next time
[matchedVarList, table, status] = parseVarString(indexStr, table, wrkspc)

else
  % end of parse
  % select out the indexed COLUMNS
  if isnumeric(indexStr)
    % could only be a numeric index for a numeric array/matrix
    status.isNumericIndex = 1;
    indexedVarValue = table(:, [indexStr]);
  else
  eval(sprintf('indexedVarValue = table(:, [%s]);', indexStr));
end
end

end
