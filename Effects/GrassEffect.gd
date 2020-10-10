extends Node2D

onready var animated_sprite = $AnimatedSprite

func _ready():
	animated_sprite.play("Animate")
	
func _process(delta):
	if Input.is_action_just_pressed("attack"):
		animated_sprite.frame = 0
		animated_sprite.play("Animate")
		


func _on_AnimatedSprite_animation_finished():
	queue_free()
