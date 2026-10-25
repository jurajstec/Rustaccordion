
extends CharacterBody2D


const SPEED = 220.0 # Horizontal movement speed
const ASCEND_SPEED = 300.0 # Maximum upward flight speed
@export var deceleration = 500.0 # How quickly the player slows down horizontally


const FLIGHT_ACCELERATION = 1800.0 # Upward acceleration while flying
const TAKEOFF_BOOST = 270.0 # Initial boost when taking off from the ground
const AIR_BOOST_DURATION = 0.1 # Duration of the extra mid-air boost
const AIR_BOOST_ACCELERATION = 1900.0 # Strength of the extra mid-air boost
const AIR_BOOST_COST = 0.10


@export var max_energy: float = 1.3 # Maximum stamina
@export var recharge_speed: float = 4.5 
var energy_left: float # Current stamina remaining


var air_boost_time: float = 0.1 # Time for the extra mid-air boost


# Stamina bar
@onready var stamina_bar: ProgressBar = $StaminaBar


func _ready() -> void:
	energy_left = max_energy
	stamina_bar.max_value = max_energy
	stamina_bar.value = energy_left


func _physics_process(delta: float) -> void:


	if is_on_floor():
		energy_left = move_toward(
			energy_left,
			max_energy,
			recharge_speed * delta
		) #this recharges smoothly the stamina while on the floor


	# Apply gravity whenever the player is airborne
	if not is_on_floor():
		var gravity = get_gravity()

		# Fall faster when moving downward to make it nicer to look at
		if velocity.y >= 0:
			gravity *= 1.5

		velocity += gravity * delta


	# Start a takeoff boost and extra boost in mid-air to make the game easier (and also use up stamina for the mid-air boost)
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			if energy_left > 0:
				velocity.y = -TAKEOFF_BOOST
		elif energy_left >= AIR_BOOST_COST:
			air_boost_time = AIR_BOOST_DURATION
			energy_left -= AIR_BOOST_COST


	if Input.is_action_pressed("ui_accept") and energy_left > 0:
		var flight_power = FLIGHT_ACCELERATION

		# Give extra flight power when falling otherwise it's impossible to get back up
		if velocity.y > 0:
			flight_power *= 1.5

		velocity.y -= flight_power * delta

		#This prevents the upward speed from going over its limit
		velocity.y = maxf(velocity.y, -ASCEND_SPEED)

		#Drain stamina while flying
		energy_left = maxf(energy_left - delta, 0.0)


	#mini air-boost with a short space press
	if air_boost_time > 0.0 and not is_on_floor():
		velocity.y -= AIR_BOOST_ACCELERATION * delta
		air_boost_time = maxf(air_boost_time - delta, 0.0)


	#speed flight limit
	velocity.y = maxf(velocity.y, -ASCEND_SPEED)


	#This is for the horizontal movement
	# Move left or right based on the arrow keys
	var direction := Input.get_axis("ui_left", "ui_right")

	if direction:
		velocity.x = direction * SPEED
	elif is_on_floor():
		# Gradually slow down to create a subtle glide
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)
		
	else: velocity.x = move_toward(velocity.x, 0, deceleration/1.5 * delta)
		


	#sync stamina with the UI bar
	stamina_bar.value = energy_left


	#apply
	move_and_slide()
