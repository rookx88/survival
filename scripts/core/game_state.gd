# game_state.gd
extends Node

# Player persistent data
var player_spice: int = 0
var player_water: float = 50.0
var player_equipment = {}
var unlocked_tools = ["harvester"]
var player_name = "Player"

# Arena session data
var current_session = {
    "spice_collected": 0,
    "water_remaining": 0,
    "session_duration": 0,
    "success": false
}

# Methods for data management
func add_player_spice(amount: int) -> void:
    player_spice += amount
    save_game()
    
func set_player_water(amount: float) -> void:
    player_water = amount
    save_game()
    
func start_arena_session() -> void:
    current_session = {
        "spice_collected": 0,
        "water_remaining": player_water,
        "session_duration": 0,
        "success": false
    }
    
func save_game() -> void:
    var save_data = {
        "player_spice": player_spice,
        "player_water": player_water,
        "player_equipment": player_equipment,
        "unlocked_tools": unlocked_tools
    }
    
    var save_file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
    save_file.store_string(JSON.stringify(save_data))
    save_file.close()
    
func load_game() -> void:
    if not FileAccess.file_exists("user://savegame.json"):
        return
        
    var save_file = FileAccess.open("user://savegame.json", FileAccess.READ)
    var json = JSON.new()
    var error = json.parse(save_file.get_as_text())
    save_file.close()
    
    if error == OK:
        var save_data = json.data
        if save_data:
            player_spice = save_data.player_spice
            player_water = save_data.player_water
            player_equipment = save_data.player_equipment
            unlocked_tools = save_data.unlocked_tools
