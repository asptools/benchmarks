% Explain-with-Short-Formulas - An Implementation in Answer Set Programming
% Copyright (C) 2025 Tomi Janhunen
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.

% Postprocessing a solution to the n-queens problem

% For negative explanations, misplace one queen

{ newcol(X): X=1..n } = 1.
{ newrow(Y): Y=1..n } = 1.
:- queen(X,Y), newcol(X), newrow(Y).

#const p=0.
newqueen(X,Y) :- newcol(X), newrow(Y), p=0.
newqueen(X,Y) :- queen(X,Y), not newcol(X), p=0.
noqueen(X,Y) :- not queen(X,Y), not newcol(X), X=1..n, Y=1..n, p=0.
noqueen(X,Y) :- newcol(X), not newrow(Y), Y=1..n, p=0.

% For positive explanations, just copy the assignment

newqueen(X,Y) :- queen(X,Y), p=1.
noqueen(X,Y) :- not queen(X,Y), X=1..n, Y=1..n, p=1.

#show newqueen/2.
#show noqueen/2.
