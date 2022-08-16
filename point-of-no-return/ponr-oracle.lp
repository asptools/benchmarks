% Point of no return: Encoding for stable-unstable semantics
% (c) 2022 Tomi Janhunen

% Oracle program (not supposed to have a stable model)

% Input
{ path(X,Y) } :- arc(X,Y), not start(Y).
{ ponr(X) } :- node(X), not start(X).
#show path/2.
#show ponr/1.

% Choose return path
{ return(X,Y): arc(X,Y), not start(X) } = 1 :- reach(Y).
:- return(X,Y), path(X,Y).

% Check that the start node can be reached
reach(X) :- start(X).
reach(X) :- return(X,Y), not ponr(X).
:- ponr(X), not return(X,Y): arc(X,Y).

% Check satisfiability along both paths
{ true(A) } :- atom(A).
true(n(A)) :- negative(n(A)), not true(A).
:- arc(X,Y), path(X,Y), not true(L): lit(X,Y,L).
:- arc(X,Y), return(X,Y), not true(L): lit(X,Y,L).
