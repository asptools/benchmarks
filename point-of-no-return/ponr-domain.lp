% Point of no return: Encoding for stable-unstable semantics
% (c) 2022 Tomi Janhunen

% Domain declarations

% Identify atoms and literals
literal(L) :- lit(_,_,L).  negative(n(A)) :- literal(n(A)).
atom(L) :- literal(L), not negative(L).

% Determine arcs, nodes, and the start node
arc(X,Y) :- lit(X,Y,_).
node(X) :- arc(X,_).  node(Y) :- arc(_,Y).
start(N) :- node(N), N2 >= N: node(N2).
