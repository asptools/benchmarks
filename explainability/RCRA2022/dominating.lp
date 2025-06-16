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

% The dominating set problem for Satgrnd
% (c) 2022-2025 Tomi Janhunen
%
% USAGE:
% planar 100 $RANDOM \
% | gringo --output smodels - dominating.lp | lpstrip | satgrnd | clasp

% Infer undirected edges from the arcs produced by planar

edge(X,Y) :- arc(X,Y), X <= Y.
edge(Y,X) :- arc(X,Y), Y > X.

% Choose vertices based on edges

in(X) | in(Y): edge(X,Y) | in(Z): edge(Z,X) :- vertex(X).

% The part below is only for clasp in ASP mode

#const k=0.
:- k < #count{ 1,X: in(X) }, k>0. % By default inactive (use -ck=... to set)

#const m=0.
#minimize{ 1,X: in(X), m>0 }. % By default inactive (use -cm=... to set)

#show in/1.
% #show edge/2. % Uncomment for checking the input graph
