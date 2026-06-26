extends Control

@export_category("Setup")
@export var ISSUE : Node2D
@export var brain : Control
@export var brain_spawn_loc : Node2D
@export var JSON_file_path : String
@export var paul_dialogue : RichTextLabel
@export var date_dialogue : RichTextLabel
@export var progression_icon : Sprite2D
@export_range (0,1.5,.01) var display_buffer #amount of time inbetween each word

var date_buffer : float = 0
var paul_buffer
var JSON_dict : Dictionary
var paul_dialogue_dict : Dictionary
var date_dialogue_dict : Dictionary
var date_name : String
var place_in_dialogue : String
var date_dialogue_array 
var paul_dialogue_array
var response_button_path = preload("res://Entities/response_button.tscn")
var next_status : String

@export_category("Dialogue_Status")
var display_date_line : bool 
var display_paul_line : bool
var setup_date_display : bool
var setup_paul_display : bool 
var current_date_dialogue : Dictionary
var current_paul_dialogue: Dictionary
var date_current_sentence : String
var date_split_sentence #an array that stores all the words in a sentence
var date_word_in_sentence : int #used to track where we are in displaying the sentence
var paul_current_sentence : String
var paul_split_sentence #an array that stores all the words in a sentence
var paul_word_in_sentence : int #used to track where we are in displaying the sentence
var date_current_status : String
var paul_status : String 
var paul_choice : Button
var waiting_for_progression : bool #used if there's not choice just waiting for the player to press interact
var speaking : bool

func _ready():
	JSON_dict = _JSON_to_dictionary(JSON_file_path)
	paul_dialogue_dict = JSON_dict.Paul
	date_dialogue_dict = JSON_dict.Date
	date_name = date_dialogue_dict.Name
	date_dialogue_array = date_dialogue_dict.Dialogue
	paul_dialogue_array = paul_dialogue_dict.Dialogue
	_progress_date_dialogue("next") 

func _process(delta):
	if (waiting_for_progression):
		progression_icon.visible = true
		if (Input.is_action_just_pressed("Enter")):
			if (current_date_dialogue.Player_Response):
				_progress_paul_response(current_date_dialogue.Next_Status)
			elif ((!current_date_dialogue.Player_Response) || ((current_paul_dialogue.One_off || current_paul_dialogue.Interruption))):
				_progress_date_dialogue(next_status) #problem area
			waiting_for_progression = false
			progression_icon.visible = false

	if (display_date_line):
		_display_date_dialogue(current_date_dialogue.Line, delta)
	if (display_paul_line):
		_display_paul_dialogue(current_paul_dialogue.Line, delta)

func _display_date_dialogue(disp : String, delta):
	if (!setup_date_display):
		print("[" + date_name + " Current Sentence]: " + disp)
		date_buffer = randf_range(.01,display_buffer)
		date_split_sentence = disp.split(" ") 
		date_word_in_sentence = -1
		date_current_sentence  = " "
		date_dialogue.text == " "
		setup_date_display = true
	else:
		if(date_buffer >= 0):
			date_buffer -= delta
		else: 
			if (date_word_in_sentence < date_split_sentence.size()-1):
				date_word_in_sentence += 1
				date_current_sentence += date_split_sentence[date_word_in_sentence] + " "
				date_dialogue.text = date_current_sentence #update label text
				#play audio
				date_buffer = randf_range(.01,display_buffer)
			else:
				display_date_line = false
				setup_date_display = false
				if (current_date_dialogue.Queue == null):
					if (current_date_dialogue.Wait_For_Progression):
							next_status = current_date_dialogue.Next_Status
							waiting_for_progression = true
					else:
						if (current_date_dialogue.Response_Options != null):
							_display_paul_options()
						else:
							if(current_date_dialogue.Player_Response):
								_progress_paul_response(current_date_dialogue.Next_Status)
							else:
								_progress_date_dialogue(current_date_dialogue.Next_Status)
				else:
					#if queue
					if(current_date_dialogue.Queue_Game):
						if (!current_date_dialogue.Queue_Async):
							pass
						else:
							if(current_date_dialogue.Player_Response):
								_progress_paul_response(current_date_dialogue.Next_Status)
							else:
								_progress_date_dialogue(current_date_dialogue.Next_Status)
							ISSUE._play_game(current_date_dialogue.Queue)
					else:
						if (!current_date_dialogue.Queue_Async):
							pass
						else:
							if(current_date_dialogue.Player_Response):
								_progress_paul_response(current_date_dialogue.Next_Status)
							else:
								_progress_date_dialogue(current_date_dialogue.Next_Status)
							ISSUE._play_anim(current_date_dialogue.Queue)

