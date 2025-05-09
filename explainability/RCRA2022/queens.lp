% The n-queens problem for Satgrnd
% (c) 2022-2025 Tomi Janhunen
%
% USAGE: gringo -cn=<number of queens> --output smodels queens.lp \
%        | lpstrip | satgrnd | clasp <number of solutions>

% The number of queens and the pairs and triples of coordinate values
#const n=8.

pair(X1,X2) :- X1=1..n, X2=X1+1..n.
triple(X1,X2,Y1) :- pair(X1,X2), Y1=1..n-(X2-X1).

% Choose positions

queen(X,Y): Y=1..n :- X=1..n.

% Constraints to prevent queens from threatening each other

-queen(X,Y1) | -queen(X,Y2) :- X=1..n, pair(Y1,Y2).
-queen(X1,Y) | -queen(X2,Y) :- pair(X1,X2), Y=1..n.
% Based on Y2=Y1+X2-X1 <=> X1+Y2 = X2+Y1 without absolute difference!
-queen(X1,Y1+X2-X1) | -queen(X2,Y1) :- triple(X1,X2,Y1).
-queen(X1,Y1) | -queen(X2,Y1+X2-X1) :- triple(X1,X2,Y1).

#show queen/2.
#show -queen/2.

