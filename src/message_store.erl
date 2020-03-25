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

-include("qlc.hrl").

-record(chat_message, {addressee, body, created_on}).

%% API
-export([start/0, stop/0, run/1, init_store/0, store_message/2, get_messages/1, save_message/2, find_messages/1]).

start() ->
  server_util:start(?MODULE, {?MODULE, run, [true]}).

stop() ->
  server_util:stop(?MODULE).

save_message(Addressee, Body) ->
  global:send(?MODULE, {save_msg, Addressee, Body}).

find_messages(Addressee) ->
  global:send(?MODULE, {find_msg, Addressee, self()}),
  receive
    {ok, Messages} -> Messages
  end.

run(FirstTime) ->
  if
    FirstTime == true -> init_store(),
      run(false);
    true ->
      receive
        {save_msg, Addressee, Body} ->
          store_message(Addressee, Body),
          run(FirstTime);
        {find_msg, Addressee, Pid} ->
          Messages = get_messages(Addressee),
          Pid ! {ok, Messages},
          run(FirstTime);
        shutdown -> mnesia:stop(),
          io:format("Shutting down...~n")
      end
  end.

init_store() ->
  mnesia:create_schema([node()]),
  mnesia:start(),
  try
      mnesia:table_info(chat_message, type)
  catch
      exit:_  -> mnesia:create_table(chat_message, [{attributes, record_info(fields, chat_message)},
        {type, bag}, {disc_copies, [node()]}])
  end.

store_message(Addressee, Body) ->
  {_, Created_On, _} = erlang:timestamp(),
  F = fun() -> mnesia:write(#chat_message{addressee = Addressee, body = Body, created_on = Created_On}) end,
  mnesia:transaction(F).

get_messages(Addressee) ->
  F = fun() ->
      Query = qlc:q([M#chat_message.body || M <- mnesia:table(chat_message), M#chat_message.addressee =:= Addressee]),
      Results = qlc:e(Query),
      delete_messages(Results),
      Results
      end,
      {atomic, Messages} = mnesia:transaction(F),
  Messages.

delete_messages(Messages) ->
  F = fun() ->
      lists:foreach(fun(Msg) -> mnesia:delete_object(Msg) end, Messages)
      end,
  mnesia:transaction(F).