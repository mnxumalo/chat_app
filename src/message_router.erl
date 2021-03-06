%%%-------------------------------------------------------------------
%%% @author Mthulisi
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. Mar 2020 21:18
%%%-------------------------------------------------------------------
-module(message_router).
-author("mthulisi").

%% API
-export([route_messages/1, start/0, stop/0, send_chat_message/2, register_nick/2, unregister_nick/1]).

start() ->
  server_util:start(?MODULE, {?MODULE, route_messages, [dict:new()]}),
  message_store:start().

stop() ->
  server_util:stop(?MODULE),
  message_store:stop().

send_chat_message(Addressee, MessageBody) ->
  global:send(?MODULE, {send_chat_msg, Addressee, MessageBody}).


register_nick(ClientName, ClientPid) ->
  global:send(?MODULE, {register_nick, ClientName, ClientPid}).


unregister_nick(ClientName) ->
  global:send(?MODULE, {unregister, ClientName}).

route_messages(Clients) ->

  receive

    {send_chat_msg, ClientName, MessageBody} ->
      case dict:find(ClientName, Clients) of
        {ok, ClientPid} -> ClientPid ! {print_msg, MessageBody};
        error ->
          message_store:save_message(ClientName, MessageBody),
          io:format("Archived message for ~p~n", [ClientName])
      end,
      route_messages(Clients);

    {register_nick, ClientName, ClientPid} ->
      Messages = message_store:find_messages(ClientName),
      lists:foreach(fun(Msg) -> ClientPid ! {print_msg, Msg} end, Messages),
      route_messages(dict:store(ClientName, ClientPid, Clients));

    {unregister, ClientName} ->
      case dict:find(ClientName, Clients) of
        {ok, ClientPid}  ->
          ClientPid ! stop,
          route_messages(dict:erase(ClientName, Clients));
        error ->
          io:format("Error! Unknown Client ~p~n", [ClientName]),
          route_messages(Clients)
        end;

    shutdown -> io:format("Shutting down~n");

    Other -> io:format("Warning! Received: ~p~n", [Other]),
      route_messages(Clients)

  end.
