%Alex Johnson
% I pledge my honor that I have abided by the Stevens Honor System.

-module(lea).
-compile(export_all).


node(MyNumber) ->
    receive
	{Outp} ->
	    ok
    end,
    Outp ! {one,MyNumber},
    node_loop(Outp,MyNumber).

node_loop(Outp, MyNumber)->
    receive
        {one,N} when N==MyNumber ->
          Outp!{winner, MyNumber};
        {one,N} when N>MyNumber ->
          Outp!{N},
          node_loop(N, MyNumber);
        {one,_N} ->
          io:format("LEA: LOST: ~p~n", [MyNumber]),
          % Outp!{one, MyNumber};
          node_loop(Outp, MyNumber);
        {winner,N} ->
          io:format("LEA: LEADER: ~p~n", [MyNumber])
    end.


next(I,N) ->
    J = I+1,
    if 
	J==N+1 -> 1;
	true -> J
    end.


new_rand(L,Max) ->
    N = rand:uniform(Max),    
    case lists:member(N,L) of
	true  ->
	    new_rand(L,Max);
	false ->
	    [ N | L]
    end.

rand_list(N,L) when length(L)==N ->
    L;
rand_list(N,L) ->
    rand_list(N,new_rand(L,10000)).


start(N) ->
    L = [ spawn(?MODULE,node,[Id]) || Id <- rand_list(N,[])],
    [ Pid!{lists:nth(next(I,N),L)}  ||  {Pid,I} <- lists:zip(L,lists:seq(1,N))],
    ok.

