#include "clause.lp".

% Specify input atoms

{ t(A) } :- plit(A).
{ f(A) } :- nlit(A).

% Check the two-valued model property

et(A) :- t(A).
{ et(A) } :- not t(A), not f(A), atom(A).
:- clause(C), not et(P): pcond(C,P); et(N): ncond(C,N).

% Show the input atoms only

#show t/1.
#show f/1.
