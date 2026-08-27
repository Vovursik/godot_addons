@icon("uid://cgkd8v8b22h08")
class_name BasicStateMachine extends Node

@export var initial_state: BasicState

var current_state: BasicState
var states: Dictionary = {}

func init(root_ref: Variant) -> void:
	# Init all states 
	for child in find_children("*", "BasicState", true, false):
		if child is BasicState:
			states[child.name] = child
			child.root = root_ref
			if not child.Transitioned.is_connected(_on_transition):
				child.Transitioned.connect(_on_transition)

			var parent = child.get_parent()
			if parent is BasicState:
				child.parent_state = parent
				
				if not (parent is BasicComplexState):
					push_warning("'%s' is a plain BasicState but has child state '%s'. Only BasicComplexState should have BasicState children — consider making '%s' extend BasicComplexState." % [parent.name, child.name, parent.name])

	if initial_state:
		current_state = initial_state
		current_state.enter()

# Run all state methods
func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func _input(event: InputEvent) -> void:
	if current_state:
		current_state.handle_input(event)

func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.unhandled_input(event)

# Transition between states
func _get_ancestor_chain(state: BasicState) -> Array:
	var chain: Array = []
	var s = state
	while s:
		chain.append(s)
		s = s.parent_state
	return chain

func _on_transition(state: BasicState, new_state_name: String, context = {}) -> void:
	var new_state = states.get(new_state_name)
	if !state || !new_state:
		return
	
	if current_state:
		var old_chain = _get_ancestor_chain(current_state)
		var new_chain = _get_ancestor_chain(new_state)
		
		var common_ancestor: BasicState = null
		for ancestor in old_chain:
			if ancestor in new_chain:
				common_ancestor = ancestor
				break
		
		current_state.exit(common_ancestor)
	
	new_state.enter(context)
	current_state = new_state
