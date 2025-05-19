# extraction_arena.gd
extends Node2D

@export var arena_width: int = 192
@export var arena_height: int = 192
@export var tile_size: int = 64

var prize_disturbed: bool = false
var escape_points_unlocked: bool = false

func _ready() -> void:
	# Initialize the arena
	generate_arena()
	
func generate_arena() -> void:
	# Placeholder for arena generation code
	# Will be implemented later
	print("Arena generation placeholder")
	
func get_spawn_position() -> Vector2:
	# Return a valid spawn position
	# For now, just return the center
	return Vector2(
		arena_width * tile_size / 2,
		arena_height * tile_size / 2
	)
	
func spawn_player(player_id: int, spawn_pos: Vector2) -> void:
	# Placeholder for player spawning
	print("Player spawn placeholder")
	
func game_over(success: bool) -> void:
	# Handle game over condition
	print("Game over - Success: " + str(success))
	
func unlock_escape_routes() -> void:
	escape_points_unlocked = true
	print("Escape routes unlocked")
