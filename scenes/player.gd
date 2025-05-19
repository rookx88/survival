extends CharacterBody2D
@export var speed = 200
# Water resource variables (from your specification)
@export var max_water = 100.0
@export var water_depletion_rate = 0.05
var current_water = 100.0
# Animation and facing direction
var last_direction = Vector2(0, 1)  # Default facing down
signal water_changed(current, maximum)
signal water_depleted
func _ready():
	# Initialize character
	current_water = max_water
	emit_signal("water_changed", current_water, max_water)
	
	# Set initial animation
	$AnimatedSprite2D.play("idle_down")
func _physics_process(delta):
	# Get input direction
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	
	# Set velocity
	velocity = direction * speed
	
	# Handle animations based on movement
	if direction.length() > 0:
		# Character is moving, play walk animation
		update_animation(direction, true)
		# Save the last direction for idle state
		last_direction = direction
		
		# Deplete water based on movement
		deplete_water(water_depletion_rate * delta)
	else:
		# Character is idle, play idle animation
		update_animation(last_direction, false)
	
	# Move the character
	move_and_slide()
	
	# Basic interaction with space/enter
	if Input.is_action_just_pressed("ui_accept"):
		interact()
func update_animation(direction, is_moving):
	var anim = $AnimatedSprite2D
	
	# Determine which animation to play based on direction and movement state
	var animation_name = "idle_down"  # Default animation
	
	if abs(direction.x) > abs(direction.y):
		# Horizontal movement is dominant
		if direction.x > 0:
			animation_name = "walk_right" if is_moving else "idle_right"
		else:
			animation_name = "walk_left" if is_moving else "idle_left"
	else:
		# Vertical movement is dominant
		if direction.y > 0:
			animation_name = "walk_down" if is_moving else "idle_down"
		else:
			animation_name = "walk_up" if is_moving else "idle_up"
	
	# Play the selected animation if it's not already playing
	if anim.animation != animation_name:
		anim.play(animation_name)
func interact():
	# Cast a ray to detect interactive objects
	var space_state = get_world_2d().direct_space_state
	
	# First create the query parameters
	var query = PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + last_direction * 32
	)
	
	# Then set additional properties
	query.collision_mask = 1
	
	# Now intersect with the query
	var result = space_state.intersect_ray(query)
	
	if result:
		var collider = result["collider"]
		if collider.has_method("harvest"):
			collider.harvest(self)
		elif collider.has_method("mine"):
			collider.mine(self)
func deplete_water(amount):
	current_water = max(0.0, current_water - amount)
	emit_signal("water_changed", current_water, max_water)
	
	if current_water <= 0:
		emit_signal("water_depleted")
		# You can add player death or penalty here
func collect_spice(amount):
	# Will be used when you add harvestable resources
	print("Collected spice: ", amount)
	# Add spice to inventory
