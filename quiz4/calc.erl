%% Alex Johnson
%% I pledge my honor that I have abided by the Stevens Honor System.

-module(calc).
-compile(export_all).

ex() ->
	{add, {const, 3}, {divi, {const, 8}, {const, 2}}}.

const(Int) ->
	{const, Int}.

expression() ->
	{mode, {expr}, {expr}}.

lookup(Env, Key) ->
	case maps:find(Key, Env) of
		{Var, Value} -> Value;
		_ -> error
	end.

pullVal({const, V}) ->
	V.

calc({const, N}, Env) ->
	{val, N};
calc({var, Var}, Env) ->
	{maps:put(var, Var, Env)};
calc({add, expr1, expr2}, Env) ->
	{val, (pullVal(calc(expr1, Env)) + pullVal(calc(expr2, Env)))};
calc({sub,expr1, expr2}, Env) ->
	{val, (pullVal(calc(expr1, Env)) - pullVal(calc(expr2, Env)))};
calc({mul, expr1, expr2}, Env) ->
	{val, (pullVal(calc(expr1, Env)) * pullVal(calc(expr2, Env)))};
calc({divi, expr1, expr2}, Env) ->
	{val, (pullVal(calc(expr1, Env)) / pullVal(calc(expr2, Env)))}.
