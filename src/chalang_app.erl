-module(chalang_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
    spawn(fun()-> 
                  timer:sleep(200),
                  mainloop:doit() end),
    chalang_sup:start_link().

stop(_State) ->
    ok.
