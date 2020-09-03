-module(es).
-compile(export_all).

echo() ->
	receive
		{From, Msg} ->
			From !{Msg},
			echo();
		stop ->
			stop
	end.

fact(0) ->
	1;
fact(N) when N>0 ->
	N * fact(N-1).

fs() ->
	receive
		{From, N} ->
			From !fact(N),
			fs();
		stop -> stop
	end.