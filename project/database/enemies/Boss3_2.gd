extends EnemyData

var scene_path = "res://game/enemies/enemy-scenes/Boss3-2.tscn"
var image = "res://assets/images/enemies/boss3-2/idle.png"
var name = "EN_BOSS_3_2"
var sfx = "boss-3-2"
var use_idle_sfx = false
var hp = 420
var battle_init = true
var size = "big"
var change_phase = null

var states = ["start", "attack1", "attack2", "attack3", "attack4", "init",\
			  "debuff1", "debuff2", "debuff3", "debuff3", "debuff4", "debuff5"]
var connections = [
					  ["init", "start", 1],
					
					  ["start", "attack1", 1],
					  ["start", "attack2", 1],
					  ["start", "attack3", 1],
					
					  ["attack1", "debuff1", 1],
					  ["attack1", "debuff2", 1],
					  ["attack1", "debuff3", 1],
					  ["attack1", "debuff4", 1],
					  ["attack1", "debuff5", 1],
					
					  ["attack2", "debuff1", 1],
					  ["attack2", "debuff2", 1],
					  ["attack2", "debuff3", 1],
					  ["attack2", "debuff4", 1],
					  ["attack2", "debuff5", 1],
					
					  ["attack3", "debuff1", 1],
					  ["attack3", "debuff2", 1],
					  ["attack3", "debuff3", 1],
					  ["attack3", "debuff4", 1],
					  ["attack3", "debuff5", 1],
					
					  ["attack4", "debuff1", 1],
					  ["attack4", "debuff2", 1],
					  ["attack4", "debuff3", 1],
					  ["attack4", "debuff4", 1],
					  ["attack4", "debuff5", 1],
					
					  ["debuff1", "attack1", 1],
					  ["debuff1", "attack2", 1],
					  ["debuff1", "attack3", 1],
					  ["debuff1", "attack4", 1],
					  
					  ["debuff2", "attack1", 1],
					  ["debuff2", "attack2", 1],
					  ["debuff2", "attack3", 1],
					  ["debuff2", "attack4", 1],
					
					  ["debuff3", "attack1", 1],
					  ["debuff3", "attack2", 1],
					  ["debuff3", "attack3", 1],
					  ["debuff3", "attack4", 1],
					
					  ["debuff4", "attack1", 1],
					  ["debuff4", "attack2", 1],
					  ["debuff4", "attack3", 1],
					  ["debuff4", "attack4", 1],
					
					  ["debuff5", "attack1", 1],
					  ["debuff5", "attack2", 1],
					  ["debuff5", "attack3", 1],
					  ["debuff5", "attack4", 1],
				  ]
var first_state = ["init"]

var actions = {
	"init": [
		{"name": "shield", "value": 100, "animation": ""},
	],
	"start": [
		{"name": "status", "status_name": "deviation", "value": 1, "target": "player", "positive": false, "animation": ""},
		{"name": "status", "status_name": "divine_protection", "value": 60, "target": "self", "positive": true, "extra_args": {"value": 60}, "animation": ""},
	],
	"attack1": [
		{"name": "damage", "value": 45, "amount":2, "type": "regular", "animation": "02_atk"},
		{"name": "shield", "value": [50,60], "animation": ""},
	],
	"attack2": [
		{"name": "damage", "value": [10,25], "amount":4, "type": "regular", "animation": "02_atk"},
		{"name": "shield", "value": [50,60], "animation": ""},
	],
	"attack3": [
		{"name": "damage", "value": 100, "type": "regular", "animation": "02_atk"},
		{"name": "shield", "value": [50,60], "animation": ""},
	],
	"attack4": [
		{"name": "drain", "value": 60, "animation": "02_atk"},
		{"name": "shield", "value": [50,60], "animation": ""},
	],
	"debuff1": [
		{"name": "status", "status_name": "burning", "value": 12, "target": "player", "positive": false, "animation": ""},
		{"name": "status", "status_name": "perm_strength", "value": 2, "target": "self", "positive": true, "animation": ""}
	],
	"debuff2": [
		{"name": "status", "status_name": "freeze", "value": 5, "target": "player", "positive": false, "animation": ""},
		{"name": "status", "status_name": "perm_strength", "value": 2, "target": "self", "positive": true, "animation": ""}
	],
	"debuff3": [
		{"name": "status", "status_name": "time_bomb", "value": 12, "target": "player", "positive": false, "animation": ""},
		{"name": "status", "status_name": "perm_strength", "value": 2, "target": "self", "positive": true, "animation": ""}
	],
	"debuff4": [
		{"name": "status", "status_name": "weakness", "value": 2, "target": "player", "positive": false, "animation": ""},
		{"name": "status", "status_name": "perm_strength", "value": 2, "target": "self", "positive": true, "animation": ""}
	],
	"debuff5": [
		{"name": "status", "status_name": "perm_strength", "value": 6, "target": "self", "positive": true, "animation": ""}
	],
	
}


func _init():
	idle_anim_name = "01_idle"
	death_anim_name = "04_death"
	dmg_anim_name = "03_dmg"
