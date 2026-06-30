extends Button
@export var anim_player : AnimationPlayer
@export var mover : Node2D
@export var item_name : String
@export var item_unfurl : Sprite2D
@export var thought_spawn_location : Node2D
var show : bool = false
var buffer_max = 1
var buffer : float
#if item spawns a response
#if item spawns an inspectable
func _process(delta: float) -> void:
	if (!anim_player.is_playing()):
		if(button_pressed && !show):
			anim_player.play("mover_in")
			show = true
		if(!button_pressed && show):
			anim_player.play("mover_out")
			show = false
