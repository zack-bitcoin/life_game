-module(birthing).
-behaviour(gen_server).
-export([start_link/0,code_change/3,handle_call/3,handle_cast/2,handle_info/2,init/1,terminate/2,
        add_animal/1, next/0]).
init(ok) -> {ok, []}.
start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, ok, []).
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_, _) -> io:format("died!"), ok.
handle_info(_, X) -> {noreply, X}.
handle_cast({add, Animal}, X) -> 
    X2 = [Animal|X],
    {noreply, X2};
handle_cast(_, X) -> {noreply, X}.
handle_call(next, _From, X) -> 
    case lists:reverse(X) of
        [A|X3] ->
            X2 = lists:reverse(X3),
            {reply, A, X2};
        [] -> {reply, 0, X}
    end;
handle_call(_, _From, X) -> {reply, X, X}.

add_animal(Animal) ->
    gen_server:cast(?MODULE, {add, Animal}).
next() ->
    case board:empty_location() of
        full_board_error -> 
            {0, 0};
        Location ->
            {gen_server:call(?MODULE, next), 
             Location}
    end.
