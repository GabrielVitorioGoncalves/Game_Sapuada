extends Node2D
const PAUSE_MENU = preload("res://scenes/pause_menu.tscn")
const GAME_OVER_SCREEN = preload("res://scenes/game_over_screen.tscn")

@onready var path = $Path2D
@onready var timer = $Timer 
@onready var ui_canvas = $CanvasLayer
@onready var label_equacao = $CanvasLayer/Label
@onready var score_label = $CanvasLayer/ScoreLabel
@onready var lives_label = $CanvasLayer/LivesLabel
@onready var bee_hitted = $BeeHitted
@onready var frog_hitted = $FrogHitted
@onready var frog_gameover = $FrogGameOver
@export var ball_scene: PackedScene
@onready var frog = $Sapo
@onready var _produtos_validos: Array = _gerar_produtos_validos_array()

var bolas = []
var game_over = false
var resultado_atual:int = 0
var difficulty_level: int = 1
var current_bee_speed: float = 300.0
var current_spawn_rate: float = 2.5 
var score: int = 0:
	set(value):
		score = value
		if score_label:
			score_label.text = "Score: %d" % score
		_update_difficulty()
var lives: int = 5: 
	set(value):
		lives = value
		if lives_label:
			lives_label.text = "Vidas: %d" % max(0, lives)
		if lives <= 0 and not game_over:
			_game_over()

func _gerar_produtos_validos_array() -> Array:
	var produtos = {} 
	for a in range(1, 11):
		for b in range(1, 11):
			produtos[a * b] = true
	return produtos.keys() 

func _ready():
	self.score = 0
	self.lives = 5
	randomize()
	timer.timeout.connect(_on_Timer_timeout)
	timer.wait_time = current_spawn_rate
	timer.start()
	resultado_atual = -1
	if $ScoreTimer:
		$ScoreTimer.timeout.connect(_on_score_timer_timeout)
	await get_tree().create_timer(10.0).timeout
	gerar_equacao_baseada_em_bolas()

func _update_difficulty():
	@warning_ignore("integer_division")
	var new_level = 1 + int(score / 80)
	if new_level == difficulty_level:
		return 

	difficulty_level = new_level
	print("NOVO NÍVEL DE DIFICULDADE: ", difficulty_level)
	current_bee_speed = min(300.0 + (difficulty_level * 35.0), 750.0)
	current_spawn_rate = max(2.5 - (difficulty_level * 0.15), 0.6)
	timer.wait_time = current_spawn_rate

func _on_Timer_timeout():
	if not game_over:
		spawn_ball()

func spawn_ball():
	var valor = 0
	if difficulty_level <= 2:
		valor = _produtos_validos.pick_random()
	else:
		var produtos_dificeis = _produtos_validos.filter(func(v): return v > 20)
		if randf() > 0.4 and !produtos_dificeis.is_empty():
			valor = produtos_dificeis.pick_random()
		else:
			valor = _produtos_validos.pick_random()
	var velocidade = current_bee_speed
	var follow = PathFollow2D.new()
	follow.rotates = false
	path.add_child(follow)
	follow.progress = 0
	var ball = ball_scene.instantiate()
	ball.setup(follow, valor, velocidade)
	ball.ball_destroyed.connect(_on_bola_destroyed)
	ball.reached_end.connect(_on_ball_reached_end)
	follow.add_child(ball)
	bolas.append(ball)
	follow.loop = false

func _process(_delta):
	for i in range(bolas.size() - 1, -1, -1):
		if not is_instance_valid(bolas[i]):
			bolas.remove_at(i)
	if resultado_atual != -1 and (resultado_atual == 0 or not valor_existe_em_bolas(resultado_atual)):
		gerar_equacao_baseada_em_bolas()

func gerar_equacao_baseada_em_bolas():
	
	var valores_bolas = get_valores_bolas_em_campo()
	var valores_validos = valores_bolas.filter(func(v): return _produtos_validos.has(v))
	if valores_validos.is_empty():
		var msg = "Aguardando abelhas..."
		if !valores_bolas.is_empty():
			msg = "Aguardando abelhas com contas (1-10)..."
		label_equacao.text = msg
		resultado_atual = 0
		return

	var valor_alvo = 0
	if difficulty_level <= 2:
		valor_alvo = valores_validos.pick_random() # Pega qualquer uma
	else:
		var valores_dificeis = valores_validos.filter(func(v): return v > 20 and v % 10 != 0)
		if randf() > 0.3 and !valores_dificeis.is_empty(): 
			valor_alvo = valores_dificeis.pick_random()
		else:
			valor_alvo = valores_validos.pick_random() 
	resultado_atual = valor_alvo
	var a = 0
	var b = 0
	var fatores_teste = range(2, 11)
	fatores_teste.shuffle()
	fatores_teste.append(1)

	for fator_a in fatores_teste:
		if valor_alvo % fator_a == 0: 
			var fator_b = valor_alvo / fator_a
			if fator_b >= 1 and fator_b <= 10: 
				a = fator_a
				b = fator_b
				break 

	if a > b:
		var temp = a
		a = b
		b = temp
	label_equacao.text = "%d x %d = ?" % [a, b]

func get_valores_bolas_em_campo() -> Array:
	var valores = []
	for ball in bolas:
		if is_instance_valid(ball) and ball is MathBall:
			valores.append(ball.ball_value)
	return valores

func valor_existe_em_bolas(valor: int) -> bool:
	for ball in bolas:
		if is_instance_valid(ball) and ball is MathBall and ball.ball_value == valor:
			return true
	return false

func _on_bola_destroyed(value:int, ball_node: MathBall):
	if value == resultado_atual:
		print("🎉 Acertou! Valor:", value)
		bee_hitted.play()
		ball_node.destroy()
		@warning_ignore("integer_division")
		score += int((value * 2) / 3)
		gerar_equacao_baseada_em_bolas()
	else:
		print("❌ Errou! Valor:", value, "| Esperado:", resultado_atual)
		@warning_ignore("integer_division")
		score -= int((value * 3 / 4))

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		var pause_menu_instance = PAUSE_MENU.instantiate()
		add_child(pause_menu_instance)
		get_tree().paused = true

func _on_score_timer_timeout():
	score += 1

func _on_ball_reached_end():
	if game_over:
		return
	frog_hitted.play()
	frog.morrer()
	self.lives -= 1

func _game_over():
	game_over = true
	get_tree().paused = true 
	frog_gameover.play()
	await await get_tree().create_timer(0.9).timeout
	ui_canvas.hide()
	var game_over_instance = GAME_OVER_SCREEN.instantiate()
	add_child(game_over_instance)
	game_over_instance.setup(score)
