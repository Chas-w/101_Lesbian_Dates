extends Button
@export var dialogue_manager : Control
@export var floater : RigidBody2D

@export var connected_responses : Array[String]
#used to delete responses on a similar path

func _process(delta):
	position += floater.position
	rotation += floater.rotation
	if (button_pressed):
		#dialogue_manager.paul_responding = true
		#dialogue_manager.paul_choice = self
		dialogue_manager._paul_response(self)
