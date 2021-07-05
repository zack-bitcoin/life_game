-module(test).
-export([doit/0]).


doit() ->
   
%             macro [ nil ;\
%macro , swap cons ;\
%macro ] swap cons reverse ;\
    %create the species
    %4 -> eat
    %2 -> walk
    %5 -> attack
    %6 -> reproduce
    Code = compiler_chalang:doit(<<"\

%recursion crash test
% def recurse call ; call

%eating
 smell_food if int 4 int 30 swap return else then 

%turning
 smell_animal car drop if int 40 int 3 return else then 

%attacking
% smell_animal car drop if int 30 int 5 return else then 

%reproducing
energy int 100000 > if int 30 int 6 return else then 

%tagging
% random int 4 split swap drop int 10 rem int 0 =2 if binary 32 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAo= int 30 int 7 return else then

%testing memory
%int 5 @1 print drop
%int 1 int 5 !1

%int 5 @8 print drop
%int 255 int 5 !8

%int 5 @32 print drop
%binary 32 AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAo= int 5 !32

%test crashing
%random int 4 split swap drop int 10 rem int 0 =2 if + + +  return else then

%walking
int 2 int 25 swap
">>),
    AccID = <<"account1">>,
    SID = species:new(AccID, Code),

    Location = {50,50},%board:empty_location(),
    Animal = animals:empty_animal(SID, Location, 0),
    birthing:add_animal(Animal).
