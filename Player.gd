extends SGFixedNode2D

export(bool) var using_sg_area_2d := false

var input_prefix := "player1_"

var ZERO := SGFixedVector2.new() # fixed analog to Vector2.ZERO
var speed := 65536*10
var pull_speed := 65536*1

onready var area := $SGArea2D
onready var area_radius: int = $SGArea2D/SGCollisionShape2D.shape.radius + (65536 * 32) # player radius

func _get_local_input() -> Dictionary:
	var input_vector := Input.get_vector(input_prefix + "left", input_prefix + "right", input_prefix + "up", input_prefix + "down")

	var input := {}
	if input_vector != Vector2.ZERO:
		input["input_vector"] = SGFixed.from_float_vector2(input_vector)

	return input

func _network_process(input: Dictionary) -> void:
	var input_vector: SGFixedVector2 = input.get("input_vector", ZERO)
	fixed_position.iadd(input_vector.mul(speed))
	area.sync_to_physics_engine()

	if using_sg_area_2d:
		# This seems to behave nondeterministically, causing a fatal state mismatch
		for body in area.get_overlapping_bodies():
			pull_to_me(body)
	else:
		# but somehow, this seems to work fine
		var body := $'/root/Main/Ball' as SGKinematicBody2D
		if body.fixed_position.distance_to(fixed_position) <= area_radius:
			pull_to_me(body)

func pull_to_me(body: SGKinematicBody2D) -> void:
	var direction_to_me := body.fixed_position.direction_to(fixed_position)
	body.fixed_position.iadd(direction_to_me.mul(pull_speed))
	body.sync_to_physics_engine()

func _save_state() -> Dictionary:
	return {
		fpx = fixed_position.x,
		fpy = fixed_position.y,
	}

func _load_state(state: Dictionary) -> void:
	fixed_position.x = state['fpx']
	fixed_position.y = state['fpy']
