### Overview
BATCHFILTER applies batchFun as a filter to multiple mat-files then combines
output into statistics-friendly tables.

### Syntax

`[stat dataTree] = batchFilter(matfiles, varList, indexList, groupVar, batchFun, outFiles, options)`

#### INPUT

##### matFiles

`matFiles` specifies the pathname of the data files to be opened as mat-files.
The pathname could either be relative pathname to the current directory, or
absolute pathname. When empty, batchFilter searches by defaultfor mat-files with
.mat suffix first under an ./data directory (if one exists under current
  directory), then under current directory.

The data files could be specified with one of the following synatx:

1. A directory string. In this case, all mat-files under this directory is
processed. For example:
```matlab
% setting the value of `matFiles` to
'exp1/data/' % searches under exp1/data/
```

2. A glob pattern string consisting one or more asterisks (\*) sign which
represents zero or more of any characters. The glob pattern will be expanded by
MATLAB's native `ls` command, which in turn, relies upon the `ls` or `dir`
utilities that the operating system provides. For example:
```matlab
% setting the value of `matFiles` to
'exp*/data/' % searches through data under exp1, exp2 etc.  
```

3. A regular expressions pattern (regexp) string inside `'s/<pattern>/'`. If a
regexp is provided, the pattern is matched against the relative full path under
current directory. Setting options.isMatchFullPath to 0 can change this matching
mode so that the pattern is matched against each file (e.g. `'a.mat'`) and
folder names (e.g. `'exp1'`, `'data'`) instead of relative full path names (e.g.
`'./exp1/data/a.mat'`). The regexp matching is processed by MATLAB's native
`regexp` command. see `DOC REGEXP` for more information. For example:
```matlab
% setting the value of `matFiles` to
's/.*john.*\.mat/' % searches for all .mat files whose name contains `'john'`.
```

4. A list of cell strings where each elements of the cell string is a single
mat-file to be treated as the data-file to be processed. For example:
```matlab
% setting the value of `matFiles` to
{'data/a.mat', 'data/b.mat'} % processes all data files as mat-files.
```matlab


##### varList

A cell string of size 1 x n or a single string that specifies n variables or s
single variable in every data files to be processed. The string could be a
literal string specifying the variable name, a glob pattern consisting one or
more asterisks, or a regular expression. Use `'1'` to specify ALL the variables
and `'eye()'` or `'file()'` to specify the variable which has the same name with
the data file it was stored in.

Use a cell string of size m x n to respectively specify the variables to be
processed for every single data files. m should be the same with the number of
data files to be processed. For example:
```matlab
% set the value of `varList` to one of the values below

% to process variable `Trials` in all the data files
'Trials'

% to process variables `Pre` and `Post` in all the data files
{'Pre', 'Post'}

% to process fields `Pre` and `Post` of variable `data` in all the data files
{'data.Pre', 'data.Post'}

% or 'train*' to process variables `train1`, `train2` etc. in all the data files
{'train*'}

% process ALL the variables in the first mat file, and process the variable that
% shares name with the second data file
{'1'; 'eye()'}
```

##### indexList, groupVar

indexList specifies the target COLUMN(S) of the variables specified by varList
to be processed. This column(s) could also be further grouped using groupVar.
The indexed (indexList) column(s) in each variable (varList) will be grouped
based on the values of the column(s) specified by groupVar of that variable
(varList). Integers in indexList should be no greater than the column numbers of
the variables. Length of groupVar should be equal to the length of the variable
to be processed, with the same number of rows in each of them.

Both indexList and groupVar are specified using the same rules. They can be: A
single integer or an 1 x n array of integers that specifies the COLUMN indexes
of each variables in varList to be (grouped and then) processed. Use m x n array
of integers to respectively specify the COLUMNS indexes for each of the
variables. m should be equal to the number of variables in varList.

Could also be a string that satisfies one of the following cases:

1. `'T(rowIndex)'`. This first `transpose`s the variable, and then uses the
original row index as the column index for the transposed variable.

2. `'P(dimIndex, ORDER)'`. This permutes the variable using `permute(x, order)`,
and then uses dimIndex as the column index (second dimention) for the transposed
variable.

3. `'eye()'` specifies ALL the columns as target columns or all rows as a single
group. This is equivalent to '1:end' for indexList, or a single vector of all
ones with the same length of the variable(s) to be processed for groupVar.
Could be provided as the first argument to index transpose function T() and
index permutation function P().

4. `'file()'` gets the indexes from the variable that shares the same name with
the data file to be used. Could be provided as the first argument to index
transpose function T() and index permutation function P().

5. A valid MATLAB index or a string representation of it which could be
evaluated as a literal matrix or cell index (Use varList to specify a structure
indexing instead), e.g. `1:4`, `1`, '`1:end'`, `'3:6'`, `'[2 4 end-1]'`, `'{[1 2]}'` etc. Do
NOT include any brackets `()` in this string expression, which is reserved for
the special functions mentioned above. Use square brackets `[]` for grouping
parts of the expression when necessary.

6. `'indexVarName'` specifies the variable `indexVarName` in the data file whose
values are to be treated as the index array (should be one dimentional vector)
or the grouping variables (should be m x n matrix where groups are divided based
on the value of each column).

In addition, use cell strings of size m x 1 to specify respectively for each of
the m variables. For example:
```matlab
% use the following syntax for setting values for `indexList` or `groupVar`
% for all mat-files under ./data/, group Trials(:,4) based on Trials(:,[2 3])
% and then return the mean for each group (6 groups in total)
batchFilter('data', 'Trials', 4, [2 3], 'mean');

% for all mat-files under ./data/, group Trials(:,targetIndex) based on
% Trials(:,condition) and then return the mean for each group (results in 6
% groups in total)
batchFilter('data', 'Trials', 'targetIndex', 'condition', 'mean');
```

##### batchFun

A function handle or a string that specifies the processing method on the
indexed (indexList) columns of the target variables after dividing them into
groups based on groupVar. The first input and output argument of the function
should be a numeric array of any size. The function handle can be defined using
a) the function handle (`@`); b) `inline` functions; c) `function` m-files
(recommended). The string is processed by `statFun` to get several basic
statistics (e.g. `'mean'`, `'std'`). For a complete list of valid strings, see
`HELP statFun`.

If any additional input arguments are required, batchFun can be a cell of two
elements whose fist element specifies the processing method, and the contents of
second element (cell) specifies other arguments in that order. batchFun could
also be 1 x n cell with elements specified according to the rules above where
each of elements are used as a separate processing method on each of the
variables.

In addition, use cell array of size m x n to specify respectively for each of
the m variables. For example:
```matlab
% compute mean
'mean'

% compute 20% trimmed mean; see HELP TRIMMEAN
{'trimmean', {20}}

% compute mean and std seperately
{'mean', 'std'}

% compute several trimmed means seperately
{'trimmean', {'trimmean', {10}}, {'trimmean', {20}} }

% compute mean and std of the first variable, then compute trimmean and range
% for the second variable
[{'mean', 'std'}; {'trimmean', 'range'}]

% apply user defined myFun. Define using a function handle (@), inline
% functions, or a function m-file (recommended)
  @myFun
```

##### outFiles

##### options

#### OUTPUT

##### stat


--------


Author: H�rmetjan Yiltiz, 2015-05-23
UPDATED: 2015-05-23 16:18:17

Copyright 2015 by H�rmetjan Yiltiz <hyiltiz@gmail.com>
This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any lamamter version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
