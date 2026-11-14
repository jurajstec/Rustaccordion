extends Area2D

@export var attack_distance = 100
@export var attack_speed = 700

var start_position: Vector2
var target_position: Vector2

var attacking = false
var retracting = false

func _ready():
	start_position = position
	
func start_attack(direction): #if anyone reads the code, the direction is here to be able to be one of 2 values: 1 (right) -1 (left) !!! there's no underscore for this function since it's not supposed to only be used in the script. Shoul'dnt chnage anything tho
	if attacking:
		return #if the player is already attacking, nothing happens
	
	attacking = true
	retracting = false #not retracting yet
	
	start_position = position #not sure if this will work if the player moves so this might be a problem
	target_position = start_position + Vector2(attack_distance * direction, 0) #where the accordion is going to extend to (in this case the collision shape) we use for that a Vector2 and 0 since it should stay the same altitude
	
	$CollisionShape2D.disabled = false #I disabled it in the inspector so that it doesn't deal damage while inactive. Here, it's enabled. The $ sign is here cause its a child node
	
func _physics_process(delta):
	if not attacking:
		return #don't attack if you aren't attacking
		
	if not retracting:
		position = position.move_toward(target_position, attack_speed * delta) #it moves toward our target position with our selected speed
		
		if position.distance_to(target_position) < 1:
			retracting = true
			
	else: #if it's retracting
		position = position.move_toward(start_position, attack_speed * delta) #moves toward the player
		
		if position.distance_to(start_position) < 1: #resets to the starting values so the cycle can begin again
			position = start_position
			attacking = false
			retracting = false
			$CollisionShape2D.set_deferred("disabled", true)
