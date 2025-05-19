extends Area2D

class_name MinorSpice

signal collected(amount)

@export var spice_amount: int = 1
@export var float_height: float = 3.0
@export var float_speed: float = 1.5
@export var rotation_speed: float = 0.5
@export var glow_intensity: float = 0.2

var time_offset: float
var base_position: Vector2

func _ready() -> void:
	# Random offset for the floating animation
	time_offset = randf() * TAU
	base_position = position
	
	# Connect signal for collection
	body_entered.connect(_on_body_entered)
	
	# Set up appearance animation
	var tween = create_tween()
	scale = Vector2(0.01, 0.01)
	modulate.a = 0.0
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.3)
	tween.parallel().tween_property(self, "modulate:a", 1.0, 0.3)
	
	# Add a pulsing glow effect to highlight the spice
	_start_glow_effect()

func _start_glow_effect() -> void:
	var glow_tween = create_tween()
	glow_tween.set_loops() # Make it repeat indefinitely
	glow_tween.tween_property($Sprite2D, "modulate", Color(1.2, 1.2, 0.8, 1.0), 1.0)
	glow_tween.tween_property($Sprite2D, "modulate", Color(1.0, 1.0, 1.0, 1.0), 1.0)

func _process(delta: float) -> void:
	# Gentle floating animation
	var y_offset = sin(Time.get_ticks_msec() * 0.001 * float_speed + time_offset) * float_height
	position.y = base_position.y + y_offset
	
	# Slow rotation animation for the spiral effect
	rotation += rotation_speed * delta
	
func _on_body_entered(body: Node2D) -> void:
	# Check if it's the player who collected the spice
	if body.is_in_group("player"):
		collect(body)

func collect(player) -> void:
	# Emit collected signal
	collected.emit(spice_amount)
	
	# Give spice to player if they have the method
	if player.has_method("add_spice"):
		player.add_spice(spice_amount)
	else:
		print("Player collected spice but has no add_spice method")
	
	# Play collection sound if available
	if has_node("CollectionSound"):
		$CollectionSound.play()
	
	# Disable collision to prevent multiple collections
	$CollisionShape2D.set_deferred("disabled", true)
	
	# Visual collection effect - float upward and fade out
	var tween = create_tween()
	tween.tween_property(self, "position:y", position.y - 30, 0.5)
	tween.parallel().tween_property(self, "scale", Vector2(0.1, 0.1), 0.5)
	tween.parallel().tween_property(self, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)
