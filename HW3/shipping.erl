%% Alex Johnson
%% I pledge my honor that I have abided by the Stevens Honor System.

-module(shipping).
-compile(nowarn_export_all).
-compile(export_all).
-include_lib("./shipping.hrl").

mem(Val, List) ->
  case List of
    [] -> false;
    [X|_T] when X == Val -> true;
    [_|T] -> mem(Val, T)
  end.

find_ship(List, ID) ->
  case List of
    [] -> error;
    [R | _T] when R#ship.id == ID -> R;
    [_ | T] -> find_ship(T, ID)
  end.

find_container(List, ID) ->
  case List of
    [] -> error;
    [R | _T] when R#container.id == ID -> R;
    [_ | T] -> find_container(T, ID)
  end.

find_port(List, ID) ->
  case List of
    [] -> error;
    [R | _T] when R#port.id == ID -> R;
    [_ | T] -> find_port(T, ID)
  end.

find_docks(Locs, Port_ID) ->
  case Locs of
    [] -> [];
    [{X,Y,_}| T] when X==Port_ID -> [Y] ++ find_docks(T, Port_ID);
    [_ | T] -> find_docks(T, Port_ID)
  end.

find_ship_location(Locs, Ship_ID) ->
  case Locs of
    [] -> error;
    [{X,Y,Z}|_T] when Z==Ship_ID -> {X,Y};
    [_|T] -> find_ship_location(T, Ship_ID)
  end.

