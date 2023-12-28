extends CharacterBody3D

@onready var camera_3d = $Camera3D
@onready var wall_run_timer = $WallRunTimer
@onready var left_ray_cast_3d = $LeftRayCast3D
@onready var right_ray_cast_3d = $RightRayCast3D
@onready var wall_buffer_timer = $WallBufferTimer
@onready var ceiling_ray_cast_3d = $CeilingRayCast3D
@onready var stagger_timer = $StaggerTimer
@onready var stagger_panel = %StaggerPanel
@onready var roll_buffer_timer = $RollBufferTimer
@onready var jump_buffer_timer = $JumpBufferTimer
@onready var coyote_jump_timer = $CoyoteJumpTimer

var forward_acceleration = 10.0
var forward_speed = 8.0
var side_acceleration = forward_acceleration
var side_speed = forward_speed
var gravity_acceleration = 10.0
var gravity_max = -20.0
var friction = 50.0

var jump_str = 7
var wall_jump_str = 5

var twist_input = 0.0
var pitch_input = 0.0
var camera_pitch_limit = 0.9

var can_wall_run = false
var wall_running = false

var was_on_wall = false

var was_on_floor = false

var turning = false
var turn_speed = 500
var turn_to: float

var sliding = false
var slide_angle_speed = 280
var slide_friction = 2

var rolling = false
var roll_speed = 540
var roll_positive = false

var camera_start_rotation

var fall_speed_stagger_limit = -10

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera_start_rotation = camera_3d.rotation

func _physics_process(delta):
	apply_gravity(delta)
	handle_turn_around(delta)
	var input_z_axis = Input.get_axis("move_backward", "move_forward")
	var input_x_axis = Input.get_axis("move_right", "move_left")
	velocity = velocity.rotated(Vector3.UP, -global_rotation.y)
	if stagger_timer.time_left == 0.0:
		stagger_panel.hide()
		handle_acceleration(delta, input_z_axis, input_x_axis)
		apply_friction(delta, input_z_axis, input_x_axis)
		handle_slide(delta)
		handle_jump()
	else:
		apply_friction(delta, 0.0, 0.0)
	was_on_wall = wall_running
	handle_wall_run(input_z_axis, input_x_axis)
	
	velocity = velocity.rotated(Vector3.UP, global_rotation.y)
	
	var was_falling_speed = velocity.y
	
	was_on_floor = is_on_floor()
	
	move_and_slide()
	
	if was_on_floor and not is_on_floor():
		coyote_jump_timer.start()
	
	if Input.is_action_just_pressed("slide") and not is_on_floor() and roll_buffer_timer.time_left == 0.0:
		roll_buffer_timer.start()
	
	if velocity.y == 0.0 and was_falling_speed < fall_speed_stagger_limit:
		if roll_buffer_timer.time_left == 0.0:
			stagger_timer.start()
			stagger_panel.show()
		else:
			rolling = true
#			position.y += 10
#			axis_lock_linear_y = true
			roll_buffer_timer.stop()
	
	if rolling:
#		print(camera_3d.rotation_degrees.x)
		camera_3d.rotation.x -= deg_to_rad(roll_speed * delta)
		if camera_3d.rotation_degrees.x < -180:
			camera_3d.rotation_degrees.x = 180
			roll_positive = true
		if roll_positive and camera_3d.rotation_degrees.x <= 0.0:
			roll_positive = false
			camera_3d.rotation_degrees.x = 0.0
			rolling = false
	
	if was_on_wall and not wall_running:
		wall_buffer_timer.start()
	
	if twist_input == 0.0:
		twist_input = - Input.get_axis("look_left", "look_right") * Globals.settings["joystick_sensitivity"]
	if pitch_input == 0.0:
		pitch_input = - Input.get_axis("look_down", "look_up") * Globals.settings["joystick_sensitivity"]
	
	if not sliding and not rolling:
		rotate_y(twist_input)
		camera_3d.rotate_x(pitch_input)
	if not rolling:
		camera_3d.rotation.x = clamp(camera_3d.rotation.x, -camera_pitch_limit, camera_pitch_limit)
	twist_input = 0.0
	pitch_input = 0.0
	
	if Input.is_action_just_pressed("quit_game"):
		get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	if Input.is_action_just_pressed("restart_level"):
		dead()
	for index in range(get_slide_collision_count()):
		var collision = get_slide_collision(index)
		if collision.get_collider() is GridMap:
			if Globals.meshes[collided(collision.get_collider(), collision.get_position(), collision.get_normal())] == "Lava":
				dead()

func apply_gravity(delta):
	velocity.y = move_toward(velocity.y, gravity_max, gravity_acceleration * delta)

func handle_turn_around(delta):
	if sliding: return
	if Input.is_action_just_pressed("turn_around") and not turning:
		turning = true
		turn_to = rotation_degrees.y + 180
		if turn_to > 180:
			turn_to -= 360
	if turning:
#		print("turn to: ", turn_to)
#		print("rotation y: ", rotation_degrees.y)
		rotation_degrees.y = move_toward(rotation_degrees.y, turn_to, turn_speed * delta)
		if int(rotation_degrees.y) == int(turn_to):
			turning = false

