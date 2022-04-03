extends SGFixedNode2D

func _save_state() -> Dictionary:
	return {
		fpx = fixed_position.x,
		fpy = fixed_position.y,
	}

func _load_state(state: Dictionary) -> void:
	fixed_position.x = state['fpx']
	fixed_position.y = state['fpy']
