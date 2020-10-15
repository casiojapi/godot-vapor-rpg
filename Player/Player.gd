extends KinematicBody2D

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN
var stats = PlayerStats

onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")
onready var sword_hitbox = $HitboxPivot/SwordHitbox
onready var hurtbox = $Hurtbox
onready var blink_animation_player = $BlinkAnimationPlayer

const PlayerHurtSound = preload("res://Effects/PlayerHurtSound.tscn")
export var ACCELERATION = 1300
export var FRICTION = 2000
export var MAX_SPEED = 130
export var ROLL_SPEED = 1.5

func _ready():
	randomize()
	stats.connect("no_health", self, "queue_free")
	animation_tree.active = true;
	sword_hitbox.knockback_vector = roll_vector

func _physics_process(delta):	#_physics_process if im using physics (position)
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			move_state(delta *10)
			attack_state(delta)
			
func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	animation_tree.set("parameters/Attack/blend_position", get_local_mouse_position())
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		sword_hitbox.knockback_vector = input_vector
		animation_tree.set("parameters/Idle/blend_position", input_vector)
		animation_tree.set("parameters/Run/blend_position", input_vector)
		animation_tree.set("parameters/Roll/blend_position", input_vector)
		animation_state.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		
		if Input.is_action_just_pressed("roll"):
			state = ROLL
		
	else:
		animation_state.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
	move()
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK


func roll_state(_delta):
	velocity = roll_vector * MAX_SPEED * ROLL_SPEED
	animation_state.travel("Roll")
	move()

func attack_state(delta):
	#velocity = Vector2.ZERO
	animation_state.travel("Attack")
	
func move():
	velocity = move_and_slide(velocity)
	
func attack_animation_finished():
	state = MOVE
	
func roll_animation_finished():
	state = MOVE


func _on_Hurtbox_area_entered(area):
	if hurtbox.inv == false:
		stats.health -= area.damage
		hurtbox.start_inv(1)
		hurtbox.create_hit_effect()
		var player_hurt_sound = PlayerHurtSound.instance()
		get_tree().current_scene.add_child(player_hurt_sound)

func _on_Hurtbox_inv_started():
	blink_animation_player.play("Start")

func _on_Hurtbox_inv_ended():
	blink_animation_player.play("Stop")
