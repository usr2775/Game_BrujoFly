extends Node

#obstáculos de precarga
var stump_scene = preload("res://scenes/stump.tscn")
var smile_scene = preload("res://scenes/smile.tscn")
var barrel_scene = preload("res://scenes/barrel.tscn")
var smile2_scene = preload("res://scenes/smile2.tscn")
var obstacle_types := [stump_scene, smile_scene, barrel_scene]
var obstacles : Array
var smile2_heights := [200, 390]

#variables del juego
const brujo_START_POS := Vector2(350, 485)
const CAM_START_POS := Vector2(676, 324)
var difficulty
const MAX_DIFFICULTY : int = 2
var score : int
const SCORE_MODIFIER : int = 10
var high_score : int
var speed : float
const START_SPEED : float = 10.0
const MAX_SPEED : int = 25
const SPEED_MODIFIER : int = 1000
var screen_size : Vector2i
var ground_height : int
var game_running : bool
var last_obs
var is_jumping : bool

# Se llama cuando el nodo ingresa al árbol de escena por primera vez
func _ready():
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	$GameOver.get_node("Button").pressed.connect(new_game)
	new_game()
	
	
func new_game():
	#restableser las variables
	score = 0
	show_score()
	game_running = false
	get_tree().paused = false
	difficulty = 0
	is_jumping = false
	$Music.play()
	
	#borrar todos los obtaculoss
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()

	#restablecer los nodos
	$Brujo.position = brujo_START_POS
	$Brujo.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i(0, 0)
	
	#restablecer hud y pantalla de juego terminado
	$HUD.get_node("StartLabel").show()
	$GameOver.hide()
	

# Llamó a cada fotograma. 'delta' es el tiempo transcurrido desde el cuadro anterior
func _process(delta):
	if game_running:
		#acelerar y ajustar la dificultad
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		adjust_difficulty()
		#generar obstaculos
		generate_obs()
		
		#move al brujo ya la camara
		$Brujo.position.x += speed
		if is_jumping:
			#Ajusta la velocidad horizontal al salta
			$Brujo.position.x += speed * 0.5 
		$Camera2D.position.x += speed
		
		#actualizar puntuacion
		score += speed
		show_score()
		
		#actualizar la posición del suelo
		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
			$Ground.position.x += screen_size.x
			
		#eliminar obtaculo salido de la pantalla
		for obs in obstacles:
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obs(obs)
	else:
		if Input.is_action_pressed("ui_accept"):
			game_running = true
			$HUD.get_node("StartLabel").hide()

func generate_obs():
	#generar obtaculos en el jugo
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(300, 500):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs
		var max_obs = difficulty + 1
		for i in range(randi() % max_obs + 1):
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x : int = screen_size.x + score + 100 + (i * 100)
			var obs_y : int = screen_size.y - ground_height - (obs_height * obs_scale.y / 2) + 5
			last_obs = obs
			add_obs(obs, obs_x, obs_y)
		#generar smile especiales aleatoriamente
		if difficulty == MAX_DIFFICULTY:
			if (randi() % 2) == 0:
				#generar smiles especiales en el juego
				obs = smile2_scene.instantiate()
				var obs_x : int = screen_size.x + score + 100
				var obs_y : int = smile2_heights[randi() % smile2_heights.size()]
				add_obs(obs, obs_x, obs_y)

#anade nuevos obtaculos
func add_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)

#elimina obtaculos
func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)
	
	#golpe
func hit_obs(body):
	if body.name == "Brujo":
		game_over()
#mustra la puntuacion actual
func show_score():
	$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score / SCORE_MODIFIER)

#checkea la la puntuacion
func check_high_score():
	if score > high_score:
		high_score = score
		$HUD.get_node("HighScoreLabel").text = "HIGH SCORE: " + str(high_score / SCORE_MODIFIER)

#ajusta la dificuldad
func adjust_difficulty():
	difficulty = score / SPEED_MODIFIER
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY
#mustra el menu fin del juego
func game_over():
	check_high_score()
	get_tree().paused = true
	game_running = false
	$GameOver.show()
	$Music.stop()
	
