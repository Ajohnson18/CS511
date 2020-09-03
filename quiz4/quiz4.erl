%Alex Johnson
% I pledge my honor that I have abided by the Stevens Honor System.
-module(calc).
-compile(export_all).
-record(shipping_state, 
        {
          ships = [],
          containers = [],
          ports = [],
          ship_locations = [],
          ship_inventory = maps:new(),
          port_inventory = maps:new()
         }
       ).

calc()