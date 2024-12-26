% Select edges for the cycle
1 { cycle(X,Y) : edge(X,Y); cycle(X,Y) : edge(Y,X) } 1 :- vtx(X).
1 { cycle(X,Y) : edge(X,Y); cycle(X,Y) : edge(Y,X) } 1 :- vtx(Y).

reached(X) :- bound(X).
reached(Y) :- reached(X), cycle(X,Y).

:- vtx(X), not reached(X).

cost(X,Y,C) :- edgewt(X,Y,C).
cost(X,Y,C) :- edgewt(Y,X,C), { edgewt(X,Y,D) : edgewt(X,Y,D) } 0.

% Weight constraint on the Hamiltonian cycle
:- W+1 { cycle(X,Y) : cost(X,Y,C) }, maxweight(W).

% Symmetry breaking: Reach "smaller" neighbor from starting node
% (assumes symmetric costs for both directions of an edge!)
:- bound(X), cycle(Y,X), cycle(X,Z), Y < Z.

#minimize { W,X,Y : cycle(X,Y), cost(X,Y,W)}.

#show cycle/2.