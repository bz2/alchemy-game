extends Node

onready var player = $Player
onready var recipe_book = $BookLayer/RecipeBook
onready var shop = $Shop
onready var rest = $Rest
onready var smith = $Blacksmith

const BATTLE_SCENE = preload("res://game/battle/Battle.tscn")
const MAP_SCENE = preload("res://game/map/Map.tscn")
const RECIPES_REWARDED_PER_BATTLE = 3

var battle
var combinations := {}
var floor_level := 1
var times_recipe_made := {}
var favorite_combinations := []
var max_favorites := 8
var possible_rewarded_combinations := []
var map : Map
var current_node : MapNode


func _ready():
	# DEBUG
# warning-ignore:return_value_discarded
	Debug.connect("combinations_unlocked", self, "_on_Debug_combinations_unlocked")
# warning-ignore:return_value_discarded
	Debug.connect("floor_selected", self, "_on_Debug_floor_selected")
	
# warning-ignore:return_value_discarded
	rest.connect("combination_rewarded", self, "_on_combination_rewarded")
	
	randomize()
	create_combinations()
	
	if Debug.floor_to_go != -1:
		floor_level = Debug.floor_to_go
		player.set_level(floor_level)
	
	create_level(floor_level)
	
	play_map_bgm()

func _input(event):
	if event.is_action_pressed("show_recipe_book"):
		if not (battle and battle.player_disabled):
			recipe_book.toggle_visibility()

func play_map_bgm():
	AudioManager.play_bgm("map" + str(floor_level))

func create_combinations():
	for recipe in RecipeManager.recipes.values():
		var combination = Combination.new()
		combination.create_from_recipe(recipe)
		combination.connect("fully_discovered", self, "_on_Combination_fully_discovered")
		
		if combinations.has(combination.grid_size):
			(combinations[combination.grid_size] as Array).append(combination)
		else:
			combinations[combination.grid_size] = [combination]
		
		if player.known_recipes.has(recipe.name):
			combination.discover_all_reagents()
			recipe_book.add_combination(combination, player.known_recipes.find(recipe.name))


func create_level(level: int):
	EncounterManager.set_random_encounter_pool(level)
	
	# MAP
	map = MAP_SCENE.instance()
	add_child(map)
	match level:
		1:
			# ( *∀*)y─┛
			#  ______________
			# (̅_̅_̅_̅(̅_̅_̅_̅_̅_̅_̅_̅_̅̅_̅()ڪے~
			map.create_map(4, 2, 0)
		2:
			map.create_map(6, 3, 0)
		3:
			map.create_map(8, 4, 0)
		var invalid:
			assert(false, str("Invalid level: ", invalid))
	map.connect("map_node_pressed", self, "_on_map_node_selected")
	
	# SHOP
	for grid_size in combinations:
		for combination in combinations[grid_size]:
			if combination.recipe.floor_sold_in == level and not\
					player.known_recipes.has(combination.recipe.name):
				possible_rewarded_combinations.append(combination)
	
	setup_shop()


func get_incomplete_combinations():
	var incomplete_combinations = []
	for grid_size in combinations:
		for combination in combinations[grid_size]:
			if player.known_recipes.has(combination.recipe.name) and not combination.discovered:
				incomplete_combinations.append(combination)
	
	return incomplete_combinations


func setup_shop():
	var shop_combinations = []
	possible_rewarded_combinations.shuffle()
	for i in range(shop.sold_amount):
		if i < possible_rewarded_combinations.size():
			shop_combinations.append(possible_rewarded_combinations[i])
		else:
			shop_combinations.append(null)
	
	shop.setup(shop_combinations, player)


func get_combination_in_grid(reagent_matrix: Array) -> Combination:
	var grid_size = battle.grid.grid_size
	var grid_combination = get_combination_in_matrix(grid_size, reagent_matrix)
	
	if grid_combination:
		return grid_combination
	
	var new_grid_size = grid_size
	while new_grid_size > 2:
		new_grid_size -= 1
		var new_matrix = []
		for _i in range(new_grid_size):
			var line = []
			for _j in range(new_grid_size):
				line.append(null)
			new_matrix.append(line)
		
		for i_offset in range(grid_size - new_grid_size + 1):
			for j_offset in range(grid_size - new_grid_size + 1):
				
				for i in range(new_grid_size):
					for j in range(new_grid_size):
						new_matrix[i][j] = reagent_matrix[i+i_offset][j+j_offset]
				
				grid_combination = get_combination_in_matrix(new_grid_size, new_matrix)
				if grid_combination:
					return grid_combination
	
	return null


