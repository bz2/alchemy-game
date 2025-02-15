extends HBoxContainer

var type : String
var positive : bool
var tooltips_enabled := false
var block_tooltips := false

func init(_type: String, value, _positive: bool):
	type = _type
	positive = _positive
	
	var status_data = StatusDB.get_from_name(type)
	$Image.texture = status_data.image
	if status_data.show_value and value:
		set_value(value)
	else:
		set_value("")
	
	var w = $Value.rect_position.x + $Value.rect_size.x
	var h = $Image.rect_size.y
	$TooltipCollision.position.x = w/2
	$TooltipCollision.position.y = h/2
	$TooltipCollision.set_collision_width(w)
	$TooltipCollision.set_collision_height(h)

func set_value(value):
	$Value.text = str(value)

func disable():
	block_tooltips = true
	disable_tooltips()

func enable():
	block_tooltips = false

func get_self_tooltip():
	var tooltip = {}
	var status_data = StatusDB.get_from_name(type)
	tooltip.title = status_data.title_name
	tooltip.text = tr(status_data.description)
	if status_data.use_value_on_tooltip:
		tooltip.text = tooltip.text % int($Value.text)
	tooltip.title_image = status_data.image
	tooltip.subtitle = "Status"
	
	return tooltip

func disable_tooltips():
	if tooltips_enabled:
		tooltips_enabled = false
		TooltipLayer.clean_tooltips()

func _on_TooltipCollision_disable_tooltip():
	disable_tooltips()

func _on_TooltipCollision_enable_tooltip():
	if block_tooltips:
		return
	tooltips_enabled = true
	var tooltip = get_self_tooltip()
	TooltipLayer.add_tooltip($TooltipPosition.global_position, tooltip.title, \
							 tooltip.text, tooltip.title_image, tooltip.subtitle, true)
