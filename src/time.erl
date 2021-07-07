
-module(time).
-behaviour(gen_server).
-export([start_link/0,code_change/3,handle_call/3,handle_cast/2,handle_info/2,init/1,terminate/2,
        set/1, get/0]).
init(ok) -> {ok, 0}.
start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, ok, []).
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_, _) -> io:format("died!"), ok.
handle_info(_, X) -> {noreply, X}.
handle_cast({set, T}, X) -> {noreply, T};
handle_cast(_, X) -> {noreply, X}.
handle_call(get, _From, X) -> {reply, X, X};
handle_call(_, _From, X) -> {reply, X, X}.

set(T) ->
    gen_server:cast(?MODULE, {set, T}).

get() ->
    gen_server:call(?MODULE, get).