func get_combination_in_matrix(grid_size: int, reagent_matrix: Array) -> Combination:
	if not combinations.has(grid_size):
		print("No recipes exist for grid with size ", grid_size)
		return null
	
	for combination in combinations[grid_size]:
		if reagent_matrix == (combination as Combination).matrix:
			return combination
	
	return null


func make_combination(combination: Combination, boost_effects: Dictionary):
	var recipe := combination.recipe
	battle.apply_effects(recipe.effects, recipe.effect_args, recipe.destroy_reagents, boost_effects)
	
	if not player.known_recipes.has(recipe.name):
		MessageLayer.add_message("Oh yeah! I discovered a new recipe")
		combination.discover_all_reagents()
		player.discover_combination(combination, true)
		shop.update_combinations()
	elif not combination.discovered:
		combination.discover_all_reagents()
		recipe_book.update_combination(combination)
		shop.update_combinations()
	
	if not times_recipe_made.has(recipe.name):
		times_recipe_made[recipe.name] = 1
	else:
		times_recipe_made[recipe.name] += 1
	
	if should_unlock_mastery(combination):
		recipe_book.unlock_mastery(combination)
	


func should_unlock_mastery(combination: Combination) -> bool:
	if not times_recipe_made.has(combination.recipe.name):
		return false
	
	var threshold = min(10, 14 - combination.recipe.reagents.size())
	threshold = max(threshold, 2)
	
	return times_recipe_made[combination.recipe.name] > threshold


func new_battle(encounter: Encounter):
	assert(battle == null)
	battle = BATTLE_SCENE.instance()
	add_child(battle)
	
	battle.setup(player, encounter, favorite_combinations, floor_level)
# warning-ignore:return_value_discarded
	battle.connect("combination_made", self, "_on_Battle_combination_made")
# warning-ignore:return_value_discarded
	battle.connect("won", self, "_on_Battle_won")
# warning-ignore:return_value_discarded
	battle.connect("finished", self, "_on_Battle_finished")
# warning-ignore:return_value_discarded
	battle.connect("rewarded_combinations_seen", self, "_on_new_combinations_seen")
# warning-ignore:return_value_discarded
	battle.connect("combination_rewarded", self, "_on_combination_rewarded")
# warning-ignore:return_value_discarded
	battle.connect("grid_modified", self, "_on_Battle_grid_modified")
# warning-ignore:return_value_discarded
	battle.connect("recipe_book_toggle", self, "_on_Battle_recipe_book_toggle")
	
	recipe_book.create_hand(battle)


func open_shop():
	AudioManager.play_bgm("shop")
	map.hide()
	shop.update_currency()
	shop.update_reagents()
	shop.show()


func open_rest(room, _player):
	AudioManager.play_bgm("rest")
	rest.setup(room, _player, get_incomplete_combinations())
	rest.show()
	map.hide()


func open_smith(room, _player):
	AudioManager.play_bgm("blacksmith")
	smith.setup(room, _player)
	smith.show()
	map.hide()


func extract_boost_effects(reagents):
	var effects = {
		"all": 0,
		"damage": 0,
		"shield": 0,
		"status": 0,
		"heal": 0,
	}
	for reagent in reagents:
		if reagent.is_upgraded():
			var effect = ReagentDB.get_from_name(reagent.type).effect.upgraded_boost
			effects[effect.type] += effect.value
	return effects


func thanks_for_playing():
	var scene = load("res://game/ui/ThanksScreen.tscn").instance()
	add_child(scene)


func _on_Combination_fully_discovered(combination: Combination):
	possible_rewarded_combinations.erase(combination)


func _on_map_node_selected(node:MapNode):
	if node.type in [MapNode.ENEMY, MapNode.ELITE, MapNode.BOSS]:
		current_node = node
		new_battle(node.encounter)
		map.hide()
		node.set_type(MapNode.EMPTY)
	elif node.type == MapNode.SHOP:
		open_shop()
	elif node.type == MapNode.REST:
		open_rest(node, player)
	elif node.type == MapNode.SMITH:
		open_smith(node, player)


