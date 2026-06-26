extends Control

@export var dialogue_manager : Control

@export var kai_boob : Sprite2D
@export var paul_boob : Sprite2D
@export var needle : Sprite2D
@export var needle_max_pos : Node2D
@export var needle_min_pos : Node2D
@export var needle_start_pos : Node2D
@export var pierce_pos : Node2D

var start_game : bool
var started : bool
var pierce : bool = false

var rise : bool

var max_speed = 550
var min_speed = 500
var speed

var ok_shot : bool 
var great_shot : bool 

var buffer = 1
var wait_after_pierce = 1
var wait_to_progress = 3


# Called when the node enters the scene tree for the first time.
func _ready():
	speed = randf_range(min_speed,max_speed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(start_game):
		if (!started):
			needle.position = needle_start_pos.position
			paul_boob.visible = false
			kai_boob.visible = true
			started = true
		else:
			if (Input.is_action_just_pressed("Enter")):
				pierce = true
			if (!pierce):
				if (rise):
					if (needle.position.y > needle_max_pos.position.y):
						needle.position.y -= speed * delta
					else:
						rise = false
						speed = randf_range(min_speed,max_speed)
				else:
					if (needle.position.y < needle_min_pos.position.y):
						needle.position.y += speed * delta
					else:
						rise = true
						speed = randf_range(min_speed,max_speed)
			else:
				if (needle.position.x > pierce_pos.position.x):
						needle.position.x -= (speed * 10) * delta
				else:
					if(wait_after_pierce >= 0):
						wait_after_pierce -= delta
					else: 
						if (!ok_shot && !great_shot):
							var speak = ["ummm", "erm", "right"]
							dialogue_manager._progress_date_dialogue(speak[randi_range(0,2)])
							wait_to_progress -= delta
							if (wait_to_progress <= 0):
								wait_to_progress = 3
								pierce = false
								needle.position = needle_start_pos.position
						else:
							if(ok_shot):
								dialogue_manager._progress_date_dialogue("ok")
								start_game = false
							if(great_shot && !ok_shot):
								dialogue_manager._progress_date_dialogue("great!")
								start_game = false

func _on_area_2d_area_entered(area):
	if (started):
		if (area.is_in_group("ok")):
			ok_shot = true
		if (area.is_in_group("great")):
			great_shot = true
