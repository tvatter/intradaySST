function d = base2dec(h,b)
%BASE2DEC Convert base B string to decimal integer.
%   BASE2DEC(S,B) converts the string number S of base B into its 
%   decimal (base 10) equivalent.  B must be an integer
%   between 2 and 36. S must represent a non-negative integer value.
%
%   If S is a character array, each row is interpreted as a base B string.
%
%   Example
%      base2dec('212',3) returns 23
%
%   See also DEC2BASE, HEX2DEC, BIN2DEC.

%   Copyright 1984-2009 The MathWorks, Inc.

%   Douglas M. Schwarz, 18 February 1996

narginchk(2,2);
if (b < 1 || b > 36 || floor(b) ~= b)
    error(message('MATLAB:base2dec:InvalidBase'));
end
%If the input cannot be converted to char, base2dec cannot do anything with
%it.
h = char(h);
if isempty(h), d = []; return, end

if ~isempty(find(h==' ' | h==0,1)), 
  h = strjust(h);
  h(h==' ' | h==0) = '0';
end
%We should accept numbers like 12abf in base 16
h = upper(h);

[m,n] = size(h);
bArr = [ones(m,1) cumprod(b(ones(m,n-1)),2)];
values = -1*ones(256,1);
values(double('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ')) = 0:35;
if any(any(values(h) >= b | values(h) < 0))
    error(message('MATLAB:base2dec:NumberOutsideRange', h,b));
end
a = fliplr(reshape(values(abs(h)),size(h)));
d = sum((bArr .* a),2);
