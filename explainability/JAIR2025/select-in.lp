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

% Postprocessing optimal dominating sets

vertex(0..B-1) :- base(B).

size(S) :- S = #count{ N: in(N) }.

% For negative explanations

#const p=0.
{ newin(N): in(N) } = S-1 :- size(S), p=0.

% For positive explanations

newin(N) :- vertex(N), p=1.

% Out by default

newout(N) :- vertex(N), not newin(N).

#show newin/1.
#show newout/1.
