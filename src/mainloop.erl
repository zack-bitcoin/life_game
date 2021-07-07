-module(mainloop).
-export([doit/0, day/3, hour/1, season/1, fertility/1, likelyhood/3, get_random_location/0]).

-include("records.hrl").
-record(db, {todo = [], time = 0}).
-record(task, {time, animal_id}).

doit() ->
    W = settings:map_width(),
    H = settings:map_height(),
    add_foods(0, W*H),
    doit(#db{}).

doit(DB) ->
    %first check if there are new animals to drop.
    time:set(DB#db.time),
    {B, BLocation} = birthing:next(),
    DB2 = case B of
              0 -> DB;
              Animal ->
                  add_animal_to_map(
                    Animal, DB, BLocation)
          end,
    T = DB2#db.todo,
    TF = settings:tick_frequency(),
    case T of
        [] -> %empty tasks list
            food_time(TF, DB#db.time),
            doit(DB2#db{
                   time = DB2#db.time + TF});
        [Task|Rest] ->
            WaitTicks = 
                Task#task.time - DB2#db.time,
        %WaitTime = 1000 * WaitTicks
       %         div settings:tick_frequency(),
            food_time(WaitTicks, DB#db.time),
            DB3 = DB2#db{
                    time = DB2#db.time + WaitTicks,
                    todo = Rest},
            AID = Task#task.animal_id,
            case animals:read(AID) of
                error -> doit(DB3);
                {ok, Animal5} ->
                    #animal{sid = SID,
                            health = H,
                            location = {X, Y},
                            direction = Direction
                           } = Animal5,
                    if
                        (H < 1) -> 
                            animals:delete(AID),
                            board:remove_animal(X, Y),
                            board:add_food(X, Y),
                            doit(DB3);
                        true ->
                            doit2(Animal5, Rest, DB3)
                    end
            end
    end.
doit2(Animal, Rest, DB3) ->
    Time = DB3#db.time,
    {X, Y} = Animal#animal.location,
    D = Animal#animal.direction,
    Location = board:read(X, Y),
    {XF, YF} = step(X, Y, D),
    LocationF = board:read(XF, YF),
    SID = Animal#animal.sid,
    {ok, Species} = species:read(SID),
    #species{
              code = Code
            } = Species,
    {Message, SpeciesF, AnimalF} = 
        case animals:read(LocationF#location.animal_id) of
            error -> {0,0,0};
            {ok, AnimalF0} ->
                {AnimalF0#animal.message,
                 LocationF#location.species_id,
                 AnimalF0}
        end,
    
    State = #state{
      display = Animal#animal.message,
      can_see = board:can_see(X, Y, D, Time),
      smell_animal = [SpeciesF, Message],
      smell_tile = [LocationF#location.smell_species, LocationF#location.smell_age],
      smell_tile_tag = Location#location.tag,
      smell_food = Location#location.food,
      random = crypto:strong_rand_bytes(32),
      memory1 = Animal#animal.memory1,
      memory8 = Animal#animal.memory8,
      memory32 = Animal#animal.memory32,
      pain_front = Animal#animal.pain_front,
      pain_left = Animal#animal.pain_left,
      pain_right = Animal#animal.pain_right,
      pain_back = Animal#animal.pain_back,
      energy = Animal#animal.energy,
      health = Animal#animal.health,
      time = Time
     },
                            
    CDB = chalang:data_maker(
            1000, 2000, 1000, 500,
            <<>>, Code, State, 32, 2, 
            0),
    CDB20 = chalang:run5(Code, CDB), 
    {CDB2, EnergyCost} 
        = case CDB20 of
               {error, "out of time"} ->
                  {CDB, 10000};
               {error, ErrorMsg} ->
                  {CDB, 1000};
              _ ->
                  {CDB20, 0}
           end,
    %State2 = CDB2#db.state,
    State2 = element(12, CDB2),
    Animal2 = Animal#animal{
                message = State2#state.display,
                memory1 = State2#state.memory1,
                memory8 = State2#state.memory8,
                memory32 = State2#state.memory32,
                energy = State2#state.energy - EnergyCost,
                health = State2#state.health,
                pain_front = 0,
                pain_right = 0,
                pain_left = 0,
                pain_back = 0
               },
    Stack0 = element(3, CDB2),
    %io:fwrite(packer:pack(hd(Stack0))),
    Stack = Stack0 ++ [0,0,0,0,0],
    Action1 = hd(Stack),
    Action0 = case Action1 of
                  <<Action2:32>> -> Action2;
                  _ -> 1
              end,
    Action = if
                 %not(is_integer(Action0)) -> 1;
                 %Action0 < 0 -> 1;
                 Action0 > 7 -> 1;
                 true -> Action0
             end,
    CoolDown1 = hd(tl(Stack)),
    CoolDown0 = case CoolDown1 of
                    <<CoolDown2:32>> -> CoolDown2;
                    _ -> 0
                end,
    TF = settings:tick_frequency(),
    CoolDown = 
        if
            not(is_integer(CoolDown0)) -> TF;
            CoolDown0 < 1 -> TF;
            CoolDown0 > (20*TF) -> TF;
            true -> CoolDown0
        end,
    Status = " id=" ++ 
        integer_to_list(Animal2#animal.id) ++
        " at=" ++
        integer_to_list(X) ++
        " " ++
        integer_to_list(Y) ++
        " direction=" ++
        integer_to_list(D) ++
        " time=" ++
        integer_to_list(Time) ++
        " energy=" ++
        integer_to_list(Animal2#animal.energy) ++
        " ",
    %io:fwrite(Status),
    {Animal3, TaskList} = 
        case Action of
            1 -> 
                %io:fwrite("waited\n"),
                {Animal2, Rest}; %wait
            2 -> %step
                %io:fwrite("took a step\n"),
                case SpeciesF of
                    0 ->
                        board:remove_animal(
                          X, Y),
                        board:add_animal(
                          XF, YF, Animal2#animal.id, 
                          SID, D, Time),
                        MW = settings:map_width(),
                        MH = settings:map_height(),
                        {Animal2#animal{
                           %location = {XF, YF}},
                           location = {((XF + MW) rem MW),
                                       ((YF+MH) rem MH)}},
                         Rest};
                    _ -> %cannot step because an animal is blocking you.
                        {Animal2, Rest}
                end;
            3 ->%turn 
                %io:fwrite("turning\n"),
                TurnAmount0 = hd(tl(tl(Stack))),
                TurnAmount = case TurnAmount0 of
                                  <<1:32>> -> 1;
                                  <<2:32>> -> 2;
                                  <<3:32>> -> 3;
                                  _ -> 1
                              end,
                %S = "turned " ++ integer_to_list(TurnAmount) ++ " right \n",
                %io:fwrite(S),
                NewDirection = new_direction(
                                 D,
                                 TurnAmount),
                board:animal_direction(X, Y, NewDirection),
                {Animal2#animal{
                   direction = NewDirection},
                 Rest};
            4 -> %eat
                %io:fwrite("eating food\n"),
                case Location#location.food of
                    0 -> {Animal2, Rest};
                    1 ->
                        board:remove_food(X, Y),
                        {Animal2#animal{energy = Animal2#animal.energy + settings:energy_in_food()},
                         Rest}
                end;
            5 -> %attack
                case SpeciesF of
                    0 -> {Animal2, Rest};%nothing to attack
                    _ ->
                        DF = AnimalF#animal.direction,
                        PainFrom = pain_from(D, DF),
                        Health2 = AnimalF#animal.health - settings:attack_damage(),
                        AnimalF2 = 
                            AnimalF#animal{
                              health = Health2},
                        AnimalF3 = 
                            case PainFrom of
                                pain_front ->
                                    AnimalF2#animal{pain_front = 1};
                                pain_left ->
                                    AnimalF2#animal{pain_left = 1};
                                pain_right ->
                                    AnimalF2#animal{pain_right = 1};
                                pain_back ->
                                    AnimalF2#animal{pain_back = 1}
                            end,
                        animals:update(AnimalF3),
                        if
                            Health2 < 0 ->
                                %they died. adding task to delete them sooner.
                                Task4 = #task{
                                  time = Time,
                                  animal_id = AnimalF2#animal.id},
                                {Animal2, [Task4|Rest]};
                            true ->
                                {Animal2, Rest}
                        end
                end;
            6 -> %reproduce
                %io:fwrite("reproducing\n"),
                case SpeciesF of
                    0 ->
                        CodeLength = size(Code),
                        {CostN, CostD} = settings:code_length_to_base_energy(),
                        Cost = (CodeLength * CostN div CostD) + settings:energy(),
                        Energy = Animal2#animal.energy - Cost,
                        if
                            Energy < 1 ->
                                %not enough energy
                                {Animal2, Rest};
                            true ->
                                BAID = animals:new(SID, {XF, YF}, Time),
                                {ok, Baby} = animals:read(BAID),
                                BabyDirection =
                                    case Animal2#animal.direction of
                                        1 -> 3;
                                        2 -> 1;
                                        3 -> 4;
                                        4 -> 2
                                    end,
                                Animal7=Animal2#animal{
                                          energy = Energy, 
                                          direction = BabyDirection},
                                Baby2 = Baby#animal{
                                          memory1 = Animal7#animal.memory1,
                                          memory8 = Animal7#animal.memory8,
                                          memory32 = Animal7#animal.memory32
                                         },
                                animals:update(Baby2),
                                board:add_animal(XF, YF, BAID, SID, BabyDirection, Time),
                                BabyTask = #task{time = Time, animal_id = BAID},
                                {Animal7,
                                 [BabyTask|Rest]}
                        end;
                    _ -> 
                        %something is blocking you from making the baby animal.
                        {Animal2, Rest}
                end;
            7 -> %tag
                %io:fwrite("tagging\n"),
                Tag0 = hd(tl(tl(Stack))),
                Tag = case Tag0 of
                          <<_:256>> -> Tag0;
                          _ -> <<0:256>>
                      end,
                board:change_tag(X, Y, Tag),
                {Animal2, Rest}
        end,
    Animal4 = cooldown_cost(Action, CoolDown, Animal3), 
    if
        (Animal4#animal.energy < 0) -> 
            {X3, Y3} = Animal4#animal.location,
            AID = Animal4#animal.id,
            animals:delete(AID),
            board:remove_animal(X3, Y3),
            board:add_food(X3, Y3),
            doit(DB3);
        true ->
            animals:update(Animal4),
            Task2 = #task{
              time = Time + CoolDown,
              animal_id = Animal4#animal.id},
            TaskList2 = insert_task(Task2, TaskList),
            
            DB4 = DB3#db{todo = TaskList2},
            doit(DB4)
    end.
    
pain_from(1, 1) -> pain_back;
pain_from(1, 2) -> pain_left;
pain_from(1, 3) -> pain_right;
pain_from(1, 4) -> pain_front;
pain_from(2, 1) -> pain_right;
pain_from(2, 2) -> pain_back;
pain_from(2, 3) -> pain_front;
pain_from(2, 4) -> pain_left;
pain_from(3, 1) -> pain_left;
pain_from(3, 2) -> pain_front;
pain_from(3, 3) -> pain_back;
pain_from(3, 4) -> pain_right;
pain_from(4, 1) -> pain_front;
pain_from(4, 2) -> pain_right;
pain_from(4, 3) -> pain_left;
pain_from(4, 4) -> pain_back.

    

insert_task(Task, []) -> [Task];
insert_task(Task, [H|T]) ->
    %todo. should do binary insertion sort into ordered list.
    NT = Task#task.time,
    Time = H#task.time,
    if
        NT < Time -> [Task|[H|T]];
        true -> [H|insert_task(Task, T)]
    end.

step(X, Y, 1) ->
    {X, Y+1};
step(X, Y, 2) ->
    {X-1, Y};
step(X, Y, 3) ->
    {X+1, Y};
step(X, Y, 4) ->
    {X, Y-1}.

cooldown_cost(Action, CoolDown, Animal) ->
    Cost1 = case Action of
                1 -> settings:wait_cost();
                2 -> settings:step_cost();
                3 -> settings:turn_cost();
                4 -> settings:eat_cost();
                5 -> settings:attack_cost();
                6 -> settings:reproduce_cost();
                7 -> settings:tag_cost()
            end,
    TF = settings:tick_frequency(),
    Cost2 = Cost1 * TF * TF div CoolDown div CoolDown,
    Cost3 = max(Cost2, 1),
    Energy2 = Animal#animal.energy - Cost2,
    Animal#animal{energy = Energy2}.


add_animal_to_map(Animal, DB, Location) ->
    #animal{
             sid = SID
           } = Animal,
    Now = DB#db.time,
    AID = animals:new(SID, Location, Now),
    {X, Y} = Location,
    %species should have already been created
    board:add_animal(X, Y, AID, SID, 1, Now),
    Task = #task{time = Now, animal_id = AID},
    DB#db{todo = [Task|DB#db.todo]}.

