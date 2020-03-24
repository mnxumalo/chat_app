%%%-------------------------------------------------------------------
%%% @author mthulisi
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. Mar 2020 21:42
%%%-------------------------------------------------------------------
-module(message_store).
-author("mthulisi").

%% API
-export([start/0, stop/0, run/0]).

start() ->
  server_util:start(?MODULE, {?MODULE, run, []}).

stop() ->
  server_util:stop(?MODULE).

run() ->
  ok.
