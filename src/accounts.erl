-module(accounts).
-behaviour(gen_server).
-export([start_link/0,code_change/3,handle_call/3,handle_cast/2,handle_info/2,init/1,terminate/2,
        new/3]).
%* accounts: name, points, species, last_animal_created, animal_creation_frequency.
-record(acc, {
          name, pub, points = 0, species = [],
          time_last, creation_frequency = 0
         }).
init(ok) -> {ok, []}.
start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, ok, []).
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_, _) -> io:format("died!"), ok.
handle_info(_, X) -> {noreply, X}.
handle_cast({new, Name, Pub, Now}, X) -> 
    A = #acc{name = Name, pub = Pub, 
             time_last = Now},
    X2 = dict:write(Pub, A, X),
    {noreply, X2};
handle_cast(_, X) -> {noreply, X}.
handle_call(_, _From, X) -> {reply, X, X}.

new(Name, Pub, Now) ->
    gen_server:cast(
      ?MODULE, {new, Name, Pub, Now}).
