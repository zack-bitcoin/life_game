-module(board_cache).
-behaviour(gen_server).
-export([start_link/0,code_change/3,handle_call/3,handle_cast/2,handle_info/2,init/1,terminate/2,
        cron/0, draw_board/0, read/0]).
-include("records.hrl").
init(ok) -> {ok, []}.
start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, ok, []).
code_change(_OldVsn, State, _Extra) -> {ok, State}.
terminate(_, _) -> io:format("died!"), ok.
handle_info(_, X) -> {noreply, X}.
handle_cast(draw, X) -> 
    {noreply, draw_internal()};
handle_cast(_, X) -> {noreply, X}.
handle_call(read, _From, X) -> 
    {reply, X, X};
handle_call(_, _From, X) -> {reply, X, X}.

cron() ->
    timer:sleep(1000),
    spawn(fun()->
                 draw_board()
          end),
    cron().

draw_board() ->
    %todo check to see if we are ready to draw the next board.
    gen_server:cast(?MODULE, draw).

read() ->
    gen_server:call(?MODULE, read).

%-record(mini_loc, {
%          food = 0,
%          animal_id = 0,
%          species_id = 0,
%          direction = 0}).

draw_internal() ->
    %grab a bunch of data from the board.
    B = board:all(),
    W = settings:map_width(),
    H = settings:map_height(),
    draw2(1, 1, W, H, B).

draw2(W1, H1, W, H, B) 
  when (H1 > H) -> 
    B;
draw2(W1, H1, W, H, B) when (W1 > W) -> 
    draw2(1, H1+1, W, H, B);
draw2(W1, H1, W, H, B) -> 
    R = element(H1, B),
    L = element(W1, R),
    %Mini = #mini_loc{
    %  food = L#location.food,
    %  animal_id = L#location.animal_id,
    %  species_id = L#location.species_id,
    %  direction = L#location.direction
    % },
    Mini = {
      L#location.food,
      L#location.animal_id,
      L#location.direction,
      L#location.species_id
     },
    R2 = setelement(W1, R, Mini),
    B2 = setelement(H1, B, R2),
    draw2(W1+1, H1, W, H, B2).
    

    
    
