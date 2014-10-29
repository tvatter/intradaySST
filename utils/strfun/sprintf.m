%SPRINTF Write formatted data to string.
%   STR = SPRINTF(FORMAT, A, ...) applies the FORMAT to all elements of
%   array A and any additional array arguments in column order, and returns
%   the results to string STR.
%
%   [STR, ERRMSG] = SPRINTF(FORMAT, A, ...) returns an error message when
%   the operation is unsuccessful.  Otherwise, ERRMSG is empty.
%
%   SPRINTF is the same as FPRINTF except that it returns the data in a 
%   MATLAB string rather than writing to a file.
%
%   FORMAT is a string that describes the format of the output fields, and
%   can include combinations of the following:
%
%      * Conversion specifications, which include a % character, a
%        conversion character (such as d, i, o, u, x, f, e, g, c, or s),
%        and optional flags, width, and precision fields.  For more
%        details, type "doc sprintf" at the command prompt.
%
%      * Literal text to print.
%
%      * Escape characters, including:
%            \b     Backspace            ''   Single quotation mark
%            \f     Form feed            %%   Percent character
%            \n     New line             \\   Backslash
%            \r     Carriage return      \xN  Hexadecimal number N
%            \t     Horizontal tab       \N   Octal number N%
%        where \n is a line termination character on all platforms.
%
%   Notes:
%
%   If you apply an integer or string conversion to a numeric value that
%   contains a fraction, MATLAB overrides the specified conversion, and
%   uses %e.
%
%   Numeric conversions print only the real component of complex numbers.
%
%   Examples
%      sprintf('%0.5g',(1+sqrt(5))/2)       % 1.618
%      sprintf('%0.5g',1/eps)               % 4.5036e+15       
%      sprintf('%15.5f',1/eps)              % 4503599627370496.00000
%      sprintf('%d',round(pi))              % 3
%      sprintf('%s','hello')                % hello
%      sprintf('The array is %dx%d.',2,3)   % The array is 2x3.
%
%   See also FPRINTF, SSCANF, NUM2STR, INT2STR, CHAR.

%   Copyright 1984-2010 The MathWorks, Inc.
%   Built-in function.

