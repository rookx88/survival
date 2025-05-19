# water_system.gd
extends Node

@export var max_water: float = 100.0
@export var starting_water: float = 100.0
@export var movement_drain_rate: float = 0.05
@export var passive_drain_rate: float = 0.01

var current_water: float

signal water_changed(current, maximum)
signal water_depleted

func _ready() -> void:
    current_water = starting_water
    water_changed.emit(current_water, max_water)
    
func _process(delta: float) -> void:
    # Passive drain
    deplete(passive_drain_rate * delta)
    
func deplete(amount: float) -> void:
    current_water = max(0.0, current_water - amount)
    water_changed.emit(current_water, max_water)
    
    if current_water <= 0:
        water_depleted.emit()
        
func add(amount: float) -> void:
    current_water = min(max_water, current_water + amount)
    water_changed.emit(current_water, max_water)
    
func get_percent() -> float:
    return current_water / max_water
    
func is_empty() -> bool:
    return current_water <= 0
