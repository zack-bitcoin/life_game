
-record(state, {
               display, 
          memory1,
          memory8,
          memory32,
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
        {id = 0, location, sid,
         health, energy, last_time,
         direction = 1, message = <<0:256>>,
         pain_front = 0, pain_left = 0,
         pain_right = 0, pain_back = 0,
         memory1, memory8, memory32
         }).

-record(species, {
          id, acc_id, animals = [], code
         }).
-record(location, {
          food = 0,
          tag = <<0:256>>,
          smell_species = 0,
          smell_age = 0,
          animal_id = 0,
          species_id = 0,
          direction = 0,
          day = 1
         }).