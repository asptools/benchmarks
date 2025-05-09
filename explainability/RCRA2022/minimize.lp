% Minimal satisfaction via meta programming

#include "clause.lp".

{ t(A) } :- atom(A), plit(A).
{ f(A) } :- atom(A), nlit(A).

#const k=0.

% Overall minimization

#minimize { 1,A: t(A), k=0; 1,A: f(A), k=0 }.

% Bounding from above

:- #count { 1,A: t(A); 1,A: f(A)} > k, k>0.

#show t/1.
#show f/1.
