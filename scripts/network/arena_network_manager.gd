# arena_network_manager.gd
extends Node

# Network constants
const PORT = 10567
const MAX_PLAYERS = 8

# Player tracking
var players = {}
var local_player_id = 0

# Server info
var is_server = false

# Signals
signal player_connected(id)
signal player_disconnected(id)
signal server_created
signal connection_succeeded
signal connection_failed
signal game_ended

# Placeholder for Godot 4.x multiplayer implementation
# Will be expanded in later development
func _ready() -> void:
    pass
