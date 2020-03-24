{application, 'chat_app', [
	{description, "New project"},
	{vsn, "0.1.0"},
	{modules, ['chat_app_app','chat_app_sup','chat_client','message_router','server_util']},
	{registered, [chat_app_sup]},
	{applications, [kernel,stdlib]},
	{mod, {chat_app_app, []}},
	{env, []}
]}.