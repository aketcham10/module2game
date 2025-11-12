extends MarginContainer
@onready var life_counter = $Lives.get_children()

func update_life(value):
	for heart in life_counter.size():
		life_counter[heart].visible = value > heart
