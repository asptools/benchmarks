% Postprocessing a solution to the n-queens problem

% For negative explanations, misplace one queen

{ newcol(X): X=1..n } = 1.
{ newrow(Y): Y=1..n } = 1.
:- queen(X,Y), newcol(X), newrow(Y).

#const p=0.
newqueen(X,Y) :- newcol(X), newrow(Y), p=0.
newqueen(X,Y) :- queen(X,Y), not newcol(X), p=0.
noqueen(X,Y) :- not queen(X,Y), not newcol(X), X=1..n, Y=1..n, p=0.
noqueen(X,Y) :- newcol(X), not newrow(Y), Y=1..n, p=0.

% For positive explanations, just copy the assignment

newqueen(X,Y) :- queen(X,Y), p=1.
noqueen(X,Y) :- not queen(X,Y), X=1..n, Y=1..n, p=1.

#show newqueen/2.
#show noqueen/2.
