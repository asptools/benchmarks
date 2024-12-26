% Find a Markov network with optimal structure

% Copyright (C) 2015 Martin Gebser, Tomi Janhunen

% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.

% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.

% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.

% This encoding belongs to the software package published on 
% http://research.ics.aalto.fi/software/asp/ and related to the paper
% Janhunen, T., Gebser, M., Rintanen, J., H. Nyman, J. Pensar, J. Corander:
% 'Learning Discrete Decomposable Graphical Models via Constraint Optimization'
% Statistics and Computing, online access, 11 Nov 2015.
% DOI: 10.1007/s11222-015-9611-4

% List of changes:
%
% asp-core-2 version adopted by Tomi Janhunen, March 2017

% Domains

pair(C,X) :- penalty(C,X,P).
clique(C) :- pair(C,X).
var(X) :- pair(C,X).
triple(X,C,Y) :- var(X), pair(C,Y), Y!=X, member(X,C).

nvar(N) :- N = #count{ X: var(X) }.
cliquesize(C,S) :- clique(C), S = #count{ X: member(X,C) }.

cex(C1,C2) :- member(X,C1), clique(C2), not member(X,C2).
subeq(C1,C2) :- clique(C1), clique(C2), not cex(C1,C2).

rest(C1,X,C2) :- member(X,C1), subeq(C2,C1),
                 cliquesize(C1,S), cliquesize(C2,S-1), S>1.

% Define penalty scale per variable

minpen(M,X) :- M = #min{ P: penalty(C,X,P) }, var(X).
nextpen(P,M,X) :-  penalty(C,X,P), penalty(C1,X,M),
                   M = #min{ P2: P<P2, penalty(C2,X,P2) }.

% Choose context for each variable

{ in(C,X): pair(C,X) } = 1 :- var(X).

:- #count{ X: in(C,X), pair(C,X) } > 2, clique(C).

% Chordality via variable deletion (via the order determined by contexts)

less(X,C,Y1,C,Y2)   :- triple(X,C,Y1), triple(X,C,Y2), Y1<Y2.
less(X,C1,Y1,C2,Y2) :- triple(X,C1,Y1), triple(X,C2,Y2), C1<C2.

diff(X,C1,Y1,C2,Y2) :- less(X,C1,Y1,C,Y), less(X,C,Y,C2,Y2).
next(X,C1,Y1,C2,Y2) :- less(X,C1,Y1,C2,Y2), not diff(X,C1,Y1,C2,Y2).

pred(X,C1,Y1) :- next(X,C1,Y1,C2,Y2).
succ(X,C2,Y2) :- next(X,C1,Y1,C2,Y2).

oktr(X,C1,Y1) :- triple(X,C1,Y1), okin(C1,Y1), not succ(X,C1,Y1).
oktr(X,C2,Y2) :- next(X,C1,Y1,C2,Y2), oktr(X,C1,Y1), okin(C2,Y2).

ok(X) :- var(X), #count{ 1: triple(X,C,Y) } = 0.
ok(X) :- oktr(X,C,Y), not pred(X,C,Y).

okin(C,X) :- in(C,X), ok(X), pair(C,X).
okin(C,X) :- not in(C,X), pair(C,X).

:- var(X), not ok(X).

% Check that all edges in contexts are created by the choices made

aux(R,Y) :- in(R,Y), not cliquesize(R,1).
aux(R,Y) :- aux(C,Y), rest(C,Z,R), not cliquesize(R,1).

:- in(C,X), rest(C,X,R), not cliquesize(R,1),
   #count{ Y: aux(R,Y), member(Y,R)} = 0.

% Score calculation

diffpen(P,X) :- in(C,X), penalty(C,X,P), not minpen(P,X).
diffpen(P1,X) :- diffpen(P2,X), nextpen(P1,P2,X), not minpen(P1,X).

:~ minpen(P,X). [P,X]
:~ diffpen(P2,X), nextpen(P1,P2,X). [P2-P1,P2,X]

#show in/2.
