(function() {
    var div = document.createElement("div");
    document.body.appendChild(div);
    div.appendChild(br());

    var result = document.createElement("div");

    load_examples(5, [
        ["basic", `

%walks forward until it finds food. turns if something is blocking it.

macro cooldown 30 ;
macro eat cooldown 4 return ;
macro turn cooldown 3 return ;
macro reproduce cooldown 6 return ;
macro walk cooldown 2 return ;

%eating
 smell_food if eat else then 

%turning
 smell_animal car drop if turn else then 

%reproducing
energy 100000 > if reproduce else then 

%walking
walk

`],
        ["aggresive", `

% walks forward until it finds food. attacks anything that blocks it.

macro cooldown 30 ;
macro eat cooldown 4 return ;
macro attack 9 5 return ;
macro turn cooldown 3 return ;
macro reproduce cooldown 6 return ;
macro walk cooldown 2 return ;


%eating
 smell_food if eat else then 

%attacking
 smell_animal car drop if attack else then 

%reproducing
energy 100000 > if reproduce else then 

%walking
walk


`],
        ["scared", `
%walks forward until it finds food.
%turns if something is blocking it.
%runs away if it feels pain.

macro cooldown 30 ;
macro eat cooldown 4 return ;
macro attack 9 5 return ;
macro turn cooldown 3 return ;
macro quick_turn 8 3 return ;
macro reproduce cooldown 6 return ;
macro walk cooldown 2 return ;

2 @1 if 0 2 !1 walk else then

pain_front if 
 1 2 !1
quick_turn else then

%eating
 smell_food if eat else then 

%turning
 smell_animal car drop if attack else then 

%reproducing
energy 100000 > if reproduce else then 

%walking
walk

`],
        ["loyal", `

%walks forward until it finds food.
%attacks anything other than it's own species that blocks it.
%turns if it's own species is blocking it.

macro cooldown 30 ;
macro eat cooldown 4 return ;
macro attack 9 5 return ;
macro turn cooldown 3 return ;
macro reproduce cooldown 6 return ;
macro walk cooldown 2 return ;

macro my_species 2 ;

%find out own species
my_species @8 if else
0 0 look car swap drop car drop my_species !8 then

%eating
 smell_food if eat else then 

%turning
 smell_animal car drop my_species @8 == if turn else then

%attacking
 smell_animal car drop if attack else then 

%reproducing
energy 100000 > if reproduce else then 

%walking
walk

`]
    ]);

    div.appendChild(br());

    var text = document.createElement("textarea");
    text.rows = 20;
    text.cols = 60;

    div.appendChild(text);
    div.appendChild(br());

    
    var compile = button_maker2(
        "create this species",
        async function(){
            var code = text.value;
            var s = chalang_compiler.doit(code);
            s = btoa(array_to_string(s));
            var response = await rpc.apost(["add", s]);
            text.value = "";
            link.href = "board.html?focus=".concat(response);
            link.innerHTML = "view your animal in red";
            link.target = "_blank";
            //console.log(response);
        });
    div.appendChild(compile);
    div.appendChild(br());
    var link = document.createElement("a");
    div.appendChild(link);
    
    //div.appendChild(result);
    //div.appendChild(br());


    /*
    function run(code){
        var d = chalang_object.data_maker(
            1000000000, 1000000000, 100, 100, [], [],
            chalang_object.new_state(0, 0));
        var result = chalang_object.run5(code, d);
        return(result.stack);
    };
    */

    function load_examples(cols, pairs){
        return(load_examples2(cols, cols, pairs));
    }
    function load_examples2(n, cols, pairs){
        if(pairs.length === 0){
            return(0);
        };
        var pair = pairs[0];
        var button = button_maker2(
            pair[0],
            function(){
                result.innerHTML = "";
                text.value = pair[1];
            });
        div.appendChild(button);
        var n2;
        if(n === 1){
            n2 = cols;
            div.appendChild(br());
        } else {
            n2 = n-1;
        }
        return(load_examples2(n2, cols, pairs.slice(1)));
    };

})();
