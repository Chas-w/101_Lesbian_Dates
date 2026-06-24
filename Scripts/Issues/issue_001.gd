extends Node2D

@export var dialogue_controller : Control
@export var anim_player : AnimationPlayer
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


#region In every issue
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _play_anim(anim : String):
	anim_player.play(anim)
	pass #if can't progress unless animation is played
	
func _wait_for_gameplay(gameplay, next_status):
	pass #if can't progress until gameplay has been finished
#endregion

func _play_game(minigame : String):
	print(minigame)
	pass
