#!/bin/bash

# SPICE Game Setup Script for Godot 4.x
# This script creates the development environment and project structure 
# for the SPICE Game Extraction Arena prototype

echo "========================================"
echo "SPICE Game Development Environment Setup (Godot 4.x)"
echo "========================================"

# Create basic directory structure
echo "Creating project directory structure..."
mkdir -p assets/{sprites/{characters,environment,tools,ui,effects},sounds/{music,sfx},fonts}
mkdir -p scenes/{extraction_arena,home_base,ui,common}
mkdir -p scripts/{core,entities,resources,tools,ui,network,blockchain}
mkdir -p tests
mkdir -p addons
mkdir -p resources
mkdir -p build

# Create core game files
echo "Creating core game files..."

# Main project file
cat > project.godot << EOF
; Engine configuration file.
; It's best edited using the editor UI and not directly,
; since the parameters that go here are not all obvious.
;
; Format:
;   [section] ; section goes between []
;   param=value ; assign values to parameters

config_version=5

[application]

config/name="SPICE Mine"
run/main_scene="res://scenes/extraction_arena/extraction_arena.tscn"
config/features=PackedStringArray("4.2")
config/icon="res://assets/sprites/ui/spice_icon.png"

[autoload]

GameState="*res://scripts/core/game_state.gd"
ArenaNetworkManager="*res://scripts/network/arena_network_manager.gd"
Web3Manager="*res://scripts/blockchain/web3_manager.gd"

[display]

window/size/viewport_width=1280
window/size/viewport_height=720
window/stretch/mode="canvas_items"
window/stretch/aspect="keep"

[input]

move_up={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":87,"physical_keycode":0,"key_label":0,"unicode":0,"echo":false,"script":null)
]
}
move_down={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":83,"physical_keycode":0,"key_label":0,"unicode":0,"echo":false,"script":null)
]
}
move_left={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":65,"physical_keycode":0,"key_label":0,"unicode":0,"echo":false,"script":null)
]
}
move_right={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":68,"physical_keycode":0,"key_label":0,"unicode":0,"echo":false,"script":null)
]
}
use_tool={
"deadzone": 0.5,
"events": [Object(InputEventMouseButton,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"button_mask":0,"position":Vector2(0, 0),"global_position":Vector2(0, 0),"factor":1.0,"button_index":1,"canceled":false,"pressed":false,"double_click":false,"script":null)
]
}
tool_1={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":49,"physical_keycode":0,"key_label":0,"unicode":0,"echo":false,"script":null)
]
}
tool_2={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":50,"physical_keycode":0,"key_label":0,"unicode":0,"echo":false,"script":null)
]
}
tool_3={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":51,"physical_keycode":0,"key_label":0,"unicode":0,"echo":false,"script":null)
]
}
tool_4={
"deadzone": 0.5,
"events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":0,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":52,"physical_keycode":0,"key_label":0,"unicode":0,"echo":false,"script":null)
]
}

[rendering]

renderer/rendering_method="gl_compatibility"
textures/vram_compression/import_etc2_astc=true
environment/defaults/default_environment="res://default_env.tres"
EOF

# Create default environment resource
cat > default_env.tres << EOF
[gd_resource type="Environment" format=3 uid="uid://c8kwh64d3b0p6"]

[resource]
background_mode = 2
EOF

# Create core script files
echo "Creating core script files..."

# GameState singleton
mkdir -p scripts/core
cat > scripts/core/game_state.gd << EOF
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
EOF

# Player script
mkdir -p scripts/entities
cat > scripts/entities/player.gd << EOF
# player.gd
extends CharacterBody2D

# Movement variables
@export var speed: float = 200.0

# Resource variables
@export var max_water: float = 100.0
var water_amount: float = 100.0
var spice_amount: int = 0

# Signals
signal water_changed(current, maximum)
signal spice_changed(amount)
signal tool_used(tool_id, cooldown)
signal tool_ready(tool_id)

# References
@onready var water_system = $ResourceManager/WaterSystem
@onready var tool_system = $ToolSystem
@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer

# State machine
enum State {IDLE, MOVING, MINING, USING_TOOL, ATTACKING, DYING}
var current_state = State.IDLE

func _ready() -> void:
    # Initialize water
    water_amount = GameState.player_water
    water_changed.emit(water_amount, max_water)
    
    # Connect signals
    water_system.water_changed.connect(_on_water_changed)
    water_system.water_depleted.connect(_on_water_depleted)

