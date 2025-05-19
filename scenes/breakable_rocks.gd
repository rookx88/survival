extends Node2D


class_name BreakableRocks

@export var health: int = 2
@export var contains_spice: bool = false
@export var spice_scene: PackedScene

signal destroyed(position, has_spice)

func _ready() -> void:
	# Set random chance to contain spice if not explicitly set
	if randf() < 0.3:  # 30% chance
		contains_spice = true

# Function called when rock is hit by harvester
func damage(amount: int = 1) -> void:
	health -= amount
	
	# Visual feedback
	$Sprite2D.modulate = Color(1.0, 0.7, 0.7)  # Red tint
	var tween = create_tween()
	tween.tween_property($Sprite2D, "modulate", Color(1, 1, 1), 0.2)
	
	# Play hit sound if available
	if has_node("HitSound"):
		$HitSound.play()
	
	if health <= 0:
		destroy()

# Called when rock is destroyed
func destroy() -> void:
	# Emit signal about destruction
	destroyed.emit(global_position, contains_spice)
	
	# Spawn spice if this rock contained it
	if contains_spice and spice_scene:
		var spice = spice_scene.instantiate()
		spice.global_position = global_position
		# Add to parent so it persists when rock is removed
		get_parent().add_child(spice)
	
	# Destruction animation
	var tween = create_tween()
	tween.tween_property($Sprite2D, "scale", Vector2(0.1, 0.1), 0.3)
	tween.tween_property($Sprite2D, "modulate", Color(1, 1, 1, 0), 0.2)
	tween.tween_callback(queue_free)

# Called when player interacts with rock using harvester
func harvest(player) -> void:
	# This function can be called from player's interaction
	damage(1)
	
	# Play harvester animation on player if they have that function
	if player.has_method("play_harvester_animation"):
		player.play_harvester_animation()
