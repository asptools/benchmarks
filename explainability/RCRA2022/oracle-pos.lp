simp(C) :- t(P), pcond(C,P).
simp(C) :- f(N), ncond(C,N).
simp(C) :- pcond(C,A), ncond(C,A).
:- clause(C), not simp(C), pcond(C,P), not t(P), not f(P).
:- clause(C), not simp(C), ncond(C,N), not t(N), not f(N).

% #show simp/1.
