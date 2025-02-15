extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/BabyPoisonPlus.tscn"
var image = "res://assets/images/enemies/small poison enemy plus/idle.png"
var name = "EN_BABY_OOZE_PLUS"
var sfx = "oozeling-plus"
var use_idle_sfx = false
var hp = 90
var battle_init = true
var size = "small"
var change_phase = null

var states = ["init", "poison", "defend-poison", "medium-poison"]
var connections = [
					  ["init", "poison", 1],
					  ["poison", "defend-poison", 5],
					  ["poison", "medium-poison", 3],
					  ["defend-poison", "medium-poison", 1],
					  ["medium-poison", "defend-poison", 1],
				  ]
var first_state = ["init"]

var actions = {
	"init": [
		{"name": "shield", "value": 30, "animation": ""}
	],
	"poison": [
		{"name": "damage", "value": [12,20], "type": "venom", "animation": "02_atk"}
	],
	"medium-poison": [
		{"name": "status", "status_name": "poison", "value": [2, 4], "target": "player", "positive": false, "animation": "02_atk"},
		{"name": "status", "status_name": "perm_strength", "value": 5, "target": "self", "positive": true, "animation": ""},
		
	],
	"defend-poison": [
		{"name": "shield", "value": [20,25], "animation": ""},
		{"name": "damage", "value": [5,6], "amount": 2, "type": "venom", "animation": "02_atk"}
	]
}


func _init():
	idle_anim_name = "01_stand"
	death_anim_name = "04_death"
	dmg_anim_name = "03_dmg"