func _physics_process(delta: float) -> void:
    # Get input direction
    var input_direction = Vector2(
        Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
        Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
    ).normalized()
    
    # Apply movement
    if input_direction != Vector2.ZERO:
        velocity = input_direction * speed
        # Set state to moving
        if current_state != State.MOVING:
            _change_state(State.MOVING)
    else:
        velocity = Vector2.ZERO
        # Set state to idle if not in another state
        if current_state == State.MOVING:
            _change_state(State.IDLE)
    
    # Apply movement and handle collisions
    move_and_slide()
    
    # Check for tool use
    if Input.is_action_just_pressed("use_tool"):
        use_current_tool()

func use_current_tool() -> void:
    if current_state == State.IDLE or current_state == State.MOVING:
        tool_system.use_current_tool()

func _change_state(new_state: int) -> void:
    current_state = new_state
    
    match new_state:
        State.IDLE:
            animation_player.play("idle")
        State.MOVING:
            animation_player.play("walk")
        State.MINING:
            animation_player.play("mine")
        State.USING_TOOL:
            animation_player.play("use_tool")
        State.ATTACKING:
            animation_player.play("attack")
        State.DYING:
            animation_player.play("die")

func deplete_water(amount: float) -> void:
    water_system.deplete(amount)

func add_water(amount: float) -> void:
    water_system.add(amount)

func add_spice(amount: int) -> void:
    spice_amount += amount
    spice_changed.emit(spice_amount)

func _on_water_changed(current: float, maximum: float) -> void:
    water_amount = current
    water_changed.emit(current, maximum)

func _on_water_depleted() -> void:
    _change_state(State.DYING)
    # Trigger game over after animation
    await animation_player.animation_finished
    get_parent().game_over(false)
EOF

# WaterSystem script
mkdir -p scripts/resources
cat > scripts/resources/water_system.gd << EOF
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
EOF

# ToolSystem script
mkdir -p scripts/tools
cat > scripts/tools/tool_system.gd << EOF
# tool_system.gd
extends Node

var tools = {
    "harvester": {
        "icon": null, # Will be loaded at runtime
        "action": null, # Will be set in _ready
        "water_cost": 0.5,
        "cooldown": 0.5
    },
    "thumper": {
        "icon": null, # Will be loaded at runtime
        "action": null, # Will be set in _ready
        "water_cost": 2.0,
        "cooldown": 3.0
    },
    "weapon": {
        "icon": null, # Will be loaded at runtime
        "action": null, # Will be set in _ready
        "water_cost": 1.0,
        "cooldown": 0.8
    },
    "scanner": {
        "icon": null, # Will be loaded at runtime
        "action": null, # Will be set in _ready
        "water_cost": 1.5,
        "cooldown": 5.0
    }
}

var current_tool = "harvester"
var can_use_tool = true
var cooldown_timer = null

func _ready() -> void:
    # Set function references
    tools["harvester"]["action"] = use_harvester
    tools["thumper"]["action"] = place_thumper
    tools["weapon"]["action"] = attack
    tools["scanner"]["action"] = use_scanner
    
    # Initialize cooldown timer
    cooldown_timer = Timer.new()
    cooldown_timer.one_shot = true
    add_child(cooldown_timer)
    cooldown_timer.timeout.connect(_on_cooldown_completed)
    
    # Load icons at runtime (placeholder paths, update as needed)
    tools["harvester"]["icon"] = preload("res://assets/sprites/ui/harvester_icon.png")
    tools["thumper"]["icon"] = preload("res://assets/sprites/ui/thumper_icon.png")
    tools["weapon"]["icon"] = preload("res://assets/sprites/ui/weapon_icon.png")
    tools["scanner"]["icon"] = preload("res://assets/sprites/ui/scanner_icon.png")
    
func use_current_tool() -> void:
    if can_use_tool and owner.water_amount >= tools[current_tool].water_cost:
        # Consume water
        owner.deplete_water(tools[current_tool].water_cost)
        
        # Execute tool action
        tools[current_tool].action.call()
        
        # Start cooldown
        can_use_tool = false
        cooldown_timer.wait_time = tools[current_tool].cooldown
        cooldown_timer.start()
        
        # Update UI
        owner.tool_used.emit(current_tool, tools[current_tool].cooldown)
        
func _on_cooldown_completed() -> void:
    can_use_tool = true
    owner.tool_ready.emit(current_tool)
    
func use_harvester() -> void:
    # Implementation will be filled in later
    print("Using harvester tool")
    
func place_thumper() -> void:
    # Implementation will be filled in later
    print("Placing thumper")
    
func attack() -> void:
    # Implementation will be filled in later
    print("Using weapon")
    
func use_scanner() -> void:
    # Implementation will be filled in later
    print("Using scanner")
EOF

