extends Node

var recipes = {}


func _ready():
	var dir := Directory.new()
	var path := "res://database/recipes/"
	if dir.open(path) == OK:
# warning-ignore:return_value_discarded
		dir.list_dir_begin()
		var file_name := dir.get_next() as String
		while file_name != "":
			if not dir.current_is_dir() and file_name.get_extension() == "tres":
				var recipe := load(str(path, file_name)) as Recipe
				# DEBUG
				if recipe.reagents.size() < 2:
					push_error("RecipeManager: %s has less than 2 reagents" % str(path, file_name))
					assert(false)
				if recipe.effects.size() != recipe.effect_args.size():
					push_error("RecipeManager: %s effect and arguments size mismatch" % str(path, file_name))
					assert(false)
				
				recipe.id = file_name.replace(".tres", "")
				recipes[recipe.id] = recipe
			file_name = dir.get_next()
	else:
		print("RecipeManager: An error occurred when trying to access the path.")


func update_recipes_reagent_combinations():
	for recipe in recipes.values():
		recipe.reagent_combinations = []
		var reagent_arrays_to_check = [recipe.reagents.duplicate()]
		var reagent_arrays_viewed = [recipe.reagents.duplicate()]
		while not reagent_arrays_to_check.empty():
			var cur_reagents_array = reagent_arrays_to_check.pop_front()
			cur_reagents_array.sort()
			recipe.reagent_combinations.append(cur_reagents_array)
			for upgraded_array in ReagentManager.upgraded_arrays(cur_reagents_array):
				var unique = true
				for array_viewed in reagent_arrays_viewed:
					if ReagentManager.is_same_reagent_array(array_viewed, upgraded_array):
						unique = false
						break
				if unique:
					reagent_arrays_to_check.append(upgraded_array)
					reagent_arrays_viewed.append(upgraded_array)
		var err = ResourceSaver.save(recipe.resource_path, recipe)
		assert(not err, "Something went wrong trying to save recipe resource: " + str(recipe.name) + " Error:" + str(err))


func get_short_description(recipe, is_master := false):
	var text = ""
	if is_master:
		if recipe.override_master_short_description and recipe.override_master_short_description != "":
			return recipe.override_master_short_description
		text += describe_effects(recipe.master_effects, recipe.master_effect_args, true)
	else:
		if recipe.override_short_description and recipe.override_short_description != "":
			return recipe.override_short_description
		text += describe_effects(recipe.effects, recipe.effect_args, true)
	
	return text


func get_description(recipe, is_master := false):
	var text = ""
	if is_master:
		if recipe.override_master_description and recipe.override_master_description != "":
			return recipe.override_master_description
		text += describe_effects(recipe.master_effects, recipe.master_effect_args)
		text += describe_destructions(recipe.reagents, recipe.master_destroy_reagents)
	else:
		if recipe.override_description and recipe.override_description != "":
			return recipe.override_description
		text += describe_effects(recipe.effects, recipe.effect_args)
		text += describe_destructions(recipe.reagents, recipe.destroy_reagents)
	
	return text

func get_tooltip(recipe, mastered):
	var tooltip = {}
	tooltip.title = tr(recipe.name)
	if mastered:
		tooltip.title += "+"
	tooltip.title_image = recipe.fav_icon
	if mastered:
		tooltip.subtitle = tr("MASTERED_RECIPE")
		tooltip.text = get_description(recipe, true)
	else:
		tooltip.subtitle = tr("RECIPE")
		tooltip.text = get_description(recipe, false)
	return tooltip


func describe_destructions(reagents, destroyed_reagents):
	var text = ""
	var copy_destroyed = destroyed_reagents.duplicate()
	
	while not copy_destroyed.empty():
		var destroyed_reagent = copy_destroyed.pop_front()
		var reagent_name = ReagentManager.get_data(destroyed_reagent).name
		#Search for how many of this type is being destroyed
		var count = 1
		for i in range(copy_destroyed.size()-1, -1, -1):
			if copy_destroyed[i] == destroyed_reagent:
				count += 1
				copy_destroyed.remove(i)
		#Count how many reagents in the recipe of this type are there
		var recipe_count = 0
		for reagent in reagents:
			if reagent == destroyed_reagent:
				recipe_count += 1
		text += " "
		if recipe_count == count and count > 1:
			text += tr("DESC_DESTROY_REAGENTS_ALL") % [tr(reagent_name)]
		elif count > 1:
			text += tr("DESC_DESTROY_REAGENTS_SOME") % [count, tr(reagent_name)]
		elif recipe_count == count:
			text += tr("DESC_DESTROY_REAGENTS_ONLY") % [tr(reagent_name)]
		else:
			text += tr("DESC_DESTROY_REAGENTS_ONE") % [tr(reagent_name)]
	
	return text


func describe_effects(effects_list, effect_args, short:= false):
	var short_text = "SHORT_" if short else "" 
	var text = ""
	var i = 0
	while(i < effects_list.size()):
		if i > 0:
			text += " "
		var effect = effects_list[i]
		var args = effect_args[i]
		if effect == "damage":
			#Check for multiple attacks
			var count = 1
			for j in range(i+1, effects_list.size()):
				if effects_list[j] == "damage" and effect_args[i][1] == effect_args[i][1]:
					count += 1
					i += 1
				else:
					break
			if count == 1:
				text += tr("DESC_"+short_text+"DAMAGE_SINGLE") % [args[0], tr(args[1].to_upper()+"_DAMAGE")]
			else:
				text += tr("DESC_"+short_text+"DAMAGE_MULT") % [args[0], tr(args[1].to_upper()+"_DAMAGE"), count]
		elif effect == "damage_all":
			text += tr("DESC_"+short_text+"DAMAGE_ALL") % [args[0], tr(args[1].to_upper()+"_DAMAGE")]
		elif effect == "damage_self":
			text += tr("DESC_"+short_text+"DAMAGE_SELF") % [args[0], tr(args[1].to_upper()+"_DAMAGE")]	
		elif effect == "heal":
			text += tr("DESC_"+short_text+"HEAL") % [args[0]]
		elif effect == "reduce_status":
			var status = StatusDB.get_from_name(args[1])["title_name"]
			if args[0] == "self":
				text += tr("DESC_"+short_text+"REDUCE_STATUS_SELF") % [args[2], tr(status)]
		elif effect == "draw":
			text += tr("DESC_"+short_text+"DRAW") % [args[0]]
		elif effect == "shield":
			text += tr("DESC_"+short_text+"SHIELD") % [args[0]]
		elif effect == "drain":
			text += tr("DESC_"+short_text+"DRAIN") % [args[0]]
		elif effect == "add_status":
			var status = StatusDB.get_from_name(args[1])["title_name"]
			if args[0] == "enemy":
				text += tr("DESC_"+short_text+"STATUS_ENEMY") % [args[2], tr(status)]
			elif args[0] == "self":
				text += tr("DESC_"+short_text+"STATUS_SELF") % [args[2], tr(status)]
		elif effect == "add_status_all":
			var status = StatusDB.get_from_name(args[0])["title_name"]
			text += tr("DESC_"+short_text+"STATUS_ALL") % [args[1], tr(status)]
				
		i += 1
		
	return text
