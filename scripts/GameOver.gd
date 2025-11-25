extends Control

@onready var sound = $ButtonClick
@onready var score_label = $GameOverScreen/VBoxContainer/ScoreLabel

func _on_restart_button_pressed() -> void:
	sound.play()
	await get_tree().create_timer(0.9).timeout
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_button_pressed() -> void:
	sound.play()
	await get_tree().create_timer(0.9).timeout
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_exit_button_pressed() -> void:
	sound.play()
	await get_tree().create_timer(0.9).timeout
	get_tree().quit()

func setup(score: int):
	score_label.text = "SCORE: %d" % score


func _on_link_button_pressed() -> void:
	OS.shell_open("forms.gle/uzhTSDLrPn6s38Br6")
