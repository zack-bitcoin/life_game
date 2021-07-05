-module(chalang_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    inets:start(),
    start_http(),
    spawn(fun()-> 
                  timer:sleep(200),
                  mainloop:doit() end),
    spawn(fun()-> 
                  timer:sleep(200),
                  board_cache:cron() end),
    chalang_sup:start_link().

stop(_State) ->
    ok.

start_http() ->
    Dispatch =
        cowboy_router:compile(
          [{'_', [
		  %{"/:file", file_handler, []}%,
		  {"/", http_handler, []},
		  {"/[...]", file_handler, []}
		 ]}]),
    %{ok, Port} = application:get_env(amoveo_mining_pool, port),
    {ok, _} = cowboy:start_clear(http,
				 [{ip, {0,0,0,0}}, {port, 8000}],
				 #{env => #{dispatch => Dispatch}}),
    ok.
    
