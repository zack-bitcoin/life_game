-module(board).
-behaviour(gen_server).
-export([start_link/0,code_change/3,handle_call/3,handle_cast/2,handle_info/2,init/1,terminate/2,

read/2,add_food/2,remove_food/2,change_tag/3,
add_animal/6,animal_direction/3,remove_animal/2,

can_see/3, view/3,

empty_location/0, all/0
]).
-include("records.hrl").
init(ok) -> 
    W = settings:map_width(),
    H = settings:map_height(),
    B = list_to_tuple(make_rows(H, W)),
    {ok, B}.
start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, ok, []).
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_, _) -> io:format("died!"), ok.
handle_info(_, X) -> {noreply, X}.
handle_cast({remove_food, W, H}, X) -> 
    R = element(H, X),
    L = element(W, R),
    L2 = L#location{food = 0},
    R2 = setelement(W, R, L2),
    X2 = setelement(H, X, R2),
    {noreply, X2};
handle_cast({add_food, W, H}, X) -> 
    R = element(H, X),
    L = element(W, R),
    L2 = L#location{food = 1},
    R2 = setelement(W, R, L2),
    X2 = setelement(H, X, R2),
    {noreply, X2};
handle_cast({change_tag, W, H, T}, X) -> 
    R = element(H, X),
    L = element(W, R),
    L2 = L#location{tag = T},
    R2 = setelement(W, R, L2),
    X2 = setelement(H, X, R2),
    {noreply, X2};
handle_cast({add_animal, W, H, AID, 
             SID, Direction, Time}, 
            X) -> 
    R = element(H, X),
    L = element(W, R),
    #location{animal_id = AID0} = L,%maybe we should calculate an empty location at this point.
    case AID0 of
        0 ->
            L2 = L#location{
                  animal_id = AID,
                  direction = Direction,
                  species_id = SID,
                  smell_species = SID,
                  smell_age = Time},
            R2 = setelement(W, R, L2),
            X2 = setelement(H, X, R2),
            {noreply, X2};
        _ -> {noreply, X}
    end; 
handle_cast({animal_direction, W, H, D}, X) ->
    R = element(H, X),
    L = element(W, R),
    L2 = L#location{direction = D},
    R2 = setelement(W, R, L2),
    X2 = setelement(H, X, R2),
    {noreply, X2};
handle_cast({remove_animal, W, H}, X) -> 
    R = element(H, X),
    L = element(W, R),
    L2 = L#location{
           direction = 0,
           species_id = 0,
           animal_id = 0
          },
    R2 = setelement(W, R, L2),
    X2 = setelement(H, X, R2),
    {noreply, X2};
handle_cast(_, X) -> {noreply, X}.
handle_call({read, W, H}, _From, X) -> 
    R = element(H, X),
    L = element(W, R),
    {reply, L, X};
handle_call(empty_location, _From, X) -> 
    E = empty_location_internal(X, 10),
    {reply, E, X};
handle_call(all, _From, X) -> 
    {reply, X, X};
handle_call(_, _From, X) -> {reply, X, X}.

all() ->
    gen_server:call(?MODULE, all).

make_rows(0, _) -> [];
make_rows(N, W) -> 
    [list_to_tuple(make_row(W))|
     make_rows(N-1, W)].
make_row(0) -> [];
make_row(N) -> 
    [#location{}|
     make_row(N-1)].

sanitize(X, Y) ->
    MW = settings:map_width(),
    MH = settings:map_height(),
    X2 = (X-1+MW) rem MW,
    Y2 = (Y-1+MH) rem MH,
    {X2+1, Y2+1}.

read(X, Y) ->
    {X2, Y2} = sanitize(X, Y),
    gen_server:call(?MODULE, {read, X2, Y2}).
