% test scripts for the bunch of functions

disp('testing lib/selectIndexed()');
s = load('data/angelo.mat');
s.file__Name__ = 'angelo.mat';
testIndexes = {
  1,...
  [1 2],...
  [3 4],...
  '1:end',...
  'eye()',...
  'file()',...
  'T(3)',...
  'T([3 4])',...
  'T(1:end)',...
  'P(5, [2 1])',...
  'T(eye())',...
  'T(P(3, [2 1]))',...
  {1,...
  [1 2],...
  '1:end',...
  'eye()',...
  }
  };

results = {};
status = {};
for i=1:numel(testIndexes)
  [results{i} status{i}] = selectIndexed(testIndexes{i}, s.Trial, s)
end

testIndexes = { % these should fail
  'eye(T(3))',...
  'T(3)eye()',...
};

results = {};
status = {};
nFails = 0;
for i=1:numel(testIndexes)
  try
  [results{i} status{i}] = selectIndexed(testIndexes{i}, s.Trial, s)
catch
  nFails = nFails + 1;
end
end

if nFails ~= numel(testIndexes)
  error('Fail tests succeeded!');
end


%% 

disp('testing lib/selectIndexed()');
s = load('data/lisiyu/lisiyu_behav_Pretest.mat');
s.file__Name__ = 'lisiyu_behav_Pretest.mat';
testIndexes = {
  'ResultArray',...
  'result',...
  'result*',...
  'result_*'...
  '*press',...
  's/^result..$/',...
  's/[Rr]esult.*/',...
  '*res*',...
  'ResultStruct',...
  'ResultStruct.result_1',...
  'eye()',...
  'file()',...
  '1',...
  {'result*'},...
  {'leftdire', 'rightdire'},...
  {'ResultStruct.result_1', 'ResultStruct.result_2'},...
  {'1';...
  'eye()'},...
  };

results = {};
result2 = {};
status = {};
for i=1:numel(testIndexes)
  [results{i} results2{i} status{i}] = selectFields(testIndexes{i}, s, 0)
end

testIndexes = { % these should fail
  ... % false syntax
  'eye(hello)',...
  'eye(1)',...
  'T()',...
  'P()',...
  'T(1)',...
  'P([2 1])',...
  'eye(T(3))',...
  'T(3)eye()',...
  ...% buggy syntax
  's/[Rr]esult.*',...
  ...  % feature un-implemented
  'ResultStruct.result_*',...
  };

results = {};
status = {};
result2 = {};
nFails = 0;
for i=1:numel(testIndexes)
  try
  [results{i} results2{i} status{i}] = selectFields(testIndexes{i}, s, 0)
catch
  nFails = nFails + 1;
end
end

if nFails ~= numel(testIndexes)
  error('Fail tests succeeded!');
end
