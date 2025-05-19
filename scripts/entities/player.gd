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
@onready var water_system = /WaterSystem
@onready var tool_system = 
@onready var sprite = 
@onready var animation_player = 

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
