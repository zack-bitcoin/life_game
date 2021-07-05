-module(http_handler).

-export([init/3, handle/2, terminate/3, doit/1,
	init/2]).
%example of talking to this handler:
%httpc:request(post, {"http://127.0.0.1:3010/", [], "application/octet-stream", "echo"}, [], []).
%curl -i -d '["test"]' http://localhost:3011
-include("records.hrl").
init(Req0, Opts) ->
    handle(Req0, Opts).	
handle(Req, State) ->
    {ok, Data, Req2} = cowboy_req:read_body(Req),
    {IP, _} = cowboy_req:peer(Req2),
    D = case ok of %request_frequency:doit(IP) of
	    ok ->
						%ok = request_frequency:doit(IP),
		%{ok, TimesPerSecond} = application:get_env(amoveo_core, request_frequency),
		%timer:sleep(round(1000/TimesPerSecond)),
		true = is_binary(Data),
		A = packer:unpack(Data),
                B = doit(A),
		packer:pack(B);
	    _ -> 
                io:fwrite("spammer's ip: "),
                io:fwrite(packer:pack(IP)),
                io:fwrite("\n"),
		packer:pack({ok, <<"stop spamming the server">>})
	end,	    

    Headers = #{ <<"content-type">> => <<"application/octet-stream">>,
	       <<"Access-Control-Allow-Origin">> => <<"*">>},
    %Headers = [{<<"content-type">>, <<"application/octet-stream">>},
%	       {<<"Access-Control-Allow-Origin">>, <<"*">>}],
    Req4 = cowboy_req:reply(200, Headers, D, Req2),
    {ok, Req4, State}.
init(_Type, Req, _Opts) -> {ok, Req, no_state}.
terminate(_Reason, _Req, _State) -> ok.
doit({add, Code}) ->
    %check code is smaller than a max.
    true = is_binary(Code),
    SID = species:new(<<"none">>, Code),
    Animal = animals:empty_animal(SID, board:empty_location(), 0),
    birthing:add_animal(Animal),
    {ok, SID};
doit({read}) ->
    {ok, board_cache:read()};
doit({read, 1, ID}) ->
    {ok, animals:read(ID)};
doit({read, 2, 1, ID}) ->
    {ok, (species:read(ID))#species.code};
doit({read, 2, 2, ID}) ->
    {ok, (species:read(ID))#species.animals};
doit(X) ->
    io:fwrite("I can't handle this \n"),
    io:fwrite(packer:pack(X)), %unlock2
    {error}.
