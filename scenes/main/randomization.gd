extends HBoxContainer

var chance: float = 20.0
var strength: float = 0.2

var current_generation: int = 0
var current_data: Dictionary = {}
var current_states: Array = []

var generations: Array[Dictionary]

func get_randomization_scenes() -> Array: 
	return $Scenes/VBoxContainer/RandomizedRow1.get_children() + $Scenes/VBoxContainer/RandomizedRow2.get_children()

func update_main() -> void: 
	current_data = get_tree().current_scene.get_app_state()

func use_state(scene: Node) -> void:
	var index: int = get_randomization_scenes().find(scene)
	get_tree().current_scene.update_app_state(current_states[index])

func generate_offspring(data: Dictionary) -> Dictionary:
	return data

func randomization() -> void:
	current_states.clear()
	
	
	for i in len(get_randomization_scenes()):
		current_states.append(generate_offspring(current_data))
