extends KinematicBody2D

export (int) var acceleration = 300
export (int) var max_speed = 250
export (int) var friction = 300

export (int) var vertical_snap = 16
export (int) var vertical_snap_speed = 310

export (bool) var is_biking = false

var velocity = Vector2()
var origin_y
var snapping_to_y


func _ready():
	origin_y = position.y
	snapping_to_y = origin_y
	set_process(true)

func _process(delta):
	if Input.is_action_just_pressed("mount_bike"):
		is_biking = !is_biking
		
	if is_biking:
		$player_state_animation.play("biking_idle")
	else:
		$player_state_animation.play("walking_idle")
		
func _physics_process(delta):
	var change_x_velocity = 0
	var change_y_velocity = 0

	if Input.is_action_pressed("ui_left"):
		change_x_velocity -= acceleration

	if Input.is_action_pressed("ui_right"):
		change_x_velocity += acceleration

	if Input.is_action_pressed("ui_up"):
		change_y_velocity -= 1

	if Input.is_action_pressed("ui_down"):
		change_y_velocity += 1

  # update horizontal veloxity
	velocity.x += change_x_velocity * delta

	# apply horizontal friction
	if change_x_velocity == 0:
		velocity.x -= min(abs(velocity.x), friction * delta) * sign(velocity.x)

	# don't allow x velocity to exceed max speed 
	if abs(velocity.x) > max_speed:
		velocity.x = sign(velocity.x) * max_speed

	# decide which y position to snap to
	if abs(change_y_velocity) > 0:
		snapping_to_y = floor((position.y + change_y_velocity * vertical_snap / 4 - origin_y) / vertical_snap) * vertical_snap + origin_y
		if change_y_velocity > 0:
			snapping_to_y += vertical_snap

	# set vertical velocity based on which position to snap to
	if abs(snapping_to_y - position.y) > 0:
		velocity.y = (snapping_to_y - position.y) * vertical_snap_speed * min(max(0.06, abs(velocity.x) / max_speed), 0.5) * 2 * delta

	# move player
	velocity = move_and_slide(velocity, Vector2(0, -1))

func change_is_biking(new_is_biking):
	is_biking = new_is_biking
