extends Control

@export var grid_parent: GridContainer
@export var x_template: Control
@export var circle: Control

const OFFSET = 14

@export var day = 1:
	set(value):
		day = value
		if is_node_ready():
			update_calendar()

func _ready():
	day = get_tree().get_first_node_in_group("game_manager").get_calendar_day()
	update_calendar()

func update_calendar():
	for el in grid_parent.get_children():
		if el == x_template or el == circle:
			continue
		el.free()

	for i in range(1, OFFSET + day + 1):
		var x = x_template.duplicate()
		x_template.add_sibling(x)
		x.show()

	x_template.hide()
