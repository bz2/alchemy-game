extends TextureRect

var current_reagent = null

func get_reagent():
	return current_reagent

func set_reagent(reagent):
	if reagent.slot:
		reagent.slot.remove_reagent()
	current_reagent = reagent
	reagent.slot = self
	reagent.target_position = $Area2D.global_position

func remove_reagent():
	current_reagent = null
