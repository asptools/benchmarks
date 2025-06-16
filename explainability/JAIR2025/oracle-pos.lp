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

simp(C) :- t(P), pcond(C,P).
simp(C) :- f(N), ncond(C,N).
simp(C) :- pcond(C,A), ncond(C,A).
:- clause(C), not simp(C), pcond(C,P), not t(P), not f(P).
:- clause(C), not simp(C), ncond(C,N), not t(N), not f(N).

% #show simp/1.
