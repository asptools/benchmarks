% The dominating set problem for Satgrnd
% (c) 2022-2025 Tomi Janhunen
%
% USAGE:
% planar 100 $RANDOM \
% | gringo --output smodels - dominating.lp | lpstrip | satgrnd | clasp

% Infer undirected edges from the arcs produced by planar

edge(X,Y) :- arc(X,Y), X <= Y.
edge(Y,X) :- arc(X,Y), Y > X.

% Choose vertices based on edges

in(X) | in(Y): edge(X,Y) | in(Z): edge(Z,X) :- vertex(X).

% The part below is only for clasp in ASP mode

#const k=0.
:- k < #count{ 1,X: in(X) }, k>0. % By default inactive (use -ck=... to set)

#const m=0.
#minimize{ 1,X: in(X), m>0 }. % By default inactive (use -cm=... to set)

#show in/1.
% #show edge/2. % Uncomment for checking the input graph
