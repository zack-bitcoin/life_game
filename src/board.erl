-module(board).
-behaviour(gen_server).
-export([start_link/0,code_change/3,handle_call/3,handle_cast/2,handle_info/2,init/1,terminate/2,
read/2,add_food/2,remove_food/2,change_tag/3,add_account/6,account_direction/3,remove_account/2]).
-record(location, {
          food = false,
          tag = <<0:256>>,
          smell_species = 0,
          smell_age = 0,
          account_id = 0,
          species_id = 0,
          direction = 0
         }).
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
    L2 = L#location{food = false},
    R2 = setelement(W, R, L2),
    X2 = setelement(H, X, R2),
    {noreply, X2};
handle_cast({add_food, W, H}, X) -> 
    R = element(H, X),
    L = element(W, R),
    L2 = L#location{food = true},
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
handle_cast({add_account, W, H, AID, 
             SID, Direction, Time}, 
            X) -> 
    R = element(H, X),
    L = element(W, R),
    #location{account_id = AID0} = L,
    case AID0 of
        0 ->
            L2 = L#location{
                  account_id = AID,
                  direction = Direction,
                  species_id = SID,
                  smell_species = SID,
                  smell_age = Time},
            R2 = setelement(W, R, L2),
            X2 = setelement(H, X, R2),
            {noreply, X2};
        _ -> {noreply, X}
    end; 
handle_cast({account_direction, W, H, D}, X) ->
    R = element(H, X),
    L = element(W, R),
    L2 = L#location{direction = D},
    R2 = setelement(W, R, L2),
    X2 = setelement(H, X, R2),
    {noreply, X2};
handle_cast({remove_account, W, H}, X) -> 
    R = element(H, X),
    L = element(W, R),
    L2 = L#location{
           direction = 0,
           species_id = 0,
           account_id = 0
          },
    R2 = setelement(W, R, L2),
    X2 = setelement(H, X, R2),
    {noreply, X2};
handle_cast(_, X) -> {noreply, X}.
handle_call({read, W, H}, _From, X) -> 
    R = element(H, X),
    L = element(W, R),
    {reply, L, X};
handle_call(_, _From, X) -> {reply, X, X}.

make_rows(0, _) -> [];
make_rows(N, W) -> 
    [list_to_tuple(make_row(W))|
     make_rows(N-1, W)].
make_row(0) -> [];
make_row(N) -> 
    [#location{}|
     make_row(N-1)].

read(X, Y) ->
    gen_server:call(?MODULE, {read, X, Y}).
add_food(X, Y) ->
    gen_server:cast(?MODULE, {add_food, X, Y}).
remove_food(X, Y) ->
    gen_server:cast(?MODULE, {remove_food, X, Y}).
change_tag(X, Y, T) ->
    <<_:256>> = T,
    gen_server:cast(?MODULE, {change_tag, X, Y, T}).
add_account(X, Y, AID, SID, Direction, Time) ->
    case Direction of
        1 -> ok;
        2 -> ok;
        3 -> ok;
        4 -> ok
    end,
    gen_server:cast(?MODULE, 
                    {add_account, X, Y, AID, 
                     SID, Direction, Time}).
account_direction(X, Y, Direction) ->
    case Direction of
        1 -> ok;
        2 -> ok;
        3 -> ok;
        4 -> ok
    end,
    gen_server:cast(
      ?MODULE, {account_direction, X, Y, Direction}).
remove_account(X, Y) ->
    gen_server:cast(?MODULE, {remove_account, X, Y}).
                              
