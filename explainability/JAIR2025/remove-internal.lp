% Explain-with-Short-Formulas - An Implementation in Answer Set Programming
% Copyright (C) 2025 Tomi Janhunen
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.

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