read(X, Y, D) ->
    L = read(X, Y),
    D2 = twist(L#location.direction, D),
    L#location{direction = D2}.
twist(0, _) -> 0;
twist(X, X) -> 1;
twist(X, 1) -> X;
twist(1, 2) -> 3;
twist(3, 2) -> 4;
twist(4, 2) -> 2;
twist(1, 3) -> 2;
twist(2, 3) -> 4;
twist(4, 3) -> 3;
twist(1, 4) -> 4;
twist(2, 4) -> 3;
twist(3, 4) -> 2.
add_food(X, Y) ->
    {X2, Y2} = sanitize(X, Y),
    %S = "adding food " ++ integer_to_list(X2) ++ " " ++ integer_to_list(Y2) ++ "\n",
    %io:fwrite(S),
    gen_server:cast(?MODULE, {add_food, X2, Y2}).
remove_food(X, Y) ->
    {X2, Y2} = sanitize(X, Y),
    gen_server:cast(?MODULE, {remove_food, X2, Y2}).
change_tag(X, Y, T) ->
    {X2, Y2} = sanitize(X, Y),
    <<_:256>> = T,
    gen_server:cast(?MODULE, {change_tag, X2, Y2, T}).
add_animal(X, Y, AID, SID, Direction, Time) ->
    {X2, Y2} = sanitize(X, Y),
    case Direction of
        1 -> ok;
        2 -> ok;
        3 -> ok;
        4 -> ok
    end,
    gen_server:cast(?MODULE, 
                    {add_animal, X2, Y2, AID, 
                     SID, Direction, Time}).
animal_direction(X, Y, Direction) ->
    {X2, Y2} = sanitize(X, Y),
    case Direction of
        1 -> ok;
        2 -> ok;
        3 -> ok;
        4 -> ok
    end,
    gen_server:cast(
      ?MODULE, {animal_direction, X2, Y2, Direction}).
remove_animal(X, Y) ->
    {X2, Y2} = sanitize(X, Y),
    gen_server:cast(?MODULE, {remove_animal, X2, Y2}).
empty_location() ->
    gen_server:call(?MODULE, empty_location).
empty_location_internal(_, 0) ->
    full_board_error;
empty_location_internal(X, N) ->
    <<R1:40>> = crypto:strong_rand_bytes(5),
    <<R2:40>> = crypto:strong_rand_bytes(5),
    W = R1 rem settings:map_width(),
    H = R2 rem settings:map_height(),
    %Location = read(W, H),
    Row = element(H+1, X),
    Location = element(W+1, Row),
    case Location#location.animal_id of
        0 -> {W, H};
        _ -> empty_location_internal(X, N-1)
    end.

can_see(X, Y, 1) ->%up
    F = fun(X, Y) -> read(X, Y, 1) end,
    {F(X, Y),
     {F(X-1, Y+1), F(X, Y+1), F(X+1, Y+1)},
     {F(X-2, Y+2), F(X-1, Y+2), F(X, Y+2),
      F(X+1, Y+2), F(X+2, Y+2)}};
can_see(X, Y, 2) ->%left
    F = fun(X, Y) -> read(X, Y, 2) end,
    {F(X, Y),
     {F(X-1, Y-1), F(X-1, Y), F(X-1, Y+1)},
     {F(X-2, Y-2), F(X-2, Y-1), F(X-2, Y),
      F(X-2, Y+1), F(X-2, Y+2)}};
can_see(X, Y, 3) ->%right
    F = fun(X, Y) -> read(X, Y, 3) end,
    {F(X, Y),
     {F(X+1, Y+1), F(X+1, Y), F(X+1, Y-1)},
     {F(X+2, Y+2), F(X+2, Y+1), F(X+2, Y),
      F(X+2, Y-1), F(X+2, Y-2)}};
can_see(X, Y, 4) ->%down
    F = fun(X, Y) -> read(X, Y, 4) end,
    {F(X, Y),
     {F(X+1, Y-1), F(X, Y-1), F(X-1, Y-1)},
     {F(X+2, Y-2), F(X+1, Y-2), F(X, Y-2),
      F(X-1, Y-2), F(X-2, Y-2)}}.

view(X, Y, CanSee) ->
    %grab vision info for a point in the data from can_see
    case {X, Y} of
        {0, 0} -> element(1, CanSee);
        {-1, 1} -> 
            C = element(2, CanSee),
            element(1, C);
        {0, 1} ->
            C = element(2, CanSee),
            element(2, C);
        {1, 1} ->
            C = element(2, CanSee),
            element(3, C);
        {-2, 2} -> 
            C = element(3, CanSee),
            element(1, C);
        {-1, 2} -> 
            C = element(3, CanSee),
            element(2, C);
        {0, 2} -> 
            C = element(3, CanSee),
            element(3, C);
        {1, 2} -> 
            C = element(3, CanSee),
            element(4, C);
        {2, 2} -> 
            C = element(3, CanSee),
            element(5, C);
        _ ->
            not_visible_error
    end.
