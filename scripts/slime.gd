
extends CharacterBody2D

@export var speed:float = 60.0
@export var patrol_distance:float = 150.0

var start_position:float = 0.0
var direction = 1


func _ready():
	start_position = position.x


func _process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	position.x += speed * direction * delta

	if position.x >= start_position + patrol_distance: #if it reaches the limit to the right, it switches directions
		direction = -1

	elif position.x <= start_position - patrol_distance:
		direction = 1