new_direction(1, 1) -> 3;
new_direction(1, 2) -> 4;
new_direction(1, 3) -> 2;
new_direction(2, 1) -> 1;
new_direction(2, 2) -> 3;
new_direction(2, 3) -> 4;
new_direction(3, 1) -> 4;
new_direction(3, 2) -> 2;
new_direction(3, 3) -> 1;
new_direction(4, 1) -> 2;
new_direction(4, 2) -> 1;
new_direction(4, 3) -> 3;
new_direction(X, _) -> X.
    
    
food_time(Ticks, Time) ->
    %todo sprinkle food.
    %try_add_food(Time)
    DP = settings:day_period(),
    FD = settings:food_per_day(),
    Many = FD * Ticks / DP,
    R = random:uniform(),
    if
        Many > 1 ->
            add_foods(Time, round(Many));
        Many > R ->
            try_add_food(Time);
        true -> ok
    end,
    timer:sleep(1000 * Ticks div settings:tick_frequency()).
add_foods(_, 0) -> ok;
add_foods(Time, N) -> 
    try_add_food(Time),
    add_foods(Time, N-1).
hour(Time) ->
    DP = settings:day_period(),
    (Time + (DP div 2)) rem DP.
    %(Time) rem DP.
season(Time) ->
    YP = settings:year_period(),
    (Time + (YP div 2))rem YP.
