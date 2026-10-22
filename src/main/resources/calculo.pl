% Derivada de una constante
d(Var, Func, 0) :-
 atomic(Var), number(Func).

% Derivada de una variable con respecto a si misma
d(Var, Func, 1) :-
 Var == Func.

% Derivada de una variable por una constante
d(Var, N*Var, N) :-
 atomic(Var), number(N).

% Derivada de una variable elevada a la N
d(Var, Var^N, N*Var^Nm1) :-
 number(N), is(Nm1, N - 1).

% Derivada de una variable elevada a la N por una constante
d(Var, K*Var^N, C*Var^Nm1) :-
 atomic(Var), number(K), number(N), is(C, K*N), is(Nm1, N-1).

% Derivada de un logaritmo natural
d(Var, log(Var), 1/Var) :-
 atomic(Var).

% Derivada de una suma
d(Var, A+B, RA+RB) :-
 d(Var, A, RA), d(Var, B, RB).

% Derivada de una resta
d(Var, A-B, RA-RB) :-
 d(Var, A, RA), d(Var, B, RB).

% Integral de una constante
s(Var, K, K*Var) :-
 number(K), atomic(Var).

% Integral de una variable con respecto a si misma
s(Var, Var, 1/2*Var^2) :-
 atomic(Var).

%% Integral de una constante por una variable elevada a la N
s(Var, K*Var^N, K/M*Var^M) :-
 atomic(Var), number(K), number(N), is(M, N+1).

% Integral de una suma
s(Var, A+B, RA+RB) :-
 s(Var, A, RA), s(Var, B, RB).

% Integral de una resta
s(Var, A-B, RA-RB) :-
 s(Var, A, RA), s(Var, B, RB).

% ------------------------------------------------------------------
% Simplificacion de terminos semejantes
% ------------------------------------------------------------------

% Simplifica los subterminos y luego reduce; repite hasta punto fijo
simplificar(E, S) :-
 compound(E),
 E =.. [Op, A, B],
 !,
 simplificar(A, SA),
 simplificar(B, SB),
 T =.. [Op, SA, SB],
 ( reducir(T, R) -> simplificar(R, S) ; S = T ).
simplificar(E, E).

% Operaciones entre numeros
reducir(A+B, C) :- number(A), number(B), is(C, A+B).
reducir(A-B, C) :- number(A), number(B), is(C, A-B).
reducir(A*B, C) :- number(A), number(B), is(C, A*B).
reducir(A/B, C) :- number(A), number(B), B =\= 0, 0 is A mod B, is(C, A // B).

% Identidades neutras
reducir(X+0, X).
reducir(0+X, X).
reducir(X-0, X).
reducir(X*1, X).
reducir(1*X, X).
reducir(X*0, 0).
reducir(0*X, 0).
reducir(X^1, X).
reducir(X^0, 1).

% Terminos semejantes: 5*x + x = 6*x, etc.
reducir(C1*X + C2*X, C*X) :- number(C1), number(C2), is(C, C1+C2).
reducir(C1*X - C2*X, C*X) :- number(C1), number(C2), is(C, C1-C2).
reducir(C1*X + X, C*X) :- number(C1), \+ number(X), is(C, C1+1).
reducir(X + C2*X, C*X) :- number(C2), \+ number(X), is(C, C2+1).
reducir(C1*X - X, C*X) :- number(C1), \+ number(X), is(C, C1-1).
reducir(X - C2*X, C*X) :- number(C2), \+ number(X), is(C, 1-C2).
reducir(X + X, 2*X) :- \+ number(X).
reducir(X - X, 0).