func handle_wall_run(input_z_axis, input_x_axis):
	for index in range(get_slide_collision_count()):
		var collision = get_slide_collision(index)
		if collision.get_collider() is GridMap:
			if Globals.meshes[collided(collision.get_collider(), collision.get_position(), collision.get_normal())] == "NoWallRunWall":
				wall_run_timer.stop()
				can_wall_run = true
				wall_running = false
				return
	if left_ray_cast_3d.is_colliding():
		if left_ray_cast_3d.get_collider() is GridMap:
			if Globals.meshes[collided(left_ray_cast_3d.get_collider(), left_ray_cast_3d.get_collision_point(), left_ray_cast_3d.get_collision_normal())] == "NoWallRunWall":
				wall_run_timer.stop()
				can_wall_run = true
				wall_running = false
				return
	if right_ray_cast_3d.is_colliding():
		if right_ray_cast_3d.get_collider() is GridMap:
			if Globals.meshes[collided(right_ray_cast_3d.get_collider(), right_ray_cast_3d.get_collision_point(), right_ray_cast_3d.get_collision_normal())] == "NoWallRunWall":
				wall_run_timer.stop()
				can_wall_run = true
				wall_running = false
				return
	if not is_on_wall_only() and not left_ray_cast_3d.is_colliding() and not right_ray_cast_3d.is_colliding():
		wall_run_timer.stop()
		can_wall_run = true
		wall_running = false
		return
	if can_wall_run:
		can_wall_run = false
		wall_run_timer.start()
	if wall_run_timer.time_left > 0.0 and not Input.is_action_pressed("jump"):
		wall_running = true
		velocity.y = max(0.0, velocity.y)
#		var y = velocity.y
		if not is_on_wall_only():
			var dir = Vector3(input_x_axis, 0.0, input_z_axis).rotated(Vector3.UP, camera_3d.global_rotation.y) * -1
			var normal: Vector3
			if left_ray_cast_3d.is_colliding():
				normal = left_ray_cast_3d.get_collision_normal().rotated(Vector3.UP, deg_to_rad(90))
			else:
				normal = right_ray_cast_3d.get_collision_normal().rotated(Vector3.UP, deg_to_rad(90))
				normal *= -1
			velocity = velocity.rotated(Vector3.UP, global_rotation.y)
			velocity.x = velocity.sign().x * normal.x * forward_speed * dir.x
			velocity.z = velocity.sign().z * normal.z * forward_speed * dir.z
			velocity = velocity.rotated(Vector3.UP, -global_rotation.y)
#			print(velocity.y)
#			velocity.y = y
#			print("dir: ", dir)
#			print("normal: ", normal)
	

func handle_acceleration(delta, input_z_axis, input_x_axis):
	if sliding: return
	if input_z_axis != 0:
#		print("values: " + str(velocity_local.z) + ", " + str(forward_speed * input_z_axis) + ", " + str(forward_acceleration * delta))
		velocity.z = move_toward(velocity.z, forward_speed * input_z_axis, forward_acceleration * delta)
#		print("velocity.z: " + str(velocity.z))
	if input_x_axis != 0:
		velocity.x = move_toward(velocity.x,side_speed * input_x_axis, side_acceleration * delta)

func apply_friction(delta, input_z_axis, input_x_axis):
	if sliding:
		velocity.z = move_toward(velocity.z, 0, slide_friction * delta)
	if input_z_axis == 0:
		velocity.z = move_toward(velocity.z, 0, friction * delta)
	if input_x_axis == 0:
		velocity.x = move_toward(velocity.x, 0, friction * delta)

func handle_slide(delta):
	ceiling_ray_cast_3d.global_rotation.x = 0.0
	if Input.is_action_pressed("slide") and is_on_floor():
		if not sliding:
			sliding = true
		rotation.x = move_toward(rotation.x, deg_to_rad(-89), deg_to_rad(slide_angle_speed) * delta)
#		camera_3d.rotation.x = move_toward(camera_3d.rotation.x, deg_to_rad(-90), deg_to_rad(slide_angle_speed) * delta)
	else:
		sliding = false
		if not ceiling_ray_cast_3d.is_colliding():
			rotation.x = move_toward(rotation.x, 0.0, deg_to_rad(slide_angle_speed) * delta)
#		camera_3d.rotation.x = move_toward(camera_3d.rotation.x, 0, deg_to_rad(slide_angle_speed) * delta)

func handle_jump():
	if sliding: return
	if is_on_floor() or wall_running or wall_buffer_timer.time_left > 0.0 or (coyote_jump_timer.time_left > 0.0 and velocity.y < 0.0):
		if Input.is_action_just_pressed("jump") or jump_buffer_timer.time_left > 0.0:
			coyote_jump_timer.stop()
			wall_buffer_timer.stop()
			jump_buffer_timer.stop()
			if is_on_wall_only():
				velocity.y = wall_jump_str
			else:
				velocity.y = jump_str
			wall_run_timer.stop()
	elif Input.is_action_just_pressed("jump"):
		jump_buffer_timer.start()

func dead():
	stagger_panel.show()
	get_tree().paused = true
	await LevelTransition.fade_to_black()
	get_tree().reload_current_scene()

func collided(body, position, normal):
	if body is GridMap:
		var grid = body
		var pos =  position - grid.position - normal * (grid.cell_size / 2)
		var gridPos = grid.local_to_map(pos)
		var item = grid.get_cell_item(gridPos)
		if item != GridMap.INVALID_CELL_ITEM:
			return item
		else:
			return 0

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		twist_input = - event.relative.x * Globals.settings["mouse_sensitivity"]
		pitch_input = event.relative.y *  Globals.settings["mouse_sensitivity"]
