extends KinematicBody2D


const EnemyDeathEffect = preload("res://effects/EnemyDeathEffect.tscn")
onready var stats = $Stats
onready var player_detection_zone = $PlayerDetectionZone
onready var sprite = $AnimatedSprite
onready var hurtbox = $Hurtbox
onready var soft_collision = $SoftCollision
onready var wander_controller = $WanderController
onready var animation_player = $AnimationPlayer

enum {
	IDLE,
	WANDER,
	CHASE
}


export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200
export var KNOCK = 115
export var WANDER_TARGET_RANGE = 4


var velocity = Vector2.ZERO
var knockback = Vector2.ZERO	
var state = IDLE

func _ready():
	state = pick_random_state([IDLE, WANDER])
	
func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, 200 * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			
			if wander_controller.get_time_left() == 0:
				update_wander()
		WANDER:
			seek_player()
			if wander_controller.get_time_left() == 0:
				update_wander()
			
			move_towards_point(wander_controller.target_position, delta)
			if global_position.distance_to(wander_controller.target_position) <= WANDER_TARGET_RANGE:
				update_wander()
		CHASE:
			var player = player_detection_zone.player
			if player != null:
				move_towards_point(player.global_position, delta)
			else:
				state = IDLE

	if soft_collision.is_colliding():
		velocity += soft_collision.get_push_vector() * delta * 400
	velocity = move_and_slide(velocity)

func move_towards_point(point, delta):
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0

func update_wander():
	state = pick_random_state([IDLE, WANDER])
	wander_controller.start_wander_timer(rand_range(1, 3))

func seek_player():
	if player_detection_zone.can_see_player():
		state = CHASE
	
func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()
	
func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	knockback = area.knockback_vector * KNOCK
	hurtbox.create_hit_effect()
	hurtbox.start_inv(0.2)
	
func _on_Stats_no_health():
	queue_free()
	var enemy_death_effect = EnemyDeathEffect.instance()
	get_parent().add_child(enemy_death_effect)
	enemy_death_effect.global_position = global_position

func _on_Hurtbox_inv_ended():
	animation_player.play("Start")
	
func _on_Hurtbox_inv_started():
	animation_player.play("Stop")
