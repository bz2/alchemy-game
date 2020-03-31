tool

extends Control

signal grid_cleaned

const GRIDSLOT = preload("res://test/battle/Grid/GridSlot.tscn")
const MARGIN = 30

onready var Grid = $GridContainer
onready var RecipeButton = $CreateRecipe 

var DiscardBag = null #Setted by parent

func _ready():
	set_grid(3)

func set_grid(size):
	assert(size > 0)
	for child in Grid.get_children():
		Grid.remove_child(child)
	Grid.columns = size
	for _i in range(size*size):
		Grid.add_child(GRIDSLOT.instance())
	var slot = Grid.get_child(1)
	
	#Position button correctly
	var scale = RecipeButton.rect_scale.x
	RecipeButton.rect_position.y = slot.rect_size.y * size + MARGIN
	RecipeButton.rect_position.x = slot.rect_size.x*size/2 - RecipeButton.rect_size.x*scale/2

func is_empty():
	for slot in Grid.get_children():
		var reagent = slot.get_reagent()
		if reagent:
			return false
	return true

func clean_grid():
	var reagents_to_be_discarded = []
	for slot in Grid.get_children():
		var reagent = slot.get_reagent()
		if reagent:
			slot.remove_reagent()
			reagents_to_be_discarded.append(reagent)
	
	while not reagents_to_be_discarded.empty():
		var reagent = reagents_to_be_discarded.pop_back()
		DiscardBag.discard(reagent)
		if not reagents_to_be_discarded.empty():
			randomize()
			yield(get_tree().create_timer(rand_range(.1, .3)), "timeout")
		else:
			yield(DiscardBag, "discarded_reagent")

	emit_signal("grid_cleaned")

func disable():
	RecipeButton.disabled = true
	

func enable():
	RecipeButton.disabled = false

func _on_CreateRecipe_pressed():
	clean_grid()
