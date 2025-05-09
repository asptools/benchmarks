% Extract atoms and clauses from a reified DIMACS instance

atom(P) :- pcond(C,P).
atom(N) :- ncond(C,N).
clause(C) :- rule(C,clause).

