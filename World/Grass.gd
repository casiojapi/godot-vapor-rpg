extends Node2D

func create_grass_effect():
	var GrassEffect = load("res://Effects/GrassEffect.tscn")	#scene - CamelCase
	var grass_effect = GrassEffect.instance()	#node - snake_case
	var world = get_tree().current_scene
	world.add_child(grass_effect)	#adding the instance/node
	grass_effect.global_position = global_position
	queue_free()
	
func _on_Hurtbox_area_entered(area):
	create_grass_effect()
	queue_free()
