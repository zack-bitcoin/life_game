-module(mainloop).
-export([doit/0]).

-include("records.hrl").
-record(db, {todo = [], time = 0}).
-record(task, {time, animal_id}).

doit() ->
    doit(#db{}).

doit(DB) ->
    %todo check if there are new animals to drop.
    T = DB#db.todo,
    case T of
        [] ->
            food_time(1000),
            doit(DB);
        [Task|Rest] ->
%if there is something on the todo list ready, do it.
            AID = Task#task.animal_id,
            Animal = animals:read(AID),
            #animal{sid = SID} = Animal,
            Species = species:read(SID),
            #species{
                      code = Code
                    } = Species,
            %if the animal is dead, delete the task and wait for the next.
            %run contract

            %while running we may need to update the display and memory of this animal.

            %if the animal dies while running the contract, kill it at that point, without finishing the contract. delete the animal, and wait for the next task.

            %the final result of the contract is an action, which can be attacking another animal, creating another animal, tagging a tile, eating, or changing location.

            %the final result has a cooldown. we need to create a new task, of revisiting this same animal, after it's cooldown. it should be sorted into the list of tasks

            DB2 = DB#db{todo = Rest},
            case Rest of
                [] ->
                    food_time(1000);
                [H|T] ->
                    food_time(
                      1000 
                      * (H#task.time 
                         - DB#db.time) 
                          div settings:tick_frequency())
            end,
            doit(DB2)
    end.
    
food_time(N) ->
    %todo sprinkle food.
    timer:sleep(N).

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
      
