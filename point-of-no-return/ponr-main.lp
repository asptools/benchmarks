% Point of no return: Encoding for stable-unstable semantics
% (c) 2022 Tomi Janhunen

% Main program

% Choose path and the point of no return
{ path(X,Y): arc(X,Y), not start(Y) } = 1 :- start(X).
{ path(X,Y): arc(X,Y), not start(Y) } <= 1 :- reach(X).

% The point of no return is the final node reached
reach(Y) :- path(X,Y).
ponr(X) :- reach(X), not path(X,Y): arc(X,Y).
:- not ponr(X): node(X).

% Check satisfiability along the chosen path
{ true(A) } :- atom(A).
true(n(A)) :- negative(n(A)), not true(A).
:- arc(X,Y), path(X,Y), not true(L): lit(X,Y,L).

% Filter
#show path/2.
#show ponr/1.
#show true/1.
