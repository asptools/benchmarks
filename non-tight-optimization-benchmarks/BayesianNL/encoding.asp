% Rescale score values and select variables

% #const d=1000.    % d=1000 yields orginal scores truncated to integers

% penalty(X,S,-Y/d) :- score(X,S,Y).
penalty(X,S,-Y/1000) :- score(X,S,Y).
in_parent_set(X,S,Y) :- cond_parent(X,S,Y).

% Other domains of interest

pot_pset(X,S) :- penalty(X,S,Y).
pot_parent(X,Y) :- in_parent_set(X,S,Y).

% Order penalties for each node

% minpen(M,X) :- M = #min { P: penalty(X,_,P) }, node(X).
% nextpen(P,M,X) :- penalty(X,_,P), penalty(X,_,M),
%                   M = #min { P2: P<P2, penalty(X,_,P2) }.
minpen(M,X) :- M = #min { P: penalty(X,S,P) }, node(X).
nextpen(P,M,X) :- penalty(X,S1,P), penalty(X,S,M),
                  M = #min { P2: P<P2, penalty(X,S2,P2) }.

% Choose the parent set for each node

% #count { S: pset(X,S): pot_pset(X,S) } = 1 :- node(X).
{ pset(X,S): pot_pset(X,S) } = 1 :- node(X).

% Derive parent relationships from selected parent sets

parent(X,Y) :- in_parent_set(X,S,Y), pset(X,S).

% Enforce DAG structure (adopted from the KR'14 paper; leaf non-tight)

ord(X)            :- node(X), pot_parent(X,Y).
ord_init(X,Y1)    :- ord(X), Y1 = #min { Y: pot_parent(X,Y) }.
ord_last(X,Y2)    :- ord(X), Y2 = #max { Y: pot_parent(X,Y) }.
ord_next(X,Y1,Y2) :- ord(X), pot_parent(X,Y1), not ord_last(X,Y1),
                     Y2 = #min { Y: Y1<Y, pot_parent(X,Y) }.

order(X,Y) :- pot_parent(X,Y), not parent(X,Y).
order(X,Y) :- pot_parent(X,Y), order(Y).
% order(X) :- node(X), order(X,Y): pot_parent(X,Y).
order(X) :- ord_last(X,Y), chain(X,Y).
order(X) :- node(X), not ord(X).

chain(X,Y1) :- ord_init(X,Y1), order(X,Y1).
chain(X,Y2) :- ord_next(X,Y1,Y2), chain(X,Y1), order(X,Y2).

:- node(X), not order(X).

% Score calculation

diffpen(P,X) :- pset(X,S), penalty(X,S,P), not minpen(P,X).
diffpen(P1,X) :- diffpen(P2,X), nextpen(P1,P2,X), not minpen(P1,X).

% #minimize { P,P,X: minpen(P,X);
%             P2-P1,P2,X: diffpen(P2,X), nextpen(P1,P2,X) }.
:~ minpen(P,X). [P,X]
:~ diffpen(P2,X), nextpen(P1,P2,X). [P2-P1,P2,X]

% #show pset/2.
