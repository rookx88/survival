extends Area2D

class_name CollectableSpice

signal can_interact(item)
signal end_interact(item)
signal collected(player, item_data)

@export var spice_value: int = 1
@export var interaction_distance: float = 40.0
@export var float_height: float = 2.0
@export var float_speed: float = 1.5

var can_be_collected: bool = false
var nearby_player = null
var base_position: Vector2
var item_data = {
    "type": "spice",
    "amount": 1,
    "name": "Spice Crystal",
    "icon": "spice_crystal"  # Used for inventory UI
}

func _ready() -> void:
    # Set item data
    item_data.amount = spice_value
    
    # Connect signals
    body_entered.connect(_on_body_entered)
    body_exited.connect(_on_body_exited)
    
    # Initialize position for floating effect
    base_position = position
    
    # Create spawn effect
    _spawn_effect()
    
func _spawn_effect() -> void:
    # Initial appearance from slightly above
    position.y -= 10
    scale = Vector2(0.1, 0.1)
    modulate.a = 0.0
    
    # Spawn animation
    var spawn_tween = create_tween()
    spawn_tween.tween_property(self, "position:y", base_position.y, 0.3)
    spawn_tween.parallel().tween_property(self, "scale", Vector2(1.0, 1.0), 0.3)
    spawn_tween.parallel().tween_property(self, "modulate:a", 1.0, 0.3)
    spawn_tween.tween_callback(func(): can_be_collected = true)
    
    # Start gentle pulsing glow
    _start_glow_effect()
    
func _start_glow_effect() -> void:
    var glow_tween = create_tween()
    glow_tween.set_loops() # Infinite loops
    glow_tween.tween_property($Sprite2D, "modulate", Color(1.2, 1.2, 0.8, 1.0), 1.0)
    glow_tween.tween_property($Sprite2D, "modulate", Color(1.0, 1.0, 1.0, 1.0), 1.0)

func _process(delta: float) -> void:
    # Gentle floating effect
    if can_be_collected:
        var y_offset = sin(Time.get_ticks_msec() * 0.001 * float_speed) * float_height
        position.y = base_position.y + y_offset
        
        # Subtle rotation
        rotation = sin(Time.get_ticks_msec() * 0.0005) * 0.05

func _on_body_entered(body: Node2D) -> void:
    if body.is_in_group("player") and can_be_collected:
        nearby_player = body
        
        # Signal that player can interact
        can_interact.emit(self)
        
        # Show interaction prompt if player has this method
        if body.has_method("show_interaction_prompt"):
            body.show_interaction_prompt(self, "Press E to collect Spice")

func _on_body_exited(body: Node2D) -> void:
    if body == nearby_player:
        nearby_player = null
        
        # Signal that player is no longer in range
        end_interact.emit(self)
        
        # Hide interaction prompt
        if body.has_method("hide_interaction_prompt"):
            body.hide_interaction_prompt()

# Called when player interacts with this item
func interact(player) -> bool:
    if !can_be_collected or !player:
        return false
    
    # Check if player can add to inventory
    if player.has_method("can_add_to_inventory"):
        if !player.can_add_to_inventory(item_data):
            # Show "inventory full" message if needed
            if player.has_method("show_notification"):
                player.show_notification("Inventory full!")
            return false
    
    # Add to player inventory
    if player.has_method("add_to_inventory"):
        player.add_to_inventory(item_data)
    
    # Emit collection signal
    collected.emit(player, item_data)
    
    # Play collection effect
    _collect_effect()
    
    return true

func _collect_effect() -> void:
    # Prevent further collection
    can_be_collected = false
    $CollisionShape2D.set_deferred("disabled", true)
    
    # Play sound if available
    if has_node("CollectSound"):
        $CollectSound.play()
    
    # Visual effect
    var collect_tween = create_tween()
    collect_tween.tween_property(self, "position:y", position.y - 20, 0.3)
    collect_tween.parallel().tween_property(self, "scale", Vector2(0.1, 0.1), 0.3)
    collect_tween.parallel().tween_property(self, "modulate:a", 0, 0.3)
    collect_tween.tween_callback(queue_free)
