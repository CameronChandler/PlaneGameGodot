extends CharacterBody2D

const MAX_ROTATION_SPEED = 0.035
const MIN_ROTATION_SPEED = 0.025
const THRUST = 200
const WEIGHT = 25
const DRAG = THRUST / 250_000.0
const DRAG_PENALTY = 1.2
const LIFT = 4
const CRASH_ALTITUDE = 50

var health: int = 50
var is_alive: bool = true
var crashed: bool = false
var flat_motion: bool = true

func _get_rotation_speed() -> float:
	''' Sigmoid curve for rotation speed: Faster velocity = slower rotation '''
	# Centre of sigmoid
	var centre = 300 
	# How quickly rotation speed changes
	var scale = 0.1
	var denom = 1 + exp(scale*(velocity.length() - centre))
	return MIN_ROTATION_SPEED + (MAX_ROTATION_SPEED - MIN_ROTATION_SPEED) / denom

func _ready():
	# Start and stop timer when plane exits and enters screen
	$VisibleOnScreenNotifier2D.screen_entered.connect($OffScreenTimer.stop)
	$VisibleOnScreenNotifier2D.screen_exited.connect($OffScreenTimer.start)
	$VisibleOnScreenNotifier2D.screen_entered.connect($LostPlaneTimer.stop)
	$VisibleOnScreenNotifier2D.screen_exited.connect($LostPlaneTimer.start)
	# Turn plane around if off screen too long
	$OffScreenTimer.timeout.connect(_turnaround)
	$LostPlaneTimer.timeout.connect(_lost_plane)
	
	#$BulletTimer.timeout.connect(_shoot)

func _lost_plane() -> void:
	print('lost')
	var middle = get_viewport_rect().position / 2.0
	rotation = position.direction_to(middle).angle()
	flat_motion = false
	$LostPlaneTimer.start

func _turnaround() -> void:
	print('Turnaround')
	if global_position.x < 0:
		rotation = 0
		flat_motion = true
		
	elif global_position.y < 0:
		rotation = deg_to_rad(90)
		
	else:
		rotation = deg_to_rad(180)
		flat_motion = true

func crash() -> void:
	health = 0
	is_alive = false
	crashed = true
	velocity = Vector2(0, 0)
	
	var explosion = preload("./explosion.tscn").instantiate()
	get_parent().add_child(explosion)
	explosion.global_position = global_position
	queue_free()
		
func _process(delta: float) -> void:
	if crashed:
		return
	
	var turn = 0
	turn -= 1 if Input.is_action_pressed("key_left")  else 0
	turn += 1 if Input.is_action_pressed("key_right") else 0
	flat_motion = false if turn != 0 else flat_motion
		
	rotation += turn * _get_rotation_speed()
	
	var rotation_vector = Vector2(1, 0).rotated(rotation)
	var thrust = THRUST * rotation_vector
	var drag_area = 1 + DRAG_PENALTY*(1 - cos(2*(velocity.angle() - rotation)))
	velocity += thrust
	velocity -= DRAG * velocity.length() * velocity * drag_area
	
	# Lift
	var velocity_in_dir_of_rotation = velocity.normalized().dot(rotation_vector)
	var lift = LIFT * velocity_in_dir_of_rotation**2 * rotation_vector.rotated(deg_to_rad(-90))
	velocity += lift
	velocity -= Vector2(0, -WEIGHT)
	
	# Stop vertical movement if coming from off screen
	velocity.y *= 1 - int(flat_motion)
	
	# Move the plane
	move_and_slide()

func _shoot():
	print('_shoot()')
	var bullet = preload("res://plane/bullet.tscn").instantiate()
	bullet.global_position = self.global_position#Vector2(100, 100)
	#bullet.rotation = self.rotation
	get_parent().add_child(bullet)
	print(bullet.global_position)
