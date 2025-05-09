% Postprocessing optimal dominating sets

vertex(0..B-1) :- base(B).

size(S) :- S = #count{ N: in(N) }.

% For negative explanations

#const p=0.
{ newin(N): in(N) } = S-1 :- size(S), p=0.

% For positive explanations

newin(N) :- vertex(N), p=1.

% Out by default

newout(N) :- vertex(N), not newin(N).

#show newin/1.
#show newout/1.
