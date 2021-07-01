-module(species).
-behaviour(gen_server).
-export([start_link/0,code_change/3,handle_call/3,handle_cast/2,handle_info/2,init/1,terminate/2,

new/1, read/1
]).

-include("records.hrl").

-record(db, {
          species = dict:new(),
          height = 1
         }).

init(ok) -> {ok, #db{}}.
start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, ok, []).
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_, _) -> io:format("died!"), ok.
handle_info(_, X) -> {noreply, X}.
handle_cast(_, X) -> {noreply, X}.
handle_call({read, ID}, _From, X) -> 
    V = dict:find(ID, X#db.species),
    {reply, V, X};
handle_call({new, S}, _From, X) -> 
    Species = X#db.species,
    H = X#db.height,
    S2 = S#species{id = H},
    X2 = X#db{species = dict:store(H, S2, Species),
              height = H+1},
    {reply, H, X2};
handle_call(_, _From, X) -> {reply, X, X}.

new(Code) ->
    S = #species{code = Code},
    gen_server:call(?MODULE, {new, S}).
read(ID) ->
    gen_server:call(?MODULE, {read, ID}).
