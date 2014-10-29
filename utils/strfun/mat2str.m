function string = mat2str(matrix, varargin)
%MAT2STR Convert a 2-D matrix to a string in MATLAB syntax.
%   STR = MAT2STR(MAT) converts the 2-D matrix MAT to a MATLAB
%   string so that EVAL(STR) produces the original matrix (to
%   within 15 digits of precision).  Non-scalar matrices are
%   converted to a string containing brackets [].
%
%   STR = MAT2STR(MAT,N) uses N digits of precision.
%
%   STR = MAT2STR(MAT, 'class') creates a string with the name of the class
%   of MAT included.  This option ensures that the result of evaluating STR
%   will also contain the class information.
%
%   STR = MAT2STR(MAT, N, 'class') uses N digits of precision and includes
%   the class information.
%
%   Example
%       mat2str(magic(3)) produces the string '[8 1 6; 3 5 7; 4 9 2]'.
%       a = int8(magic(3))
%       mat2str(a,'class') produces the string
%                  'int8([8 1 6; 3 5 7; 4 9 2])'.
%
%   See also NUM2STR, INT2STR, SPRINTF, CLASS, EVAL.

%   Copyright 1984-2006 The MathWorks, Inc.

narginchk(1,3);

numoptions = length(varargin);
useclass = false;
usedigits = false;
for i = 1:numoptions
    if ischar(varargin{i})
        switch lower(varargin{i})
        case 'class'
            useclass = true; 
        otherwise
            error(message('MATLAB:mat2str:InvalidOptionString', varargin{ i }));
        end
    elseif isnumeric(varargin{i})
        usedigits = true;
        n = varargin{i};
    else
        error(message('MATLAB:mat2str:InvalidOptionType'));    
    end
end

if ~ismatrix(matrix)
    error(message('MATLAB:mat2str:TwoDInput'));
end

enumerationFlag = isenumeration(matrix);

if ~(isnumeric(matrix) || ischar(matrix) || islogical(matrix) || enumerationFlag)
    error(message('MATLAB:mat2str:NumericInput'));
end

if enumerationFlag
    useclass = false;
end

[rows, cols] = size(matrix);
if usedigits == false
    n = 15;
    form = '%.15g';
else
    form = sprintf('%%.%dg',n);
end
if issparse(matrix)
    [i,j,s] = find(matrix);
    string = ['sparse(' mat2str(i) ', ' mat2str(j), ', '];
    if useclass
        string = [string mat2str(s, n, 'class')];
    else
        string = [string mat2str(s, n)];
    end
    string = [string ', ' mat2str(rows) ', ' mat2str(cols) ')'];
    return;
end
    
if useclass
    string = [class(matrix), '('];
else
    if ischar(matrix) && ~isempty(matrix)
        strings = cell(rows,1); 
        for row=1:rows
            strings{row} = matrix(row,:);
        end
        needsConcatenation = rows > 1;
        
        dangerousPattern =  '[\0\n-\r]';
        hasDangerousChars = regexp(strings, dangerousPattern, 'once');
        
        needsConcatenation = needsConcatenation | ~isempty([hasDangerousChars{:}]);
        
        strings = strrep(strings, '''', '''''');
        strings = regexprep(strings, dangerousPattern, ''' char(${sprintf(''%d'',$0)}) ''');

        if needsConcatenation
            string = '[';
        else
            string = '';
        end
        
        string = [string '''' strings{1} ''''];
        
        for row = 2:rows
            string = [string ';''' strings{row} '''']; %#ok 
        end
            
        if needsConcatenation
            string = [string ']'];
        end

        return;
    end
    string = '';
end

if isempty(matrix)
    if enumerationFlag
        string = [string class(matrix) '.empty(' int2str(rows) ',' int2str(cols) ')'];
    elseif (rows==0) && (cols==0)
        if ischar(matrix)
            string = [string ''''''];
        else
            string = [string '[]'];
        end
    else
        string = [string 'zeros(' int2str(rows) ',' int2str(cols) ')'];
    end
    if useclass
        string = [string, ')'];
    end
    return;
end

if isfloat(matrix) && ~enumerationFlag
    matrix = 0+matrix;  % Remove negative zero
end

pos = length(string)+1;
% now guess how big string will need to be
% n+7 covers (space) or +-i at the start of the string, the decimal point
% and E+-00. The +10 covers class string and parentheses.
if enumerationFlag
    spaceRequired = (2*length(class(matrix)) * numel(matrix)) + 10;    
elseif ~isreal(matrix)
    spaceRequired = (2*(n+7)) * numel(matrix) + 10;
    realFlag = false;
else
    spaceRequired = ((n+7) * numel(matrix)) + 10;
    realFlag = true;
end
string(1,spaceRequired) = char(0);

if rows*cols ~= 1
    string(pos) = '[';
    pos = pos + 1;
end

for i = 1:rows
    for j = 1:cols
        if(matrix(i,j) == Inf)
            string(pos:pos+2) = 'Inf';
            pos = pos + 3;
        elseif (matrix(i,j) == -Inf)
            string(pos:pos+3) = '-Inf';
            pos = pos + 4;
        elseif islogical(matrix(i,j))
            if matrix(i,j) % == true
                string(pos:pos+3) = 'true';
                pos = pos + 4;
            else
                string(pos:pos+4) = 'false';
                pos = pos + 5;
            end
        else
            if enumerationFlag
                tempStr = [class(matrix) '.' char(matrix(i,j))];
            elseif realFlag || isreal(matrix(i,j))
                tempStr = sprintf(form,matrix(i,j));
            else
                realStr = sprintf(form,real(matrix(i,j)));
                if(imag(matrix(i,j)) < 0)
                    imagStr = ['-',sprintf(form,abs(imag(matrix(i,j)))),'i'];
                else
                    imagStr =  ['+',sprintf(form,imag(matrix(i,j))),'i'];
                end
                tempStr = [realStr, imagStr];
            end
            len = length(tempStr);
            string(pos:pos+len-1) = tempStr;
            pos = pos+len;
        end
        string(pos) = ' ';
        pos = pos + 1;
    end
    string(pos-1) = ';';
end
% clean up the end of the string
if rows * cols ~= 1
    string(pos-1) = ']';
else
    % remove trailing space from scalars
    pos = pos - 1;
end
if useclass
    string(pos) = ')';
    pos = pos+1;
end
string = string(1:pos-1);
% end mat2str
end

function b = isenumeration(m)
    b = ~isempty(enumeration(m));
end