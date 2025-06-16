% Explain-Tabular-Data-Globally - An Implementation in Answer Set Programming
% Copyright (C) 2025 Masood Feyzbakhsh Rankooh and Tomi Janhunen
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

% EXPLANATIONS for Boolean data sets
%
% (c) 2023 Masood Feyzbakhsh Rankooh and Tomi Janhunen
%
% Main program for selecting an explanation and measuring relative error

#const l=10.
node(1..l).
root(l).

op(neg).
op(and).
op(or).

% Choose the actual length
{used(1)}.
used(N+1) :- used(N), node(N+1).
{used(N+1)} :- not used(N), node(N), node(N+1).
used(N) :- root(N).

%  choose the leaves and inner nodes of the parse tree
{leaf(N)} :- used(N).
inner(N) :- used(N), not leaf(N).
{ op(N,O): op(O) } = 1 :- inner(N).

%  set the stack size for the leftmost node to zero
count(N,0) :- used(N), not used(N-1).

%  increase the stack size after a push
count(N+1,K+1) :- leaf(N), count(N,K), node(N), K>=0, K<=2.

%  push a leaf on top of the stack
stack(N+1,K+1,N) :- leaf(N), count(N,K), node(N), K>=0, K<=2.
stack(N+1,I,M) :- leaf(N), count(N,K), node(N), I>=0, I<=K, stack(N,I,M).

%  stack cannot have a size greater than 3 
:- leaf(N), count(N,3), node(N).

%  stack size must be at least 2 when encountering and/or, and 1 when encountering neg
:- count(N,0), inner(N).
:- count(N,1), node(N), op(N,O), O!=neg.

% compute stack members when encountering neg
count(N+1,K) :- count(N,K), node(N), op(N,neg).
stack(N+1,K,N) :- op(N,neg), count(N,K), node(N), K>0, K<=3.
stack(N+1,I,M) :- op(N,neg), count(N,K), node(N), I>0, I<K, stack(N,I,M).

% compute stack members when encountering and/or
count(N+1,K-1) :- count(N,K), node(N), op(N,O), O!=neg.
stack(N+1,K-1,N) :- op(N,O), O!=neg, count(N,K), node(N), K>=2, K<=3.
stack(N+1,1,M) :- op(N,O), O!=neg, count(N,3), node(N), stack(N,1,M).

% size of the stack must be 1 at the end
:- not count(l+1,1).

% identifying the target
attr(A) :- val(D,A,B).
idx(I) :- attr(a(I)).
idx(I) :- attr(a(I,V)).
maxidx(M) :- M = #max{ I: idx(I) }.
maxattr(a(I)) :- maxidx(I), attr(a(I)).
maxattr(a(I,M)) :- maxidx(I), attr(a(I,_)), M = #max{ V: attr(a(I,V)) }. 
expl(A) :- maxattr(A).
exclude(a(A,V2)) :- attr(a(A,V2)), expl(a(A,V)), V!=V2.

% choosingt attributes for leaves
{ lat(N,A): attr(A) } = 1 :- leaf(N).
:- leaf(N), lat(N,A), maxattr(A).
:- leaf(N), lat(N,A), expl(A).
:- leaf(N), lat(N,A), exclude(A).

% identify the data points
data(D) :- val(D,A,B).

% guess the value for all innernodes
{guess(D,N)} :- data(D), used(N), inner(N).

% identify the value of the leaves
guess(D,N) :- data(D), lat(N,A), val(D,A,1).

% constrain the value of neg nodes
:- op(N,neg), guess(D,N), guess(D,N-1), data(D).
:- op(N,neg), not guess(D,N), not guess(D,N-1), data(D).

% constrain the value of and/or nodes.
% Note: the top of the stack is always node N-1
:- data(D), op(N,or), count(N,I), stack(N,I-1,N3), guess(D,N), not guess(D,N-1), not guess(D,N3).
:- data(D), op(N,or), not guess(D,N), guess(D,N-1).
:- data(D), op(N,or), count(N,I), stack(N,I-1,N2), not guess(D,N), guess(D,N2).
:- data(D), op(N,and), guess(D,N), not guess(D,N-1).
:- data(D), op(N,and), guess(D,N), count(N,I), not guess(D,N2), stack(N,I-1,N2).
:- data(D), op(N,and), count(N,I), stack(N,I-1,N3), not guess(D,N), guess(D,N-1), guess(D,N3).

% compute error
error(D) :- data(D), val(D,A,0), expl(A), guess(D,N), root(N).
error(D) :- data(D), val(D,A,1), expl(A), not guess(D,N), root(N).

#minimize { 1@1,D: error(D);
            1@0,N: used(N), node(N) }.

#show expl/1.
#show op/2.
#show lat/2.
