extends KinematicBody2D

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN

onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")
const ACCELERATION = 1300
const FRICTION = 2000
const MAX_SPEED = 200
const ROLL_SPEED = 1.5

func _ready():
		animation_tree.active = true;

func _physics_process(delta):	#_physics_process if im using physics (position)
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)


func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		animation_tree.set("parameters/Idle/blend_position", input_vector)
		animation_tree.set("parameters/Run/blend_position", input_vector)
		animation_tree.set("parameters/Attack/blend_position", input_vector)
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


func roll_state(delta):
	velocity = roll_vector * MAX_SPEED * ROLL_SPEED
	animation_state.travel("Roll")
	move()

func attack_state(delta):
	velocity = Vector2.ZERO
	animation_state.travel("Attack")
	
func move():
	velocity = move_and_slide(velocity)
	
func attack_animation_finished():
	state = MOVE
	
func roll_animation_finished():
	state = MOVE
