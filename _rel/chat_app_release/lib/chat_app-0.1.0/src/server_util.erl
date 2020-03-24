%%%-------------------------------------------------------------------
%%% @author mthulisi
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. Mar 2020 21:06
%%%-------------------------------------------------------------------
-module(server_util).
-author("mthulisi").

%% API
-export([start/2, stop/1]).

start(Server, {Module, Function, Args}) ->
  global:trans({Server, Server}, fun() ->

    case global:whereis_name(Server) of
      undefined  ->
        global:register_name(Server, spawn(Module, Function, Args));
      _ -> ok
    end
                                   end).

stop(Server) ->
  global:trans({Server, Server}, fun() ->
    case global:whereis_name(Server) of
      undefined -> ok;
      _ -> global:send(Server, shutdown)
    end
                                   end).
