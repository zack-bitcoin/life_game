Map
============

it is a torus.
during night food spawns more slowly.
you can't see things on tiles that are in night.
at the upper/lower extremes, the night-period is longer or shorter depending on the season, there is an "arctic ring", which is perpetually in night or day for much of the year.

There is a gradient from rich to poor soil that changes from left to right.
Rich soil locations produce food more rapidly.

Food appears randomly, and also there is food when an animal dies.

locations can have smells from animals.
locations can have a tag.
locations can contain up to one animal.
locations can contain up to one food.


language
=======

base it on chalang.

35 values (stores that integer on the stack)
integer1 (reads a byte as an integer)
integer2 (reads 2 bytes as an integer)
integer4 (reads 4 bytes as an integer)

binary ( N -> binary ) (reads N bytes as a binary)
print ( does nothing. only for testing purposes. )
end ( ends execution here )
drop dup swap tuck rot 2dup tuckn pickn >r r> r@
+ - * / > < ^ rem == ==2
if else then
not and or xor band bor bxor
: ; recurse call def
! @ %storing variables in short term memory. forgotten by the next activation of this animal.
cons car nil ++ split reverse

# senses 
display ( -> )  %display a 32 byte message on your body that can be smelled.
memorize_bit ( key value -> ) %store data you memorized. is available for future activations of this animal by using "recall".
recall_bit ( key -> value ) %if empty, returns 0
memorize_byte ( key value -> ) 
recall_byte ( key -> value )
memorize_32_bytes ( key value -> )
recall_32_bytes ( key -> value )
look ( x y -> 0||[animal, species, direction, food] ) %cannot see at night. looking further costs more.
smell_animal ( -> 0||[species, message])
smell_tile ( -> [recent_visitor, how_long_since_visitor])
smell_tile_tag ( -> tag)
smell_food( -> boolean)
pain_front ( -> boolean)
pain_left ( -> boolean)
pain_right ( -> boolean)
pain_back ( -> boolean)
check_energy ( -> energy_level )
check_health ( -> health_level )
check_random ( -> random ) (a random value generated for this animal at this point in time.)
check_time ( -> time_now )


% actions
wait ( cooldown -> ) %does nothing. costs little energy.
step ( cooldown -> ) 
turn ( direction cooldown -> ) %right left or back
eat ( cooldown -> ) %eats food on the same tile
attack ( cooldown -> ) %attacks an animal in front, if it exists.
reproduce ( cooldown -> ) (expensive by code length) (needs to cost more than you would get from eating the animal.) (the baby has the same memories as the mother, except one bit is always set to zero. so that the programmer can control the baby differently if they want to.)
tag_tile ( 32 bytes cooldown -> )
% All actions have a cooldown period. The longer the cooldown, the less the action costs. 4x cooldown means 1/2x the cost. You don't have senses or movement during a cooldown, the animal is paralyzed.
% Your code always ends with an action. if the code fails for any reason, it stops execution, and waits for the cooldown. if a cooldown can't be determined, it uses the default value stored for that animal.


api
============
* add animal: (code -> sid). look at test:doit()
* look at board: board_cache:read().
* lookup species_code: species:read(ID). then grab code part.
* lookup species_animals: species:read(ID). then grab animals part.
* lookup animal: animals:read(ID).



* add account: (pub name -> ).
* lookup account: (pub/aid -> balance, points, species)





