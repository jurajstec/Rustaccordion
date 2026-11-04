extends CharacterBody2D
 
 
const SPEED = 280.0
const ASCEND_SPEED = 350.0
@export var deceleration = 500.0
 
const FLIGHT_ACCELERATION = 1800.0
const TAKEOFF_BOOST = 270.0
const AIR_BOOST_DURATION = 0.2
const AIR_BOOST_ACCELERATION = 1900.0
const AIR_BOOST_COST = 0.10
 
@export var max_energy: float = 1.3
@export var recharge_speed: float = 4.5
var energy_left: float
 
# 6 health points = 3 full hearts.
# 1 health point = half a heart.
@export var max_health: float = 6.0
var health: float
 
var air_boost_time: float
var hearts: Array[Label] = []
 
@onready var stamina_bar: ProgressBar = $StaminaBar
 
 
func _ready() -> void:
	energy_left = max_energy
	stamina_bar.max_value = max_energy
	stamina_bar.value = energy_left
 
	health = max_health
 
	create_heart_ui()
	update_hearts()
 
 
func create_heart_ui() -> void:
	# Finds your existing CanvasLayer.
	var ui_layer: CanvasLayer = get_node_or_null("../CanvasLayer") as CanvasLayer
 
	# Creates one if your scene does not already have one.
	if ui_layer == null:
		ui_layer = CanvasLayer.new()
		ui_layer.name = "CanvasLayer"
		get_parent().add_child(ui_layer)
 
	# Creates a row to hold the three hearts.
	var hearts_box := HBoxContainer.new()
	hearts_box.name = "Hearts"
	hearts_box.position = Vector2(20, 20)
	hearts_box.add_theme_constant_override("separation", 5)
	ui_layer.add_child(hearts_box)
 
	# Creates three visible heart labels.
	for i in range(3):
		var heart := Label.new()
		heart.name = "Heart" + str(i + 1)
		heart.custom_minimum_size = Vector2(48, 55)
		heart.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		heart.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		heart.add_theme_font_size_override("font_size", 42)
 
		hearts_box.add_child(heart)
		hearts.append(heart)
 
 
func _physics_process(delta: float) -> void:
 
	if is_on_floor():
		energy_left = move_toward(
			energy_left,
			max_energy,
			recharge_speed * delta
		)
 
	# Apply gravity while airborne.
	if not is_on_floor():
		var gravity = get_gravity()
 
		if velocity.y >= 0:
			gravity *= 1.5
 
		velocity += gravity * delta
 
	# Takeoff and mid-air boost.
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			if energy_left > 0:
				velocity.y = -TAKEOFF_BOOST
		elif energy_left >= AIR_BOOST_COST:
			air_boost_time = AIR_BOOST_DURATION
			energy_left -= AIR_BOOST_COST
 
	# Flying.
	if Input.is_action_pressed("ui_accept") and energy_left > 0.0:
		var flight_power = FLIGHT_ACCELERATION
 
		if velocity.y > 0:
			flight_power *= 1.5
 
		velocity.y -= flight_power * delta
		velocity.y = maxf(velocity.y, -ASCEND_SPEED)
 
		energy_left = maxf(energy_left - delta, 0.0)
 
	# Small mid-air boost.
	if air_boost_time > 0.0 and not is_on_floor():
		velocity.y -= AIR_BOOST_ACCELERATION * delta
		air_boost_time = maxf(air_boost_time - delta, 0.0)
 
	velocity.y = maxf(velocity.y, -ASCEND_SPEED)
 
	# Horizontal movement.
	var direction := Input.get_axis("ui_left", "ui_right")
 
	if direction:
		velocity.x = direction * SPEED
	elif is_on_floor():
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration / 1.5 * delta)
 
	# TEST: Every Space press removes half a heart.
	# Remove this section later; enemies should call take_damage() instead.
	if Input.is_action_just_pressed("ui_accept"):
		take_damage(1.0)
 
	stamina_bar.value = energy_left
 
	move_and_slide()
 
 
func take_damage(_amount: float) -> void:
	# Every call removes half a heart.
	health = maxf(health - 1.0, 0.0)
	update_hearts()
 
 
func update_hearts() -> void:
	for i in hearts.size():
		var heart_health := clampi(roundi(health) - i * 2, 0, 2)
 
		if heart_health == 2:
			hearts[i].text = "♥"
			hearts[i].modulate = Color.RED
		elif heart_health == 1:
			hearts[i].text = "◐"
			hearts[i].modulate = Color.ORANGE
		else:
			hearts[i].text = "♡"
			hearts[i].modulate = Color.DIM_GRAY
