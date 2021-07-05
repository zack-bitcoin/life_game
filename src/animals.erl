-module(animals).
-behaviour(gen_server).
-export([start_link/0,code_change/3,handle_call/3,handle_cast/2,handle_info/2,init/1,terminate/2,

hurt_from/2,update/1,new/3,read/1,delete/1,
empty_animal/3, many/0, deaths/0
]).
% if energy or health run out, it dies.
% health is constantly regenerating, and shrinks when you are attacked.
% energy is constantly depleting, but recovers when you eat.

-include("records.hrl").

-record(db, {height = 1, many = 0, deaths = 0, dict = dict:new()}).

init(ok) -> {ok, #db{}}.
start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, ok, []).
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_, _) -> io:format("died!"), ok.
handle_info(_, X) -> {noreply, X}.
handle_cast({update, AID, Animal}, X) ->
    case dict:find(AID, X#db.dict) of
        error -> 
            io:fwrite("animal does not exist\n"),
            {noreply, X};
        {ok, _} ->
            D2 = dict:store(AID, Animal, X#db.dict),
            X2 = X#db{dict = D2},
            {noreply, X2}
    end;
handle_cast({hurt_from, AID, FromLocation}, X) -> 
    case dict:find(AID, X#db.dict) of
        error ->
            io:fwrite("cannot hurt non-existence animal\n"),
            {noreply, X};
        {ok, Animal} ->
            #animal{
          location = Location
         } = Animal,
            Animal2 = hurt_from_relative_direction(
                        Location, FromLocation, 
                        Animal),
            H1 = Animal#animal.health,
            H2 = H1 - settings:attack_damage(),
            Animal3 = Animal2#animal{
                        health = H2
                       },
            D = dict:store(AID, Animal3, X#db.dict),
            X2 = X#db{dict = D},
            {noreply, X2}
    end;
handle_cast({delete, AID}, X) -> 
    D2 = dict:erase(AID, X#db.dict),
    X2 = X#db{dict = D2,
             many = X#db.many - 1,
             deaths = X#db.deaths + 1},
    {noreply, X2};
handle_cast(_, X) -> {noreply, X}.
handle_call({new, Animal}, _, X) -> 
    AID = X#db.height,
    Animal2 = Animal#animal{
                id = AID},
    D2 = dict:store(AID, Animal2, X#db.dict),
    X2 = X#db{height = AID + 1,
              many = X#db.many + 1,
              dict = D2},
    {reply, AID, X2};
handle_call({read, AID}, _From, X) -> 
    Response = dict:find(AID, X#db.dict),
    {reply, Response, X};
handle_call(many, _From, X) -> 
    {reply, X#db.many, X};
handle_call(deaths, _From, X) -> 
    {reply, X#db.deaths, X};
handle_call(_, _From, X) -> {reply, X, X}.

many() ->
    gen_server:call(?MODULE, many).
deaths() ->
    gen_server:call(?MODULE, deaths).

hurt_from_relative_direction({W1, H1},{W2, H2}, Animal) ->
    Wd = W2 - W1,
    Hd = H2 - H1,
    if
        Hd > 0 ->
            Animal#animal{pain_front = 1};
        Hd < 0 ->
            Animal#animal{pain_back = 1};
        Wd > 1 ->
            Animal#animal{pain_right = 1};
        Wd < 1 ->
            Animal#animal{pain_left = 1}
    end.

read(AnimalID) ->
    gen_server:call(?MODULE, {read, AnimalID}).
empty_bits() ->
    list_to_tuple(list_of(32, 0)).
empty_32s() ->
    list_to_tuple(list_of(32, <<0:256>>)).
list_of(0, _) -> [];
list_of(N, X) ->
    [X|list_of(N-1, X)].

empty_animal(SpeciesID, Location, Time) ->
    #animal{
      sid = SpeciesID,
      health = settings:health(),
      energy = settings:energy(),
      memory1 = empty_bits(),
      memory8 = empty_bits(),
      memory32 = empty_32s(),
      direction = 1,
      location = Location,
      last_time = Time,
      pain_front = 0,
      pain_left = 0,
      pain_right = 0,
      pain_back = 0
    }.

new(SpeciesID, Location, Time) ->
    %todo: set one of the bits to zero so it knows it is new.
    A = empty_animal(SpeciesID, Location, Time),
    %todo store in species list
    gen_server:call(?MODULE, {new, A}).
update(Animal) ->
    AID = Animal#animal.id,
    gen_server:cast(
      ?MODULE, {update, AID, Animal}).
hurt_from(AnimalID, Location) ->
    gen_server:cast(
      ?MODULE, {hurt_from, AnimalID, Location}).
delete(AID) ->
    %todo remove from species list
    gen_server:cast(?MODULE, {delete, AID}).
