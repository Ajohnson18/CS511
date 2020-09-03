-module(chatroom).

-include_lib("./defs.hrl").

-export([start_chatroom/1]).

-spec start_chatroom(_ChatName) -> _.
-spec loop(_State) -> _.
-spec do_register(_State, _Ref, _ClientPID, _ClientNick) -> _NewState.
-spec do_unregister(_State, _ClientPID) -> _NewState.
-spec do_update_nick(_State, _ClientPID, _NewNick) -> _NewState.
-spec do_propegate_message(_State, _Ref, _ClientPID, _Message) -> _NewState.

start_chatroom(ChatName) ->
    loop(#chat_st{name = ChatName,
		  registrations = maps:new(), history = []}),
    ok.

loop(State) ->
    NewState =
	receive
	    %% Server tells this chatroom to register a client
	    {_ServerPID, Ref, register, ClientPID, ClientNick} ->
		do_register(State, Ref, ClientPID, ClientNick);
	    %% Server tells this chatroom to unregister a client
	    {_ServerPID, _Ref, unregister, ClientPID} ->
		do_unregister(State, ClientPID);
	    %% Server tells this chatroom to update the nickname for a certain client
	    {_ServerPID, _Ref, update_nick, ClientPID, NewNick} ->
		do_update_nick(State, ClientPID, NewNick);
	    %% Client sends a new message to the chatroom, and the chatroom must
	    %% propegate to other registered clients
	    {ClientPID, Ref, message, Message} ->
		do_propegate_message(State, Ref, ClientPID, Message);
	    {TEST_PID, get_state} ->
		TEST_PID!{get_state, State},
		loop(State)
end,
    loop(NewState).

%% This function should register a new client to this chatroom
do_register(State, Ref, ClientPID, ClientNick) ->
    NewMap = maps:put(ClientPID, ClientNick, State#chat_st.registrations),
    ClientPID!{self(), Ref, connect, State#chat_st.history},
    State#chat_st{registrations = NewMap}.

%% This function should unregister a client from this chatroom
do_unregister(State, ClientPID) ->
    NewMap = maps:remove(ClientPID, State#chat_st.registrations),
    State#chat_st{registrations = NewMap}.

%% This function should update the nickname of specified client.
do_update_nick(State, ClientPID, NewNick) ->
    NewMap = maps:put(ClientPID, NewNick, State#chat_st.registrations),
	State#chat_st{registrations = NewMap}.

prop_helper(State, Ref, ClientPID, Message, List, CliNick) ->
	case List of
		[] -> ok;
		[{PID, Nick} | T] ->
			case PID == ClientPID of
				true -> 
					prop_helper(State, Ref, ClientPID, Message, T, CliNick);
				false ->
					PID!{request, self(), Ref, {incoming_msg, CliNick, State#chat_st.name, Message}},
					prop_helper(State, Ref, ClientPID, Message, T, CliNick)
			end
	end.

%% This function should update all clients in chatroom with new message
%% (read assignment specs for details)
do_propegate_message(State, Ref, ClientPID, Message) ->
    ClientPID!{self(), Ref, ack_msg},
    Nick = maps:get(ClientPID, State#chat_st.registrations),
    List = maps:to_list(State#chat_st.registrations),
    prop_helper(State, Ref, ClientPID, Message, List, Nick),
    NewHist = lists:append([{Nick, Message}], State#chat_st.history),
    State#chat_st{history = NewHist}.
