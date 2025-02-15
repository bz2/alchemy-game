extends Resource
class_name Recipe

enum FILTERS {ATTACK, DEFENSE, AREA, BUFF, DEBUFF, HEAL, MISC}

var id

export(String) var name
export(int) var grid_size
export(String) var sfx := "drink_potion"
export(bool) var must_unlock := false
export(bool) var use_on_demo := false
export(int) var floor_sold_in
export(Array, String) var reagents
export(Array, String) var effects
export(Array, Array) var effect_args
export(Array, String) var destroy_reagents
export(String) var override_description
export(String) var override_short_description
export(Array, FILTERS) var filters = [FILTERS.ATTACK]
export(Texture) var fav_icon
export(int) var shop_cost
export(Array, String) var master_effects
export(Array, Array) var master_effect_args
export(Array, String) var master_destroy_reagents
export(String) var override_master_description
export(String) var override_master_short_description
export(Array, String) var reagent_combinations