find_container_weight(List, IDs) ->
  case List of
    [] -> 0;
    [R | T] -> 
      case mem(R#container.id, IDs) of
        true -> find_container_weight(T, IDs) + R#container.weight;
        false -> find_container_weight(T, IDs)
      end
  end.

get_ship_inventory_size(Shipping_State, Ship_ID) ->
  case maps:find(Ship_ID, Shipping_State#shipping_state.ship_inventory) of
    {_,List} -> length(List);
    _ -> error
  end.

get_port_containers(Shipping_State, Port_ID) ->
  case maps:find(Port_ID, Shipping_State#shipping_state.port_inventory) of
    {_, List} -> List;
    _ -> error
  end.

get_port_containers_after_load(Container_IDs, Port) ->
  case Port of
    [] -> [];
    [H|T] ->
      case lists:member(H, Container_IDs) of
        true -> get_port_containers_after_load(Container_IDs, T);
        false -> [H] ++ get_port_containers_after_load(Container_IDs, T)
      end;
    _ -> error
  end.

get_port_containers_after_unload(Container_IDs, Ship_Inventory) ->
  case Ship_Inventory of
    [] -> [];
    [H|T] ->
      case lists:member(H, Container_IDs) of
        true -> get_port_containers_after_unload(Container_IDs, T);
        false -> [H] ++ get_port_containers_after_unload(Container_IDs, T)
      end;
    _ -> error
  end.

check_containers(Container_IDs, Port) ->
  case Container_IDs of
    [] -> [];
    [ID|T] ->
      case lists:member(ID, Port) of 
        true -> [ID] ++ check_containers(T, Port);
        false -> check_containers(T,Port)
      end
  end.

check_containers_ship(Ship_Inventory, Container_IDs) ->
  case Container_IDs of
    [] -> true;
    [ID|T] ->
      case lists:member(ID, Ship_Inventory) of 
        true -> check_containers_ship(Ship_Inventory, T);
        false -> 
          io:format("The given conatiners are not all on the same ship..."),
          false
      end
  end.

check_port(Shipping_State, Port_ID, Dock) ->
  lists:member(Dock, get_occupied_docks(Shipping_State, Port_ID)).

get_ship(Shipping_State, Ship_ID) ->
  find_ship(Shipping_State#shipping_state.ships, Ship_ID).

get_container(Shipping_State, Container_ID) ->
  find_container(Shipping_State#shipping_state.containers, Container_ID).

get_port(Shipping_State, Port_ID) ->
  find_port(Shipping_State#shipping_state.ports, Port_ID).

get_occupied_docks(Shipping_State, Port_ID) ->
  find_docks(Shipping_State#shipping_state.ship_locations, Port_ID).

get_ship_location(Shipping_State, Ship_ID) ->
  find_ship_location(Shipping_State#shipping_state.ship_locations, Ship_ID).

get_container_weight(Shipping_State, Container_IDs) ->
  find_container_weight(Shipping_State#shipping_state.containers, Container_IDs).

get_ship_weight(Shipping_State, Ship_ID) ->
  case maps:find(Ship_ID, Shipping_State#shipping_state.ship_inventory) of
    {_,L} ->  get_container_weight(Shipping_State, L);
    _ -> error
  end.

load_ship(Shipping_State, Ship_ID, Container_IDs) ->
  {Port_ID, _} = get_ship_location(Shipping_State, Ship_ID),
  Ship = get_ship(Shipping_State, Ship_ID),
  case (get_ship_inventory_size(Shipping_State, Ship_ID) + length(Container_IDs)) > Ship#ship.container_cap of
    false -> 
      case check_containers(Container_IDs, get_port_containers(Shipping_State, Port_ID)) of
        [Lst|T] -> 
          case maps:find(Ship_ID, Shipping_State#shipping_state.ship_inventory) of
            {_,_L} -> 
              case maps:find(Ship_ID, Shipping_State#shipping_state.ship_inventory) of
                {_, Inv} -> 
                  maps:put(Ship_ID, Inv ++ [Lst] ++ T, Shipping_State#shipping_state.ship_inventory),
                  Map = Shipping_State#shipping_state.port_inventory,
                  case maps:find(Port_ID, Shipping_State#shipping_state.port_inventory) of
                    {_, PInv} -> 
                      Shipping_State#shipping_state{port_inventory = maps:update(Port_ID, get_port_containers_after_load(Container_IDs, PInv), Map), ship_inventory = maps:update(Ship_ID, Inv ++ [Lst] ++ T, Shipping_State#shipping_state.ship_inventory)};
                    _ -> error
                  end;
                _ -> error
              end;
            _ -> error
          end;
        [] -> Shipping_State#shipping_state{};
        _ -> error
      end;
    true -> error
  end.

unload_ship_all(Shipping_State, Ship_ID) ->
    {Port_ID, _} = get_ship_location(Shipping_State, Ship_ID),
    Port = get_port(Shipping_State, Port_ID),
    {_, Port_Inventory} = maps:find(Port_ID, Shipping_State#shipping_state.port_inventory),
    {_, Ship_Inventory} = maps:find(Ship_ID, Shipping_State#shipping_state.ship_inventory),
    case Port#port.container_cap > (length(Port_Inventory) + length(Ship_Inventory)) of
      true -> 
        Map1 = maps:update(Port_ID, Port_Inventory ++ Ship_Inventory, Shipping_State#shipping_state.port_inventory),
        Map2 = maps:update(Ship_ID, [], Shipping_State#shipping_state.ship_inventory),
        Shipping_State#shipping_state{port_inventory = Map1, ship_inventory = Map2};
      false -> false
    end.

unload_ship(Shipping_State, Ship_ID, Container_IDs) ->
    {Port_ID, _} = get_ship_location(Shipping_State, Ship_ID),
    Port = get_port(Shipping_State, Port_ID),
    {_, Port_Inventory} = maps:find(Port_ID, Shipping_State#shipping_state.port_inventory),
    {_, Ship_Inventory} = maps:find(Ship_ID, Shipping_State#shipping_state.ship_inventory),
        case Port#port.container_cap > (length(Port_Inventory) + length(Ship_Inventory)) of
          true -> 
            Map1 = maps:update(Port_ID, Port_Inventory ++ Container_IDs, Shipping_State#shipping_state.port_inventory),
            Map2 = maps:update(Ship_ID, get_port_containers_after_unload(Container_IDs, Ship_Inventory), Shipping_State#shipping_state.ship_inventory),
            case check_containers_ship(Ship_Inventory, Container_IDs) of
              false -> error;
              true -> Shipping_State#shipping_state{port_inventory = Map1, ship_inventory = Map2}
            end;
          false -> false
        end.

set_sail_helper(Ship_Locations, {Port, Dock, Ship}) ->
  case Ship_Locations of
    [] -> [];
    [{_P,_D,S}|T] when S == Ship -> 
      [{Port, Dock, Ship}] ++ set_sail_helper(T, {Port, Dock, Ship});
    [{P,D,S}|T] when S /= Ship ->
      [{P,D,S}] ++ set_sail_helper(T, {Port, Dock, Ship});
    _ -> error
  end.

set_sail(Shipping_State, Ship_ID, {Port_ID, Dock}) ->
    case check_port(Shipping_State, Port_ID, Dock) of
      false -> 
        Ship_Locations = Shipping_State#shipping_state.ship_locations,
        New_Locations = set_sail_helper(Ship_Locations, {Port_ID, Dock, Ship_ID}),
        Shipping_State#shipping_state{ship_locations = New_Locations};
      true -> error
    end.

%% Determines whether all of the elements of Sub_List are also elements of Target_List
%% @returns true is all elements of Sub_List are members of Target_List; false otherwise
is_sublist(Target_List, Sub_List) ->
    lists:all(fun (Elem) -> lists:member(Elem, Target_List) end, Sub_List).




%% Prints out the current shipping state in a more friendly format
print_state(Shipping_State) ->
    io:format("--Ships--~n"),
    _ = print_ships(Shipping_State#shipping_state.ships, Shipping_State#shipping_state.ship_locations, Shipping_State#shipping_state.ship_inventory, Shipping_State#shipping_state.ports),
    io:format("--Ports--~n"),
    _ = print_ports(Shipping_State#shipping_state.ports, Shipping_State#shipping_state.port_inventory).


%% helper function for print_ships
get_port_helper([], _Port_ID) -> error;
get_port_helper([ Port = #port{id = Port_ID} | _ ], Port_ID) -> Port;
get_port_helper( [_ | Other_Ports ], Port_ID) -> get_port_helper(Other_Ports, Port_ID).


print_ships(Ships, Locations, Inventory, Ports) ->
    case Ships of
        [] ->
            ok;
        [Ship | Other_Ships] ->
            {Port_ID, Dock_ID, _} = lists:keyfind(Ship#ship.id, 3, Locations),
            Port = get_port_helper(Ports, Port_ID),
            {ok, Ship_Inventory} = maps:find(Ship#ship.id, Inventory),
            io:format("Name: ~s(#~w)    Location: Port ~s, Dock ~s    Inventory: ~w~n", [Ship#ship.name, Ship#ship.id, Port#port.name, Dock_ID, Ship_Inventory]),
            print_ships(Other_Ships, Locations, Inventory, Ports)
    end.

print_containers(Containers) ->
    io:format("~w~n", [Containers]).

print_ports(Ports, Inventory) ->
    case Ports of
        [] ->
            ok;
        [Port | Other_Ports] ->
            {ok, Port_Inventory} = maps:find(Port#port.id, Inventory),
            io:format("Name: ~s(#~w)    Docks: ~w    Inventory: ~w~n", [Port#port.name, Port#port.id, Port#port.docks, Port_Inventory]),
            print_ports(Other_Ports, Inventory)
    end.
%% This functions sets up an initial state for this shipping simulation. You can add, remove, or modidfy any of this content. This is provided to you to save some time.
%% @returns {ok, shipping_state} where shipping_state is a shipping_state record with all the initial content.
shipco() ->
    Ships = [#ship{id=1,name="Santa Maria",container_cap=20},
              #ship{id=2,name="Nina",container_cap=20},
              #ship{id=3,name="Pinta",container_cap=20},
              #ship{id=4,name="SS Minnow",container_cap=20},
              #ship{id=5,name="Sir Leaks-A-Lot",container_cap=20}
             ],
    Containers = [
                  #container{id=1,weight=200},
                  #container{id=2,weight=215},
                  #container{id=3,weight=131},
                  #container{id=4,weight=62},
                  #container{id=5,weight=112},
                  #container{id=6,weight=217},
                  #container{id=7,weight=61},
                  #container{id=8,weight=99},
                  #container{id=9,weight=82},
                  #container{id=10,weight=185},
                  #container{id=11,weight=282},
                  #container{id=12,weight=312},
                  #container{id=13,weight=283},
                  #container{id=14,weight=331},
                  #container{id=15,weight=136},
                  #container{id=16,weight=200},
                  #container{id=17,weight=215},
                  #container{id=18,weight=131},
                  #container{id=19,weight=62},
                  #container{id=20,weight=112},
                  #container{id=21,weight=217},
                  #container{id=22,weight=61},
                  #container{id=23,weight=99},
                  #container{id=24,weight=82},
                  #container{id=25,weight=185},
                  #container{id=26,weight=282},
                  #container{id=27,weight=312},
                  #container{id=28,weight=283},
                  #container{id=29,weight=331},
                  #container{id=30,weight=136}
                 ],
    Ports = [
             #port{
                id=1,
                name="New York",
                docks=['A','B','C','D'],
                container_cap=200
               },
             #port{
                id=2,
                name="San Francisco",
                docks=['A','B','C','D'],
                container_cap=200
               },
             #port{
                id=3,
                name="Miami",
                docks=['A','B','C','D'],
                container_cap=200
               }
            ],
    %% {port, dock, ship}
    Locations = [
                 {1,'B',1},
                 {1, 'A', 3},
                 {3, 'C', 2},
                 {2, 'D', 4},
                 {2, 'B', 5}
                ],
    Ship_Inventory = #{
      1=>[14,15,9,2,6],
      2=>[1,3,4,13],
      3=>[],
      4=>[2,8,11,7],
      5=>[5,10,12]},
    Port_Inventory = #{
      1=>[16,17,18,19,20],
      2=>[21,22,23,24,25],
      3=>[26,27,28,29,30]
     },
    #shipping_state{ships = Ships, containers = Containers, ports = Ports, ship_locations = Locations, ship_inventory = Ship_Inventory, port_inventory = Port_Inventory}.
