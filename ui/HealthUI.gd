extends Control

var hearts = 4 setget set_hearts
var max_hearts = 4 setget set_max_hearts

onready var heart_full = $HeartUIFull
onready var heart_empty = $HeartUIEmpty

var stats = PlayerStats

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	if heart_full != null:
		heart_full.rect_size.x = hearts * 15

func set_max_hearts(value):
	max_hearts = max(value, 1)
	self.hearts = min(hearts, max_hearts)
	if heart_empty != null:
		heart_empty.rect_size.x = max_hearts * 15

func _ready():
	self.max_hearts = stats.max_health
	self.hearts = stats.health
	stats.connect("health_changed", self, "set_hearts")
	stats.connect("max_health_changed", self, "set_max_hearts")
