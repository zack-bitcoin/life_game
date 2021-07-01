
-record(state, {
          memorized_bits,
          memorized_bytes,
          memorized_32s,
          can_see,%some sort of structure containing visual information about everything we can see.
          smell_animal,%0||[species, message]
          smell_tile,%0||[recent_visitor, how long_since_visitor]
          smell_tile_tag,%32 byte tag
          smell_food,
          pain_front,
          pain_left,
          pain_right,
          pain_back,
          energy,
          health,
          random,
          time
	 }).

-record(animal, 
        {id = 0, acc_id, sid, health, energy,
         memory, default_cooldown,
         direction, location, last_time,
         pain_front, pain_left, pain_right, 
         pain_back}).

-record(species, {
          id, animals = [], code
         }).