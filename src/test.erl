-module(test).
-export([doit/0]).


doit() ->
   
%             macro [ nil ;\
%macro , swap cons ;\
%macro ] swap cons reverse ;\
    %create the species
    %4 -> eat
    %2 -> walk
    %6 -> reproduce
    Code = compiler_chalang:doit(<<"\
 smell_food if int 4 else 
energy int 100000 > if int 6 else int 2 then
then\
int 40 swap\
">>),
    AccID = <<"account1">>,
    SID = species:new(AccID, Code),

    Location = {50,50},%board:empty_location(),
    Animal = animals:empty_animal(SID, Location, 0),
    birthing:add_animal(Animal).
