extends CanvasLayer

onready var bg = $Background
onready var tween = $Tween
onready var floor_button = $Background/CenterContainer/VBoxContainer/FloorButton
onready var fps_label = $Info/FPS
onready var unlock_btn = $Background/CenterContainer/VBoxContainer/UnlockCombBtn
onready var version_label = $Info/Version
onready var id_box = $Background/CenterContainer/VBoxContainer/Event/IdBox
onready var artifact_box = $Background/CenterContainer/VBoxContainer/Artifact/TextEdit

signal combinations_unlocked
signal battle_won
signal died
signal floor_selected(floor_number)
signal test_map_creation
signal event_pressed(id)
signal artifact_pressed(name)

const VERSION := "v0.4.0"
const MAX_FLOOR := 3

var floor_to_go := -1
var recipes_unlocked := false
var reveal_map := false
var lower_threshold := false


func _ready():
	set_process(false)
	version_label.text = VERSION
	
	floor_button.add_item("Go to floor")
	floor_button.add_separator()
	floor_button.add_item("1")
	floor_button.add_item("2")
	floor_button.add_item("3")


func _input(event):
	if event.is_action_pressed("toggle_debug"):
		bg.visible = !bg.visible


func _process(_delta):
	fps_label.text = str(Engine.get_frames_per_second(), " FPS")


func set_version_visible(enable: bool):
	version_label.visible = enable


func _on_WinBtn_pressed():
	emit_signal("battle_won")
	bg.hide()


func _on_DieBtn_pressed():
	emit_signal("died", null)
	bg.hide()


func _on_UnlockCombBtn_pressed():
	emit_signal("combinations_unlocked")
	bg.hide()


func _on_FPSButton_toggled(button_pressed):
	fps_label.visible = button_pressed
	set_process(button_pressed)


func _on_FloorButton_item_selected(id):
	if id > 1:
		floor_to_go = id - 1
		emit_signal("floor_selected", floor_to_go)
		bg.hide()


func _on_UpdateRecipesButton_pressed():
	RecipeManager.update_recipes_reagent_combinations()


func _on_RevealMap_toggled(button_pressed):
	reveal_map = button_pressed


func _on_Test_Map_Creation_pressed():
	emit_signal("test_map_creation")


func _on_RecipeThreshold_toggled(button_pressed):
	lower_threshold = button_pressed


func _on_EventButton_pressed():
	emit_signal("event_pressed", int(id_box.get_line_edit().text))
	bg.hide()


func _on_ArtifactButton_pressed():
	var name = artifact_box.text
	if ArtifactDB.has(name):
		emit_signal("artifact_pressed", artifact_box.text)
		bg.hide()
	else:
		tween.interpolate_property(artifact_box, "modulate", Color.red,
				Color.white, .5)
		tween.start()
	artifact_box.text = ""


func _on_ResetCompendium_pressed():
	Profile.reset_compendium()


func _on_ResetProgress_pressed():
	Profile.reset_progression()
