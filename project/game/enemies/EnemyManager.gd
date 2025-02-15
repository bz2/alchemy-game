extends Node

const ENEMY_DB = {
	"carapa": preload("res://database/enemies/Carapa.gd"),
	"spawner_ooze": preload("res://database/enemies/SpawnerOoze.gd"),
	"baby_carapa": preload("res://database/enemies/BabyCarapa.gd"),
	"baby_carapa_plus": preload("res://database/enemies/BabyCarapaPlus.gd"),
	"big_buffer": preload("res://database/enemies/BigBuffer.gd"),
	"delayed_hitter": preload("res://database/enemies/DelayedHitter.gd"),
	"delayed_hitter_plus": preload("res://database/enemies/DelayedHitterPlus.gd"),
	"dodger": preload("res://database/enemies/Dodger.gd"),
	"poison": preload("res://database/enemies/Poisunculus.gd"),
	"baby_poison": preload("res://database/enemies/BabyOoze.gd"),
	"baby_poison_plus": preload("res://database/enemies/BabyOozePlus.gd"),
	"baby_slasher": preload("res://database/enemies/BabySlasher.gd"),
	"baby_retaliate": preload("res://database/enemies/BabyRetaliate.gd"),
	"big_divider" : preload("res://database/enemies/BigDivider.gd"),
	"medium_divider" : preload("res://database/enemies/MediumDivider.gd"),
	"small_divider" : preload("res://database/enemies/SmallDivider.gd"),
	"revenger" : preload("res://database/enemies/Revenger.gd"),
	"overkiller" : preload("res://database/enemies/Overkiller.gd"),
	"burner" : preload("res://database/enemies/Burner.gd"),
	"healer" : preload("res://database/enemies/Healer.gd"),
	"doomsday" : preload("res://database/enemies/Doomsday.gd"),
	"avenger" : preload("res://database/enemies/Avenger.gd"),
	"necromancer": preload("res://database/enemies/Necromancer.gd"),
	"zombie": preload("res://database/enemies/Zombie.gd"),
	"rager" : preload("res://database/enemies/Rager.gd"),
	"curser" : preload("res://database/enemies/Curser.gd"),
	"restrainer" : preload("res://database/enemies/Restrainer.gd"),
	"confuser" : preload("res://database/enemies/Confuser.gd"),
	"parasiter" : preload("res://database/enemies/Parasiter.gd"),
	"timing_bomber" : preload("res://database/enemies/TimingBomber.gd"),
	"elite_dodger" : preload("res://database/enemies/EliteDodger.gd"),
	"freezer" : preload("res://database/enemies/Freezer.gd"),
	"self_destructor" : preload("res://database/enemies/SelfDestructor.gd"),
	"boss_1" : preload("res://database/enemies/Boss1.gd"),
	"boss_2" : preload("res://database/enemies/Boss2.gd"),
	"boss_3_1" : preload("res://database/enemies/Boss3_1.gd"),
	"boss_3_2" : preload("res://database/enemies/Boss3_2.gd"),
}


func _ready():
	for enemy_name in ENEMY_DB.keys():
		var enemy = ENEMY_DB[enemy_name].new()
		assert(enemy is EnemyData)
		var actions : Dictionary = enemy.actions
		for state in actions.keys():
			var action_array : Array = actions[state]
			for action in action_array:
				assert(action is Dictionary)
				assert((action as Dictionary).has("animation"), 'Enemy %s: missing key "animation" for action in %s' % [enemy_name, state])


func create_object(enemy_type, player):
	if not ENEMY_DB.has(enemy_type):
		push_error("Given type of enemy doesn't exist: " + str(enemy_type))
		assert(false)
	
	var enemy_data = ENEMY_DB[enemy_type].new()
	var enemy = load(enemy_data.scene_path).instance()
	
	#Duplicate material so shader parameters only affect this object
	var mat_override = enemy.get_node("Sprite").get_material().duplicate()
	enemy.get_node("Sprite").set_material(mat_override)
	
	enemy.init(enemy_data.name, enemy_data.hp)
	enemy.enemy_type = enemy_type
	
	var logic = {"states":enemy_data.states,
				 "connections": enemy_data.connections,
				 "first_state": enemy_data.first_state,
				}

	enemy.setup(logic, load(enemy_data.image), enemy_data, player)
	return enemy


func get_data(enemy_type):
	if not ENEMY_DB.has(enemy_type):
		push_error("Given type of enemy doesn't exist: " + str(enemy_type))
		assert(false)
	
	return ENEMY_DB[enemy_type]