day(Time, X, Y) ->
    %is it daytime at this location and time?
    DP = settings:day_period(),
    YP = settings:year_period(),
    Width = settings:map_width(),
    Height = settings:map_height(),
    Pi = math:pi(),
    DayWave = math:cos(2*Pi*((hour(Time)/DP) - (X/Width))),
    LatitudeEffect = ((math:cos(2*Pi*Y/Height)+1)/2),
    SeasonWave = (math:cos(2*Pi*season(Time)/YP)),
    Season = (LatitudeEffect*SeasonWave),
    Pronation = 1 + settings:planet_pronation(),
    (DayWave + (Pronation * Season)) > 0.
fertility(X) ->
    Width = settings:map_width(),
    Pi = math:pi(),
    ((1 + math:cos(Pi + (2*Pi*((X/Width) + (1/4))))) / 2).
likelyhood(Time, X, Y) ->
    D = day(Time, X, Y),
    F = fertility(X),
    if
        D -> F;
        true -> F/10
    end.
try_add_food(Time) ->
    {X, Y} = get_random_location(),
    L = likelyhood(Time, X, Y),
    R = random:uniform(),
    if
        (L > R) -> 
            board:add_food(X, Y);
        true -> ok
    end.
get_random_location() ->
    <<R1:40>> = crypto:strong_rand_bytes(5),
    <<R2:40>> = crypto:strong_rand_bytes(5),
    X = R1 rem settings:map_width(),
    Y = R2 rem settings:map_height(),
    {X, Y}.
            
            



%hour: time % day_period
%season: time % year_period
%day(time, x, y):
%        ((cos(2*pi*((hour/day_period)-(x/width)) - (y/height * a_constant * cos(season))) > 0)

%fertility(x): %part of the world produces food less frequently.
%   cos(2*pi*x/width)

%try_add_food() ->
%   r = get_random_location();
%   l = likelyhood(r);
%   if(l>(random())){
%   add_food(r);
%   }

%likelyhood(r, time) ->
%   d = day(time),
%   f = fertility(r[0]),
%   if(d){
%      return(f);
%   }else{
%      return(f/10);
%   };
      