func _on_Battle_won():
	var rewarded_combinations := []
	
	if battle.is_boss:
		var size = min(player.grid_size + 1, player.GRID_SIZES.back())
		var indices = range(combinations[size].size())
		indices.shuffle()
		for i in RECIPES_REWARDED_PER_BATTLE:
			rewarded_combinations.append(combinations[size][i])
	else:
		possible_rewarded_combinations.shuffle()
		for i in RECIPES_REWARDED_PER_BATTLE:
			if i < possible_rewarded_combinations.size():
				rewarded_combinations.append(possible_rewarded_combinations[i])
			else:
				rewarded_combinations.append(null)
	
	battle.show_victory_screen(rewarded_combinations)


func _on_Battle_finished(is_boss):
	battle = null
	recipe_book.remove_hand()
	
	if is_boss:
		map.queue_free()
		floor_level += 1
		if floor_level <= Debug.MAX_FLOOR:
			create_level(floor_level)
			$Player.level_up()
		else:
			map.show()
			thanks_for_playing()
	else:
		map.show()
		map.reveal_paths(current_node)


func _on_new_combinations_seen(new_combinations: Array):
	for combination in new_combinations:
		if combination:
			player.discover_combination(combination)


func _on_combination_rewarded(combination):
	recipe_book.update_combination(combination)


func _on_Battle_combination_made(reagent_matrix: Array, reagent_list: Array):
	var combination = get_combination_in_grid(reagent_matrix)
	if combination:
		AudioManager.play_sfx("combine_success")
		#Fix unstable reagents
		for reagent in reagent_list:
			if reagent.unstable:
				reagent.toggle_unstable()
		make_combination(combination, extract_boost_effects(reagent_list))
	else:
		AudioManager.play_sfx("combine_fail")
		battle.apply_effects(["combination_failure"], reagent_list)


func _on_Battle_grid_modified(reagent_matrix: Array):
	var combination = get_combination_in_grid(reagent_matrix)
	if combination and not combination.discovered:
		combination = null
	
	battle.display_name_for_combination(combination)


func _on_Battle_recipe_book_toggle():
	recipe_book.toggle_visibility()


func _on_Player_combination_discovered(combination, index):
	recipe_book.add_combination(combination, index)


func _on_RecipeBook_recipe_pressed(combination: Combination, mastery_unlocked: bool):
	assert(battle.grid.grid_size >= combination.grid_size)
	recipe_book.toggle_visibility()
	if mastery_unlocked:
		battle.autocomplete_grid(combination)
	else:
		battle.grid.show_combination_hint(combination)


func _on_RecipeBook_favorite_toggled(combination, button_pressed):
	if button_pressed:
		if favorite_combinations.size() >= max_favorites:
			recipe_book.favorite_error(combination)
		else:
			AudioManager.play_sfx("apply_favorite")
			favorite_combinations.append(combination)
			if battle:
				battle.add_favorite(combination)
	else:
		favorite_combinations.erase(combination)
		if battle:
			battle.remove_favorite(combination)


func _on_Shop_closed():
	shop.hide()
	map.show()
	play_map_bgm()


func _on_Shop_combination_bought(combination: Combination):
	recipe_book.update_combination(combination)


func _on_Shop_hint_bought(combination: Combination):
	recipe_book.update_combination(combination)


func _on_Debug_combinations_unlocked():
	if not Debug.recipes_unlocked:
		Debug.recipes_unlocked = true
		for grid_size in [2, 3, 4]:
			for combination in combinations[grid_size]:
				combination.discover_all_reagents()
				recipe_book.add_combination(combination,
						player.known_recipes.bsearch(combination.recipe.name))
				recipe_book.update_combination(combination)


func _on_Debug_floor_selected(floor_number: int):
	if battle:
		battle.queue_free()
		battle = null
	if map:
		map.queue_free()
	
	create_level(floor_number)
	player.set_level(floor_number)


func _on_Rest_closed():
	rest.hide()
	map.show()
	play_map_bgm()


func _on_Blacksmith_closed():
	smith.hide()
	map.show()
	play_map_bgm()
