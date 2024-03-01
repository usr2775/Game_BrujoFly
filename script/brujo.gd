extends CharacterBody2D

const GRAVITY : int = 6500
const JUMP_SPEED : int = -200
const FLY_SPEED : int = -500
var can_fly : bool = false
var jump_sound_played : bool = false

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	
	if is_on_floor():
		if not get_parent().game_running:
			$AnimatedSprite2D.play("idle")
			can_fly = false
		else:
			$CharacterCol.disabled = false
			if Input.is_action_pressed("ui_accept"):
				if not jump_sound_played:  # Solo reproduce el sonido si no se ha reproducido antes
					$JumpSound.play()
					jump_sound_played = true
				velocity.y = JUMP_SPEED
				can_fly = true
			elif Input.is_action_pressed("ui_down"):
				$AnimatedSprite2D.play("duck")
				$RunCol.disabled = true
				can_fly = false
			else:
				$AnimatedSprite2D.play("run")
				can_fly = false
	else:
		if Input.is_action_pressed("ui_accept") and can_fly:
			velocity.y = FLY_SPEED
			if not jump_sound_played:  # Solo reproduce el sonido si no se ha reproducido antes
				$JumpSound.play()
				jump_sound_played = true
			$AnimatedSprite2D.play("fly")
		else:
			$AnimatedSprite2D.play("jump")
		
	move_and_slide()
	
	if is_on_floor():
		jump_sound_played = false  # Restablece el indicador cuando toca el suelo
