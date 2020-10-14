extends Control

var hearts = 4 setget set_hearts
var max_hearts = 4 setget set_max_hearts

onready var label = $Label
var stats = PlayerStats

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	if label != null:
		label.text = "HP = " + str(hearts)
func set_max_hearts(value):
	max_hearts = max(value, 1)

func _ready():
	self.max_hearts = stats.max_health
	self.hearts = stats.health
	stats.connect("health_changed", self, "set_hearts")
