-module(settings).
-compile(export_all).

tick_frequency() -> 60.%ticks per second 
day_period() -> 60 * tick_frequency().
year_period() -> 20 * day_period().
map_width() -> 100.
map_height() -> 100.
food_per_day() -> 1000.
energy_in_food() -> energy() div 2.
%todo. opcode costs.
wait_cost() -> 5.
step_cost() -> 100.
turn_cost() -> 10.
eat_cost() -> 100.
attack_cost() -> 100.
reproduce_cost() -> 100.
tag_cost() -> 100.
code_length_to_base_energy() -> {1,1}.
healing_rate() -> 100.
health() -> 1000.
energy() -> 50000.
cooldown() -> 100.
attack_damage() -> 300.
storage_bit() -> 32.
storage_byte() -> 32.
storage_32() -> 32.
board_refresh_rate() -> 2.
planet_pronation() ->  0.2.%how big is the arctic circle.
    
    
    
