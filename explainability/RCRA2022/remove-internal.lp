% Domains

atom(P) :- pcond(_,P).
atom(N) :- ncond(_,N).
internal(_int(Id)) :- atom(_int(Id)).
clause(C) :- rule(C,clause).
unit(C) :- #count{ 1,P: pcond(C,P); 1,N: ncond(C,N) } = 1, clause(C).
iclause(C) :- clause(C), internal(P): pcond(C,P); internal(N): ncond(C,N).

% Truth values for propagation

tint(A) :- internal(A), pcond(C,A), unit(C).
fint(A) :- internal(A), ncond(C,A), unit(C).

error(A) :- internal(A), not tint(A), not fint(A).
error(_clause(C)) :- iclause(C), not unit(C).

% Copy non-internal clauses and their non-internal literals

newrule(C,clause) :- rule(C,clause), not iclause(C),
                     not tint(P): pcond(C,P), internal(P);
                     not fint(N): ncond(C,N), internal(N).

newpcond(C,P) :- pcond(C,P), newrule(C,clause), not fint(P).
newncond(C,N) :- ncond(C,N), newrule(C,clause), not tint(N).

newplit(P) :- plit(P).
newnlit(N) :- nlit(N).

#show newrule/2.
#show newpcond/2.
#show newncond/2.
#show newplit/1.
#show newnlit/1.
#show error/1.
