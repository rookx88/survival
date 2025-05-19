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
