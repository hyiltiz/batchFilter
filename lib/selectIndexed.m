function selectIndexed()
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
% 1. `'T(rowIndex, n)'`. This first `transpose`s the variable, and then uses the
% original row index as the column index for the transposed variable.
%
% 2. `'P(dimIndex, ORDER)'`. This permutes the variable using `permute(x, order)`,
% and then uses dimIndex as the column index (second dimention) for the transposed
% variable. *NOT IMPLEMENTED YET*.
%
% 3. A string representation of a valid MATLAB index which could be evaluated as
% a literal matrix or cell index (Use varList to specify a structure indexing
% instead), e.g. '`1:end'`, `'3:6'`, `'[2 4 end-1]'`, `'{[1 2]}'` etc.
% 
% 4. `'eye()'` specifies ALL the columns as target columns or all rows as a single
% group. This is equivalent to '1:end' for indexList, and a single vector of all
% ones with the same length of the variable(s) to be processed.
%
% 5. `'file()'` chooses the variable that shares the same name with the data file
% to be used.
%
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

end
