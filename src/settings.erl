-module(settings).
-compile(export_all).

tick_frequency() -> 60.%ticks per second 
day_period() -> 600 * tick_frequency().%every 10 minutes
year_period() -> 20 * day_period().
map_width() -> 100.
map_height() -> 100.
food_per_day() -> 100.
%todo. opcode costs.
wait_cost() -> 10.
step_cost() -> 100.
turn_cost() -> 100.
eat_cost() -> 100.
attack_cost() -> 100.
reproduce_cost() -> 100.
tag_cost() -> 100.
code_length_to_base_energy() -> 20.
healing_rate() -> 100.
health() -> 1000.
energy() -> 1000.
cooldown() -> 100.
attack_damage() -> 50.
    
    
    