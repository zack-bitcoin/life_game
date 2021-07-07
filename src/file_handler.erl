-module(file_handler).

-export([init/2, init/3, handle/2, terminate/3]).
%example of talking to this handler:
%httpc:request(post, {"http://127.0.0.1:3011/", [], "application/octet-stream", "echo"}, [], []).
%curl -i -d '[-6,"test"]' http://localhost:3011
init(Req, Opts) ->
	handle(Req, Opts).
handle(Req, State) ->
    F0 = cowboy_req:path(Req),
    %PrivDir0 = "../../../../js",
    PrivDir0 = "js",
    PrivDir = list_to_binary(PrivDir0),
    F = case F0 of
	       <<"/blue_left.png">> -> F0;
	       <<"/blue_right.png">> -> F0;
	       <<"/light_blue_left.png">> -> F0;
	       <<"/light_blue_right.png">> -> F0;
	       <<"/cyan_left.png">> -> F0;
	       <<"/cyan_right.png">> -> F0;
	       <<"/green_left.png">> -> F0;
	       <<"/green_right.png">> -> F0;
	       <<"/orange_left.png">> -> F0;
	       <<"/orange_right.png">> -> F0;
	       <<"/pink2_left.png">> -> F0;
	       <<"/pink2_right.png">> -> F0;
	       <<"/pink_left.png">> -> F0;
	       <<"/pink_right.png">> -> F0;
	       <<"/red_left.png">> -> F0;
	       <<"/red_right.png">> -> F0;
	       <<"/white_left.png">> -> F0;
	       <<"/white_right.png">> -> F0;
	       <<"/yellow_left.png">> -> F0;
	       <<"/yellow_right.png">> -> F0;
	       <<"/up.png">> -> F0;
	       <<"/left.png">> -> F0;
	       <<"/right.png">> -> F0;
	       <<"/down.png">> -> F0;
	       <<"/empty.png">> -> F0;
	       <<"/grey.png">> -> F0;
	       <<"/main.html">> -> F0;
	       <<"/board.html">> -> F0;
	       <<"/make_animal.html">> -> F0;
	       <<"/favicon.ico">> -> F0;
	       <<"/board.js">> -> F0;
	       <<"/canvas.js">> -> F0;
	       <<"/rpc.js">> -> F0;
	       <<"/BigInteger.js">> -> F0;
	       <<"/chalang_compiler.js">> -> F0;
	       <<"/chalang_jit.js">> -> F0;
	       <<"/chalang.js">> -> F0;
	       <<"/codecBytes.js">> -> F0;
	       <<"/compiler_interface.js">> -> F0;
	       <<"/crypto.js">> -> F0;
	       <<"/elliptic.min.js">> -> F0;
	       <<"/encryption.js">> -> F0;
	       <<"/encryption_library.js">> -> F0;
	       <<"/files.js">> -> F0;
	       <<"/format.js">> -> F0;
	       <<"/keys.js">> -> F0;
	       <<"/lisp_compiler.js">> -> F0;
	       <<"/merkle_proofs.js">> -> F0;
	       <<"/server.js">> -> F0;
	       <<"/sha256.js">> -> F0;
	       <<"/signing.js">> -> F0;
	       <<"/sjcl.js">> -> F0;
	       %<<"/favicon.ico">> -> F0;
               X -> 
                io:fwrite("ext file handler block access to: "),
                io:fwrite(X),
                io:fwrite("\n"),
                <<"/main.html">>
           end,
    %File = << PrivDir/binary, <<"/external_web">>/binary, F/binary>>,
    File = << PrivDir/binary, F/binary>>,
    %io:fwrite(File),
    %io:fwrite("\n"),
    {ok, _Data, _} = cowboy_req:read_body(Req),
    Headers = #{<<"content-type">> => <<"text/html">>,
    <<"Access-Control-Allow-Origin">> => <<"*">>},
    Text = read_file(File),
    Req2 = cowboy_req:reply(200, Headers, Text, Req),
    {ok, Req2, State}.
read_file(F) ->
    {ok, File } = file:open(F, [read, binary, raw]),
    {ok, O} =file:pread(File, 0, filelib:file_size(F)),
    file:close(File),
    O.
init(_Type, Req, _Opts) -> {ok, Req, []}.
terminate(_Reason, _Req, _State) -> ok.
