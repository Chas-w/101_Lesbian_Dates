extends RigidBody2D

var velocity_max = 100
var velocity_min = -100
var velocityX
var velocityY
# Called when the node enters the scene tree for the first time.
func _ready():
	velocityX = randf_range(velocity_min, velocity_max)
	velocityY = randf_range(velocity_min, velocity_max)
	linear_velocity.x = velocityX/2
	linear_velocity.y = velocityY/2

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	linear_velocity.x = lerpf(linear_velocity.x,velocityX,.01)
	linear_velocity.y = lerpf(linear_velocity.y,velocityY,.01)



func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	velocityX = randf_range(velocity_min, velocity_max)
	velocityY = randf_range(velocity_min, velocity_max)
	linear_velocity.x = velocityX/2
	linear_velocity.y = velocityY/2
