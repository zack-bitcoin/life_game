-module(animals).
-behaviour(gen_server).
-export([start_link/0,code_change/3,handle_call/3,handle_cast/2,handle_info/2,init/1,terminate/2,

hurt_from/2,update/7,new/4,read/1
]).
% if energy or health run out, it dies.
% health is constantly regenerating, and shrinks when you are attacked.
% energy is constantly depleting, but recovers when you eat.

-include("records.hrl").

-record(db, {height = 1, dict = dict:new()}).

init(ok) -> {ok, #db{}}.
start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, ok, []).
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_, _) -> io:format("died!"), ok.
handle_info(_, X) -> {noreply, X}.
handle_cast({update, AID, Health, Energy,
            Memory, CoolDown, Direction,
            Location}, X) -> 
    case dict:find(AID, X#db.dict) of
        error -> 
            io:fwrite("account does not exist\n"),
            {noreply, X};
        {ok, Animal} ->
            Animal2 = 
                Animal#animal{
                  health = Health,
                  energy = Energy,
                  memory = Memory,
                  default_cooldown = CoolDown,
                  direction = Direction,
                  location = Location
                 },
            D2 = dict:store(AID, Animal2, X#db.dict),
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
handle_cast(_, X) -> {noreply, X}.
handle_call({new, Animal}, _, X) -> 
    AID = X#db.height,
    Animal2 = Animal#animal{
                id = AID},
    D2 = dict:store(AID, Animal2, X#db.dict),
    X2 = X#db{height = AID + 1,
              dict = D2},
    {reply, AID, X2};
handle_call({read, AID}, _From, X) -> 
    Response = dict:find(AID, X),
    {reply, Response, X};
handle_call(_, _From, X) -> {reply, X, X}.

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
new(AccID, SpeciesID, Location, Time) ->
    A = #animal{
      acc_id = AccID,
      sid = SpeciesID,
      health = settings:health(),
      energy = settings:energy(),
      memory = dict:new(),
      default_cooldown = 
          settings:cooldown(),
      direction = up,
      location = Location,
      last_time = Time,
      pain_front = false,
      pain_left = false,
      pain_right = false,
      pain_back = false
    },
    gen_server:call(?MODULE, {new, A}).
update(AnimalID, Health, Energy, Memory, CoolDown, Direction, Location) ->
    gen_server:cast(
      ?MODULE, {
         update, AnimalID, Health, 
         Energy, Memory, CoolDown, 
         Direction, Location}).
hurt_from(AnimalID, Location) ->
    gen_server:cast(
      ?MODULE, {hurt_from, AnimalID, Location}).
