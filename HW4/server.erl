%Alex Johnson
% I pledge my honor that I have abided by the Stevens Honor System.

-module(server).

-export([start_server/0]).

-include_lib("./defs.hrl").

-spec start_server() -> _.
-spec loop(_State) -> _.
-spec do_join(_ChatName, _ClientPID, _Ref, _State) -> _.
-spec do_leave(_ChatName, _ClientPID, _Ref, _State) -> _.
-spec do_new_nick(_State, _Ref, _ClientPID, _NewNick) -> _.
-spec do_client_quit(_State, _Ref, _ClientPID) -> _NewState.

start_server() ->
    catch(unregister(server)),
    register(server, self()),
    case whereis(testsuite) of
	undefined -> ok;
	TestSuitePID -> TestSuitePID!{server_up, self()}
    end,
    loop(
      #serv_st{
	 nicks = maps:new(), %% nickname map. client_pid => "nickname"
	 registrations = maps:new(), %% registration map. "chat_name" => [client_pids]
	 chatrooms = maps:new() %% chatroom map. "chat_name" => chat_pid
	}
     ).

loop(State) ->
    receive 
	%% initial connection
	{ClientPID, connect, ClientNick} ->
	    NewState =
		#serv_st{
		   nicks = maps:put(ClientPID, ClientNick, State#serv_st.nicks),
		   registrations = State#serv_st.registrations,
		   chatrooms = State#serv_st.chatrooms
		  },
	    loop(NewState);
	%% client requests to join a chat
	{ClientPID, Ref, join, ChatName} ->
	    NewState = do_join(ChatName, ClientPID, Ref, State),
	    loop(NewState);
	%% client requests to join a chat
	{ClientPID, Ref, leave, ChatName} ->
	    NewState = do_leave(ChatName, ClientPID, Ref, State),
	    loop(NewState);
	%% client requests to register a new nickname
	{ClientPID, Ref, nick, NewNick} ->
	    NewState = do_new_nick(State, Ref, ClientPID, NewNick),
	    loop(NewState);
	%% client requests to quit
	{ClientPID, Ref, quit} ->
	    NewState = do_client_quit(State, Ref, ClientPID),
	    loop(NewState);
	{TEST_PID, get_state} ->
	    TEST_PID!{get_state, State},
	    loop(State)
    end.

%% executes join protocol from server perspective

do_join_create_new(ChatName, State) ->
    PID = spawn(chatroom, start_chatroom, [ChatName]),
	{
		PID,
   		maps:put(ChatName, [], State#serv_st.registrations),
  		maps:put(ChatName, PID, State#serv_st.chatrooms)
  	}.


do_join(ChatName, ClientPID, Ref, State) ->
    case maps:is_key(ChatName, State#serv_st.chatrooms) of
    	true -> 
    		{ChatPID, Regs, Chats} = {maps:get(ChatName, State#serv_st.chatrooms), State#serv_st.registrations, State#serv_st.chatrooms},
    		NewState = State#serv_st{registrations = Regs, chatrooms = Chats},
    		ClientNick = maps:get(ClientPID, NewState#serv_st.nicks),
    		ChatPID!{self(), Ref, register, ClientPID, ClientNick},
    		Newer_Map =  maps:put(ChatName, [ClientPID] ++ maps:get(ChatName, NewState#serv_st.registrations), NewState#serv_st.registrations),
    		NewState#serv_st{registrations = Newer_Map};
    	false -> 
    		{ChatID, Regs, Chats} = do_join_create_new(ChatName, State),
    		NewState = State#serv_st{registrations = Regs, chatrooms = Chats},
    		ClientNick = maps:get(ClientPID, NewState#serv_st.nicks),
    		ChatPID = maps:get(ChatName, NewState#serv_st.chatrooms),
    		ChatPID!{self(), Ref, register, ClientPID, ClientNick},
    		Newer_Map =  maps:put(ChatName, [ClientPID] ++ maps:get(ChatName, NewState#serv_st.registrations), NewState#serv_st.registrations),
    		NewState#serv_st{registrations = Newer_Map}
    end.



%% executes leave protocol from server perspective
do_leave(ChatName, ClientPID, Ref, State) ->
    PID = maps:get(ChatName, State#serv_st.chatrooms),
    ChatList = maps:get(ChatName, State#serv_st.registrations),
    NewList = lists:delete(ClientPID, ChatList),
    NewerMap = maps:put(ChatName, NewList, State#serv_st.registrations),
    NewState = State#serv_st{registrations = NewerMap},
    PID!{self(), Ref, unregister, ClientPID},
    ClientPID!{self(), Ref, ack_leave},
    NewState.

nick_helper(State, ClientPID, AllChats) ->
	case AllChats of
		[] -> [];
		[{Name, PID} | T] ->
			case lists:member(ClientPID, PID) of
				true ->
					[Name] ++ nick_helper(State, ClientPID, T);
				false ->
					nick_helper(State, ClientPID, T)
			end
	end.

send_messages(State, Chat_List, ClientPID, NewNick, Ref) ->
	case Chat_List of
		[] -> ok;
		[H | T] ->
			PID = maps:get(H, State#serv_st.chatrooms),
			PID!{self() ,Ref, update_nick, ClientPID, NewNick},
			send_messages(State, T, ClientPID, NewNick, Ref)
	end.

%% executes new nickname protocol from server perspective
do_new_nick(State, Ref, ClientPID, NewNick) ->
    MapList = maps:values(State#serv_st.nicks),
    case lists:member(NewNick, MapList) of
    	true ->
    		ClientPID!{self(), Ref, err_nick_used},
    		State;
    	false ->
    		NewState = State#serv_st{nicks = maps:put(ClientPID, NewNick, State#serv_st.nicks)},
    		Chats = nick_helper(State, ClientPID, maps:to_list(NewState#serv_st.registrations)),
    		send_messages(NewState, Chats, ClientPID, NewNick, Ref),
    		ClientPID!{self(), Ref, ok_nick},
    		NewState
    end.

send_leave_messages(State, Chat_List, ClientPID, Ref) ->
	case Chat_List of
		[] -> ok;
		[H | T] ->
			PID = maps:get(H, State#serv_st.chatrooms),
			PID!{self() ,Ref, unregister, ClientPID},
			send_leave_messages(State, T, ClientPID, Ref);
		_ -> {err, State}
	end.

clean_map(State, ClientPID) ->
	maps:map(
		fun(Chat, PID) ->
			case lists:member(ClientPID, PID) of
				true ->	lists:delete(ClientPID, PID);
				false -> PID
			end
		end, State#serv_st.registrations).

%% executes client quit protocol from server perspective
do_client_quit(State, Ref, ClientPID) ->
    NewNicks = maps:remove(ClientPID, State#serv_st.nicks),
    NewMap = State#serv_st{nicks=NewNicks},
    Chats = nick_helper(State, ClientPID, maps:to_list(NewMap#serv_st.registrations)),
    send_leave_messages(NewMap, Chats, ClientPID, Ref),
    NewRegs = clean_map(State, ClientPID),
    NewState = NewMap#serv_st{registrations = NewRegs},
    ClientPID!{self(), Ref, ack_quit},
    NewState.


