-module(sem).
-compile(export_all).

semaphore(0) ->
	receive
		{release} ->
			semaphore(1)
	end;
semaphore(N) when N>0 ->
	receive
		{release} ->
			semaphore(N+1);
		{acquire, From, Ref} ->
			From!{self(),Ref,ok},
			semaphore(N-1)
	end.

start(Permits) ->
	S = spawn(?MODULE,semaphore,[Permits]),
	spawn(?MODULE,client1,[S]),
	spawn(?MODULE,client2,[S]).

acquire(Sem) ->
	R=make_ref(),
	Sem!{acquire,self(),R},
	receive
		{Sem,R,ok} ->
			ok
	end.

release(Sem) ->
	Sem!{release}.

client1(Sem) ->
	io:format("A~n"),
	io:format("B~n"),
	release(Sem).

client2(Sem) ->
	acquire(Sem),
	io:format("C~n"),
	io:format("D~n").

client3(Sem) ->
	acquire(Sem),
	io:format("C~n"),
	io:format("D~n"),
	release(Sem).