# ArenaNetworkManager
mkdir -p scripts/network
cat > scripts/network/arena_network_manager.gd << EOF
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
EOF

# Web3Manager
mkdir -p scripts/blockchain
cat > scripts/blockchain/web3_manager.gd << EOF
# web3_manager.gd
extends Node

# States
enum ConnectionState {DISCONNECTED, CONNECTING, CONNECTED}
var current_state = ConnectionState.DISCONNECTED

# Web3 data
var wallet_address = ""
var connected_chain_id = ""

# Signals
signal wallet_connected(address)
signal wallet_disconnect
signal transaction_success(tx_hash)
signal transaction_failure(error)

# Placeholder for JavaScript interface and web3 implementation
# Will be expanded in later development
func _ready() -> void:
    pass
EOF

# Basic Extraction Arena scene
mkdir -p scenes/extraction_arena
cat > scenes/extraction_arena/extraction_arena.tscn << EOF
[gd_scene format=3 uid="uid://dfx41c0ldgr1o"]

[node name="ExtractionArena" type="Node2D"]

[node name="TileMap" type="TileMap" parent="."]
cell_quadrant_size = 64
format = 2

[node name="NavigationRegion2D" type="NavigationRegion2D" parent="."]

[node name="Entities" type="Node2D" parent="."]
y_sort_enabled = true

[node name="UI" type="CanvasLayer" parent="."]

[node name="EscapePoints" type="Node2D" parent="."]
EOF

# Create extraction arena script
cat > scenes/extraction_arena/extraction_arena.gd << EOF
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
EOF

# README file
cat > README.md << EOF
# SPICE Game - Extraction Arena Prototype

A Dune-inspired extraction survival game with PvPvE mechanics using the Godot Engine 4.x.

## Overview

This prototype focuses on the SPICE Mine extraction arena instances, featuring:

- Stardew Valley-like interaction system with tile-based gameplay
- Resource management (water, SPICE)
- Environmental threats (sandworms)
- Tool-based interactions
- Multiplayer capabilities
- Blockchain integration (planned)

## Development Setup

1. Install [Godot Engine 4.2+](https://godotengine.org/download)
2. Clone this repository
3. Open the project in Godot Engine
4. Run the game from the editor or export for your platform

## Project Structure

- **assets/**: Game assets (sprites, sounds, etc.)
- **scenes/**: Game scenes and UI components
- **scripts/**: Game logic
  - **core/**: Core game systems
  - **entities/**: Player, enemies, and objects
  - **resources/**: Resource management
  - **tools/**: Tool system implementation
  - **ui/**: User interface scripts
  - **network/**: Multiplayer code
  - **blockchain/**: Web3 integration
- **tests/**: Testing code
- **addons/**: Godot plugins
- **resources/**: Game data resources
- **build/**: Build outputs

## Controls

- **WASD**: Movement
- **1-4**: Select tools
- **Left Mouse**: Use selected tool
- **ESC**: Pause/Menu

## Development Timeline

1. Phase 1: Extraction Arena MVP (4-6 weeks)
2. Phase 2: Multiplayer Foundation (4-6 weeks)
3. Phase 3: Home Base & Progression (4-6 weeks)
4. Phase 4: Blockchain Integration (3-4 weeks)
5. Phase 5: Polish & Launch (4-6 weeks)

## License

Proprietary - All rights reserved
EOF

# Initialize Git repository
echo "Initializing Git repository..."
git init
git add .

# Create .gitignore file
cat > .gitignore << EOF
# Godot 4+ specific ignores
.godot/
.import/
export_presets.cfg

# Godot-specific ignores
*.import
.DS_Store

# Imported translations (automatically generated from CSV files)
*.translation

# Mono-specific ignores
.mono/
data_*/
mono_crash.*.json

# System/tool-specific ignores
.DS_Store
Thumbs.db
.directory
*~
*.blend1
.vscode/
.idea/

# Build outputs
build/
EOF

git add .gitignore

# Create placeholder assets
echo "Creating placeholder assets..."
mkdir -p assets/sprites/ui

# Create empty placeholder files for important assets
touch assets/sprites/ui/spice_icon.png
touch assets/sprites/ui/harvester_icon.png
touch assets/sprites/ui/thumper_icon.png
touch assets/sprites/ui/weapon_icon.png
touch assets/sprites/ui/scanner_icon.png

echo "========================================"
echo "Setup complete! Here's what to do next:"
echo "========================================"
echo "1. Open the project in Godot Engine 4.x"
echo "2. Add the placeholder sprite assets"
echo "3. Implement the extraction arena scene"
echo "4. Begin developing the core mechanics"
echo ""
echo "Happy coding!"