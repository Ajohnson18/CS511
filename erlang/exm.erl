-module(exm).
-compile(export_all).
-compile(nowarn_export_all).

% %=================TURNSTILE=================

% startTurnstiles() ->
% 	C = spawn(?MODULE, counter_server, [0]),
% 	spawn(?MODULE, turnstile, [C, 50]),
% 	spawn(?MODULE, turnstile, [C, 50]).

% counter_server(State) ->
% 	receive
% 		{bump} -> 
% 			counter_server(State+1);
% 		{print_counter} ->
% 			io:format("Current value~p~n", [State]),
% 			counter_server(State)
% 	end.

% turnstile(C, N) ->
% 	case N of
% 		0 -> 
% 			ok;
% 		_ -> 
% 			C!{bump},
% 			turnstile(C, N-1)
% 	end.

% %==================CONCAT w/o SERVLETS=================

% startConcat1() ->
% 	S = spawn(?MODULE, server, []),
% 	[ spawn(?MODULE, client, [S]) || _ <- lists:seq(1,100000)].


% client(S) ->
% 	S!{start, self()},

% 		S!{add, "A", self()},
% 		S!{add, "B", self()},
% 		S!{add, "C", self()},
% 		S!{done, self()},
% 		receive
% 			{S,Str} ->
% 				Str
% 		end.


% server() ->
% 	receive
% 		{start, From} ->
% 			server_loop(From, "")
% 	end.	

% server_loop(Client, String) ->
% 	receive
% 		{add, C, Client} ->
% 			server_loop(Client, String ++ C);
% 		{done, Client} ->
% 			Client!{self(), String},
% 			server()
% 	end.



% %==================CONCAT w SERVLETS=================

% startConcat2() ->
% 	S = spawn(?MODULE, server, []),
% 	[ spawn(?MODULE, client, [S]) || _ <- lists:seq(1,100000)].


% client(S) ->
% 	S!{start, self()},
% 	receive
% 		{ok, Servlet} ->

% 		Servlet!{add, "A", self()},
% 		Servlet!{add, "B", self()},
% 		Servlet!{add, "C", self()},
% 		Servlet!{done, self()},
% 		receive
% 			{Servlet,Str} ->
% 				Str
% 		end
% 	end.

% server() ->
% 	receive
% 		{start, From} ->
% 			SERVLET = spawn(?MODULE, server_loop, [From, ""]),
% 			From!{ok,SERVLET},
% 			server()
% 	end.	

% server_loop(Client, String) ->
% 	receive
% 		{add, C, Client} ->
% 			server_loop(Client, String ++ C);
% 		{done, Client} ->
% 			Client!{self(), String}
% 	end.


%=====================GUESSING GAME===================

startGG() ->
	S = spawn(fun server/0),
		[ spawn(?MODULE, client, [S]) || _ <- lists:seq(1,200)].

server() ->
	receive
		{From,R,start} ->
			NUM = rand:uniform(10),
			SERVLET = spawn(?MODULE, servlet, [From, NUM]),
			From!{ok, R, SERVLET},
			server()
	end.

client(S) ->
	R=make_ref(),
	S!{self(), R, start},
	receive
		{ok, Servlet} ->
			client_loop(Servlet, R, rand:uniform(10))
	end.

client_loop(S, R, Offer) ->
	S!{move, Offer},
	receive
		{gotIt} ->
			io:format("Guess");
		{tryAgain} ->
			client_loop(S, R, rand:uniform(10))
	end.


servlet(Client, N) ->
	receive
		{move, N} ->
			Client!{gotIt};
		{move, _} ->
			Client!{tryAgain},
			servlet(Client, N)
	end.
