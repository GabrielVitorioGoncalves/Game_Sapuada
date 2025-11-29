extends Control
@onready var sound = $ButtonClick
	
func _on_start_button_pressed() -> void:
	sound.play()
	await get_tree().create_timer(0.7).timeout
	get_tree().change_scene_to_file("res://scenes/fase 1 certo.tscn")

func _on_quit_button_pressed() -> void:
	sound.play()
	await get_tree().create_timer(0.7).timeout
	get_tree().quit()


func _on_link_button_pressed() -> void:
	OS.shell_open("https://docs.google.com/forms/d/e/1FAIpQLSefCag_M9zCzHbcOQ_Wbmj6WBTEMlf91Pm6gZA3-Q7acL8y6w/viewform")
