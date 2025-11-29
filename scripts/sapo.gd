extends Node2D

@export var linguada_cooldown := 0.6 
@onready var frog_spit  = $FrogSpit
@onready var sprite = $Sprite2D
var esta_inoperante: bool = true
var frog_normal = preload("res://assets/frog/frog.png")
var frog_picado = preload("res://assets/frog/frog_spitted_2.png")
var cd_lingua := true

func _ready() -> void:
	sprite.texture = frog_normal

func _process(delta):
	look_at(get_global_mouse_position())

func linguada():
	if not cd_lingua:
		return  # ainda em cooldown
	# instancia a língua
	const lingua = preload("res://scenes/lingua.tscn")
	frog_spit.play()
	var new_lingua = lingua.instantiate()
	new_lingua.global_position = %boca.global_position
	new_lingua.global_rotation = %boca.global_rotation
	%boca.add_child(new_lingua)

	# inicia cooldown
	cd_lingua = false
	await get_tree().create_timer(linguada_cooldown).timeout
	cd_lingua = true

func _input(event):
	if esta_inoperante:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		linguada()

func morrer():
	sprite.texture = frog_picado
	await get_tree().create_timer(1.0).timeout
	sprite.texture = frog_normal

func _on_stun_timer_timeout() -> void:
	esta_inoperante = false
