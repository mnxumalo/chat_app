%%%-------------------------------------------------------------------
%%% @author mthulisi
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. Mar 2020 21:32
%%%-------------------------------------------------------------------
-module(chat_client).
-author("mthulisi").

%% API
-export([send_message/2, print_message/2, start_router/0, register_nickname/1, unregister_nickname/1]).

-export([handle_messages/1]).

register_nickname(NickName) ->
  Pid = spawn(?MODULE, handle_messages, [NickName]),
  message_router:register_nick(NickName, Pid).

unregister_nickname(NickName) ->
  message_router:unregister_nick(NickName).

send_message(Addressee, MessageBody) ->
  message_router:send_chat_message(Addressee, MessageBody).

print_message(Who, MessageBody) ->
  io:format("~p received: ~p~n", [Who, MessageBody]).

start_router() ->
  message_router:start().

handle_messages(Nickname) ->
  receive
    {print_msg, MessageBody} -> io:format("~p received: ~p~n",[Nickname, MessageBody]);
    stop -> ok
  end.