func _display_paul_dialogue(disp : String, delta):
	if (!setup_paul_display):
			print("[Paul Current Sentence]: " + disp)
			paul_buffer = randf_range(.01,display_buffer)
			paul_split_sentence = disp.split(" ") 
			paul_word_in_sentence = -1
			paul_current_sentence  = " "
			paul_dialogue.text = " "
			setup_paul_display = true
	else:
		if(paul_buffer >= 0):
			paul_buffer -= delta
		else: 
			if (paul_word_in_sentence < paul_split_sentence.size()-1):
				paul_word_in_sentence += 1
				paul_current_sentence += paul_split_sentence[paul_word_in_sentence] + " "
				paul_dialogue.text = paul_current_sentence #update label text
				#play audio
				paul_buffer = randf_range(.01,display_buffer)
			else:
				display_paul_line = false
				setup_paul_display = false
				if (current_paul_dialogue.Queue == null):
					if (current_paul_dialogue.Wait_For_Progression):
							next_status = current_paul_dialogue.Next_Status
							waiting_for_progression = true
					else:
						_progress_date_dialogue(paul_status)
				else:
				#if queue
					if(current_paul_dialogue.Queue_Game):
						if (!current_paul_dialogue.Queue_Async):
							pass
						else:
							if (current_paul_dialogue.Wait_For_Progression):
									next_status = current_paul_dialogue.Next_Status
									waiting_for_progression = true
							else:
								_progress_date_dialogue(paul_status)
							ISSUE._play_game(current_paul_dialogue.Queue)
					else:
						if (!current_paul_dialogue.Queue_Async):
							pass
						else:
							if (current_paul_dialogue.Wait_For_Progression):
									next_status = current_paul_dialogue.Next_Status
									waiting_for_progression = true
							else:
								_progress_date_dialogue(paul_status)
							ISSUE._play_anim(current_paul_dialogue.Queue)

func _progress_date_dialogue(status : String): #used to call and display next dialogue option
	if (!display_date_line):
		for i in date_dialogue_array.size():
			if (date_dialogue_array[i].Status_is_Array):
				for s in date_dialogue_array[i].Status.size():
					if (date_dialogue_array[i].Status[s] == status):
						current_date_dialogue = date_dialogue_array[i]
						display_date_line = true
			else:
				if (date_dialogue_array[i].Status == status):
					current_date_dialogue = date_dialogue_array[i]
					display_date_line = true
	else:
		return

func _display_paul_options():
	print("[Paul Current Options]: ")
	var options = current_date_dialogue.Response_Options
	print(options)
	for o in options.size(): #this response
		var button_instance = response_button_path.instantiate()
		brain.add_child(button_instance)
		button_instance.position = brain_spawn_loc.position
		button_instance.dialogue_manager = self
		button_instance.text = options[o]
		for i in options.size(): #connected responses
			if (button_instance.text != options[i]):
				button_instance.connected_responses.append(options[i])

func _paul_response(response_choice : Button):
	for game_obj in get_tree().get_nodes_in_group("Response"): #assign database
		for i in response_choice.connected_responses.size():
			if(game_obj.text == response_choice.connected_responses[i]):
				print("[Removing: '" + response_choice.connected_responses[i] + "' Option]")
				game_obj.queue_free()
	print("[Executing: '" + response_choice.text + "' Option]")
	_progress_paul_response(response_choice.text)
	response_choice.queue_free()

func _progress_paul_response(status : String):
	if (!display_paul_line):
		paul_status = status
		for i in paul_dialogue_array.size():
			if (paul_dialogue_array[i].Status_is_Array):
				for s in paul_dialogue_array[i].Status.size():
					if (paul_dialogue_array[i].Status[s] == status):
						current_paul_dialogue = paul_dialogue_array[i]
						display_paul_line = true
			else:
				if (paul_dialogue_array[i].Status == status):
					current_paul_dialogue = paul_dialogue_array[i]
					display_paul_line = true
	else:
		return

func _JSON_to_dictionary(data_path:String): #returns true if JSON contains key
	var file = FileAccess.get_file_as_string(data_path)
	var dict = JSON.parse_string(file)
	return dict
