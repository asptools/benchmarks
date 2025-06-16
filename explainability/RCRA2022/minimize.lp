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

% Minimal satisfaction via meta programming

#include "clause.lp".

{ t(A) } :- atom(A), plit(A).
{ f(A) } :- atom(A), nlit(A).

#const k=0.

% Overall minimization

#minimize { 1,A: t(A), k=0; 1,A: f(A), k=0 }.

% Bounding from above

:- #count { 1,A: t(A); 1,A: f(A)} > k, k>0.

#show t/1.
#show f/1.
