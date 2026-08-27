@icon("uid://doexs1roljv87")
class_name BasicState extends Node

signal Transitioned(state: BasicState, new_state_name: String, context: Dictionary)

# root - is script that init state machine
var _root: Variant = null
var root: Variant:
	set(value):
		if _root != null:
			push_error("root can be set once")
			return
		_root = value
	get:
		return _root
		
var _parent_state: BasicState = null
var parent_state: BasicState:
	set(value):
		if _parent_state != null:
			push_error("parent_state can be set once")
			return
		_parent_state = value
	get:
		return _parent_state
		
var _is_active: bool = false
var is_active: bool:
	set(value):
		push_error("is_active is read-only")
	get:
		return _is_active

func request_Transitioned(new_state_name: String, context: Dictionary = {}) -> void:
	emit_signal("Transitioned", self, new_state_name, context)

# Active a parent before active self
func enter(_context: Dictionary = {}) -> void:
	_is_active = true
	
	if parent_state and not parent_state.is_active:
		parent_state.enter(_context)
	
	_on_enter()

func exit(keep_active: BasicState = null) -> void:
	_is_active = false
	
	_on_exit()
	
	# If doesn't have active child, deactive parent
	if _parent_state and _parent_state != keep_active:
		if _parent_state is BasicComplexState:
			var has_other_active_children = false
			for child in _parent_state.get_children():
				if child is BasicState and child != self and child.is_active:
					has_other_active_children = true
					break
			
			if not has_other_active_children:
				_parent_state.exit(keep_active)
		else:
			_parent_state.exit(keep_active)

# Run the parent method, then run self method 
func update(_delta: float) -> void:
	if parent_state and parent_state.is_active:
		parent_state.update(_delta)
	
	_on_update(_delta)

func physics_update(_delta: float) -> void:
	if parent_state and parent_state.is_active:
		parent_state.physics_update(_delta)
	
	_on_physics_update(_delta)

func handle_input(_event: InputEvent) -> void:
	if parent_state and parent_state.is_active:
		parent_state.handle_input(_event)
	
	_on_input(_event)

func unhandled_input(_event: InputEvent) -> void:
	if parent_state and parent_state.is_active:
		parent_state.unhandled_input(_event)
	
	_on_unhandled_input(_event)

# Virtual methods
func _on_enter() -> void:
	#print("Entered: ", name)
	pass

func _on_exit() -> void:
	#print("Exited: ", name)
	pass

func _on_update(_delta: float) -> void:
	pass

func _on_physics_update(_delta: float) -> void:
	pass

func _on_input(_event: InputEvent) -> void:
	pass

func _on_unhandled_input(_event: InputEvent) -> void:
	pass
